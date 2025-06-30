import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Controllers for text fields
  final _projectNameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _numSplicesController = TextEditingController();
  final _numConnectorsController = TextEditingController();
  final _otherLossController = TextEditingController();

  // State variables
  String _fiberType = 'sm';
  String _smStandard = 'G.652.A';
  String _mmStandard = 'OM1';
  int _wavelength = 1310;

  // Read-only values derived from standards
  double _txPower = 0;
  double _rxSensitivity = 0;
  double _fiberLoss = 0;
  double _spliceLoss = 0;
  double _connectorLoss = 0;

  // Results
  String? _resultsText;

  // Data from the web app's JavaScript
  static const Map<String, dynamic> STANDARDS = {
    'sm': {
      'G.652.A': {
        'tx': -3.0,
        'rx': -28.0,
        'loss': {1310: 0.35, 1550: 0.25},
        'maxDistance': 160.0,
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'ref': 'ITU-T G.652.A (2022)',
        'wavelengths': [1310, 1550]
      },
      'G.655': {
        'tx': -2.0,
        'rx': -27.0,
        'loss': {1310: 0.35, 1550: 0.22},
        'maxDistance': 200.0,
        'connectorLoss': 0.4,
        'spliceRange': [0.05, 0.2],
        'ref': 'ITU-T G.655 (2009)',
        'wavelengths': [1310, 1550]
      }
    },
    'mm': {
      'OM1': {
        'tx': 0.0,
        'rx': -16.0,
        'loss': {850: 3.5},
        'maxDistance': 300.0, // in meters
        'connectorLoss': 0.75,
        'spliceRange': [0.3, 0.5],
        'ref': 'TIA-492AAAA',
        'wavelengths': [850]
      },
      'OM3': {
        'tx': 1.0,
        'rx': -20.0,
        'loss': {850: 3.0},
        'maxDistance': 1000.0, // in meters
        'connectorLoss': 0.6,
        'spliceRange': [0.2, 0.4],
        'ref': 'TIA-492AAAC',
        'wavelengths': [850]
      }
    }
  };

  @override
  void initState() {
    super.initState();
    _updateDefaults();
  }

  void _updateDefaults() {
    setState(() {
      final standardKey = _fiberType == 'sm' ? _smStandard : _mmStandard;
      final config = STANDARDS[_fiberType][standardKey];

      final validWavelengths = List<int>.from(config['wavelengths']);
      if (!validWavelengths.contains(_wavelength)) {
        _wavelength = validWavelengths[0];
      }

      _txPower = config['tx'];
      _rxSensitivity = config['rx'];
      _fiberLoss = config['loss'][_wavelength].toDouble();

      final spliceRange = List<double>.from(config['spliceRange']);
      _spliceLoss = (spliceRange[0] + spliceRange[1]) / 2;
      _connectorLoss = config['connectorLoss'];

      // Set default values for controllers
      _distanceController.text = (_fiberType == 'sm' ? '10' : '100');
      _numSplicesController.text = '2';
      _numConnectorsController.text = '2';
      _otherLossController.text = '0';
    });
  }

  void _calculateBudget() {
    final distance = double.tryParse(_distanceController.text) ?? 0;
    final numSplices = int.tryParse(_numSplicesController.text) ?? 0;
    final numConnectors = int.tryParse(_numConnectorsController.text) ?? 0;
    final otherLoss = double.tryParse(_otherLossController.text) ?? 0;

    final effectiveDistance = _fiberType == 'sm' ? distance : distance / 1000;

    final totalLoss =
        (_fiberLoss * effectiveDistance) +
        (_spliceLoss * numSplices) +
        (_connectorLoss * numConnectors) +
        otherLoss;

    final powerBudget = _txPower - _rxSensitivity;
    final availableMargin = powerBudget - totalLoss;

    setState(() {
      _resultsText = '''
Project: ${_projectNameController.text.isNotEmpty ? _projectNameController.text : 'Unnamed Project'}

Total System Loss: ${totalLoss.toStringAsFixed(2)} dB
Power Budget: ${powerBudget.toStringAsFixed(2)} dB
Available Margin: ${availableMargin.toStringAsFixed(2)} dB
''';
      if (availableMargin < 2) {
        _resultsText = (_resultsText ?? '') + '\n⚠️ Low Power Margin! Consider using better components or reducing distance.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final standardKey = _fiberType == 'sm' ? _smStandard : _mmStandard;
    final config = STANDARDS[_fiberType][standardKey];
    final validWavelengths = List<int>.from(config['wavelengths']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Optical Power Budget Calculator'),
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_projectNameController, 'Project Name'),
            _buildDropdown('Fiber Type', _fiberType, ['sm', 'mm'], (val) {
              setState(() {
                _fiberType = val!;
                _updateDefaults();
              });
            }),
            if (_fiberType == 'sm')
              _buildDropdown('SM Standard', _smStandard, STANDARDS['sm'].keys.toList(), (val) {
                setState(() {
                  _smStandard = val!;
                  _updateDefaults();
                });
              }),
            if (_fiberType == 'mm')
              _buildDropdown('MM Standard', _mmStandard, STANDARDS['mm'].keys.toList(), (val) {
                setState(() {
                  _mmStandard = val!;
                  _updateDefaults();
                });
              }),
            _buildDropdown('Wavelength (nm)', _wavelength.toString(), validWavelengths.map((e) => e.toString()).toList(), (val) {
              setState(() {
                _wavelength = int.parse(val!);
                _updateDefaults();
              });
            }),
            _buildReadOnlyField('Transmitter Power (dBm)', _txPower.toStringAsFixed(1)),
            _buildReadOnlyField('Receiver Sensitivity (dBm)', _rxSensitivity.toStringAsFixed(1)),
            _buildReadOnlyField('Fiber Attenuation (dB/km)', _fiberLoss.toStringAsFixed(2)),
            _buildTextField(_distanceController, 'Link Distance (${_fiberType == 'sm' ? 'km' : 'm'})', keyboardType: TextInputType.number),
            _buildReadOnlyField('Splice Loss per Splice (dB)', _spliceLoss.toStringAsFixed(2)),
            _buildTextField(_numSplicesController, 'Number of Splices', keyboardType: TextInputType.number),
            _buildReadOnlyField('Connector Loss per Connection (dB)', _connectorLoss.toStringAsFixed(2)),
            _buildTextField(_numConnectorsController, 'Number of Connectors', keyboardType: TextInputType.number),
            _buildTextField(_otherLossController, 'Other Losses (dB)', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBudget,
              child: const Text('Calculate Budget'),
            ),
            if (_resultsText != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _resultsText!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

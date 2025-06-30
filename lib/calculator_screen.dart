import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for text fields
  final _projectNameController = TextEditingController(text: 'My Project');
  final _distanceController = TextEditingController();
  final _numSplicesController = TextEditingController();
  final _numConnectorsController = TextEditingController();
  final _otherLossController = TextEditingController();

  // State variables
  String _fiberType = 'sm';
  String _smStandard = 'G.652.A';
  String _mmStandard = 'OM1';
  int _wavelength = 1310;

  // Results
  Map<String, dynamic>? _results;

  // Data model for standards
  static const Map<String, dynamic> STANDARDS = {
    'sm': {
      'G.652.A': {
        'tx': -3.0, 'rx': -28.0, 'loss': {1310: 0.35, 1550: 0.25}, 'maxDistance': 160.0, 'connectorLoss': 0.5, 'spliceRange': [0.1, 0.3], 'ref': 'ITU-T G.652.A', 'wavelengths': [1310, 1550]
      },
      'G.652.B': {
        'tx': -3.0, 'rx': -28.0, 'loss': {1310: 0.35, 1550: 0.25}, 'maxDistance': 160.0, 'connectorLoss': 0.5, 'spliceRange': [0.1, 0.3], 'ref': 'ITU-T G.652.B', 'wavelengths': [1310, 1550]
      },
      'G.652.C': {
        'tx': -3.0, 'rx': -28.0, 'loss': {1310: 0.35, 1550: 0.25}, 'maxDistance': 160.0, 'connectorLoss': 0.5, 'spliceRange': [0.1, 0.3], 'ref': 'ITU-T G.652.C', 'wavelengths': [1310, 1550]
      },
      'G.652.D': {
        'tx': -3.0, 'rx': -28.0, 'loss': {1310: 0.35, 1550: 0.22}, 'maxDistance': 180.0, 'connectorLoss': 0.4, 'spliceRange': [0.05, 0.2], 'ref': 'ITU-T G.652.D', 'wavelengths': [1310, 1550]
      },
      'G.655': {
        'tx': -2.0, 'rx': -27.0, 'loss': {1550: 0.22}, 'maxDistance': 200.0, 'connectorLoss': 0.4, 'spliceRange': [0.05, 0.2], 'ref': 'ITU-T G.655', 'wavelengths': [1550]
      },
      'G.656': {
        'tx': -2.0, 'rx': -27.0, 'loss': {1550: 0.22}, 'maxDistance': 220.0, 'connectorLoss': 0.4, 'spliceRange': [0.05, 0.2], 'ref': 'ITU-T G.656', 'wavelengths': [1550]
      },
    },
    'mm': {
      'OM1': {
        'tx': 0.0, 'rx': -16.0, 'loss': {850: 3.5}, 'maxDistance': 300.0, 'connectorLoss': 0.75, 'spliceRange': [0.3, 0.5], 'ref': 'TIA-492AAAA', 'wavelengths': [850]
      },
      'OM2': {
        'tx': 0.0, 'rx': -18.0, 'loss': {850: 3.0}, 'maxDistance': 550.0, 'connectorLoss': 0.7, 'spliceRange': [0.3, 0.5], 'ref': 'TIA-492AAAB', 'wavelengths': [850]
      },
      'OM3': {
        'tx': 1.0, 'rx': -20.0, 'loss': {850: 3.0}, 'maxDistance': 1000.0, 'connectorLoss': 0.6, 'spliceRange': [0.2, 0.4], 'ref': 'TIA-492AAAC', 'wavelengths': [850]
      },
      'OM4': {
        'tx': 2.0, 'rx': -22.0, 'loss': {850: 2.8}, 'maxDistance': 1200.0, 'connectorLoss': 0.5, 'spliceRange': [0.1, 0.3], 'ref': 'TIA-492AAAD', 'wavelengths': [850]
      },
      'OM5': {
        'tx': 2.0, 'rx': -23.0, 'loss': {850: 2.8}, 'maxDistance': 1500.0, 'connectorLoss': 0.5, 'spliceRange': [0.1, 0.3], 'ref': 'TIA-492AAAE', 'wavelengths': [850]
      },
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

      final spliceRange = List<double>.from(config['spliceRange']);
      
      _distanceController.text = (_fiberType == 'sm' ? '10' : '100');
      _numSplicesController.text = '2';
      _numConnectorsController.text = '2';
      _otherLossController.text = '0.5';
      _results = null; // Clear results on parameter change
    });
  }

  void _calculateBudget() {
    if (_formKey.currentState!.validate()) {
      final standardKey = _fiberType == 'sm' ? _smStandard : _mmStandard;
      final config = STANDARDS[_fiberType][standardKey];

      final txPower = config['tx'].toDouble();
      final rxSensitivity = config['rx'].toDouble();
      final fiberLoss = config['loss'][_wavelength].toDouble();
      final spliceRange = List<double>.from(config['spliceRange']);
      final spliceLoss = (spliceRange[0] + spliceRange[1]) / 2;
      final connectorLoss = config['connectorLoss'].toDouble();

      final distance = double.parse(_distanceController.text);
      final numSplices = int.parse(_numSplicesController.text);
      final numConnectors = int.parse(_numConnectorsController.text);
      final otherLoss = double.parse(_otherLossController.text);

      final effectiveDistance = _fiberType == 'sm' ? distance : distance / 1000;

      final totalLoss = (fiberLoss * effectiveDistance) + (spliceLoss * numSplices) + (connectorLoss * numConnectors) + otherLoss;
      final powerBudget = txPower - rxSensitivity;
      final availableMargin = powerBudget - totalLoss;

      setState(() {
        _results = {
          'projectName': _projectNameController.text,
          'totalLoss': totalLoss,
          'powerBudget': powerBudget,
          'availableMargin': availableMargin,
          'ref': config['ref']
        };
      });
    }
  }

  List<String> _getRecommendations() {
    return _fiberType == 'sm'
        ? ['Use lower attenuation fiber (e.g., G.652.D)', 'Implement amplification (EDFA/Raman)', 'Reduce number of splices or use higher quality splices', 'Use clean, high-performance connectors (APC)']
        : ['Upgrade to a higher-grade fiber (e.g., OM4/OM5)', 'Use Vertical-Cavity Surface-Emitting Lasers (VCSELs)', 'Ensure all connectors are properly cleaned and mated', 'Reduce the total link distance if possible'];
  }

  @override
  Widget build(BuildContext context) {
    final standardKey = _fiberType == 'sm' ? _smStandard : _mmStandard;
    final config = STANDARDS[_fiberType][standardKey];
    final validWavelengths = List<int>.from(config['wavelengths']);

    final txPower = config['tx'].toDouble();
    final rxSensitivity = config['rx'].toDouble();
    final fiberLoss = config['loss'][_wavelength].toDouble();
    final spliceRange = List<double>.from(config['spliceRange']);
    final spliceLoss = (spliceRange[0] + spliceRange[1]) / 2;
    final connectorLoss = config['connectorLoss'].toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Optical Power Budget Calculator')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionCard(
              title: 'Project Setup',
              children: [
                _buildTextField(_projectNameController, 'Project Name'),
                _buildDropdown('Fiber Type', _fiberType, {'sm': 'Single-Mode', 'mm': 'Multi-Mode'}.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), (val) {
                  setState(() {
                    _fiberType = val!;
                    _updateDefaults();
                  });
                }),
                if (_fiberType == 'sm')
                  _buildDropdown('SM Standard', _smStandard, STANDARDS['sm'].keys.map<DropdownMenuItem<String>>((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), (val) {
                    setState(() {
                      _smStandard = val!;
                      _updateDefaults();
                    });
                  })
                else
                  _buildDropdown('MM Standard', _mmStandard, STANDARDS['mm'].keys.map<DropdownMenuItem<String>>((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), (val) {
                    setState(() {
                      _mmStandard = val!;
                      _updateDefaults();
                    });
                  }),
                _buildDropdown('Wavelength (nm)', _wavelength.toString(), validWavelengths.map((e) => DropdownMenuItem(value: e.toString(), child: Text(e.toString()))).toList(), (val) {
                  setState(() {
                    _wavelength = int.parse(val!);
                    _results = null;
                  });
                }),
              ],
            ),
            _buildSectionCard(
              title: 'System Parameters',
              children: [
                _buildTextField(_distanceController, 'Link Distance (${_fiberType == 'sm' ? 'km' : 'm'})', keyboardType: TextInputType.number, validator: _validateNumber),
                _buildTextField(_numSplicesController, 'Number of Splices', keyboardType: TextInputType.number, validator: _validateNumber),
                _buildTextField(_numConnectorsController, 'Number of Connectors', keyboardType: TextInputType.number, validator: _validateNumber),
                _buildTextField(_otherLossController, 'Other Losses (dB)', keyboardType: TextInputType.number, validator: _validateNumber),
              ],
            ),
            _buildSectionCard(
              title: 'Standard-Based Values (Read-Only)',
              children: [
                _buildReadOnlyField('Transmitter Power (dBm)', txPower.toStringAsFixed(1)),
                _buildReadOnlyField('Receiver Sensitivity (dBm)', rxSensitivity.toStringAsFixed(1)),
                _buildReadOnlyField('Fiber Attenuation (dB/km)', fiberLoss.toStringAsFixed(2)),
                _buildReadOnlyField('Typical Splice Loss (dB)', spliceLoss.toStringAsFixed(2)),
                _buildReadOnlyField('Typical Connector Loss (dB)', connectorLoss.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _calculateBudget, child: const Text('Calculate Budget')),
            if (_results != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 16), ...children],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), keyboardType: keyboardType, validator: validator),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: Theme.of(context).textTheme.titleMedium), Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), value: value, items: items, onChanged: onChanged),
    );
  }

  Widget _buildResultsSection() {
    final margin = _results!['availableMargin'] as double;
    final marginColor = margin >= 3 ? Colors.green.shade600 : (margin >= 0 ? Colors.orange.shade700 : Colors.red.shade700);
    final recommendations = _getRecommendations();

    return _buildSectionCard(
      title: 'Calculation Results',
      children: [
        _buildReadOnlyField('Project', _results!['projectName']),
        _buildReadOnlyField('Total System Loss', '${(_results!['totalLoss'] as double).toStringAsFixed(2)} dB'),
        _buildReadOnlyField('System Power Budget', '${(_results!['powerBudget'] as double).toStringAsFixed(2)} dB'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Available Power Margin', style: Theme.of(context).textTheme.titleMedium),
            Text('${margin.toStringAsFixed(2)} dB', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: marginColor)),
          ]),
        ),
        const Divider(height: 32),
        if (margin < 3)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Recommendations', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), ...recommendations.map((r) => Text('• $r', style: Theme.of(context).textTheme.bodyMedium))], 
          ),
        Text('Reference: ${_results!['ref']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'This field cannot be empty.';
    if (double.tryParse(value) == null) return 'Please enter a valid number.';
    return null;
  }
}

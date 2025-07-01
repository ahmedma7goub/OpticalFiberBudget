import 'package:flutter/material.dart';

class LinkLossCalculatorScreen extends StatefulWidget {
  const LinkLossCalculatorScreen({super.key});

  @override
  _LinkLossCalculatorScreenState createState() => _LinkLossCalculatorScreenState();
}

class _LinkLossCalculatorScreenState extends State<LinkLossCalculatorScreen> {
  // Input Controllers
  final _distanceController = TextEditingController();
  final _numSplicesController = TextEditingController();
  final _numConnectorsController = TextEditingController();
  final _otherLossController = TextEditingController();

  // Editable parameter controllers
  final _fiberLossController = TextEditingController();
  final _spliceLossController = TextEditingController();
  final _connectorLossController = TextEditingController();

  // State variables
  String _fiberType = 'sm';
  String _smStandard = 'G.652.A';
  String _mmStandard = 'OM1';
  int _wavelength = 1310;

  // Results
  double? _totalLoss;

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

      _fiberLossController.text = config['loss'][_wavelength].toDouble().toStringAsFixed(2);

      final spliceRange = List<double>.from(config['spliceRange']);
      _spliceLossController.text = ((spliceRange[0] + spliceRange[1]) / 2).toStringAsFixed(2);
      _connectorLossController.text = config['connectorLoss'].toStringAsFixed(2);

      _distanceController.text = (_fiberType == 'sm' ? '10' : '100');
      _numSplicesController.text = '2';
      _numConnectorsController.text = '2';
      _otherLossController.text = '0';
      
      _calculateLoss(fromButton: false);
    });
  }

  void _calculateLoss({bool fromButton = true}) {
    final fiberLoss = double.tryParse(_fiberLossController.text) ?? 0;
    final spliceLoss = double.tryParse(_spliceLossController.text) ?? 0;
    final connectorLoss = double.tryParse(_connectorLossController.text) ?? 0;

    final distance = double.tryParse(_distanceController.text) ?? 0;
    final numSplices = int.tryParse(_numSplicesController.text) ?? 0;
    final numConnectors = int.tryParse(_numConnectorsController.text) ?? 0;
    final otherLoss = double.tryParse(_otherLossController.text) ?? 0;

    final effectiveDistance = _fiberType == 'sm' ? distance : distance / 1000;

    final totalLoss =
        (fiberLoss * effectiveDistance) +
        (spliceLoss * numSplices) +
        (connectorLoss * numConnectors) +
        otherLoss;

    if (fromButton) {
      setState(() {
        _totalLoss = totalLoss;
      });
    } else {
      _totalLoss = totalLoss;
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: const TabBar(
              tabs: [
                Tab(text: 'About'),
                Tab(text: 'Calculation Details'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 320,
              child: TabBarView(
                children: [
                  const SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Developed by:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Ahmed Mahgoub'),
                        Text('+201157750025'),
                        Text('info@tbteck.com'),
                        Text('Cairo, Egypt'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fiber Standards', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text(
                          'The app uses typical values from ITU-T and TIA standards. These are pre-filled when you select a standard but are fully editable.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text('Core Equation', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        const Text('Total System Loss (dB):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('(Attenuation × Distance) + (Splice Loss × Splices) + (Connector Loss × Connectors) + Other Losses', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final standardKey = _fiberType == 'sm' ? _smStandard : _mmStandard;
    final config = STANDARDS[_fiberType][standardKey];
    final validWavelengths = List<int>.from(config['wavelengths']);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Power Loss'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCategoryHeader('Fiber Configuration'),
            _buildFiberTypeSelector(),
            if (_fiberType == 'sm') _buildStandardSelector('sm')
            else _buildStandardSelector('mm'),
            _buildWavelengthSelector(validWavelengths),
            
            _buildCategoryHeader('Link Parameters'),
            _buildTextField(_distanceController, 'Distance (km for SM, m for MM)'),
            _buildTextField(_numSplicesController, 'Number of Splices'),
            _buildTextField(_numConnectorsController, 'Number of Connectors'),
            _buildTextField(_otherLossController, 'Other Losses (dB)'),
            
            _buildCategoryHeader('Loss Parameters (Editable)'),
            _buildTextField(_fiberLossController, 'Fiber Loss (dB/km)'),
            _buildTextField(_spliceLossController, 'Splice Loss per Splice (dB)'),
            _buildTextField(_connectorLossController, 'Connector Loss per Connector (dB)'),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _calculateLoss(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Calculate Total Loss'),
            ),
            
            if (_totalLoss != null) ...[
              const SizedBox(height: 20),
              _buildCategoryHeader('Calculation Results'),
              _buildResultCard('Total System Loss', '${_totalLoss!.toStringAsFixed(2)} dB', isDarkMode),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFiberTypeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'sm', label: Text('Single-Mode')),
        ButtonSegment(value: 'mm', label: Text('Multi-Mode')),
      ],
      selected: {_fiberType},
      onSelectionChanged: (newSelection) {
        setState(() {
          _fiberType = newSelection.first;
          _smStandard = 'G.652.A';
          _mmStandard = 'OM1';
          _updateDefaults();
        });
      },
    );
  }

  Widget _buildStandardSelector(String type) {
    final standards = STANDARDS[type].keys.toList();
    String currentStandard = type == 'sm' ? _smStandard : _mmStandard;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: currentStandard,
        decoration: const InputDecoration(
          labelText: 'Fiber Standard',
          border: OutlineInputBorder(),
        ),
        items: standards.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            if (type == 'sm') {
              _smStandard = newValue!;
            } else {
              _mmStandard = newValue!;
            }
            _updateDefaults();
          });
        },
      ),
    );
  }

  Widget _buildWavelengthSelector(List<int> wavelengths) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: _wavelength,
        decoration: const InputDecoration(
          labelText: 'Wavelength (nm)',
          border: OutlineInputBorder(),
        ),
        items: wavelengths.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _wavelength = newValue!;
            _updateDefaults();
          });
        },
      ),
    );
  }
  
  Widget _buildResultCard(String title, String value, bool isDarkMode) {
    Color cardColor = isDarkMode ? Colors.green[800]! : Colors.green[100]!;
    Color textColor = isDarkMode ? Colors.green[100]! : Colors.green[900]!;
    
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: textColor, fontSize: 16)),
            Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

const Map<String, dynamic> STANDARDS = {
    'sm': {
      'G.652.A': {
        'loss': {1310: 0.35, 1550: 0.25},
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'wavelengths': [1310, 1550]
      },
      'G.655': {
        'loss': {1310: 0.35, 1550: 0.22},
        'connectorLoss': 0.4,
        'spliceRange': [0.05, 0.2],
        'wavelengths': [1310, 1550]
      },
      'G.652.B': {
        'loss': {1310: 0.35, 1550: 0.25},
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'wavelengths': [1310, 1550]
      },
      'G.652.C': {
        'loss': {1310: 0.35, 1550: 0.22},
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'wavelengths': [1310, 1550]
      },
      'G.652.D': {
        'loss': {1310: 0.33, 1550: 0.19},
        'connectorLoss': 0.4,
        'spliceRange': [0.05, 0.2],
        'wavelengths': [1310, 1550]
      },
      'G.656': {
        'loss': {1310: 0.35, 1550: 0.23},
        'connectorLoss': 0.4,
        'spliceRange': [0.05, 0.2],
        'wavelengths': [1310, 1550]
      }
    },
    'mm': {
      'OM1': {
        'loss': {850: 3.5, 1300: 1.5},
        'connectorLoss': 0.75,
        'spliceRange': [0.3, 0.5],
        'wavelengths': [850, 1300]
      },
      'OM2': {
        'loss': {850: 3.0, 1300: 1.0},
        'connectorLoss': 0.7,
        'spliceRange': [0.2, 0.4],
        'wavelengths': [850, 1300]
      },
      'OM3': {
        'loss': {850: 2.5, 1300: 0.8},
        'connectorLoss': 0.6,
        'spliceRange': [0.1, 0.3],
        'wavelengths': [850, 1300]
      },
      'OM4': {
        'loss': {850: 2.3, 1300: 0.7},
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'wavelengths': [850, 1300]
      },
      'OM5': {
        'loss': {850: 2.3, 953: 1.9},
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'wavelengths': [850, 953]
      }
    }
  };

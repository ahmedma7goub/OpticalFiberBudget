import 'package:flutter/material.dart';
import 'package:optical_power_budget/models/project.dart';
import 'package:optical_power_budget/screens/projects_screen.dart';
import 'package:optical_power_budget/services/storage_service.dart';

class CalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const CalculatorScreen({super.key, required this.onToggleTheme});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final StorageService _storageService = StorageService();
  // Input Controllers
  final _projectNameController = TextEditingController(text: 'Unnamed Project');
  final _distanceController = TextEditingController();
  final _numSplicesController = TextEditingController();
  final _numConnectorsController = TextEditingController();
  final _otherLossController = TextEditingController();

  // Editable parameter controllers
  final _txPowerController = TextEditingController();
  final _rxSensitivityController = TextEditingController();
  final _fiberLossController = TextEditingController();
  final _spliceLossController = TextEditingController();
  final _connectorLossController = TextEditingController();

  // State variables
  String _fiberType = 'sm';
  String _smStandard = 'G.652.A';
  String _mmStandard = 'OM1';
  int _wavelength = 1310;

  // Results
  String? _resultsText;

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
      },
      'G.652.B': {
        'tx': -3.0,
        'rx': -28.0,
        'loss': {1310: 0.35, 1550: 0.25},
        'maxDistance': 160.0,
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'ref': 'ITU-T G.652.B',
        'wavelengths': [1310, 1550]
      },
      'G.652.C': {
        'tx': -3.0,
        'rx': -28.0,
        'loss': {1310: 0.35, 1550: 0.22},
        'maxDistance': 160.0,
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'ref': 'ITU-T G.652.C (LWP)',
        'wavelengths': [1310, 1550]
      },
      'G.652.D': {
        'tx': -2.0,
        'rx': -29.0,
        'loss': {1310: 0.33, 1550: 0.19},
        'maxDistance': 180.0,
        'connectorLoss': 0.4,
        'spliceRange': [0.05, 0.2],
        'ref': 'ITU-T G.652.D (LWP + PMD)',
        'wavelengths': [1310, 1550]
      },
      'G.656': {
        'tx': -1.0,
        'rx': -26.0,
        'loss': {1310: 0.35, 1550: 0.23},
        'maxDistance': 200.0,
        'connectorLoss': 0.4,
        'spliceRange': [0.05, 0.2],
        'ref': 'ITU-T G.656 (Wideband NZDSF)',
        'wavelengths': [1310, 1550]
      }
    },
    'mm': {
      'OM1': {
        'tx': 0.0,
        'rx': -16.0,
        'loss': {850: 3.5, 1300: 1.5},
        'maxDistance': 300.0,
        'connectorLoss': 0.75,
        'spliceRange': [0.3, 0.5],
        'ref': 'TIA-492AAAA',
        'wavelengths': [850]
      },
      'OM2': {
        'tx': -1.0,
        'rx': -18.0,
        'loss': {850: 3.0, 1300: 1.0},
        'maxDistance': 550.0,
        'connectorLoss': 0.7,
        'spliceRange': [0.2, 0.4],
        'ref': 'TIA-492AAAB',
        'wavelengths': [850]
      },
      'OM3': {
        'tx': 1.0,
        'rx': -20.0,
        'loss': {850: 2.5, 1300: 0.8},
        'maxDistance': 1000.0,
        'connectorLoss': 0.6,
        'spliceRange': [0.1, 0.3],
        'ref': 'TIA-492AAAC',
        'wavelengths': [850]
      },
      'OM4': {
        'tx': 1.0,
        'rx': -22.0,
        'loss': {850: 2.3, 1300: 0.7},
        'maxDistance': 1200.0,
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'ref': 'TIA-492AAAD',
        'wavelengths': [850]
      },
      'OM5': {
        'tx': 1.0,
        'rx': -22.0,
        'loss': {850: 2.3, 953: 1.9},
        'maxDistance': 1500.0,
        'connectorLoss': 0.5,
        'spliceRange': [0.1, 0.3],
        'ref': 'TIA-492AAAE',
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

      _txPowerController.text = config['tx'].toStringAsFixed(1);
      _rxSensitivityController.text = config['rx'].toStringAsFixed(1);
      _fiberLossController.text = config['loss'][_wavelength].toDouble().toStringAsFixed(2);

      final spliceRange = List<double>.from(config['spliceRange']);
      _spliceLossController.text = ((spliceRange[0] + spliceRange[1]) / 2).toStringAsFixed(2);
      _connectorLossController.text = config['connectorLoss'].toStringAsFixed(2);

      _distanceController.text = (_fiberType == 'sm' ? '10' : '100');
      _numSplicesController.text = '2';
      _numConnectorsController.text = '2';
      _otherLossController.text = '0';
    });
  }

  void _calculateBudget() {
    final txPower = double.tryParse(_txPowerController.text) ?? 0;
    final rxSensitivity = double.tryParse(_rxSensitivityController.text) ?? 0;
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

    final powerBudget = txPower - rxSensitivity;
    final availableMargin = powerBudget - totalLoss;

    setState(() {
      _resultsText = '''
Project: ${_projectNameController.text.isNotEmpty ? _projectNameController.text : 'Unnamed Project'}

Total System Loss: ${totalLoss.toStringAsFixed(2)} dB
Power Budget: ${powerBudget.toStringAsFixed(2)} dB
Available Margin: ${availableMargin.toStringAsFixed(2)} dB
''';
      if (availableMargin < 3) {
        _resultsText = (_resultsText ?? '') + '\n⚠️ Low Power Margin! Consider using better components or reducing distance.';
      }
    });
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
              height: 320, // Adjusted height for content
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
                        Text(
                          'Fiber Standards',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The app uses typical values from ITU-T and TIA standards. These are pre-filled when you select a standard but are fully editable to match your project\'s specific requirements.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Core Equations',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text('1. Total System Loss (dB):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('(Attenuation × Distance) + (Splice Loss × Splices) + (Connector Loss × Connectors) + Other Losses', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                        const SizedBox(height: 12),
                        const Text('2. Power Budget (dB):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('Transmitter Power - Receiver Sensitivity', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                        const SizedBox(height: 12),
                        const Text('3. Available Margin (dB):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('Power Budget - Total System Loss', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
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

  void _saveProject() {
    final projectName = _projectNameController.text;
    if (projectName.isEmpty || projectName == 'Unnamed Project') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid project name before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final project = Project(
      name: projectName,
      fiberType: _fiberType,
      smStandard: _smStandard,
      mmStandard: _mmStandard,
      wavelength: _wavelength,
      txPower: _txPowerController.text,
      rxSensitivity: _rxSensitivityController.text,
      fiberLoss: _fiberLossController.text,
      spliceLoss: _spliceLossController.text,
      connectorLoss: _connectorLossController.text,
      distance: _distanceController.text,
      numSplices: _numSplicesController.text,
      numConnectors: _numConnectorsController.text,
      otherLoss: _otherLossController.text,
    );

    _storageService.saveProject(project);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project "$projectName" saved successfully!')),
    );
  }

  void _loadProject() async {
    final selectedProject = await Navigator.of(context).push<Project>(
      MaterialPageRoute(builder: (context) => const ProjectsScreen()),
    );

    if (selectedProject != null) {
      setState(() {
        _projectNameController.text = selectedProject.name;
        _fiberType = selectedProject.fiberType;
        _smStandard = selectedProject.smStandard;
        _mmStandard = selectedProject.mmStandard;
        _wavelength = selectedProject.wavelength;
        _txPowerController.text = selectedProject.txPower;
        _rxSensitivityController.text = selectedProject.rxSensitivity;
        _fiberLossController.text = selectedProject.fiberLoss;
        _spliceLossController.text = selectedProject.spliceLoss;
        _connectorLossController.text = selectedProject.connectorLoss;
        _distanceController.text = selectedProject.distance;
        _numSplicesController.text = selectedProject.numSplices;
        _numConnectorsController.text = selectedProject.numConnectors;
        _otherLossController.text = selectedProject.otherLoss;
        _calculateBudget(); // Recalculate with loaded values
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardKey = _fiberType == 'sm' ? _smStandard : _mmStandard;
    final config = STANDARDS[_fiberType][standardKey];
    final validWavelengths = List<int>.from(config['wavelengths']);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Optical Power Budget'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'save') {
                _saveProject();
              } else if (value == 'load') {
                _loadProject();
              } else if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.save_alt_outlined),
                  title: Text('Save Project'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'load',
                child: ListTile(
                  leading: Icon(Icons.folder_open_outlined),
                  title: Text('Load Project'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Project Details'),
            _buildTextField(_projectNameController, 'Project Name'),
            const SizedBox(height: 16),
            _buildSectionHeader('Fiber Configuration'),
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
            const SizedBox(height: 16),
            _buildSectionHeader('System Parameters (Editable)'),
            _buildTextField(_txPowerController, 'Transmitter Power (dBm)', keyboardType: TextInputType.number),
            _buildTextField(_rxSensitivityController, 'Receiver Sensitivity (dBm)', keyboardType: TextInputType.number),
            _buildTextField(_fiberLossController, 'Fiber Attenuation (dB/km)', keyboardType: TextInputType.number),
            _buildTextField(_spliceLossController, 'Splice Loss per Splice (dB)', keyboardType: TextInputType.number),
            _buildTextField(_connectorLossController, 'Connector Loss per Connection (dB)', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildSectionHeader('Link Details'),
            _buildTextField(_distanceController, 'Link Distance (${_fiberType == 'sm' ? 'km' : 'm'})', keyboardType: TextInputType.number),
            _buildTextField(_numSplicesController, 'Number of Splices', keyboardType: TextInputType.number),
            _buildTextField(_numConnectorsController, 'Number of Connectors', keyboardType: TextInputType.number),
            _buildTextField(_otherLossController, 'Other Losses (dB)', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
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
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    _resultsText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
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

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class LinkLossCalculatorScreen extends StatefulWidget {
  const LinkLossCalculatorScreen({super.key});

  @override
  State<LinkLossCalculatorScreen> createState() => _LinkLossCalculatorScreenState();
}

class _LinkLossCalculatorScreenState extends State<LinkLossCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fiberLengthController = TextEditingController(text: '10');
  final _fiberLossController = TextEditingController(text: '0.25');
  final _spliceLossController = TextEditingController(text: '0.1');
  final _spliceCountController = TextEditingController(text: '2');
  final _connectorLossController = TextEditingController(text: '0.5');
  final _connectorCountController = TextEditingController(text: '2');
  final _maintenanceMarginController = TextEditingController(text: '3.0');

  double _totalLoss = 0.0;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to trigger recalculation on change
    _fiberLengthController.addListener(_calculateTotalLoss);
    _fiberLossController.addListener(_calculateTotalLoss);
    _spliceLossController.addListener(_calculateTotalLoss);
    _spliceCountController.addListener(_calculateTotalLoss);
    _connectorLossController.addListener(_calculateTotalLoss);
    _connectorCountController.addListener(_calculateTotalLoss);
    _maintenanceMarginController.addListener(_calculateTotalLoss);

    // Perform the initial calculation after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTotalLoss());
  }

  @override
  void dispose() {
    _fiberLengthController.dispose();
    _fiberLossController.dispose();
    _spliceLossController.dispose();
    _spliceCountController.dispose();
    _connectorLossController.dispose();
    _connectorCountController.dispose();
    _maintenanceMarginController.dispose();
    super.dispose();
  }

  void _calculateTotalLoss() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _totalLoss = 0.0;
      });
      return;
    }

    final fiberLength = double.tryParse(_fiberLengthController.text) ?? 0;
    final fiberLoss = double.tryParse(_fiberLossController.text) ?? 0;
    final spliceLoss = double.tryParse(_spliceLossController.text) ?? 0;
    final spliceCount = int.tryParse(_spliceCountController.text) ?? 0;
    final connectorLoss = double.tryParse(_connectorLossController.text) ?? 0;
    final connectorCount = int.tryParse(_connectorCountController.text) ?? 0;
    final maintenanceMargin = double.tryParse(_maintenanceMarginController.text) ?? 0;

    final totalFiberLoss = fiberLength * fiberLoss;
    final totalSpliceLoss = spliceLoss * spliceCount;
    final totalConnectorLoss = connectorLoss * connectorCount;

    final totalLoss = totalFiberLoss + totalSpliceLoss + totalConnectorLoss + maintenanceMargin;

    setState(() {
      _totalLoss = totalLoss;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Power Loss'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryHeader('Link Parameters'),
              _buildTextField(_fiberLengthController, 'Fiber Length (km)'),
              _buildTextField(_fiberLossController, 'Fiber Loss (dB/km)'),
              _buildTextField(_spliceLossController, 'Splice Loss (dB)'),
              _buildTextField(_spliceCountController, 'Number of Splices', isInt: true),
              _buildTextField(_connectorLossController, 'Connector Loss (dB)'),
              _buildTextField(_connectorCountController, 'Number of Connectors', isInt: true),
              _buildTextField(_maintenanceMarginController, 'Maintenance Margin (dB)'),
              const SizedBox(height: 24),
              _buildCategoryHeader('Calculation Results'),
              _buildResultCard('Total Link Loss', '${_totalLoss.toStringAsFixed(2)} dB'),
            ],
          ),
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          if (isInt && int.tryParse(value) == null) {
            return 'Please enter a whole number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResultCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

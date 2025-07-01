import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optical_power_budget/calculator_screen.dart';
import 'package:optical_power_budget/screens/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiber/Telcom Assistant'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildToolCard(
              context,
              title: 'Power Budget Calc',
              icon: Icons.calculate_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CalculatorScreen()),
              ),
            ),
            _buildToolCard(
              context,
              title: 'Link Power Loss',
              icon: Icons.show_chart_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LinkLossCalculatorScreen()),
              ),
            ),
            _buildToolCard(
              context,
              title: 'Fiber Test Report',
              icon: Icons.description_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Fiber Test Report')),
              ),
            ),
            _buildToolCard(
              context,
              title: 'Substations Data',
              icon: Icons.apartment_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Substations Data')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

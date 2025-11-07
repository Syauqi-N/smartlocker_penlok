import 'package:flutter/material.dart';
import 'package:smartlocker/screens/owner/owner_dashboard_screen.dart';
import 'package:smartlocker/screens/owner/package_receiver_screen.dart';
import 'package:smartlocker/utils/app_colors.dart';

class OwnerRoleSelectionScreen extends StatelessWidget {
  const OwnerRoleSelectionScreen({super.key});

  void _navigateToSeller(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
    );
  }

  void _navigateToReceiver(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PackageReceiverScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Owner Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Owner!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select your role',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            _buildRoleCard(
              context: context,
              title: 'Seller',
              description:
                  'Manage your e-commerce business, products, and sales',
              icon: Icons.store,
              onTap: () => _navigateToSeller(context),
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            _buildRoleCard(
              context: context,
              title: 'Package Receiver',
              description:
                  'Manage package center, incoming packages, and pickups',
              icon: Icons.inventory,
              onTap: () => _navigateToReceiver(context),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

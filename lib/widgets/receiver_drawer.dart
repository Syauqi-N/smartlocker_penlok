import 'package:flutter/material.dart';
import 'package:smartlocker/screens/auth/landing_screen.dart';
import 'package:smartlocker/screens/owner/package_center_screen.dart';
import 'package:smartlocker/screens/owner/package_receiver_screen.dart';
import 'package:smartlocker/screens/owner/package_notifications_screen.dart';
import 'package:smartlocker/screens/owner/package_history_screen.dart';
import 'package:smartlocker/screens/owner/receiver_dashboard_screen.dart';
import 'package:smartlocker/utils/app_colors.dart';

class ReceiverDrawer extends StatelessWidget {
  const ReceiverDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Text(
              'Receiver Menu',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.lock_open,
            text: 'Package Receiver',
            onTap: () => _navigateTo(context, const PackageReceiverScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            onTap: () => _navigateTo(context, const ReceiverDashboardScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            text: 'Package Center',
            onTap: () => _navigateTo(context, const PackageCenterScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: 'Delivery Notifications',
            onTap: () =>
                _navigateTo(context, const PackageNotificationsScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.history,
            text: 'Package History',
            onTap: () => _navigateTo(context, const PackageHistoryScreen()),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

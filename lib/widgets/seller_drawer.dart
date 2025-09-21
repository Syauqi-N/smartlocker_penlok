import 'package:flutter/material.dart';
import 'package:smartlocker/screens/auth/landing_screen.dart';
import 'package:smartlocker/screens/owner/owner_dashboard_screen.dart';
import 'package:smartlocker/screens/owner/owner_notifications_screen.dart';
import 'package:smartlocker/screens/owner/payment_verification_main_screen.dart';
import 'package:smartlocker/screens/owner/product_management_screen.dart';
import 'package:smartlocker/screens/owner/sales_history_screen.dart';
import 'package:smartlocker/utils/app_colors.dart';

class SellerDrawer extends StatelessWidget {
  const SellerDrawer({super.key});

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
              'Seller Menu',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            onTap: () => _navigateTo(context, const OwnerDashboardScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2,
            text: 'Product Management',
            onTap: () => _navigateTo(context, const ProductManagementScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.verified_user,
            text: 'Payment Verification',
            onTap: () => _navigateTo(context, const PaymentVerificationMainScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.history,
            text: 'Sales History',
            onTap: () => _navigateTo(context, const SalesHistoryScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: 'Order Notifications',
            onTap: () => _navigateTo(context, const OwnerNotificationsScreen()),
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

  Widget _buildDrawerItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
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
import 'package:flutter/material.dart';
import 'package:smartlocker/screens/auth/landing_screen.dart';
import 'package:smartlocker/screens/buyer/buyer_dashboard_screen.dart';
import 'package:smartlocker/screens/buyer/buyer_notifications_screen.dart';
import 'package:smartlocker/screens/buyer/buyer_otp_list_screen.dart';
import 'package:smartlocker/screens/buyer/cart_screen.dart';
import 'package:smartlocker/screens/profile/account_center_screen.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/services/auth_service.dart';

class BuyerDrawer extends StatelessWidget {
  const BuyerDrawer({super.key});

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
              'Buyer Menu',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.store,
            text: 'Dashboard',
            onTap: () => _navigateTo(context, const BuyerDashboardScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            text: 'My Cart',
            onTap: () => _navigateTo(context, const CartScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: 'Notifications',
            onTap: () => _navigateTo(context, const BuyerNotificationsScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.lock,
            text: 'My OTPs',
            onTap: () => _navigateTo(context, const BuyerOtpListScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: 'Account Center',
            onTap: () => _navigateTo(
              context,
              AccountCenterScreen(drawer: const BuyerDrawer()),
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () {
              AuthService.instance.logout();
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

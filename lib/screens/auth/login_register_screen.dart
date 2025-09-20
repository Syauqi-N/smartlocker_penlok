import 'package:flutter/material.dart';
import 'package:smartlocker/screens/buyer/buyer_dashboard_screen.dart';
import 'package:smartlocker/screens/owner/owner_dashboard_screen.dart';
import 'package:smartlocker/screens/auth/otp_screen.dart'; // <-- PERBAIKAN: IMPORT DITAMBAHKAN
import 'package:smartlocker/utils/app_colors.dart';

enum UserType { owner, buyer }

class LoginRegisterScreen extends StatelessWidget {
  final UserType userType;
  const LoginRegisterScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: const BackButton(color: AppColors.black),
          bottom: const TabBar(
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'LOGIN'),
              Tab(text: 'REGISTER'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLoginForm(context),
            _buildRegisterForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            _buildTextField(label: 'Email'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Password', obscureText: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => userType == UserType.owner
                        ? const OwnerDashboardScreen()
                        : const BuyerDashboardScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('LOGIN', style: TextStyle(color: AppColors.black, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildTextField(label: 'Email'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Password', obscureText: true),
            const SizedBox(height: 16),
            _buildTextField(label: 'Confirm Password', obscureText: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpScreen(userType: userType),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('REGISTER', style: TextStyle(color: AppColors.black, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, bool obscureText = false}) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
      ),
    );
  }
}

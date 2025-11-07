import 'package:flutter/material.dart';
import 'package:smartlocker/screens/auth/login_register_screen.dart';
import 'package:smartlocker/screens/buyer/buyer_dashboard_screen.dart';
import 'package:smartlocker/screens/owner/owner_dashboard_screen.dart';
import 'package:smartlocker/utils/app_colors.dart';

class OtpScreen extends StatelessWidget {
  final UserType userType;
  const OtpScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the OTP sent to your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const TextField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 12),
                decoration: InputDecoration(
                  hintText: '_ _ _ _ _ _',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 30),
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
                ),
                child: const Text('VERIFY',
                    style: TextStyle(color: AppColors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

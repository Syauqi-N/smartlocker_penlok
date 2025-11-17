import 'package:flutter/material.dart';
import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/transaction.dart';
import 'package:smartlocker/services/api_client.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/app_logo.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class OtpInputScreen extends StatefulWidget {
  final TransactionModel transaction;

  const OtpInputScreen({super.key, required this.transaction});

  @override
  State<OtpInputScreen> createState() => _OtpInputScreenState();
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  final _otpController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      await _apiClient.post(
        ApiRoutes.lockersValidateOtp,
        body: {'otp': _otpController.text},
      );
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('OTP validated. Locker should be opening!')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            AppTextLogo(height: 28),
            SizedBox(width: 8),
            Text('Enter OTP'),
          ],
        ),
      ),
      drawer: const BuyerDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Package Pickup',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Product: ${widget.transaction.product?.name ?? 'Unknown product'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter the 6-digit OTP provided by the seller:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

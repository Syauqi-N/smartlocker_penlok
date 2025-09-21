import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class OtpInputScreen extends StatefulWidget {
  final Purchase purchase;

  const OtpInputScreen({super.key, required this.purchase});

  @override
  State<OtpInputScreen> createState() => _OtpInputScreenState();
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  final _otpController = TextEditingController();
  final PurchaseService _purchaseService = PurchaseService();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    setState(() {
      _isVerifying = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        if (_otpController.text == widget.purchase.otp) {
          // Update purchase status to completed
          final index = _purchaseService.getPurchases().indexWhere((p) => p.id == widget.purchase.id);
          if (index != -1) {
            _purchaseService.getPurchases()[index].status = PurchaseStatus.completed;
            // Notify seller that package has been picked up
            _purchaseService.markPurchaseAsCompleted(widget.purchase.id);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package picked up successfully!')),
          );

          // In a real app, you would notify the seller here
          // For now, we'll just show a message
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Package picked up successfully! The seller has been notified.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (mounted) {
                          Navigator.of(context).pop(true); // Return true to indicate success
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid OTP. Please try again.')),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
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
              'Product: ${widget.purchase.productName}',
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
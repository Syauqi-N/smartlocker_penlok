import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

class PaymentDetailScreen extends StatelessWidget {
  final Purchase purchase;
  final PurchaseService _purchaseService = PurchaseService();

  PaymentDetailScreen({super.key, required this.purchase});

  void _approveAndGenerateOtp(BuildContext context) {
    _purchaseService.verifyPaymentAndGenerateOtp(purchase.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment approved and OTP generated!')),
    );
    Navigator.pop(context);
  }

  void _rejectPayment(BuildContext context) {
    _purchaseService.rejectPayment(purchase.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment rejected.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${purchase.productName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Buyer: ${purchase.buyerName}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Price: IDR ${purchase.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text('Payment Proof:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Image.asset(purchase.paymentProofImageUrl), // Display the proof
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _rejectPayment(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('REJECT', style: TextStyle(color: AppColors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _approveAndGenerateOtp(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('APPROVE & GENERATE OTP', style: TextStyle(color: AppColors.black)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
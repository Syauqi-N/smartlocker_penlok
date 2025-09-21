import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class BuyerOtpListScreen extends StatefulWidget {
  const BuyerOtpListScreen({super.key});

  @override
  State<BuyerOtpListScreen> createState() => _BuyerOtpListScreenState();
}

class _BuyerOtpListScreenState extends State<BuyerOtpListScreen> {
  final PurchaseService _purchaseService = PurchaseService();

  @override
  Widget build(BuildContext context) {
    // Get all purchases that have OTP generated (verified ready for pickup)
    final otpPurchases = _purchaseService.getPurchases()
        .where((p) => p.status == PurchaseStatus.verifiedReadyForPickup && p.otp != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My OTPs'),
      ),
      drawer: const BuyerDrawer(),
      body: otpPurchases.isEmpty
          ? const Center(
              child: Text(
                'You have no OTPs available.\nWait for seller to generate OTP for your purchases.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.grey),
              ),
            )
          : ListView.builder(
              itemCount: otpPurchases.length,
              itemBuilder: (context, index) {
                final purchase = otpPurchases[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                purchase.productName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'READY FOR PICKUP',
                                style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('From: ${purchase.buyerName}'),
                        Text('Price: IDR ${purchase.price.toStringAsFixed(0)}'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'OTP:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                purchase.otp!,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Use this OTP on the smart locker hardware to pick up your item.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
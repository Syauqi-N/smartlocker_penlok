import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() => _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  late List<Purchase> _buyerPurchases;

  @override
  void initState() {
    super.initState();
    // In a real app, you would get the logged-in buyer's name dynamically.
    _buyerPurchases = _purchaseService.getPurchasesByBuyer('Active Buyer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notifications'),
      ),
      drawer: const BuyerDrawer(),
      body: _buyerPurchases.isEmpty
          ? const Center(
              child: Text('You have no notifications.', style: TextStyle(fontSize: 16, color: AppColors.grey)),
            )
          : ListView.builder(
              itemCount: _buyerPurchases.length,
              itemBuilder: (context, index) {
                final purchase = _buyerPurchases[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: _getIconForStatus(purchase.status),
                    title: _getTitleForStatus(purchase.status),
                    subtitle: _getSubtitleForStatus(purchase),
                  ),
                );
              },
            ),
    );
  }

  Icon _getIconForStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pendingVerification:
        return const Icon(Icons.hourglass_top, color: Colors.orange);
      case PurchaseStatus.verifiedReadyForPickup:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PurchaseStatus.completed:
        return const Icon(Icons.inventory, color: AppColors.primary);
    }
  }

  Text _getTitleForStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pendingVerification:
        return const Text('Awaiting Payment Verification');
      case PurchaseStatus.verifiedReadyForPickup:
        return const Text('Ready for Pickup!', style: TextStyle(fontWeight: FontWeight.bold));
      case PurchaseStatus.completed:
        return const Text('Order Completed');
    }
  }

  Text _getSubtitleForStatus(Purchase purchase) {
    switch (purchase.status) {
      case PurchaseStatus.pendingVerification:
        return Text('Your payment for "${purchase.productName}" is being reviewed.');
      case PurchaseStatus.verifiedReadyForPickup:
        return Text('Item: "${purchase.productName}"\nYour OTP is: ${purchase.otp}');
      case PurchaseStatus.completed:
        return Text('You have picked up "${purchase.productName}".');
    }
  }
}
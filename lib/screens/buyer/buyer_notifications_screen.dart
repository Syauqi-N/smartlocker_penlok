import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/screens/buyer/otp_input_screen.dart';
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

  void _refreshPurchases() {
    setState(() {
      // In a real app, you would get the logged-in buyer's name dynamically.
      _buyerPurchases = _purchaseService.getPurchasesByBuyer('Active Buyer');
    });
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
                    onTap: purchase.status == PurchaseStatus.verifiedReadyForPickup
                        ? () => _navigateToOtpInput(purchase)
                        : null,
                  ),
                );
              },
            ),
    );
  }

  void _navigateToOtpInput(Purchase purchase) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OtpInputScreen(purchase: purchase)),
    );
    if (result == true) {
      _refreshPurchases();
    }
  }

  Icon _getIconForStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pendingVerification:
        return const Icon(Icons.hourglass_top, color: Colors.orange);
      case PurchaseStatus.paymentApproved:
        return const Icon(Icons.check_circle, color: Colors.blue);
      case PurchaseStatus.verifiedReadyForPickup:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PurchaseStatus.completed:
        return const Icon(Icons.inventory, color: AppColors.primary);
      case PurchaseStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.red);
    }
  }

  Text _getTitleForStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pendingVerification:
        return const Text('Awaiting Payment Verification');
      case PurchaseStatus.paymentApproved:
        return const Text('Payment Approved');
      case PurchaseStatus.verifiedReadyForPickup:
        return const Text('Ready for Pickup!', style: TextStyle(fontWeight: FontWeight.bold));
      case PurchaseStatus.completed:
        return const Text('Order Completed');
      case PurchaseStatus.rejected:
        return const Text('Order Rejected');
    }
  }

  Text _getSubtitleForStatus(Purchase purchase) {
    switch (purchase.status) {
      case PurchaseStatus.pendingVerification:
        return Text('Your payment for "${purchase.productName}" is being reviewed.');
      case PurchaseStatus.paymentApproved:
        return Text('Your payment for "${purchase.productName}" has been approved. Waiting for OTP generation.');
      case PurchaseStatus.verifiedReadyForPickup:
        return Text('Item: "${purchase.productName}"\nTap to enter OTP for pickup.');
      case PurchaseStatus.completed:
        return Text('You have picked up "${purchase.productName}".');
      case PurchaseStatus.rejected:
        return Text('Your order for "${purchase.productName}" has been rejected.');
    }
  }
}
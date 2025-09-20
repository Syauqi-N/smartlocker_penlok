import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/screens/owner/payment_detail_screen.dart'; // Will be created next
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/owner_drawer.dart';

class PaymentVerificationScreen extends StatefulWidget {
  const PaymentVerificationScreen({super.key});

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  late List<Purchase> _pendingPurchases;

  @override
  void initState() {
    super.initState();
    _loadPendingPurchases();
  }

  void _loadPendingPurchases() {
    setState(() {
      _pendingPurchases = _purchaseService.getPendingVerificationPurchases();
    });
  }

  void _navigateToDetail(Purchase purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentDetailScreen(purchase: purchase)),
    ).then((_) => _loadPendingPurchases()); // Refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Verification'),
      ),
      drawer: const OwnerDrawer(),
      body: _pendingPurchases.isEmpty
          ? const Center(
              child: Text('No pending payments to verify.', style: TextStyle(fontSize: 16, color: AppColors.grey)),
            )
          : ListView.builder(
              itemCount: _pendingPurchases.length,
              itemBuilder: (context, index) {
                final purchase = _pendingPurchases[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(purchase.productName),
                    subtitle: Text('From: ${purchase.buyerName}\nPrice: IDR ${purchase.price.toStringAsFixed(0)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _navigateToDetail(purchase),
                  ),
                );
              },
            ),
    );
  }
}
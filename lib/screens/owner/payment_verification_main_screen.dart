import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';

class PaymentVerificationMainScreen extends StatefulWidget {
  const PaymentVerificationMainScreen({super.key});

  @override
  State<PaymentVerificationMainScreen> createState() => _PaymentVerificationMainScreenState();
}

class _PaymentVerificationMainScreenState extends State<PaymentVerificationMainScreen>
    with SingleTickerProviderStateMixin {
  final PurchaseService _purchaseService = PurchaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Verification'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Need Verification'),
            Tab(text: 'Approved'),
            Tab(text: 'Completed/Rejected'),
          ],
        ),
      ),
      drawer: const SellerDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNeedVerificationSection(),
          _buildApprovedSection(),
          _buildCompletedRejectedSection(),
        ],
      ),
    );
  }

  Widget _buildNeedVerificationSection() {
    final pendingPurchases = _purchaseService.getPendingVerificationPurchases();
    
    if (pendingPurchases.isEmpty) {
      return const Center(
        child: Text('No products need verification.', style: TextStyle(fontSize: 16, color: AppColors.grey)),
      );
    }

    return ListView.builder(
      itemCount: pendingPurchases.length,
      itemBuilder: (context, index) {
        final purchase = pendingPurchases[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.productName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('From: ${purchase.buyerName}'),
                Text('Price: IDR ${purchase.price.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _purchaseService.rejectPayment(purchase.id);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment rejected!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('REJECT', style: TextStyle(color: AppColors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _purchaseService.verifyPayment(purchase.id);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment approved!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('APPROVE', style: TextStyle(color: AppColors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedSection() {
    final approvedPurchases = _purchaseService.getPurchases()
        .where((p) => p.status == PurchaseStatus.paymentApproved)
        .toList();
    
    if (approvedPurchases.isEmpty) {
      return const Center(
        child: Text('No approved products.', style: TextStyle(fontSize: 16, color: AppColors.grey)),
      );
    }

    return ListView.builder(
      itemCount: approvedPurchases.length,
      itemBuilder: (context, index) {
        final purchase = approvedPurchases[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.productName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('From: ${purchase.buyerName}'),
                Text('Price: IDR ${purchase.price.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _purchaseService.generateOtp(purchase.id);
                      _refreshData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP generated!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('GENERATE OTP', style: TextStyle(color: AppColors.black)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedRejectedSection() {
    final completedRejectedPurchases = _purchaseService.getPurchases()
        .where((p) => p.status == PurchaseStatus.verifiedReadyForPickup || 
                     p.status == PurchaseStatus.completed || 
                     p.status == PurchaseStatus.rejected)
        .toList();
    
    if (completedRejectedPurchases.isEmpty) {
      return const Center(
        child: Text('No completed or rejected products.', style: TextStyle(fontSize: 16, color: AppColors.grey)),
      );
    }

    return ListView.builder(
      itemCount: completedRejectedPurchases.length,
      itemBuilder: (context, index) {
        final purchase = completedRejectedPurchases[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.productName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('From: ${purchase.buyerName}'),
                Text('Price: IDR ${purchase.price.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: purchase.status == PurchaseStatus.rejected 
                        ? Colors.redAccent 
                        : purchase.status == PurchaseStatus.completed 
                            ? Colors.green 
                            : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    purchase.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (purchase.status == PurchaseStatus.verifiedReadyForPickup && purchase.otp != null) ...[
                  const SizedBox(height: 8),
                  Text('OTP: ${purchase.otp}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
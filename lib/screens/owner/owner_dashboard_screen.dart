import 'package:flutter/material.dart';
import 'package:smartlocker/models/purchase.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';
import 'package:smartlocker/widgets/placeholder_chart.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  late List<Purchase> _allPurchases;

  @override
  void initState() {
    super.initState();
    _allPurchases = _purchaseService.getPurchases();
  }

  int _getPurchaseCountByStatus(PurchaseStatus status) {
    return _allPurchases.where((p) => p.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const SellerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Performance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 250,
              child: Card(
                color: AppColors.white,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: PlaceholderSalesChart(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Status Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.hourglass_top,
              title: 'Pending Verification',
              count: _getPurchaseCountByStatus(PurchaseStatus.pendingVerification),
              color: Colors.orange,
            ),
            _buildSummaryCard(
              icon: Icons.check_circle,
              title: 'Ready for Pickup',
              count: _getPurchaseCountByStatus(PurchaseStatus.verifiedReadyForPickup),
              color: Colors.blue,
            ),
            _buildSummaryCard(
              icon: Icons.inventory,
              title: 'Completed',
              count: _getPurchaseCountByStatus(PurchaseStatus.completed),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String title, required int count, required Color color}) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$count Orders', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
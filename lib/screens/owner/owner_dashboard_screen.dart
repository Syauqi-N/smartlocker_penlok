import 'package:flutter/material.dart';
import 'package:smartlocker/models/transaction.dart';
import 'package:smartlocker/services/transaction_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';
import 'package:smartlocker/widgets/placeholder_chart.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  final List<TransactionModel> _transactions = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _transactionService.fetchSellerTransactions();
      if (!mounted) return;
      setState(() {
        _transactions
          ..clear()
          ..addAll(data);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  int _count(TransactionStatus status) {
    return _transactions.where((t) => t.status == status).length;
  }

  int _completedCount() {
    return _transactions
        .where((t) =>
            t.status == TransactionStatus.completed ||
            t.status == TransactionStatus.released)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const SellerDrawer(),
      body: _loading && _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _transactions.isEmpty
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sales Performance',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
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
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        icon: Icons.hourglass_top,
                        title: 'Pending Verification',
                        count: _count(TransactionStatus.pending),
                        color: Colors.orange,
                      ),
                      _buildSummaryCard(
                        icon: Icons.check_circle,
                        title: 'Ready for Pickup',
                        count: _count(TransactionStatus.awaitingPickup),
                        color: Colors.blue,
                      ),
                      _buildSummaryCard(
                        icon: Icons.inventory,
                        title: 'Completed',
                        count: _completedCount(),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(
      {required IconData icon,
      required String title,
      required int count,
      required Color color}) {
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

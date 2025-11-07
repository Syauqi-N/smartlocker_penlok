import 'package:flutter/material.dart';
import 'package:smartlocker/models/transaction.dart';
import 'package:smartlocker/services/transaction_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class BuyerOtpListScreen extends StatefulWidget {
  const BuyerOtpListScreen({super.key});

  @override
  State<BuyerOtpListScreen> createState() => _BuyerOtpListScreenState();
}

class _BuyerOtpListScreenState extends State<BuyerOtpListScreen> {
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
      final data = await _transactionService.fetchBuyerTransactions();
      if (!mounted) return;
      setState(() {
        _transactions
          ..clear()
          ..addAll(
            data.where((t) =>
                t.status == TransactionStatus.awaitingPickup &&
                t.otp != null &&
                t.otp!.isNotEmpty),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My OTPs'),
      ),
      drawer: const BuyerDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _transactions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    if (_transactions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'You have no OTPs available.\nWait for seller to generate OTP for your purchases.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grey),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final productName = transaction.product?.name ?? 'Unknown product';
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
                        productName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'READY FOR PICKUP',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Total: ${transaction.formattedTotalPrice}'),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        transaction.otp ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
    );
  }
}

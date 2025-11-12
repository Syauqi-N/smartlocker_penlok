import 'package:flutter/material.dart';
import 'package:smartlocker/models/transaction.dart';
import 'package:smartlocker/services/transaction_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';

class PaymentVerificationMainScreen extends StatefulWidget {
  const PaymentVerificationMainScreen({super.key});

  @override
  State<PaymentVerificationMainScreen> createState() =>
      _PaymentVerificationMainScreenState();
}

class _PaymentVerificationMainScreenState
    extends State<PaymentVerificationMainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = const [];
  bool _loading = false;
  String? _error;
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _transactionService.fetchSellerTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = items;
        _loading = false;
        _processingIds.clear();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
        _processingIds.clear();
      });
    }
  }

  Future<void> _approve(TransactionModel transaction) async {
    setState(() {
      _processingIds.add(transaction.id);
    });
    try {
      await _transactionService.approveTransaction(transaction.id);
      if (!mounted) return;
      await _loadTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment approved. Transaction moved to escrow.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() {
        _processingIds.remove(transaction.id);
      });
    }
  }

  Future<void> _reject(TransactionModel transaction) async {
    setState(() {
      _processingIds.add(transaction.id);
    });
    try {
      await _transactionService.rejectTransaction(transaction.id);
      if (!mounted) return;
      await _loadTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment rejected.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() {
        _processingIds.remove(transaction.id);
      });
    }
  }

  Future<void> _generateOtp(TransactionModel transaction) async {
    setState(() {
      _processingIds.add(transaction.id);
    });
    try {
      await _transactionService.generateOtp(transaction.id);
      if (!mounted) return;
      await _loadTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP generated and sent to buyer.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() {
        _processingIds.remove(transaction.id);
      });
    }
  }

  bool _isProcessing(int id) => _processingIds.contains(id);

  Widget _shippingInfo(TransactionModel transaction) {
    if (!transaction.hasShippingInfo) {
      return const Text(
        'Buyer detail belum lengkap.',
        style: TextStyle(color: Colors.redAccent),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buyer: ${transaction.buyerFullName}'),
        const SizedBox(height: 4),
        Text('Phone: ${transaction.buyerPhoneNumber}'),
        const SizedBox(height: 4),
        Text('Address: ${transaction.shippingAddress}'),
      ],
    );
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
            Tab(text: 'Escrow / Paid'),
            Tab(text: 'Completed / Rejected'),
          ],
        ),
      ),
      drawer: const SellerDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: _loading && _transactions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _transactions.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNeedVerification(),
                      _buildEscrowList(),
                      _buildCompletedRejected(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildNeedVerification() {
    final pending = _transactions
        .where((t) =>
            t.status == TransactionStatus.needVerification ||
            t.status == TransactionStatus.pending)
        .toList();

    if (pending.isEmpty) {
      return const Center(
        child: Text(
          'No transactions waiting for verification.',
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final transaction = pending[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.product?.name ?? 'Unknown product',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Total: ${transaction.formattedTotalPrice}'),
                const SizedBox(height: 8),
                _shippingInfo(transaction),
                const SizedBox(height: 8),
                if (transaction.paymentProof != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      transaction.paymentProof!,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Text(
                    'No payment proof uploaded yet.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing(transaction.id) ||
                                transaction.paymentProof == null ||
                                !transaction.hasShippingInfo
                            ? null
                            : () => _approve(transaction),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary),
                        child: _isProcessing(transaction.id)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('APPROVE',
                                style: TextStyle(color: AppColors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing(transaction.id)
                            ? null
                            : () => _reject(transaction),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: _isProcessing(transaction.id)
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('REJECT',
                                style: TextStyle(color: AppColors.white)),
                      ),
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

  Widget _buildEscrowList() {
    final escrowed = _transactions.where((t) =>
        t.status == TransactionStatus.escrow ||
        t.status == TransactionStatus.paid);

    if (escrowed.isEmpty) {
      return const Center(
        child: Text(
          'No approved transactions yet.',
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: escrowed
          .map(
            (transaction) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            transaction.product?.name ?? 'Unknown product',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.verified, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Total: ${transaction.formattedTotalPrice}'),
                    const SizedBox(height: 8),
                    _shippingInfo(transaction),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isProcessing(transaction.id)
                          ? null
                          : () => _generateOtp(transaction),
                      icon: _isProcessing(transaction.id)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.qr_code),
                      label: const Text('Generate OTP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCompletedRejected() {
    final others = _transactions.where((t) =>
        t.status == TransactionStatus.awaitingPickup ||
        t.status == TransactionStatus.released ||
        t.status == TransactionStatus.completed ||
        t.status == TransactionStatus.failed ||
        t.status == TransactionStatus.rejected);

    if (others.isEmpty) {
      return const Center(
        child: Text(
          'No completed or rejected transactions.',
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: others
          .map(
            (transaction) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(transaction.product?.name ?? 'Unknown product'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: ${transaction.formattedTotalPrice}'),
                    if (transaction.hasShippingInfo) ...[
                      const SizedBox(height: 4),
                      Text('Buyer: ${transaction.buyerFullName}'),
                      Text('Phone: ${transaction.buyerPhoneNumber}'),
                    ],
                    if (transaction.otp != null &&
                        transaction.otp!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('OTP: ${transaction.otp}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                trailing: Icon(
                  transaction.status == TransactionStatus.rejected
                      ? Icons.cancel
                      : Icons.inventory,
                  color: transaction.status == TransactionStatus.rejected
                      ? Colors.red
                      : AppColors.primary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

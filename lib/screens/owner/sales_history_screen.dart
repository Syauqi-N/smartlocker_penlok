import 'package:flutter/material.dart';
import 'package:smartlocker/models/transaction.dart';
import 'package:smartlocker/services/transaction_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _transactions = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
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
        title: const Text('Sales History'),
      ),
      drawer: const SellerDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
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
                : _transactions.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: const [
                          Text(
                            'No sales recorded yet.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text('#${tx.id}'),
                              ),
                              title: Text(tx.product?.name ?? 'Transaction #${tx.id}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Buyer: ${tx.buyerFullName.isNotEmpty ? tx.buyerFullName : tx.buyerName}'),
                                  if (tx.createdAt != null)
                                    Text('Created: ${_formatDate(tx.createdAt!)}'),
                                  Text('Status: ${tx.status.name.toUpperCase()}'),
                                ],
                              ),
                              trailing: Text(tx.formattedTotalPrice),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

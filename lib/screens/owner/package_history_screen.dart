import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageHistoryScreen extends StatefulWidget {
  const PackageHistoryScreen({super.key});

  @override
  State<PackageHistoryScreen> createState() => _PackageHistoryScreenState();
}

class _PackageHistoryScreenState extends State<PackageHistoryScreen> {
  final PackageService _packageService = PackageService.instance;
  final List<Package> _packages = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _packageService.fetchPackages();
      if (!mounted) return;
      setState(() {
        _packages
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package History'),
      ),
      drawer: const ReceiverDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadPackages,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _packages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _packages.isEmpty) {
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

    if (_packages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'No package history found.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(package.packageName),
            subtitle: Text('Resi: ${package.trackingNumber ?? '-'}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Tracking Number', package.trackingNumber ?? '-'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Package Name', package.packageName),
                    if (package.courier != null &&
                        package.courier!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('Courier', package.courier!),
                    ],
                    if (package.orderDate != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Order Date',
                        '${package.orderDate!.day}/${package.orderDate!.month}/${package.orderDate!.year}',
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildDetailRow(
                        'Status', package.status.toString().split('.').last),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

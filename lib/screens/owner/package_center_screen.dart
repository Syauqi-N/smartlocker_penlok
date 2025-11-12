import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/screens/owner/package_detail_screen.dart';
import 'package:smartlocker/screens/owner/package_input_screen.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageCenterScreen extends StatefulWidget {
  const PackageCenterScreen({super.key});

  @override
  State<PackageCenterScreen> createState() => _PackageCenterScreenState();
}

class _PackageCenterScreenState extends State<PackageCenterScreen>
    with SingleTickerProviderStateMixin {
  final PackageService _packageService = PackageService.instance;
  late TabController _tabController;
  final List<Package> _activePackages = [];
  final List<Package> _deliveredPackages = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPackages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packages = await _packageService.fetchPackages();
      final active = packages
          .where((p) =>
              p.status == PackageStatus.registered ||
              p.status == PackageStatus.inTransit)
          .toList();
      final delivered =
          packages.where((p) => p.status == PackageStatus.delivered).toList();
      if (!mounted) return;
      setState(() {
        _activePackages
          ..clear()
          ..addAll(active);
        _deliveredPackages
          ..clear()
          ..addAll(delivered);
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
        title: const Text('Package Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      drawer: const ReceiverDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(
              builder: (context) => const PackageInputScreen(),
            ),
          );
          if (created != null) {
            _loadPackages();
          }
        },
        backgroundColor: AppColors.primary,
        label: const Text('Add Package'),
        icon: const Icon(Icons.add, color: AppColors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadPackages,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPackageList(_activePackages),
                      _buildPackageList(_deliveredPackages),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPackageList(List<Package> packages) {
    if (packages.isEmpty) {
      return const Center(child: Text('No packages found.'));
    }
    return ListView.builder(
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(package.packageName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resi: ${package.trackingNumber}'),
                if (package.courier != null && package.courier!.isNotEmpty)
                  Text('Courier: ${package.courier}'),
                if (package.orderDate != null)
                  Text(
                      'Order Date: ${package.orderDate!.day}/${package.orderDate!.month}/${package.orderDate!.year}'),
                if (package.receiverName?.isNotEmpty == true)
                  Text('Receiver: ${package.receiverName}'),
                if (package.lockerSlot?.isNotEmpty == true)
                  Text('Locker: ${package.lockerSlot}'),
              ],
            ),
            trailing: Text(
              package.status.label,
              style: TextStyle(
                color: switch (package.status) {
                  PackageStatus.registered => Colors.grey,
                  PackageStatus.inTransit => Colors.orange,
                  PackageStatus.delivered => Colors.green,
                },
              ),
            ),
            onTap: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => PackageDetailScreen(package: package),
                ),
              );
              if (changed == true) {
                _loadPackages();
              }
            },
          ),
        );
      },
    );
  }
}

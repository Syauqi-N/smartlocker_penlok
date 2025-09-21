import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/screens/owner/package_detail_screen.dart';
import 'package:smartlocker/screens/owner/package_input_screen.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageCenterScreen extends StatefulWidget {
  const PackageCenterScreen({super.key});

  @override
  State<PackageCenterScreen> createState() => _PackageCenterScreenState();
}

class _PackageCenterScreenState extends State<PackageCenterScreen>
    with SingleTickerProviderStateMixin {
  final PackageService _packageService = PackageService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshPackages() {
    setState(() {});
  }

  void _navigateToAddPackage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PackageInputScreen()),
    );
    if (result == true) {
      _refreshPackages();
    }
  }

  void _navigateToPackageDetail(Package package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetailScreen(package: package),
      ),
    );
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
            Tab(text: 'Completed'),
          ],
        ),
      ),
      drawer: const ReceiverDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPackageList(_packageService.getActivePackages()),
          _buildPackageList(_packageService.getCompletedPackages()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPackage,
        child: const Icon(Icons.add),
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
              ],
            ),
            trailing: Text(
              package.status.toString().split('.').last,
              style: TextStyle(
                color: package.status == PackageStatus.inTransit
                    ? Colors.orange
                    : package.status == PackageStatus.delivered
                        ? Colors.blue
                        : Colors.green,
              ),
            ),
            onTap: () => _navigateToPackageDetail(package),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/services/package_service.dart';

import 'package:smartlocker/widgets/owner_drawer.dart';

class PackageCenterScreen extends StatefulWidget {
  const PackageCenterScreen({super.key});

  @override
  State<PackageCenterScreen> createState() => _PackageCenterScreenState();
}

class _PackageCenterScreenState extends State<PackageCenterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _trackingNumberController = TextEditingController();
  final _packageNameController = TextEditingController();

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
    _trackingNumberController.dispose();
    _packageNameController.dispose();
    super.dispose();
  }

  void _addPackage() {
    if (_formKey.currentState!.validate()) {
      _packageService.addPackage(
        _trackingNumberController.text,
        _packageNameController.text,
      );
      _trackingNumberController.clear();
      _packageNameController.clear();
      setState(() {}); // Refresh the lists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package added successfully!')),
      );
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
            Tab(text: 'Completed'),
          ],
        ),
      ),
      drawer: const OwnerDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPackageList(_packageService.getActivePackages()),
          _buildPackageList(_packageService.getCompletedPackages()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPackageDialog(),
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
            subtitle: Text('Resi: ${package.trackingNumber}'),
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
          ),
        );
      },
    );
  }

  void _showAddPackageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Package'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _trackingNumberController,
                  decoration: const InputDecoration(labelText: 'Tracking Number (Resi)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a tracking number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _packageNameController,
                  decoration: const InputDecoration(labelText: 'Package Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a package name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addPackage();
                Navigator.pop(context);
              },
              child: const Text('Add Package'),
            ),
          ],
        );
      },
    );
  }
}
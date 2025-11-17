import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/screens/owner/package_detail_screen.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/widgets/app_logo.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class ReceiverDashboardScreen extends StatefulWidget {
  const ReceiverDashboardScreen({super.key});

  @override
  State<ReceiverDashboardScreen> createState() =>
      _ReceiverDashboardScreenState();
}

class _ReceiverDashboardScreenState extends State<ReceiverDashboardScreen> {
  final PackageService _packageService = PackageService.instance;
  final List<Package> _activePackages = [];
  final List<Package> _deliveredPackages = [];
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
        title: Row(
          children: const [
            AppTextLogo(height: 22),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Receiver Dashboard',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      drawer: const ReceiverDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadPackages,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red))
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Package Center Dashboard',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        _buildStatCard('Active Packages',
                            _activePackages.length.toString(), Colors.blue),
                        const SizedBox(height: 16),
                        _buildStatCard('Delivered Packages',
                            _deliveredPackages.length.toString(), Colors.green),
                        const SizedBox(height: 32),
                        const Text(
                          'Recent Packages',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildRecentPackagesList(
                              _activePackages, _deliveredPackages),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            count,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPackagesList(
      List<Package> activePackages, List<Package> deliveredPackages) {
    final allPackages = [...activePackages, ...deliveredPackages];
    if (allPackages.isEmpty) {
      return const Center(
        child: Text('No packages found.'),
      );
    }

    return ListView.builder(
      itemCount: allPackages.length,
      itemBuilder: (context, index) {
        final package = allPackages[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(package.packageName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resi: ${package.trackingNumber}'),
                Text('Status: ${package.status.label}'),
                if (package.receiverName?.isNotEmpty == true)
                  Text('Receiver: ${package.receiverName}'),
                if (package.lockerSlot?.isNotEmpty == true)
                  Text('Locker: ${package.lockerSlot}'),
              ],
            ),
            trailing: Icon(
              switch (package.status) {
                PackageStatus.registered => Icons.pending,
                PackageStatus.inTransit => Icons.local_shipping,
                PackageStatus.delivered => Icons.inventory,
              },
              color: switch (package.status) {
                PackageStatus.registered => Colors.grey,
                PackageStatus.inTransit => Colors.orange,
                PackageStatus.delivered => Colors.green,
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PackageDetailScreen(package: package),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

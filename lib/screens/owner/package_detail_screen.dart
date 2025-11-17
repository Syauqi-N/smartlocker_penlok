import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/screens/owner/package_input_screen.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/widgets/app_logo.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key, required this.package});

  final Package package;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final PackageService _packageService = PackageService.instance;
  late Package _package;
  bool _statusUpdating = false;
  bool _deleting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _package = widget.package;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              AppTextLogo(height: 28),
              SizedBox(width: 8),
              Text('Package Details'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: _statusUpdating || _deleting ? null : _editPackage,
            ),
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _deleting ? null : _confirmDelete,
            ),
          ],
        ),
        drawer: const ReceiverDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _package.packageName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<PackageStatus>(
                            value: _package.status,
                            items: PackageStatus.values
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.label),
                                  ),
                                )
                                .toList(),
                            onChanged: _statusUpdating ? null : _changeStatus,
                          ),
                          if (_statusUpdating)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                          'Tracking Number', _package.trackingNumber),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Courier',
                        _package.courier?.isNotEmpty == true
                            ? _package.courier!
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Order Date',
                        _package.orderDate != null
                            ? _formatDate(_package.orderDate!)
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Delivered Date',
                        _package.deliveredDate != null
                            ? _formatDate(_package.deliveredDate!)
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Locker Slot',
                        _package.lockerSlot?.isNotEmpty == true
                            ? _package.lockerSlot!
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Receiver',
                        _package.receiverName?.isNotEmpty == true
                            ? _package.receiverName!
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Receiver Phone',
                        _package.receiverPhone?.isNotEmpty == true
                            ? _package.receiverPhone!
                            : '-',
                      ),
                      if (_package.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Notes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(_package.notes!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _changeStatus(PackageStatus? status) async {
    if (status == null || status == _package.status) return;
    setState(() => _statusUpdating = true);
    try {
      final updated = await _packageService.updatePackage(
        id: _package.id,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _package = updated;
        _statusUpdating = false;
        _hasChanges = true;
      });
      _showMessage('Status updated to ${status.label}.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusUpdating = false);
      _showMessage('Failed to update status: $error', isError: true);
    }
  }

  Future<void> _editPackage() async {
    final updated = await Navigator.push<Package>(
      context,
      MaterialPageRoute(
        builder: (context) => PackageInputScreen(package: _package),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _package = updated;
        _hasChanges = true;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this package?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _deletePackage();
    }
  }

  Future<void> _deletePackage() async {
    setState(() => _deleting = true);
    try {
      await _packageService.deletePackage(_package.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      _showMessage('Failed to delete package: $error', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

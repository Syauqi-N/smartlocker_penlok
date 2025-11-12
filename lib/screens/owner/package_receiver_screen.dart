import 'package:flutter/material.dart';
import 'package:smartlocker/models/access_log.dart';
import 'package:smartlocker/services/access_log_service.dart';
import 'package:smartlocker/services/owner_locker_service.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageReceiverScreen extends StatefulWidget {
  const PackageReceiverScreen({super.key});

  @override
  State<PackageReceiverScreen> createState() => _PackageReceiverScreenState();
}

class _PackageReceiverScreenState extends State<PackageReceiverScreen>
    with SingleTickerProviderStateMixin {
  final OwnerLockerService _lockerService = OwnerLockerService.instance;
  final AccessLogService _logService = AccessLogService.instance;
  final TextEditingController _receiverNameController = TextEditingController();

  String _selectedLockerId = 'locker-1';
  bool _isOpeningLocker = false;
  LockerActionResult? _lastActionResult;
  late Future<List<AccessLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _logService.fetchAccessLogs(lockerId: _selectedLockerId);
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    super.dispose();
  }

  Future<void> _handleManualOpen() async {
    setState(() {
      _isOpeningLocker = true;
      _lastActionResult = null;
    });

    final result = await _lockerService.openLockerManually(
      lockerId: _selectedLockerId,
      receiverName: _receiverNameController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isOpeningLocker = false;
      _lastActionResult = result;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) {
      await _refreshLogs();
    }
  }

  Future<void> _refreshLogs() async {
    final future = _logService.fetchAccessLogs(lockerId: _selectedLockerId);
    setState(() {
      _logsFuture = future;
    });
    await future;
  }

  String _formatDateTime(DateTime dateTime) {
    final dt = dateTime.toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Owner - Package Receiver'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.lock_open), text: 'Kontrol Manual'),
              Tab(icon: Icon(Icons.history), text: 'Log Akses'),
            ],
          ),
        ),
        drawer: const ReceiverDrawer(),
        body: TabBarView(
          children: [
            _buildManualControlTab(),
            _buildAccessLogTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLockerSelector(),
          const SizedBox(height: 24),
          _buildManualControlCard(),
          const SizedBox(height: 16),
          _buildActionStatus(),
        ],
      ),
    );
  }

  Widget _buildLockerSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.archive, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Locker Saat Ini',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedLockerId,
                    items: const [
                      DropdownMenuItem(
                          value: 'locker-1', child: Text('Locker 1')),
                      DropdownMenuItem(
                          value: 'locker-2', child: Text('Locker 2')),
                      DropdownMenuItem(
                          value: 'locker-3', child: Text('Locker 3')),
                    ],
                    onChanged: (value) {
                      if (value == null || value == _selectedLockerId) return;
                      setState(() {
                        _selectedLockerId = value;
                      });
                      _refreshLogs();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buka Paket Secara Manual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _receiverNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Penerima (opsional)',
                hintText: 'Masukkan nama pemilik paket',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isOpeningLocker
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock_open),
                label:
                    Text(_isOpeningLocker ? 'Membuka...' : 'Buka Paket Manual'),
                onPressed: _isOpeningLocker ? null : _handleManualOpen,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Saat tombol ditekan, locker akan menerima perintah untuk membuka pintu secara manual. '
              'Pastikan penerima berada di depan kamera untuk validasi visual.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionStatus() {
    if (_lastActionResult == null) {
      return const SizedBox.shrink();
    }
    final result = _lastActionResult!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.success ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result.success ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.success ? Icons.check_circle : Icons.error,
            color: result.success ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result.message,
              style: TextStyle(
                color: result.success
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessLogTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<AccessLog>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat log akses.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refreshLogs,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          final logs = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refreshLogs,
            child: logs.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 32),
                      Icon(Icons.camera_outdoor, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Center(
                          child: Text('Belum ada riwayat akses locker ini.')),
                    ],
                  )
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildLogTile(log);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: logs.length,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLogTile(AccessLog log) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.imageUrl != null && log.imageUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                log.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image,
                      size: 48, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.receiverName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(log.mode.label),
                      backgroundColor: log.mode == AccessMode.manual
                          ? Colors.orange.shade100
                          : Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color: log.mode == AccessMode.manual
                            ? Colors.orange.shade900
                            : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(_formatDateTime(log.capturedAt)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.archive_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(log.lockerId.isEmpty ? 'Locker' : log.lockerId),
                  ],
                ),
                if (log.details != null && log.details!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(log.details!)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

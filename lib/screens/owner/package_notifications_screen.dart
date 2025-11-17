import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartlocker/models/app_notification.dart';
import 'package:smartlocker/services/notification_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/app_logo.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageNotificationsScreen extends StatefulWidget {
  const PackageNotificationsScreen({super.key});

  @override
  State<PackageNotificationsScreen> createState() =>
      _PackageNotificationsScreenState();
}

class _PackageNotificationsScreenState
    extends State<PackageNotificationsScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  final List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _poller = Timer.periodic(
        const Duration(seconds: 30), (_) => _loadNotifications(rebuild: false));
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications({bool rebuild = true}) async {
    if (rebuild) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _notificationService.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _notifications
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
        title: Row(
          children: const [
            AppTextLogo(height: 22),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Package Notifications',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      drawer: const ReceiverDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [Text(_error!, style: const TextStyle(color: Colors.red))],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('No delivery notifications yet.', textAlign: TextAlign.center)
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.inventory_2, color: AppColors.secondary),
            title: Text(notification.title.isEmpty
                ? 'SmartLocker Update'
                : notification.title),
            subtitle: Text(notification.body),
            trailing: Text(
              _formatTimestamp(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    final formattedDate =
        '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return '$formattedDate $formattedTime';
  }
}

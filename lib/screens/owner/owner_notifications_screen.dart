import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartlocker/models/app_notification.dart';
import 'package:smartlocker/services/notification_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';

class OwnerNotificationsScreen extends StatefulWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  State<OwnerNotificationsScreen> createState() =>
      _OwnerNotificationsScreenState();
}

class _OwnerNotificationsScreenState extends State<OwnerNotificationsScreen> {
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
        title: const Text('Order Notifications'),
      ),
      drawer: const SellerDrawer(),
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
          Text('No notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey))
        ],
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.primary),
            title: Text(notification.title.isEmpty
                ? 'SmartLocker Update'
                : notification.title),
            subtitle: Text(notification.body),
            trailing: Text(
              _formatTimestamp(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

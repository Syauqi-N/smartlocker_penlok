import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartlocker/models/app_notification.dart';
import 'package:smartlocker/services/notification_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/app_logo.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  final List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _poller = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadNotifications(rebuild: false);
    });
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

  Future<void> _handleRefresh() => _loadNotifications();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            AppTextLogo(height: 28),
            SizedBox(width: 8),
            Text('My Notifications'),
          ],
        ),
      ),
      drawer: const BuyerDrawer(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
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
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'You have no notifications yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grey),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(item.title.isEmpty ? 'SmartLocker' : item.title),
            subtitle: Text(item.body),
            trailing: Text(
              _formatTimestamp(item.createdAt),
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime time) {
    final dt = time.toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

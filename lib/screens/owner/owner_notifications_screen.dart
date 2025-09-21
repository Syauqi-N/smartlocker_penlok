import 'package:flutter/material.dart';
import 'package:smartlocker/services/purchase_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/seller_drawer.dart';

class OwnerNotificationsScreen extends StatefulWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  State<OwnerNotificationsScreen> createState() => _OwnerNotificationsScreenState();
}

class _OwnerNotificationsScreenState extends State<OwnerNotificationsScreen> {
  final PurchaseService _purchaseService = PurchaseService();

  void _markAsRead(String notificationId) {
    setState(() {
      _purchaseService.markNotificationAsRead(notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _purchaseService.getSellerNotifications();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Notifications'),
      ),
      drawer: const SellerDrawer(),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No notifications.', style: TextStyle(fontSize: 16, color: AppColors.grey)),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['isRead'];
                final timestamp = notification['timestamp'] as DateTime;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isRead ? AppColors.white : AppColors.primary.withAlpha(30),
                  child: ListTile(
                    leading: Icon(
                      _getIconForNotification(notification['title']),
                      color: _getColorForNotification(notification['title']),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: isRead ? AppColors.black : AppColors.primary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message']),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: isRead 
                        ? null 
                        : IconButton(
                            icon: const Icon(Icons.mark_email_read, color: AppColors.primary),
                            onPressed: () => _markAsRead(notification['id']),
                          ),
                    onTap: isRead ? null : () => _markAsRead(notification['id']),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForNotification(String title) {
    if (title.contains('Order')) {
      return Icons.shopping_cart_checkout;
    } else if (title.contains('Payment')) {
      return Icons.payment;
    } else if (title.contains('OTP')) {
      return Icons.lock;
    } else if (title.contains('Package')) {
      return Icons.inventory;
    }
    return Icons.notifications;
  }

  Color _getColorForNotification(String title) {
    if (title.contains('Order')) {
      return AppColors.secondary;
    } else if (title.contains('Payment')) {
      return Colors.blue;
    } else if (title.contains('OTP')) {
      return AppColors.primary;
    } else if (title.contains('Package')) {
      return Colors.green;
    }
    return AppColors.grey;
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

import 'dart:convert';

import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/app_notification.dart';
import 'package:smartlocker/services/api_client.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final ApiClient _client = ApiClient();

  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _client.get(ApiRoutes.notifications);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];
    final list = decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}

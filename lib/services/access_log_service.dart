import 'dart:convert';

import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/access_log.dart';
import 'package:smartlocker/services/api_client.dart';

class AccessLogService {
  AccessLogService._internal();
  static final AccessLogService instance = AccessLogService._internal();

  final ApiClient _client = ApiClient();

  Future<List<AccessLog>> fetchAccessLogs({String? lockerId}) async {
    final response = await _client.get(ApiRoutes.lockersLogs);
    final data = jsonDecode(response.body);
    if (data is! List) return const [];
    var logs = data
        .whereType<Map<String, dynamic>>()
        .map((json) => AccessLog.fromJson(json))
        .toList();
    if (lockerId != null && lockerId.isNotEmpty) {
      logs = logs.where((log) => log.lockerId == lockerId).toList();
    }
    return logs;
  }
}

import 'dart:convert';

import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/store.dart';
import 'package:smartlocker/services/api_client.dart';

class StoreService {
  StoreService._internal();
  static final StoreService instance = StoreService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<StoreSummary>> fetchStores({String? search}) async {
    final response = await _apiClient.get(
      ApiRoutes.marketplaceStores,
      query: search == null || search.isEmpty ? null : {'search': search},
    );
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(StoreSummary.fromJson)
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      return (decoded['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(StoreSummary.fromJson)
          .toList();
    }
    return const [];
  }
}

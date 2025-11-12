import 'dart:convert';

import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/services/api_client.dart';

class PackageService {
  PackageService._internal();
  static final PackageService instance = PackageService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<Package>> fetchPackages({PackageStatus? status}) async {
    final response = await _apiClient.get(
      ApiRoutes.packageEntries,
      query: status == null ? null : {'status': status.apiValue},
    );
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Package.fromJson)
          .toList();
    }
    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      return (decoded['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Package.fromJson)
          .toList();
    }
    return const [];
  }

  Future<Package> createPackage({
    required String packageName,
    required String trackingNumber,
    String? courier,
    DateTime? orderDate,
    DateTime? deliveredDate,
    PackageStatus status = PackageStatus.registered,
    String? lockerSlot,
    String? receiverName,
    String? receiverPhone,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'package_name': packageName,
      'tracking_number': trackingNumber,
      if (courier != null) 'courier': courier,
      if (orderDate != null) 'order_date': orderDate.toIso8601String(),
      if (deliveredDate != null)
        'delivered_date': deliveredDate.toIso8601String(),
      'status': status.apiValue,
      if (lockerSlot != null) 'locker_slot': lockerSlot,
      if (receiverName != null) 'receiver_name': receiverName,
      if (receiverPhone != null) 'receiver_phone': receiverPhone,
      if (notes != null) 'notes': notes,
    };
    final response =
        await _apiClient.post(ApiRoutes.packageEntries, body: body);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Package.fromJson(data);
  }

  Future<Package> updatePackage({
    required int id,
    String? packageName,
    String? trackingNumber,
    String? courier,
    DateTime? orderDate,
    DateTime? deliveredDate,
    PackageStatus? status,
    String? lockerSlot,
    String? receiverName,
    String? receiverPhone,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (packageName != null) body['package_name'] = packageName;
    if (trackingNumber != null) body['tracking_number'] = trackingNumber;
    if (courier != null) body['courier'] = courier;
    if (orderDate != null) body['order_date'] = orderDate.toIso8601String();
    if (deliveredDate != null) {
      body['delivered_date'] = deliveredDate.toIso8601String();
    }
    if (status != null) body['status'] = status.apiValue;
    if (lockerSlot != null) body['locker_slot'] = lockerSlot;
    if (receiverName != null) body['receiver_name'] = receiverName;
    if (receiverPhone != null) body['receiver_phone'] = receiverPhone;
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.put(
      ApiRoutes.packageEntryDetail(id),
      body: body,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Package.fromJson(data);
  }

  Future<void> deletePackage(int id) async {
    await _apiClient.delete(ApiRoutes.packageEntryDetail(id));
  }

  Future<List<Package>> fetchActivePackages() async {
    final packages = await fetchPackages();
    return packages
        .where((p) =>
            p.status == PackageStatus.registered ||
            p.status == PackageStatus.inTransit)
        .toList();
  }

  Future<List<Package>> fetchCompletedPackages() async {
    final packages = await fetchPackages();
    return packages.where((p) => p.status == PackageStatus.delivered).toList();
  }
}

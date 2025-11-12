import 'package:smartlocker/config/env.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.storeId,
    this.storeName = '',
    this.storeOwnerName = '',
    this.storeLocation,
    this.storeDescription,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final int storeId;
  final String storeName;
  final String storeOwnerName;
  final String? storeLocation;
  final String? storeDescription;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) =>
        value == null ? null : DateTime.tryParse(value);

    return Product(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      stock: _parseInt(json['stock']),
      description: json['description']?.toString() ?? '',
      storeId: _parseInt(json['store']),
      storeName:
          (json['store_info'] as Map<String, dynamic>?)?['name']?.toString() ??
              '',
      storeOwnerName: (json['store_info'] as Map<String, dynamic>?)?['owner']
                  ?['username']
              ?.toString() ??
          (json['store_info'] as Map<String, dynamic>?)?['owner']?['email']
              ?.toString() ??
          '',
      storeLocation: (json['store_info'] as Map<String, dynamic>?)?['location']
          ?.toString(),
      storeDescription:
          (json['store_info'] as Map<String, dynamic>?)?['description']
              ?.toString(),
      imageUrl: _resolveImageUrl(json['image_url'] ?? json['image']),
      createdAt: parseDate(json['created_at']?.toString()),
      updatedAt: parseDate(json['updated_at']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'store': storeId,
      'store_name': storeName,
      'store_owner_name': storeOwnerName,
      if (storeLocation != null) 'store_location': storeLocation,
      if (storeDescription != null) 'store_description': storeDescription,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    String? description,
    int? storeId,
    String? storeName,
    String? storeOwnerName,
    String? storeLocation,
    String? storeDescription,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeOwnerName: storeOwnerName ?? this.storeOwnerName,
      storeLocation: storeLocation ?? this.storeLocation,
      storeDescription: storeDescription ?? this.storeDescription,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _resolveImageUrl(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    final parsed = Uri.tryParse(raw);
    if (parsed == null) return null;
    final origin = Uri.parse(Env.apiOrigin);
    if (parsed.hasScheme) {
      final hostMatches = parsed.host.isNotEmpty &&
          parsed.host.toLowerCase() == origin.host.toLowerCase() &&
          _effectivePort(parsed) == _effectivePort(origin);
      if (hostMatches) {
        return raw;
      }
      final target = Uri(
        scheme: origin.scheme,
        host: origin.host,
        port: origin.hasPort ? origin.port : null,
        path: parsed.path,
        query: parsed.hasQuery ? parsed.query : null,
        fragment: parsed.hasFragment ? parsed.fragment : null,
      );
      return target.toString();
    }
    return origin.resolveUri(parsed).toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int _effectivePort(Uri uri) {
    if (uri.hasPort) return uri.port;
    return uri.scheme == 'https' ? 443 : 80;
  }
}

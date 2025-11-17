import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/services/api_client.dart';

class ProductService {
  ProductService._internal();
  factory ProductService() => instance;

  static final ProductService instance = ProductService._internal();
  final ApiClient _apiClient = ApiClient();

  Future<List<Product>> _fetchProductList(
    String url, {
    int? storeId,
  }) async {
    final response = await _apiClient.get(
      url,
      query: storeId == null ? null : {'store_id': storeId.toString()},
    );

    if (response.statusCode != 200) {
      throw ProductServiceException(
          _parseError(response.body) ?? 'Unable to load products.');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> listPublicProducts({int? storeId}) {
    return _fetchProductList(
      ApiRoutes.marketplaceProducts,
      storeId: storeId,
    );
  }

  Future<List<Product>> listMyProducts({int? storeId}) {
    return _fetchProductList(
      ApiRoutes.marketplaceMyProducts,
      storeId: storeId,
    );
  }

  Future<List<Product>> fetchProducts({int? storeId}) {
    return listPublicProducts(storeId: storeId);
  }

  Future<Product> createProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    String? imagePath,
  }) async {
    final http.Response response;

    if (imagePath != null && imagePath.isNotEmpty) {
      response = await _apiClient.multipart(
        'POST',
        ApiRoutes.marketplaceProducts,
        fields: {
          'name': name,
          'price': price.toString(),
          'stock': stock.toString(),
          'description': description,
        },
        files: {'image': imagePath},
      );
    } else {
      response = await _apiClient.post(
        ApiRoutes.marketplaceProducts,
        body: jsonEncode({
          'name': name,
          'price': price,
          'stock': stock,
          'description': description,
        }),
      );
    }

    if (response.statusCode != 201) {
      throw ProductServiceException(
          _parseError(response.body) ?? 'Unable to create product.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(decoded);
  }

  Future<Product> updateProduct({
    required int id,
    required String name,
    required double price,
    required int stock,
    required String description,
    String? imagePath,
    bool removeImage = false,
  }) async {
    final http.Response response;

    if (imagePath != null && imagePath.isNotEmpty) {
      response = await _apiClient.multipart(
        'PUT',
        '${ApiRoutes.marketplaceProducts}$id/',
        fields: {
          'name': name,
          'price': price.toString(),
          'stock': stock.toString(),
          'description': description,
        },
        files: {'image': imagePath},
      );
    } else {
      response = await _apiClient.put(
        '${ApiRoutes.marketplaceProducts}$id/',
        body: jsonEncode({
          'name': name,
          'price': price,
          'stock': stock,
          'description': description,
          if (removeImage) 'image': null,
        }),
      );
    }

    if (response.statusCode != 200) {
      throw ProductServiceException(
          _parseError(response.body) ?? 'Unable to update product.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(decoded);
  }

  Future<void> deleteProduct(int id) async {
    final response =
        await _apiClient.delete('${ApiRoutes.marketplaceProducts}$id/');

    if (response.statusCode != 204) {
      throw ProductServiceException(
          _parseError(response.body) ?? 'Unable to delete product.');
    }
  }

  String? _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] != null) return decoded['detail'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
      }
      return decoded.toString();
    } catch (_) {
      return null;
    }
  }
}

class ProductServiceException implements Exception {
  const ProductServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

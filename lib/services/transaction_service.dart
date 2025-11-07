import 'dart:convert';

import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/transaction.dart';

import 'api_client.dart';

class TransactionService {
  TransactionService._internal();
  static final TransactionService _instance = TransactionService._internal();

  factory TransactionService() => _instance;

  final ApiClient _apiClient = ApiClient();

  Future<TransactionModel> createTransaction({
    required int productId,
    required int quantity,
    String? buyerFullName,
    String? shippingAddress,
    String? buyerPhoneNumber,
  }) async {
    final body = <String, dynamic>{
      'product_id': productId,
      'quantity': quantity,
    };
    if (buyerFullName != null) body['buyer_full_name'] = buyerFullName;
    if (shippingAddress != null) body['shipping_address'] = shippingAddress;
    if (buyerPhoneNumber != null) body['buyer_phone_number'] = buyerPhoneNumber;

    final response = await _apiClient.post(
      '${ApiRoutes.marketplaceTransactions}create/',
      body: body,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> uploadPaymentProof({
    required int transactionId,
    required String imagePath,
  }) async {
    final response = await _apiClient.multipartPost(
      ApiRoutes.transactionPaymentProof(transactionId),
      files: {'payment_proof': imagePath},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> fetchTransaction(int id) async {
    final response = await _apiClient.get(ApiRoutes.transactionDetail(id));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<List<TransactionModel>> fetchTransactions({String? role}) async {
    final response = await _apiClient.get(
      ApiRoutes.marketplaceTransactions,
      query: role == null ? null : {'role': role},
    );
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TransactionModel.fromJson)
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      return (decoded['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(TransactionModel.fromJson)
          .toList();
    }

    return const [];
  }

  Future<List<TransactionModel>> fetchBuyerTransactions() =>
      fetchTransactions(role: 'buyer');

  Future<List<TransactionModel>> fetchSellerTransactions() =>
      fetchTransactions(role: 'seller');

  Future<TransactionModel> approveTransaction(int id) async {
    final response =
        await _apiClient.post(ApiRoutes.transactionApprove(id), body: const {});
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> rejectTransaction(int id) async {
    final response =
        await _apiClient.post(ApiRoutes.transactionReject(id), body: const {});
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> updateShipping({
    required int id,
    required String buyerFullName,
    required String shippingAddress,
    required String buyerPhoneNumber,
  }) async {
    final response = await _apiClient.post(
      '${ApiRoutes.transactionDetail(id)}shipping/',
      body: {
        'buyer_full_name': buyerFullName,
        'shipping_address': shippingAddress,
        'buyer_phone_number': buyerPhoneNumber,
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> generateOtp(int id) async {
    final response = await _apiClient
        .post(ApiRoutes.transactionGenerateOtp(id), body: const {});
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }
}

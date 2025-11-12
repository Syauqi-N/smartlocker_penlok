import 'package:smartlocker/config/env.dart';

enum TransactionStatus {
  pending,
  needVerification,
  escrow,
  paid,
  awaitingPickup,
  released,
  completed,
  failed,
  rejected,
}

TransactionStatus transactionStatusFromString(String? value) {
  switch (value) {
    case 'NEED_VERIFICATION':
      return TransactionStatus.needVerification;
    case 'ESCROW':
      return TransactionStatus.escrow;
    case 'PAID':
      return TransactionStatus.paid;
    case 'AWAITING_PICKUP':
      return TransactionStatus.awaitingPickup;
    case 'RELEASED':
      return TransactionStatus.released;
    case 'COMPLETED':
      return TransactionStatus.completed;
    case 'FAILED':
      return TransactionStatus.failed;
    case 'REJECTED':
      return TransactionStatus.rejected;
    case 'PENDING':
    default:
      return TransactionStatus.pending;
  }
}

class TransactionProduct {
  const TransactionProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
    this.image,
  });

  final int id;
  final String name;
  final double price;
  final String description;
  final int stock;
  final String? image;

  factory TransactionProduct.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    return TransactionProduct(
      id: json['id'],
      name: json['name'] ?? '',
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      image: _resolveImageUrl(json['image_url'] ?? json['image']),
    );
  }
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.status,
    required this.quantity,
    required this.totalPrice,
    required this.productId,
    this.paymentProof,
    this.paymentProofUploadedAt,
    this.qrisPayload,
    this.qrisImage,
    this.paymentUrl,
    this.paymentExpiresAt,
    this.createdAt,
    this.paidAt,
    this.paymentGatewayId,
    this.product,
    this.buyerFullName = '',
    this.buyerName = '',
    this.sellerName = '',
    this.shippingAddress = '',
    this.buyerPhoneNumber = '',
    this.otp,
    this.updatedAt,
    this.paymentProofUrl,
  });

  final int id;
  final TransactionStatus status;
  final int quantity;
  final double totalPrice;
  final int? productId;
  final String? paymentProof;
  final DateTime? paymentProofUploadedAt;
  final String? qrisPayload;
  final String? qrisImage;
  final String? paymentUrl;
  final DateTime? paymentExpiresAt;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final String? paymentGatewayId;
  final TransactionProduct? product;
  final String buyerFullName;
  final String buyerName;
  final String sellerName;
  final String shippingAddress;
  final String buyerPhoneNumber;
  final String? otp;
  final DateTime? updatedAt;
  final String? paymentProofUrl;

  String get formattedTotalPrice => 'IDR ${totalPrice.toStringAsFixed(0)}';

  bool get hasPaymentProof => paymentProofUploadedAt != null;
  bool get hasShippingInfo =>
      buyerFullName.isNotEmpty &&
      shippingAddress.isNotEmpty &&
      buyerPhoneNumber.isNotEmpty;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null) return null;
      return DateTime.tryParse(value);
    }

    return TransactionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      status: transactionStatusFromString(json['status'] as String?),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      totalPrice: json['total_price'] is num
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      productId: json['product'] is Map<String, dynamic>
          ? (json['product'] as Map<String, dynamic>)['id'] as int?
          : json['product_id'] as int?,
      paymentProof: json['payment_proof'] as String?,
      paymentProofUploadedAt:
          parseDate(json['payment_proof_uploaded_at'] as String?),
      qrisPayload: json['qris_payload'] as String?,
      qrisImage: json['qris_image'] as String?,
      paymentUrl: json['payment_url'] as String?,
      paymentExpiresAt: parseDate(
        json['payment_expires_at'] as String? ?? json['expires_at'] as String?,
      ),
      createdAt: parseDate(json['created_at'] as String?),
      updatedAt: parseDate(json['updated_at'] as String?),
      paidAt: parseDate(json['paid_at'] as String?),
      paymentGatewayId: json['payment_gateway_id'] as String?,
      product: json['product'] is Map<String, dynamic>
          ? TransactionProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      buyerFullName: json['buyer_full_name']?.toString() ?? '',
      buyerName: _extractUserName(json['buyer']),
      sellerName: _extractUserName(json['seller']),
      shippingAddress: json['shipping_address']?.toString() ?? '',
      buyerPhoneNumber: json['buyer_phone_number']?.toString() ?? '',
      otp: json['otp']?.toString() ?? json['otp_code']?.toString(),
      paymentProofUrl: json['payment_proof_url']?.toString(),
    );
  }

  TransactionModel copyWith({
    TransactionStatus? status,
    String? paymentProof,
    DateTime? paymentProofUploadedAt,
    String? buyerFullName,
    String? shippingAddress,
    String? buyerPhoneNumber,
    String? otp,
    DateTime? updatedAt,
    String? paymentProofUrl,
  }) {
    return TransactionModel(
      id: id,
      status: status ?? this.status,
      quantity: quantity,
      totalPrice: totalPrice,
      productId: productId,
      paymentProof: paymentProof ?? this.paymentProof,
      paymentProofUploadedAt:
          paymentProofUploadedAt ?? this.paymentProofUploadedAt,
      qrisPayload: qrisPayload,
      qrisImage: qrisImage,
      paymentUrl: paymentUrl,
      paymentExpiresAt: paymentExpiresAt,
      createdAt: createdAt,
      paidAt: paidAt,
      paymentGatewayId: paymentGatewayId,
      product: product,
      buyerFullName: buyerFullName ?? this.buyerFullName,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      buyerPhoneNumber: buyerPhoneNumber ?? this.buyerPhoneNumber,
      otp: otp ?? this.otp,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
    );
  }

  static String _extractUserName(Object? userJson) {
    if (userJson is Map<String, dynamic>) {
      return userJson['username']?.toString() ??
          userJson['email']?.toString() ??
          '';
    }
    return '';
  }
}

String? _resolveImageUrl(dynamic value) {
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

int _effectivePort(Uri uri) {
  if (uri.hasPort) return uri.port;
  return uri.scheme == 'https' ? 443 : 80;
}

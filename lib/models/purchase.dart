enum PurchaseStatus { pendingVerification, paymentApproved, verifiedReadyForPickup, completed, rejected }

class Purchase {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String buyerName;
  final String paymentProofImageUrl;
  PurchaseStatus status;
  String? otp;

  Purchase({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.buyerName,
    required this.paymentProofImageUrl,
    this.status = PurchaseStatus.pendingVerification,
    this.otp,
  });
}

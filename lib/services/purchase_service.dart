import 'dart:math';
import 'package:smartlocker/models/cart_item.dart';
import 'package:smartlocker/models/purchase.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final List<Purchase> _purchases = [
    Purchase(
      id: '101',
      productId: '1',
      productName: 'Produk Contoh 1',
      price: 150000,
      buyerName: 'John Doe',
      paymentProofImageUrl: 'assets/images/placeholder.png', // Placeholder for payment proof
    ),
    Purchase(
      id: '102',
      productId: '2',
      productName: 'Produk Contoh 2',
      price: 250000,
      buyerName: 'Jane Smith',
      paymentProofImageUrl: 'assets/images/placeholder.png',
      status: PurchaseStatus.verifiedReadyForPickup,
      otp: '123456',
    ),
    Purchase(
      id: '103',
      productId: '3',
      productName: 'Produk Contoh 3',
      price: 75000,
      buyerName: 'Peter Jones',
      paymentProofImageUrl: 'assets/images/placeholder.png',
    ),
  ];

  List<Purchase> getPurchases() {
    return _purchases;
  }

  List<Purchase> getPurchasesByBuyer(String buyerName) {
    return _purchases.where((p) => p.buyerName == buyerName).toList();
  }

  List<Purchase> getPendingVerificationPurchases() {
    return _purchases.where((p) => p.status == PurchaseStatus.pendingVerification).toList();
  }

  void addPurchaseFromCartItem({
    required CartItem cartItem,
    required String buyerName,
    required String address,
    required String phoneNumber,
    required String paymentProofImageUrl,
  }) {
    for (int i = 0; i < cartItem.quantity; i++) {
      final newPurchase = Purchase(
        id: (104 + _purchases.length + i).toString(),
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        price: cartItem.product.price,
        buyerName: buyerName,
        paymentProofImageUrl: paymentProofImageUrl,
      );
      _purchases.add(newPurchase);
    }
  }

  void verifyPaymentAndGenerateOtp(String purchaseId) {
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index != -1) {
      _purchases[index].status = PurchaseStatus.verifiedReadyForPickup;
      // Generate a random 6-digit OTP
      _purchases[index].otp = (100000 + Random().nextInt(900000)).toString();
    }
  }

  void rejectPayment(String purchaseId) {
    // In a real app, you might change the status to 'rejected' or remove it.
    // For this mock service, we'll just remove it from the list.
    _purchases.removeWhere((p) => p.id == purchaseId);
  }
}
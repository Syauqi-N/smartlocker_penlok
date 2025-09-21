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
      productName: 'Smartphone XYZ Pro',
      price: 150000,
      buyerName: 'Active Buyer',
      paymentProofImageUrl: 'assets/images/placeholder.png', // Placeholder for payment proof
    ),
    Purchase(
      id: '102',
      productId: '2',
      productName: 'Wireless Headphones Elite',
      price: 250000,
      buyerName: 'Active Buyer',
      paymentProofImageUrl: 'assets/images/placeholder.png',
      status: PurchaseStatus.verifiedReadyForPickup,
      otp: '583927',
    ),
    Purchase(
      id: '103',
      productId: '3',
      productName: 'Smart Watch Series 5',
      price: 75000,
      buyerName: 'Active Buyer',
      paymentProofImageUrl: 'assets/images/placeholder.png',
    ),
    Purchase(
      id: '104',
      productId: '4',
      productName: 'Bluetooth Speaker',
      price: 120000,
      buyerName: 'Active Buyer',
      paymentProofImageUrl: 'assets/images/placeholder.png',
      status: PurchaseStatus.verifiedReadyForPickup,
      otp: '918473',
    ),
    Purchase(
      id: '105',
      productId: '5',
      productName: 'Tablet 10 inch',
      price: 350000,
      buyerName: 'Active Buyer',
      paymentProofImageUrl: 'assets/images/placeholder.png',
      status: PurchaseStatus.verifiedReadyForPickup,
      otp: '264815',
    ),
  ];

  // Simple notification system for sellers
  final List<Map<String, dynamic>> _sellerNotifications = [
    {
      'id': '1',
      'title': 'New Order Received!',
      'message': 'Active Buyer purchased "Smartphone XYZ Pro"',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Payment Verified',
      'message': 'Payment for "Wireless Headphones Elite" has been verified',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': true,
    },
    {
      'id': '3',
      'title': 'Package Picked Up',
      'message': 'Active Buyer has picked up "Bluetooth Speaker" using OTP',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
    },
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

  List<Map<String, dynamic>> getSellerNotifications() {
    return _sellerNotifications;
  }

  void markNotificationAsRead(String notificationId) {
    final index = _sellerNotifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _sellerNotifications[index]['isRead'] = true;
    }
  }

  void addSellerNotification(String title, String message) {
    _sellerNotifications.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'timestamp': DateTime.now(),
      'isRead': false,
    });
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
        id: (106 + _purchases.length + i).toString(),
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        price: cartItem.product.price,
        buyerName: buyerName,
        paymentProofImageUrl: paymentProofImageUrl,
      );
      _purchases.add(newPurchase);
    }
  }

  void verifyPayment(String purchaseId) {
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index != -1) {
      _purchases[index].status = PurchaseStatus.paymentApproved;
      
      // Add notification
      addSellerNotification(
        'Payment Verified', 
        'Payment for "${_purchases[index].productName}" has been verified'
      );
    }
  }

  void generateOtp(String purchaseId) {
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index != -1) {
      _purchases[index].status = PurchaseStatus.verifiedReadyForPickup;
      // Generate a random 6-digit OTP
      _purchases[index].otp = (100000 + Random().nextInt(900000)).toString();
      
      // Add notification
      addSellerNotification(
        'OTP Generated', 
        'OTP for "${_purchases[index].productName}" is ready for pickup'
      );
    }
  }

  void verifyPaymentAndGenerateOtp(String purchaseId) {
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index != -1) {
      _purchases[index].status = PurchaseStatus.verifiedReadyForPickup;
      // Generate a random 6-digit OTP
      _purchases[index].otp = (100000 + Random().nextInt(900000)).toString();
      
      // Add notification
      addSellerNotification(
        'Payment Verified & OTP Generated', 
        'Payment verified and OTP for "${_purchases[index].productName}" is ready for pickup'
      );
    }
  }

  void rejectPayment(String purchaseId) {
    // Change the status to 'rejected' instead of removing it
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index != -1) {
      _purchases[index].status = PurchaseStatus.rejected;
      
      // Add notification
      addSellerNotification(
        'Payment Rejected', 
        'Payment for "${_purchases[index].productName}" has been rejected'
      );
    }
  }

  void markPurchaseAsCompleted(String purchaseId) {
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index != -1) {
      _purchases[index].status = PurchaseStatus.completed;
      
      // Add notification
      addSellerNotification(
        'Package Picked Up', 
        'Buyer has picked up "${_purchases[index].productName}" using OTP'
      );
    }
  }
}
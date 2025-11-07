import 'package:smartlocker/models/transaction.dart';

enum PackageStatus { inTransit, delivered, completed, failed }

class Package {
  Package({
    required this.id,
    required this.packageName,
    this.trackingNumber,
    this.courier,
    this.orderDate,
    this.deliveredDate,
    this.status = PackageStatus.inTransit,
    this.totalPrice,
    this.buyerName,
    this.buyerPhoneNumber,
    this.shippingAddress,
    this.transaction,
    List<PackageTrackingEvent>? trackingHistory,
  }) : trackingHistory = trackingHistory ?? [];

  final String id;
  final String packageName;
  final String? trackingNumber;
  final String? courier;
  final DateTime? orderDate;
  DateTime? deliveredDate;
  PackageStatus status;
  final double? totalPrice;
  final String? buyerName;
  final String? buyerPhoneNumber;
  final String? shippingAddress;
  final TransactionModel? transaction;
  final List<PackageTrackingEvent> trackingHistory;

  PackageTrackingEvent? get latestTrackingEvent {
    if (trackingHistory.isEmpty) return null;
    trackingHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return trackingHistory.first;
  }

  factory Package.fromTransaction(TransactionModel tx) {
    final history = _buildHistory(tx);
    return Package(
      id: tx.id.toString(),
      packageName: tx.product?.name ?? 'Transaction #${tx.id}',
      trackingNumber: tx.paymentGatewayId ?? 'TRX-${tx.id}',
      courier: tx.sellerName,
      orderDate: tx.createdAt,
      deliveredDate: tx.status == TransactionStatus.completed
          ? tx.updatedAt ?? tx.createdAt
          : null,
      status: _mapStatus(tx.status),
      totalPrice: tx.totalPrice,
      buyerName: tx.buyerFullName.isNotEmpty ? tx.buyerFullName : tx.buyerName,
      buyerPhoneNumber: tx.buyerPhoneNumber,
      shippingAddress: tx.shippingAddress,
      transaction: tx,
      trackingHistory: history,
    );
  }

  static PackageStatus _mapStatus(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return PackageStatus.completed;
      case TransactionStatus.released:
      case TransactionStatus.awaitingPickup:
        return PackageStatus.delivered;
      case TransactionStatus.failed:
      case TransactionStatus.rejected:
        return PackageStatus.failed;
      case TransactionStatus.pending:
      case TransactionStatus.escrow:
      case TransactionStatus.paid:
        return PackageStatus.inTransit;
    }
  }

  static List<PackageTrackingEvent> _buildHistory(TransactionModel tx) {
    final events = <PackageTrackingEvent>[];
    final createdAt = tx.createdAt ?? DateTime.now();
    events.add(
      PackageTrackingEvent(
        location: 'SmartLocker System',
        description: 'Order created',
        timestamp: createdAt,
        status: tx.status.name.toUpperCase(),
      ),
    );
    if (tx.status == TransactionStatus.awaitingPickup ||
        tx.status == TransactionStatus.released) {
      events.add(
        PackageTrackingEvent(
          location: 'Locker',
          description: 'Order ready for pickup',
          timestamp: tx.updatedAt ?? createdAt,
          status: 'READY_FOR_PICKUP',
        ),
      );
    }
    if (tx.status == TransactionStatus.completed) {
      events.add(
        PackageTrackingEvent(
          location: 'Locker',
          description: 'Order picked up',
          timestamp: tx.updatedAt ?? DateTime.now(),
          status: 'COMPLETED',
        ),
      );
    }
    return events;
  }
}

class PackageNotification {
  PackageNotification({
    required this.package,
    required this.timestamp,
    required this.isRead,
  });

  final Package package;
  final DateTime timestamp;
  final bool isRead;
}

class PackageTrackingEvent {
  final String location;
  final String description;
  final DateTime timestamp;
  final String status;

  PackageTrackingEvent({
    required this.location,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}

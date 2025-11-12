enum PackageStatus { registered, inTransit, delivered }

PackageStatus packageStatusFromString(String? value) {
  switch (value) {
    case 'IN_TRANSIT':
      return PackageStatus.inTransit;
    case 'DELIVERED':
      return PackageStatus.delivered;
    case 'REGISTERED':
    default:
      return PackageStatus.registered;
  }
}

extension PackageStatusExtension on PackageStatus {
  String get label {
    switch (this) {
      case PackageStatus.registered:
        return 'Registered';
      case PackageStatus.inTransit:
        return 'In Transit';
      case PackageStatus.delivered:
        return 'Delivered';
    }
  }

  String get apiValue {
    switch (this) {
      case PackageStatus.registered:
        return 'REGISTERED';
      case PackageStatus.inTransit:
        return 'IN_TRANSIT';
      case PackageStatus.delivered:
        return 'DELIVERED';
    }
  }
}

class Package {
  Package({
    required this.id,
    required this.packageName,
    required this.trackingNumber,
    this.courier,
    this.orderDate,
    this.deliveredDate,
    this.status = PackageStatus.registered,
    this.lockerSlot,
    this.receiverName,
    this.receiverPhone,
    this.notes,
  });

  final int id;
  final String packageName;
  final String trackingNumber;
  final String? courier;
  final DateTime? orderDate;
  final DateTime? deliveredDate;
  final PackageStatus status;
  final String? lockerSlot;
  final String? receiverName;
  final String? receiverPhone;
  final String? notes;

  factory Package.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return Package(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      packageName: json['package_name']?.toString() ?? '-',
      trackingNumber: json['tracking_number']?.toString() ?? '-',
      courier: json['courier']?.toString(),
      orderDate: parseDate(json['order_date']),
      deliveredDate: parseDate(json['delivered_date']),
      status: packageStatusFromString(json['status']?.toString()),
      lockerSlot: json['locker_slot']?.toString(),
      receiverName: json['receiver_name']?.toString(),
      receiverPhone: json['receiver_phone']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_name': packageName,
      'tracking_number': trackingNumber,
      if (courier != null) 'courier': courier,
      if (orderDate != null) 'order_date': orderDate!.toIso8601String(),
      if (deliveredDate != null)
        'delivered_date': deliveredDate!.toIso8601String(),
      'status': status.apiValue,
      if (lockerSlot != null) 'locker_slot': lockerSlot,
      if (receiverName != null) 'receiver_name': receiverName,
      if (receiverPhone != null) 'receiver_phone': receiverPhone,
      if (notes != null) 'notes': notes,
    };
  }
}

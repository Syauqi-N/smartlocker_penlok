import 'dart:math';
import 'package:smartlocker/models/package.dart';

class PackageService {
  static final PackageService _instance = PackageService._internal();
  factory PackageService() => _instance;
  PackageService._internal();

  final List<Package> _packages = [
    Package(
      id: '1',
      trackingNumber: 'JP1234567890',
      packageName: 'Smartphone XYZ Pro',
      courier: 'JNE',
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      deliveredDate: DateTime.now().subtract(const Duration(days: 1)),
      status: PackageStatus.delivered,
      trackingHistory: [
        PackageTrackingEvent(
          location: 'Jakarta Warehouse',
          description: 'Package received at warehouse',
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
          status: 'Received',
        ),
        PackageTrackingEvent(
          location: 'Bandung Distribution Center',
          description: 'Package in transit to destination',
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          status: 'In Transit',
        ),
        PackageTrackingEvent(
          location: 'Bandung Local Facility',
          description: 'Package out for delivery',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          status: 'Out for Delivery',
        ),
        PackageTrackingEvent(
          location: 'SmartLocker Station',
          description: 'Package delivered to smart locker',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Delivered',
        ),
      ],
    ),
    Package(
      id: '2',
      trackingNumber: 'JP0987654321',
      packageName: 'Wireless Headphones Elite',
      courier: 'POS Indonesia',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: PackageStatus.inTransit,
      trackingHistory: [
        PackageTrackingEvent(
          location: 'Surabaya Warehouse',
          description: 'Package received at warehouse',
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
          status: 'Received',
        ),
        PackageTrackingEvent(
          location: 'Jakarta Sorting Center',
          description: 'Package being sorted for delivery',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
          status: 'Processing',
        ),
      ],
    ),
    Package(
      id: '3',
      trackingNumber: 'JP1122334455',
      packageName: 'Smart Watch Series 5',
      courier: 'J&T Express',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      deliveredDate: DateTime.now().subtract(const Duration(days: 2)),
      status: PackageStatus.completed,
      trackingHistory: [
        PackageTrackingEvent(
          location: 'Medan Warehouse',
          description: 'Package received at warehouse',
          timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
          status: 'Received',
        ),
        PackageTrackingEvent(
          location: 'Jakarta Hub',
          description: 'Package in transit',
          timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
          status: 'In Transit',
        ),
        PackageTrackingEvent(
          location: 'Tangerang Facility',
          description: 'Package out for delivery',
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 9)),
          status: 'Out for Delivery',
        ),
        PackageTrackingEvent(
          location: 'SmartLocker Station',
          description: 'Package delivered to smart locker',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          status: 'Delivered',
        ),
        PackageTrackingEvent(
          location: 'SmartLocker Station',
          description: 'Package picked up by recipient',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Completed',
        ),
      ],
    ),
  ];

  List<Package> getPackages() {
    return _packages;
  }

  List<Package> getActivePackages() {
    return _packages.where((p) => p.status == PackageStatus.inTransit || p.status == PackageStatus.delivered).toList();
  }

  List<Package> getCompletedPackages() {
    return _packages.where((p) => p.status == PackageStatus.completed).toList();
  }

  void addPackage(String trackingNumber, String packageName, {String? courier, DateTime? orderDate}) {
    final newPackage = Package(
      id: Random().nextInt(10000).toString(),
      trackingNumber: trackingNumber,
      packageName: packageName,
      courier: courier,
      orderDate: orderDate,
    );
    _packages.add(newPackage);
  }

  Package? getPackageById(String id) {
    try {
      return _packages.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void updatePackage(String id, String trackingNumber, String packageName, {String? courier, DateTime? orderDate}) {
    final index = _packages.indexWhere((p) => p.id == id);
    if (index != -1) {
      _packages[index] = Package(
        id: id,
        trackingNumber: trackingNumber,
        packageName: packageName,
        courier: courier,
        orderDate: orderDate,
        status: _packages[index].status,
        deliveredDate: _packages[index].deliveredDate,
        trackingHistory: _packages[index].trackingHistory,
      );
    }
  }

  void deletePackage(String id) {
    _packages.removeWhere((p) => p.id == id);
  }

  void updatePackageStatus(String id, PackageStatus status) {
    final index = _packages.indexWhere((p) => p.id == id);
    if (index != -1) {
      _packages[index].status = status;
      if (status == PackageStatus.delivered) {
        _packages[index].deliveredDate = DateTime.now();
      }
    }
  }
}
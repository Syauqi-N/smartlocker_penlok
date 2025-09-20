import 'dart:math';
import 'package:smartlocker/models/package.dart';

class PackageService {
  static final PackageService _instance = PackageService._internal();
  factory PackageService() => _instance;
  PackageService._internal();

  final List<Package> _packages = [
    Package(id: '1', trackingNumber: 'JP1234567890', packageName: 'Buku Flutter', status: PackageStatus.inTransit),
    Package(id: '2', trackingNumber: 'JP0987654321', packageName: 'Keyboard Mechanical', status: PackageStatus.delivered),
    Package(id: '3', trackingNumber: 'JP1122334455', packageName: 'Mouse Gaming', status: PackageStatus.completed),
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

  void addPackage(String trackingNumber, String packageName) {
    final newPackage = Package(
      id: Random().nextInt(10000).toString(),
      trackingNumber: trackingNumber,
      packageName: packageName,
    );
    _packages.add(newPackage);
  }
}
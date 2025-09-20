enum PackageStatus { inTransit, delivered, completed }

class Package {
  final String id;
  final String trackingNumber;
  final String packageName;
  PackageStatus status;

  Package({
    required this.id,
    required this.trackingNumber,
    required this.packageName,
    this.status = PackageStatus.inTransit,
  });
}

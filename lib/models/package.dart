enum PackageStatus { inTransit, delivered, completed }

class Package {
  final String id;
  final String trackingNumber;
  final String packageName;
  final String? courier;
  final DateTime? orderDate;
  DateTime? deliveredDate;
  final List<PackageTrackingEvent> trackingHistory;
  PackageStatus status;

  Package({
    required this.id,
    required this.trackingNumber,
    required this.packageName,
    this.courier,
    this.orderDate,
    this.deliveredDate,
    this.status = PackageStatus.inTransit,
    List<PackageTrackingEvent>? trackingHistory,
  }) : trackingHistory = trackingHistory ?? [];

  // Helper method to get the latest tracking event
  PackageTrackingEvent? get latestTrackingEvent {
    if (trackingHistory.isEmpty) return null;
    trackingHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return trackingHistory.first;
  }
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

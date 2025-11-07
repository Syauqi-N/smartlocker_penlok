enum AccessMode {
  manual,
  automatic,
}

extension AccessModeLabel on AccessMode {
  String get label {
    switch (this) {
      case AccessMode.manual:
        return 'Manual';
      case AccessMode.automatic:
        return 'Otomatis';
    }
  }
}

class AccessLog {
  AccessLog({
    required this.id,
    required this.lockerId,
    required this.receiverName,
    required this.mode,
    required this.capturedAt,
    this.imageUrl,
    this.details,
  });

  final String id;
  final String lockerId;
  final String receiverName;
  final AccessMode mode;
  final DateTime capturedAt;
  final String? imageUrl;
  final String? details;

  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      id: json['id']?.toString() ?? '',
      lockerId: json['locker'] is Map
          ? (json['locker']['number']?.toString() ?? '')
          : json['locker_id']?.toString() ?? '',
      receiverName: _resolveName(json),
      mode: _modeFromString(json['action'] ?? json['mode']),
      capturedAt: DateTime.tryParse(json['timestamp']?.toString() ??
              json['captured_at']?.toString() ??
              '') ??
          DateTime.now(),
      imageUrl: json['image_url']?.toString(),
      details: json['details']?.toString(),
    );
  }

  static String _resolveName(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is Map && user['username'] != null) {
      return user['username'].toString();
    }
    return json['receiver_name']?.toString() ?? 'Unknown';
  }

  static AccessMode _modeFromString(Object? value) {
    final raw = (value ?? '').toString().toLowerCase();
    switch (raw) {
      case 'manual':
      case 'retrieve':
        return AccessMode.manual;
      case 'automatic':
      case 'auto':
      case 'deposit':
      case 'open':
        return AccessMode.automatic;
      default:
        return AccessMode.manual;
    }
  }
}

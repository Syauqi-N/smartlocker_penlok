class StoreSummary {
  const StoreSummary({
    required this.id,
    required this.name,
    required this.ownerName,
    this.location,
    this.description,
  });

  final int id;
  final String name;
  final String ownerName;
  final String? location;
  final String? description;

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    return StoreSummary(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      ownerName: owner?['username']?.toString() ??
          owner?['email']?.toString() ??
          'Seller',
      location: json['location']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

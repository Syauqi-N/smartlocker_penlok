class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  final int id;
  final String username;
  final String email;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      username: json['username']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      role: json['role']?.toString() ?? 'buyer',
    );
  }

  bool get isOwner =>
      role.toLowerCase() == 'owner' || role.toLowerCase() == 'seller';

  bool get isBuyer => role.toLowerCase() == 'buyer';

  String get displayRole {
    if (isOwner) return 'Owner / Seller';
    if (isBuyer) return 'Buyer';
    return role.isEmpty ? '-' : role;
  }
}

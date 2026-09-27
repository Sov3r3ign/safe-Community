class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String verificationStatus;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.verificationStatus = 'not_required',
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? 'SafeZone User') as String,
      role: (json['role'] ?? 'resident') as String,
      phone: json['phone'] as String?,
      verificationStatus: (json['verification_status'] ?? 'not_required') as String,
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
    );
  }
}

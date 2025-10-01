
class UserProfile {
  final int id;
  final String? phone; // Optional in backend
  final String email; // Required in backend
  final String? pseudonym;
  final String? photoUrl;
  final bool? is2faEnabled;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    this.phone,
    required this.email,
    this.pseudonym,
    this.photoUrl,
    this.is2faEnabled,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      phone: json['phone'],
      email: json['email'],
      pseudonym: json['pseudonym'],
      photoUrl: json['photo_url'],
      is2faEnabled: json['is_2fa_enabled'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'pseudonym': pseudonym,
      'photo_url': photoUrl,
      'is_2fa_enabled': is2faEnabled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

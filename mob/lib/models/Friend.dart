
class UserFriend {
  final int id;
  final int userId;
  final int friendId;
  final DateTime createdAt;
  final String email; // Optional: add email if needed

  UserFriend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
    this.email = '',
  });

  factory UserFriend.fromJson(Map<String, dynamic> json) {
    return UserFriend(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      friendId: json['friend_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

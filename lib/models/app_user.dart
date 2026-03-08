// lib/models/user_model.dart

class AppUser {
  final String uid;
  final String name;
  final String role; // 'user' or 'host'
  final int coins;
  final bool isOnline;

  AppUser({
    required this.uid,
    required this.name,
    this.role = 'user',
    this.coins = 0,
    this.isOnline = true,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
      'coins': coins,
      'isOnline': isOnline,
    };
  }

  // Create from Firestore Document
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      role: map['role'] as String? ?? 'user',
      coins: map['coins'] as int? ?? 0,
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }
}
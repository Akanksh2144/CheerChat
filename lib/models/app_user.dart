// lib/models/app_user.dart
//
// Mirrors the `users` + `user_profiles` tables in schema_v9.
// This model is the single source of truth for the logged-in user
// throughout the Flutter app.
//
// IMPORTANT — Coin balance:
//   `coins` here is a LOCAL DISPLAY COPY only.
//   The authoritative balance lives in `wallet_balances` on the server.
//   Always re-fetch from GET /api/me after any transaction.

class AppUser {
  const AppUser({
    required this.uid,
    required this.publicId,
    required this.displayName,
    required this.countryCode,
    required this.language,
    required this.gender,
    required this.role,
    required this.level,
    required this.coins,
    required this.isOnline,
    required this.isHost,
    this.profilePhotoUrl,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.createdAt,
  });

  // ── Identity ─────────────────────────────────────────────────────────────
  /// Firebase UID — used for auth only, never shown in UI.
  final String uid;

  /// 8-digit public display ID (e.g. 10042837).
  /// Shown on profile cards; used for friend search.
  final int publicId;

  // ── Display ───────────────────────────────────────────────────────────────
  final String displayName;
  final String? profilePhotoUrl;
  final String? bio;

  // ── Contact ───────────────────────────────────────────────────────────────
  final String? email;
  final String? phoneNumber;

  // ── Profile attributes ────────────────────────────────────────────────────
  /// ISO 3166-1 alpha-2, e.g. "IN", "PK", "BD".
  final String countryCode;

  /// Primary language, e.g. "Hindi", "English".
  final String language;

  /// "female" | "male" | "other"
  final String gender;

  final DateTime? dateOfBirth;

  // ── Role & progression ────────────────────────────────────────────────────
  /// "user" or "host"
  final String role;

  /// User level 1–8. Matches level_definitions seed in schema_v9.
  final int level;

  // ── Wallet ────────────────────────────────────────────────────────────────
  /// LOCAL DISPLAY COPY — not authoritative. Sync from GET /api/me.
  final int coins;

  // ── Status ────────────────────────────────────────────────────────────────
  final bool isOnline;

  /// True if user has an approved host profile.
  final bool isHost;

  // ── Timestamps ────────────────────────────────────────────────────────────
  final DateTime? createdAt;

  // ── Derived helpers ───────────────────────────────────────────────────────

  /// Age in full years, or null if DOB not set.
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int years = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month &&
            today.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  /// Level label matching level_definitions in schema_v9.
  String get levelLabel {
    const labels = {
      1: 'Newcomer',
      2: 'Rising Star',
      3: 'Popular',
      4: 'Trending',
      5: 'Expert',
      6: 'Pro',
      7: 'Elite',
      8: 'Legend',
    };
    return labels[level] ?? 'Lv $level';
  }

  /// Short display name for tight spaces (truncated to 12 chars).
  String get shortName => displayName.length > 12
      ? '${displayName.substring(0, 12)}…'
      : displayName;

  // ── Serialisation ─────────────────────────────────────────────────────────

  /// Deserialise from the `GET /api/me` response JSON.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String? ?? '',
      // publicId: json['public_id'] as int? ?? 0,
      publicId: json['public_id'] is int
          ? json['public_id'] as int
          : int.tryParse(json['public_id'].toString()) ?? 0,
      displayName: json['display_name'] as String? ?? 'User',
      profilePhotoUrl: json['profile_photo_url'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      countryCode: json['country_code'] as String? ?? 'IN',
      language: json['language'] as String? ?? 'English',
      gender: json['gender'] as String? ?? 'other',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      role: json['role'] as String? ?? 'user',
      // level: json['level'] as int? ?? 1,
      level: json['level'] is int
          ? json['level'] as int
          : int.tryParse(json['level'].toString()) ?? 0,
      // coins: json['coins'] as int? ?? 0,
      coins: json['coins'] is int
          ? json['coins'] as int
          : int.tryParse(json['coins'].toString()) ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      isHost: json['is_host'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Serialise for `POST /api/auth/register` and `PUT /api/me`.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'public_id': publicId,
      'display_name': displayName,
      'profile_photo_url': profilePhotoUrl,
      'bio': bio,
      'email': email,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'language': language,
      'gender': gender,
      'date_of_birth': dateOfBirth
          ?.toIso8601String()
          .split('T')
          .first,
      'role': role,
      'level': level,
      'coins': coins,
      'is_online': isOnline,
      'is_host': isHost,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // ── Mutation ──────────────────────────────────────────────────────────────

  /// Returns a new instance with the specified fields replaced.
  /// Use this after a successful API call to update local state.
  AppUser copyWith({
    String? uid,
    int? publicId,
    String? displayName,
    String? profilePhotoUrl,
    String? bio,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? language,
    String? gender,
    DateTime? dateOfBirth,
    String? role,
    int? level,
    int? coins,
    bool? isOnline,
    bool? isHost,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      publicId: publicId ?? this.publicId,
      displayName: displayName ?? this.displayName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      language: language ?? this.language,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      isOnline: isOnline ?? this.isOnline,
      isHost: isHost ?? this.isHost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convenience: add or subtract coins without touching other fields.
  /// Pass a negative value to deduct.
  AppUser withCoins(int delta) => copyWith(coins: coins + delta);

  @override
  String toString() =>
      'AppUser(uid: $uid, displayName: $displayName, coins: $coins, role: $role)';
}

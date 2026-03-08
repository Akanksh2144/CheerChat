// lib/models/host_model.dart
//
// Mirrors the `active_hosts` view in schema_v9:
//   user_id, display_name, profile_photo_url, country,
//   language, price_coins, level, is_online, last_online_at
//
// Also carries derived UI fields (age from DOB, status).

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Status — derived from is_online + whether host is in an active call
// ---------------------------------------------------------------------------
enum HostStatus { online, busy, offline }

Color getStatusColor(HostStatus status) {
  switch (status) {
    case HostStatus.online:
      return const Color(0xFF4CAF50); // green
    case HostStatus.busy:
      return const Color(0xFFF44336); // red
    case HostStatus.offline:
      return const Color(0xFFBDBDBD); // grey
  }
}

// ---------------------------------------------------------------------------
// HostModel
// ---------------------------------------------------------------------------
class HostModel {
  const HostModel({
    required this.userId,
    required this.publicId,
    required this.displayName,
    required this.countryCode, // ISO 3166-1 alpha-2, e.g. "IN"
    required this.language, // e.g. "Hindi"
    required this.priceCoins, // coins per minute
    required this.level, // 1–8
    required this.status,
    this.profilePhotoUrl,
    this.bio,
    this.dateOfBirth,
    this.lastOnlineAt,
  });

  final String userId; // UUID from PostgreSQL
  final int publicId; // 8-digit public ID
  final String displayName;
  final String countryCode;
  final String language;
  final int priceCoins;
  final int level;
  final HostStatus status;
  final String? profilePhotoUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final DateTime? lastOnlineAt;

  // ---------------------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------------------

  /// Returns age in years, or null if DOB not set.
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

  /// Convenience: is the host reachable right now?
  bool get isCallable => status == HostStatus.online;

  /// Level label — matches level_definitions seed data in schema_v9.
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

  /// Flag code for the `flag` package.
  FlagsCode get flagCode {
    const map = {
      'IN': FlagsCode.IN,
      'BD': FlagsCode.BD,
      'PK': FlagsCode.PK,
      'AR': FlagsCode.AR,
      'AU': FlagsCode.AU,
      'BR': FlagsCode.BR,
      'BH': FlagsCode.BH,
      'CA': FlagsCode.CA,
      'CO': FlagsCode.CO,
      'EG': FlagsCode.EG,
      'DE': FlagsCode.DE,
      'ID': FlagsCode.ID,
      'MA': FlagsCode.MA,
      'NP': FlagsCode.NP,
      'PH': FlagsCode.PH,
      'SA': FlagsCode.SA,
      'TR': FlagsCode.TR,
      'US': FlagsCode.US,
      'GB': FlagsCode.GB,
      'AE': FlagsCode.AE,
      'UA': FlagsCode.UA,
      'VE': FlagsCode.VE,
      'VN': FlagsCode.VN,
    };
    return map[countryCode] ?? FlagsCode.UN;
  }

  // ---------------------------------------------------------------------------
  // Serialisation — for when the API layer is wired up
  // ---------------------------------------------------------------------------

  /// Maps directly to the JSON shape returned by the Node.js
  /// GET /hosts endpoint (which queries the `active_hosts` view).
  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      userId: json['user_id'] as String,
      publicId: json['public_id'] as int,
      displayName: json['display_name'] as String,
      countryCode:
          (json['country'] as String?)?.toUpperCase() ?? 'UN',
      language: json['language'] as String? ?? '',
      priceCoins: json['price_coins'] as int? ?? 50,
      level: json['level'] as int? ?? 1,
      status: _statusFromJson(
        json['is_online'],
        json['is_busy'],
      ),
      profilePhotoUrl: json['profile_photo_url'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      lastOnlineAt: json['last_online_at'] != null
          ? DateTime.tryParse(json['last_online_at'] as String)
          : null,
    );
  }

  static HostStatus _statusFromJson(
    dynamic isOnline,
    dynamic isBusy,
  ) {
    if (isOnline == true && isBusy == true)
      return HostStatus.busy;
    if (isOnline == true) return HostStatus.online;
    return HostStatus.offline;
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'public_id': publicId,
    'display_name': displayName,
    'country': countryCode,
    'language': language,
    'price_coins': priceCoins,
    'level': level,
    'is_online': status != HostStatus.offline,
    'is_busy': status == HostStatus.busy,
    'profile_photo_url': profilePhotoUrl,
    'bio': bio,
    'date_of_birth': dateOfBirth?.toIso8601String(),
    'last_online_at': lastOnlineAt?.toIso8601String(),
  };

  HostModel copyWith({
    String? userId,
    int? publicId,
    String? displayName,
    String? countryCode,
    String? language,
    int? priceCoins,
    int? level,
    HostStatus? status,
    String? profilePhotoUrl,
    String? bio,
    DateTime? dateOfBirth,
    DateTime? lastOnlineAt,
  }) {
    return HostModel(
      userId: userId ?? this.userId,
      publicId: publicId ?? this.publicId,
      displayName: displayName ?? this.displayName,
      countryCode: countryCode ?? this.countryCode,
      language: language ?? this.language,
      priceCoins: priceCoins ?? this.priceCoins,
      level: level ?? this.level,
      status: status ?? this.status,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
    );
  }
}

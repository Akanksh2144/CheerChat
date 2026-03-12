// // lib/providers/user_provider.dart
// //
// // Riverpod v2 state for the currently signed-in user (AppUser).
// //
// // Load order:
// //   1. GET /api/me from server (10s timeout)
// //   2. Server 404 → check cache anyway (user registered offline before)
// //   3. API unreachable → fall back to SharedPreferences cache
// //   4. No cache and 404 → return null → AuthGate shows ProfileSetupScreen
// //
// // Cache key: cheerchat_user_<uid>  →  JSON AppUser
// //
// // ── WHY clear() does NOT wipe the cache ──────────────────────────────────────
// // Previous bug: clear() called prefs.remove() on logout.
// // On next sign-in, if backend was still offline → cache gone → ProfileSetup shown again.
// // Fix: clear() only nulls the in-memory Riverpod state.
// // The disk cache is preserved so returning users are never asked to re-register.
// // ─────────────────────────────────────────────────────────────────────────────

// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:cheerchat/constants/app_constants.dart';
// import 'package:cheerchat/models/app_user.dart';
// import 'package:cheerchat/providers/auth_provider.dart';
// import 'package:cheerchat/providers/user_provider.dart';

// // ─────────────────────────────────────────────────────────────────────────────

// final currentUserProvider =
//     AsyncNotifierProvider<CurrentUserNotifier, AppUser?>(
//       CurrentUserNotifier.new,
//     );

// // ─────────────────────────────────────────────────────────────────────────────

// class CurrentUserNotifier extends AsyncNotifier<AppUser?> {
//   static const _prefix = 'cheerchat_user_';

//   @override
//   Future<AppUser?> build() async {
//     final fbUser = await ref.watch(authStateProvider.future);
//     if (fbUser == null) return null;
//     // Anonymous users are now removed — same profile load path for all real users.
//     return _loadUser(fbUser);
//   }

//   // ── Load ──────────────────────────────────────────────────────────────────

//   Future<AppUser?> _loadUser(User fbUser) async {
//     try {
//       final serverUser = await _fetchFromServer(fbUser);
//       if (serverUser != null) {
//         await _cache(fbUser.uid, serverUser);
//         return serverUser;
//       }
//       // 404 — but user may have registered offline before; check cache first.
//       final cached = await _fromCache(fbUser.uid);
//       if (cached != null) {
//         debugPrint(
//           '[UserProvider] Server 404 but cache found — using cache.',
//         );
//         return cached;
//       }
//       return null; // genuinely new user → ProfileSetup
//     } catch (e) {
//       debugPrint(
//         '[UserProvider] API unreachable, trying cache: $e',
//       );
//       return _fromCache(fbUser.uid);
//     }
//   }

//   Future<AppUser?> _fetchFromServer(User fbUser) async {
//     final token = await fbUser.getIdToken();
//     final res = await http
//         .get(
//           Uri.parse('${AppConstants.apiBaseUrl}/api/me'),
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         )
//         .timeout(const Duration(seconds: 10));

//     if (res.statusCode == 200) {
//       return AppUser.fromJson(
//         jsonDecode(res.body) as Map<String, dynamic>,
//       );
//     }
//     if (res.statusCode == 404) return null;
//     debugPrint('[UserProvider] GET /api/me → ${res.statusCode}');
//     return null;
//   }

//   // ── Cache (read/write only — never delete) ────────────────────────────────

//   Future<void> _cache(String uid, AppUser user) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(
//         _prefix + uid,
//         jsonEncode(user.toJson()),
//       );
//     } catch (e) {
//       debugPrint('[UserProvider] Cache write failed: $e');
//     }
//   }

//   Future<AppUser?> _fromCache(String uid) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString(_prefix + uid);
//       if (raw == null) return null;
//       debugPrint('[UserProvider] Loaded from cache.');
//       return AppUser.fromJson(
//         jsonDecode(raw) as Map<String, dynamic>,
//       );
//     } catch (e) {
//       debugPrint('[UserProvider] Cache read failed: $e');
//       return null;
//     }
//   }

//   // ── Public API ────────────────────────────────────────────────────────────

//   Future<void> refresh() async {
//     final fbUser = FirebaseAuth.instance.currentUser;
//     if (fbUser == null) {
//       state = const AsyncData(null);
//       return;
//     }
//     state = const AsyncLoading();
//     state = AsyncData(await _loadUser(fbUser));
//   }

//   void addCoins(int delta) {
//     final u = state.asData?.value;
//     if (u == null) return;
//     state = AsyncData(u.withCoins(delta));
//   }

//   void setUser(AppUser user) => state = AsyncData(user);

//   /// Signals an auth transition — sets AsyncLoading (no value) so AuthGate
//   /// shows the splash screen during logout/re-login instead of ProfileSetupScreen.
//   /// Intentionally does NOT touch the SharedPreferences disk cache.
//   Future<void> clear() async {
//     state = const AsyncLoading();
//   }

//   // ── Registration ──────────────────────────────────────────────────────────

//   Future<AppUser?> register({
//     required String displayName,
//     required String countryCode,
//     required String language,
//     required String gender,
//     DateTime? dateOfBirth,
//     String? profilePhotoUrl,
//   }) async {
//     final fbUser = FirebaseAuth.instance.currentUser;
//     if (fbUser == null) return null;

//     final localUser = AppUser(
//       uid: fbUser.uid,
//       publicId: 0,
//       displayName: displayName,
//       countryCode: countryCode,
//       language: language,
//       gender: gender,
//       role: 'user',
//       level: 1,
//       coins: 0,
//       isOnline: true,
//       isHost: false,
//       profilePhotoUrl: profilePhotoUrl,
//       phoneNumber: fbUser.phoneNumber,
//       email: fbUser.email,
//       dateOfBirth: dateOfBirth,
//       createdAt: DateTime.now(),
//     );

//     try {
//       final token = await fbUser.getIdToken();
//       final res = await http
//           .post(
//             Uri.parse(
//               '${AppConstants.apiBaseUrl}/api/auth/register',
//             ),
//             headers: {
//               'Authorization': 'Bearer $token',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode({
//               'uid': fbUser.uid,
//               'display_name': displayName,
//               'country_code': countryCode,
//               'language': language,
//               'gender': gender,
//               if (dateOfBirth != null)
//                 'date_of_birth': dateOfBirth
//                     .toIso8601String()
//                     .split('T')
//                     .first,
//               if (profilePhotoUrl != null)
//                 'profile_photo_url': profilePhotoUrl,
//               if (fbUser.email != null) 'email': fbUser.email,
//               if (fbUser.phoneNumber != null)
//                 'phone_number': fbUser.phoneNumber,
//             }),
//           )
//           .timeout(const Duration(seconds: 10));

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         final serverUser = AppUser.fromJson(
//           jsonDecode(res.body) as Map<String, dynamic>,
//         );
//         await _cache(fbUser.uid, serverUser);
//         state = AsyncData(serverUser);
//         return serverUser;
//       }
//       debugPrint('[UserProvider] Register → ${res.statusCode}');
//     } catch (e) {
//       debugPrint('[UserProvider] Register offline fallback: $e');
//     }

//     // Offline: save locally and proceed
//     await _cache(fbUser.uid, localUser);
//     state = AsyncData(localUser);
//     return localUser;
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Selectors
// // ─────────────────────────────────────────────────────────────────────────────

// final coinBalanceProvider = Provider<int>((ref) {
//   return ref.watch(currentUserProvider).asData?.value?.coins ??
//       0;
// });

// final displayNameProvider = Provider<String>((ref) {
//   return ref
//           .watch(currentUserProvider)
//           .asData
//           ?.value
//           ?.displayName ??
//       '';
// });

// final isUserReadyProvider = Provider<bool>((ref) {
//   final val = ref.watch(currentUserProvider);
//   return val is AsyncData && val.value != null;
// });
// lib/providers/user_provider.dart
//
// Riverpod v2 state for the currently signed-in user (AppUser).
//
// Load order:
//   1. GET /api/me from server (10s timeout)
//   2. Server 404 → check cache anyway (user registered offline before)
//   3. API unreachable → fall back to SharedPreferences cache
//   4. No cache and 404 → return null → AuthGate shows ProfileSetupScreen
//
// Cache key: cheerchat_user_<uid>  →  JSON AppUser
//
// ── WHY clear() does NOT wipe the cache ──────────────────────────────────────
// Previous bug: clear() called prefs.remove() on logout.
// On next sign-in, if backend was still offline → cache gone → ProfileSetup shown again.
// Fix: clear() only nulls the in-memory Riverpod state.
// The disk cache is preserved so returning users are never asked to re-register.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cheerchat/constants/app_constants.dart';
import 'package:cheerchat/models/app_user.dart';
import 'package:cheerchat/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, AppUser?>(
      CurrentUserNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────

class CurrentUserNotifier extends AsyncNotifier<AppUser?> {
  static const _prefix = 'cheerchat_user_';

  @override
  Future<AppUser?> build() async {
    final fbUser = await ref.watch(authStateProvider.future);
    if (fbUser == null) return null;
    // Anonymous users are now removed — same profile load path for all real users.
    return _loadUser(fbUser);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<AppUser?> _loadUser(User fbUser) async {
    try {
      final serverUser = await _fetchFromServer(fbUser);
      if (serverUser != null) {
        await _cache(fbUser.uid, serverUser);
        return serverUser;
      }
      // 404 — but user may have registered offline before; check cache first.
      final cached = await _fromCache(fbUser.uid);
      if (cached != null) {
        debugPrint(
          '[UserProvider] Server 404 but cache found — using cache.',
        );
        return cached;
      }
      return null; // genuinely new user → ProfileSetup
    } catch (e) {
      debugPrint(
        '[UserProvider] API unreachable, trying cache: $e',
      );
      return _fromCache(fbUser.uid);
    }
  }

  Future<AppUser?> _fetchFromServer(User fbUser) async {
    final token = await fbUser.getIdToken();
    final res = await http
        .get(
          Uri.parse('${AppConstants.apiBaseUrl}/api/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      return AppUser.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    }
    if (res.statusCode == 404) return null;
    debugPrint('[UserProvider] GET /api/me → ${res.statusCode}');
    return null;
  }

  // ── Cache (read/write only — never delete) ────────────────────────────────

  Future<void> _cache(String uid, AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefix + uid,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      debugPrint('[UserProvider] Cache write failed: $e');
    }
  }

  Future<AppUser?> _fromCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefix + uid);
      if (raw == null) return null;
      debugPrint('[UserProvider] Loaded from cache.');
      return AppUser.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('[UserProvider] Cache read failed: $e');
      return null;
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    state = AsyncData(await _loadUser(fbUser));
  }

  void addCoins(int delta) {
    final u = state.asData?.value;
    if (u == null) return;
    state = AsyncData(u.withCoins(delta));
  }

  void setUser(AppUser user) => state = AsyncData(user);

  /// Signals an auth transition — sets AsyncLoading (no value) so AuthGate
  /// shows the splash screen during logout/re-login instead of ProfileSetupScreen.
  /// Intentionally does NOT touch the SharedPreferences disk cache.
  Future<void> clear() async {
    state = const AsyncLoading();
  }

  // ── Registration ──────────────────────────────────────────────────────────

  Future<AppUser?> register({
    required String displayName,
    required String countryCode,
    required String language,
    required String gender,
    DateTime? dateOfBirth,
    String? profilePhotoUrl,
  }) async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) return null;

    final localUser = AppUser(
      uid: fbUser.uid,
      publicId: 0,
      displayName: displayName,
      countryCode: countryCode,
      language: language,
      gender: gender,
      role: 'user',
      level: 1,
      coins: 0,
      isOnline: true,
      isHost: false,
      profilePhotoUrl: profilePhotoUrl,
      phoneNumber: fbUser.phoneNumber,
      email: fbUser.email,
      dateOfBirth: dateOfBirth,
      createdAt: DateTime.now(),
    );

    try {
      final token = await fbUser.getIdToken();
      final res = await http
          .post(
            Uri.parse(
              '${AppConstants.apiBaseUrl}/api/auth/register',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'uid': fbUser.uid,
              'display_name': displayName,
              'country_code': countryCode,
              'language': language,
              'gender': gender,
              if (dateOfBirth != null)
                'date_of_birth': dateOfBirth
                    .toIso8601String()
                    .split('T')
                    .first,
              if (profilePhotoUrl != null)
                'profile_photo_url': profilePhotoUrl,
              if (fbUser.email != null) 'email': fbUser.email,
              if (fbUser.phoneNumber != null)
                'phone_number': fbUser.phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final serverUser = AppUser.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
        await _cache(fbUser.uid, serverUser);
        state = AsyncData(serverUser);
        return serverUser;
      }
      debugPrint('[UserProvider] Register → ${res.statusCode}');
    } catch (e) {
      debugPrint('[UserProvider] Register offline fallback: $e');
    }

    // Offline: save locally and proceed
    await _cache(fbUser.uid, localUser);
    state = AsyncData(localUser);
    return localUser;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selectors
// ─────────────────────────────────────────────────────────────────────────────

final coinBalanceProvider = Provider<int>((ref) {
  return ref.watch(currentUserProvider).asData?.value?.coins ??
      0;
});

final displayNameProvider = Provider<String>((ref) {
  return ref
          .watch(currentUserProvider)
          .asData
          ?.value
          ?.displayName ??
      '';
});

final isUserReadyProvider = Provider<bool>((ref) {
  final val = ref.watch(currentUserProvider);
  return val is AsyncData && val.value != null;
});

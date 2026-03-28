// lib/providers/notification_provider.dart
//
// In-app notification center: list, unread count, mark read.
// Also handles FCM token registration on app start.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Unread count (polled or refreshed after actions)
// ─────────────────────────────────────────────────────────────────────────────

final unreadNotificationCountProvider =
    AsyncNotifierProvider<UnreadCountNotifier, int>(
      UnreadCountNotifier.new,
    );

class UnreadCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final api = ref.read(apiServiceProvider);
    final res = await api.get('/api/notifications', query: {
      'page': '1',
      'limit': '1',
    });
    return res.ok ? res.data['unread_count'] as int? ?? 0 : 0;
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

// ─────────────────────────────────────────────────────────────────────────────
// Full notification list
// ─────────────────────────────────────────────────────────────────────────────

final notificationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
  (ref, page) async {
    final api = ref.read(apiServiceProvider);
    final res = await api.get('/api/notifications', query: {
      'page': page.toString(),
      'limit': '30',
    });
    return res.ok ? res.list('notifications') : [];
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Actions
// ─────────────────────────────────────────────────────────────────────────────

Future<void> markNotificationRead(ApiService api, String id) async {
  await api.put('/api/notifications/$id/read');
}

Future<void> markAllNotificationsRead(ApiService api) async {
  await api.put('/api/notifications/read-all');
}

/// Register the FCM token with the backend.
/// Call this once after login and whenever the token refreshes.
Future<void> registerFcmToken(
  ApiService api, {
  required String token,
  required String platform, // 'ios' or 'android'
}) async {
  final res = await api.post('/api/notifications/fcm-token', body: {
    'token': token,
    'platform': platform,
  });
  if (res.ok) {
    debugPrint('[Notifications] FCM token registered.');
  } else {
    debugPrint('[Notifications] FCM token registration failed: ${res.error}');
  }
}

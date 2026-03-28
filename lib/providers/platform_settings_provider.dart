// lib/providers/platform_settings_provider.dart
//
// Fetches platform settings from GET /api/settings on app launch.
// These are admin-configurable values like unlock fee, trial call
// duration, bonus amounts, etc.
//
// Usage:
//   final settings = ref.watch(platformSettingsProvider);
//   final unlockFee = settings.value?['unlock_fee_coins'] ?? 20;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final platformSettingsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/settings');
  if (!res.ok) return {};
  return res.data;
});

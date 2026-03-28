// lib/services/unlock_service.dart
//
// Chat unlock: check entitlement, purchase, and get fee info.

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final unlockServiceProvider = Provider((ref) => UnlockService(ref));

class UnlockService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  UnlockService(this._ref);

  /// Check if the current user has an active unlock for the target.
  /// Returns { unlocked: bool, expires_at: String? }.
  Future<bool> isUnlocked(String targetId) async {
    final res = await _api.get('/api/unlock/check/$targetId');
    return res.ok && res.data['unlocked'] == true;
  }

  /// Get the current unlock fee and duration.
  /// Returns { fee_coins: int, duration_days: int }.
  Future<Map<String, int>> getFee() async {
    final res = await _api.get('/api/unlock/fee');
    if (!res.ok) return {'fee_coins': 20, 'duration_days': 7};
    return {
      'fee_coins': res.data['fee_coins'] as int? ?? 20,
      'duration_days': res.data['duration_days'] as int? ?? 7,
    };
  }

  /// Purchase an unlock. Returns the SP result:
  /// { status, transaction_id, new_balance, expires_at }.
  Future<ApiResponse> unlock(String targetId) async {
    final key = 'unlock_${targetId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    return _api.post('/api/unlock', body: {
      'target_id': targetId,
      'idempotency_key': key,
    });
  }
}

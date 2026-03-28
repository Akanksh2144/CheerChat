// lib/services/gift_api_service.dart
//
// Gift catalog + sending. Talks to the Node.js backend which calls
// the process_gift_purchase stored procedure.

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

String _idempotencyKey(String prefix) =>
    '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

final giftApiServiceProvider = Provider((ref) => GiftApiService(ref));

class GiftApiService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  GiftApiService(this._ref);

  /// Fetch the active gift catalog.
  Future<List<Map<String, dynamic>>> getCatalog() async {
    final res = await _api.get('/api/gifts');
    return res.ok ? res.list('gifts') : [];
  }

  /// Send a gift. Returns { status, transaction_id, new_balance, host_earned }.
  Future<ApiResponse> sendGift({
    required String receiverId,
    required String giftId,
    String? callSessionId,
  }) async {
    return _api.post('/api/gifts/send', body: {
      'receiver_id': receiverId,
      'gift_id': giftId,
      'idempotency_key': _idempotencyKey('gift'),
      if (callSessionId != null) 'call_session_id': callSessionId,
    });
  }

  /// Get received gifts history.
  Future<List<Map<String, dynamic>>> getReceivedGifts({int page = 1}) async {
    final res = await _api.get('/api/gifts/received', query: {
      'page': page.toString(),
    });
    return res.ok ? res.list('gifts') : [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gift catalog provider (cached)
// ─────────────────────────────────────────────────────────────────────────────

final giftCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(giftApiServiceProvider);
  return service.getCatalog();
});

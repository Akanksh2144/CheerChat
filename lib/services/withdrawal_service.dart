// lib/services/withdrawal_service.dart
//
// Host withdrawal requests and exchange rate lookup.

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final withdrawalServiceProvider =
    Provider((ref) => WithdrawalService(ref));

class WithdrawalService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  WithdrawalService(this._ref);

  /// Request a withdrawal.
  Future<ApiResponse> request(int amountCoins) async {
    final key =
        'withdraw_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    return _api.post('/api/withdrawals', body: {
      'amount_coins': amountCoins,
      'idempotency_key': key,
    });
  }

  /// Get withdrawal history.
  Future<List<Map<String, dynamic>>> history({
    String? status,
    int page = 1,
  }) async {
    final q = <String, String>{'page': page.toString()};
    if (status != null) q['status'] = status;
    final res = await _api.get('/api/withdrawals', query: q);
    return res.ok ? res.list('withdrawals') : [];
  }

  /// Current exchange rate.
  Future<Map<String, dynamic>?> exchangeRate() async {
    final res = await _api.get('/api/withdrawals/exchange-rate');
    return res.ok ? res.data : null;
  }
}

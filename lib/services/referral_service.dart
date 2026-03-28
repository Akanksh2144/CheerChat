// lib/services/referral_service.dart
//
// Record referrals when a new user signs up with a referral code.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final referralServiceProvider =
    Provider((ref) => ReferralService(ref));

class ReferralService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  ReferralService(this._ref);

  /// Record that the current user was referred by [referrerPublicId].
  Future<bool> recordReferral(int referrerPublicId) async {
    final res = await _api.post('/api/referrals', body: {
      'referrer_public_id': referrerPublicId,
    });
    return res.ok;
  }
}

// lib/providers/wallet_provider.dart
//
// Wallet state: coin balance, income balance, ledger history.
// Also handles signup bonus and daily bonus claiming.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Balance
// ─────────────────────────────────────────────────────────────────────────────

final walletBalanceProvider =
    AsyncNotifierProvider<WalletBalanceNotifier, WalletBalance>(
      WalletBalanceNotifier.new,
    );

class WalletBalance {
  final int coinBalance;
  final int incomeBalance;

  const WalletBalance({
    this.coinBalance = 0,
    this.incomeBalance = 0,
  });
}

class WalletBalanceNotifier extends AsyncNotifier<WalletBalance> {
  @override
  Future<WalletBalance> build() async {
    final api = ref.read(apiServiceProvider);
    final res = await api.get('/api/wallet');

    if (!res.ok) return const WalletBalance();

    return WalletBalance(
      coinBalance: res.data['coin_balance'] as int? ?? 0,
      incomeBalance: res.data['income_balance'] as int? ?? 0,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Optimistically update coins locally (e.g. after a gift send).
  void deductCoins(int amount) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(WalletBalance(
      coinBalance: current.coinBalance - amount,
      incomeBalance: current.incomeBalance,
    ));
  }

  void addCoins(int amount) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(WalletBalance(
      coinBalance: current.coinBalance + amount,
      incomeBalance: current.incomeBalance,
    ));
  }
}

// Convenience selector for just the coin count
final coinBalanceProvider = Provider<int>((ref) {
  return ref.watch(walletBalanceProvider).asData?.value?.coinBalance ?? 0;
});

// ─────────────────────────────────────────────────────────────────────────────
// Bonus claiming
// ─────────────────────────────────────────────────────────────────────────────

/// Claim signup bonus. Returns coins awarded, or null on error.
Future<int?> claimSignupBonus(ApiService api) async {
  final res = await api.post('/api/auth/claim-signup-bonus');
  if (res.ok) return res.data['coins_awarded'] as int?;
  debugPrint('[Wallet] Signup bonus error: ${res.error}');
  return null;
}

/// Claim daily login bonus. Returns coins awarded, or null on error.
Future<int?> claimDailyBonus(ApiService api) async {
  final res = await api.post('/api/auth/claim-daily-bonus');
  if (res.ok) return res.data['coins_awarded'] as int?;
  debugPrint('[Wallet] Daily bonus error: ${res.error}');
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Coin packages
// ─────────────────────────────────────────────────────────────────────────────

final coinPackagesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/wallet/packages');
  if (!res.ok) return [];
  return res.list('packages');
});


// lib/screens/auth_gate.dart
//
// Root navigator for the app.
//
// Routing logic:
//   Firebase null                → LoginPage
//   Firebase user, first load   → SplashScreen
//   Firebase user, no profile   → ProfileSetupScreen  (first-time user)
//   Firebase user, has profile  → App (PersistentBottomNavBar)
//
// AuthGate must NEVER unmount PersistentBottomNavBar on a transient
// AsyncLoading tick — doing so corrupts each tab's NavigatorState and
// triggers '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_page.dart';
import '../screens/profile_setup_screen.dart';
import '../widgets/nav_bar.dart';
// import 'package:cheerchat/providers/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // ── Cold start — Firebase restoring session ────────────────────────
      loading: () => const _SplashScreen(),

      error: (err, _) => Scaffold(
        body: Center(child: Text('Auth error: $err')),
      ),

      data: (fbUser) {
        // ── Not signed in ──────────────────────────────────────────────
        if (fbUser == null) return const LoginPage();

        // ── Signed-in user ─────────────────────────────────────────────
        // ── Show splash during any auth transition ─────────────────────
        //
        // showSplash = true when AsyncLoading AND:
        //   • no previous value at all (first load / fresh rebuild), OR
        //   • previous value was null (just logged out, re-logging in)
        //
        // showSplash = false when AsyncLoading AND:
        //   • previous value was a real AppUser (soft refresh) — NavBar stays
        //
        // This prevents ProfileSetupScreen flashing during logout and
        // during re-login to the same account.
        final showSplash = ref.watch(
          currentUserProvider.select((async) {
            if (async is! AsyncLoading) return false;
            // Soft refresh with a real user cached → don't interrupt NavBar
            if (async.hasValue && async.value != null)
              return false;
            // First load OR post-logout/pre-login transition → show splash
            return true;
          }),
        );

        if (showSplash) return const _SplashScreen();

        final hasProfile = ref.watch(
          currentUserProvider.select(
            (async) => async.asData?.value != null,
          ),
        );

        return hasProfile
            ? AppShell(uid: fbUser.uid)
            : const ProfileSetupScreen();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash — shown only during cold-start auth resolution
// ─────────────────────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0D0D)
          : const Color(0xFFF8F9FA),
      body: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: Color(0xFFE91E8C),
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_page.dart';
import '../screens/profile_setup_screen.dart';
import '../services/fcm_service.dart';
import '../widgets/nav_bar.dart';

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
        if (fbUser == null) {
          // Reset logout flag after sign-out completes.
          // postFrameCallback keeps this out of the build phase.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(isLoggingOutProvider.notifier).done();
          });
          return const LoginPage();
        }

        // ── Logout in progress ─────────────────────────────────────────
        // isLoggingOut is set synchronously before signOut() is called,
        // so fbUser is still non-null here. Show SplashScreen so the
        // AppShell content doesn't flash before fbUser turns null.
        final isLoggingOut = ref.watch(isLoggingOutProvider);
        if (isLoggingOut) return const _SplashScreen();

        // ── Wait for profile load ──────────────────────────────────────
        final userAsync = ref.watch(currentUserProvider);

        // Loading state — two cases:
        //
        // (a) Cached non-null user present (soft refresh, e.g. PUT /api/me):
        //     Keep AppShell alive so tab NavigatorStates aren't destroyed.
        //
        // (b) No cached user (login transition, or brief race window where
        //     AuthGate rebuilds before user_provider transitions to
        //     AsyncLoading after fbUser changes):
        //     Show SplashScreen so ProfileSetupScreen never flashes.
        // ── Loading ────────────────────────────────────────────────────
        // AsyncNotifier preserves the previous value during rebuild, so
        // userAsync can be AsyncLoading(value: previousAppUser) here.
        //
        // The uid check is CRITICAL: if the previous AppUser belongs to a
        // different (or non-existent) session, we must NOT show AppShell —
        // that's exactly the new-account flash: stale previousUser is non-null
        // but belongs to the old account, so AppShell fires for one frame.
        //
        // Only keep AppShell alive (soft refresh) when the cached user's uid
        // matches the current Firebase user — meaning it's the same account
        // doing a background refresh, not a new sign-in.
        if (userAsync.isLoading) {
          final cachedUser = userAsync.value;
          final isSameUser =
              cachedUser != null && cachedUser.uid == fbUser.uid;
          return isSameUser
              ? AppShell(
                  uid: fbUser.uid,
                ) // soft refresh — keep NavBar alive
              : const _SplashScreen(); // new account / stale state — wait
        }

        if (userAsync.hasError) return const _SplashScreen();

        // ── Data resolved ──────────────────────────────────────────────
        final user = userAsync.value;
        if (user != null) {
          // Initialize FCM once when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(fcmServiceProvider).initialize();
          });
          return AppShell(uid: fbUser.uid);
        }
        return const ProfileSetupScreen();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash — cold-start + logout + login transition
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

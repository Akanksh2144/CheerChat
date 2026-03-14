// // // // // // lib/screens/auth_gate.dart
// // // // // //
// // // // // // Root navigator for the app.
// // // // // //
// // // // // // Routing logic:
// // // // // //   Firebase null                → LoginPage
// // // // // //   Firebase user, first load   → SplashScreen
// // // // // //   Firebase user, no profile   → ProfileSetupScreen  (first-time user)
// // // // // //   Firebase user, has profile  → App (PersistentBottomNavBar)
// // // // // //
// // // // // // AuthGate must NEVER unmount PersistentBottomNavBar on a transient
// // // // // // AsyncLoading tick — doing so corrupts each tab's NavigatorState and
// // // // // // triggers '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // // // import '../providers/auth_provider.dart';
// // // // // import '../providers/user_provider.dart';
// // // // // import '../screens/login_page.dart';
// // // // // import '../screens/profile_setup_screen.dart';
// // // // // import '../widgets/nav_bar.dart';
// // // // // // import 'package:cheerchat/providers/auth_provider.dart';

// // // // // class AuthGate extends ConsumerWidget {
// // // // //   const AuthGate({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // //     final authState = ref.watch(authStateProvider);

// // // // //     return authState.when(
// // // // //       // ── Cold start — Firebase restoring session ────────────────────────
// // // // //       loading: () => const _SplashScreen(),

// // // // //       error: (err, _) => Scaffold(
// // // // //         body: Center(child: Text('Auth error: $err')),
// // // // //       ),

// // // // //       data: (fbUser) {
// // // // //         // ── Not signed in ──────────────────────────────────────────────
// // // // //         if (fbUser == null) return const LoginPage();

// // // // //         // ── Signed-in user ─────────────────────────────────────────────
// // // // //         // ── Show splash during any auth transition ─────────────────────
// // // // //         //
// // // // //         // showSplash = true when AsyncLoading AND:
// // // // //         //   • no previous value at all (first load / fresh rebuild), OR
// // // // //         //   • previous value was null (just logged out, re-logging in)
// // // // //         //
// // // // //         // showSplash = false when AsyncLoading AND:
// // // // //         //   • previous value was a real AppUser (soft refresh) — NavBar stays
// // // // //         //
// // // // //         // This prevents ProfileSetupScreen flashing during logout and
// // // // //         // during re-login to the same account.
// // // // //         final showSplash = ref.watch(
// // // // //           currentUserProvider.select((async) {
// // // // //             if (async is! AsyncLoading) return false;
// // // // //             // Soft refresh with a real user cached → don't interrupt NavBar
// // // // //             if (async.hasValue && async.value != null)
// // // // //               return false;
// // // // //             // First load OR post-logout/pre-login transition → show splash
// // // // //             return true;
// // // // //           }),
// // // // //         );

// // // // //         if (showSplash) return const _SplashScreen();

// // // // //         final hasProfile = ref.watch(
// // // // //           currentUserProvider.select(
// // // // //             (async) => async.asData?.value != null,
// // // // //           ),
// // // // //         );

// // // // //         return hasProfile
// // // // //             ? AppShell(uid: fbUser.uid)
// // // // //             : const ProfileSetupScreen();
// // // // //       },
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // Splash — shown only during cold-start auth resolution
// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // class _SplashScreen extends StatelessWidget {
// // // // //   const _SplashScreen();

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final isDark =
// // // // //         Theme.of(context).brightness == Brightness.dark;
// // // // //     return Scaffold(
// // // // //       backgroundColor: isDark
// // // // //           ? const Color(0xFF0D0D0D)
// // // // //           : const Color(0xFFF8F9FA),
// // // // //       body: const Center(
// // // // //         child: SizedBox(
// // // // //           width: 28,
// // // // //           height: 28,
// // // // //           child: CircularProgressIndicator(
// // // // //             color: Color(0xFFE91E8C),
// // // // //             strokeWidth: 2.5,
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // lib/screens/auth_gate.dart
// // // // //
// // // // // Root navigator for the app.
// // // // //
// // // // // Routing logic:
// // // // //   Logging out (flag)          → SplashScreen   ← checked FIRST
// // // // //   Firebase null               → LoginPage
// // // // //   Firebase user, first load   → SplashScreen
// // // // //   Firebase user, no profile   → ProfileSetupScreen  (first-time user)
// // // // //   Firebase user, has profile  → App (PersistentBottomNavBar)
// // // // //
// // // // // AuthGate must NEVER unmount PersistentBottomNavBar on a transient
// // // // // AsyncLoading tick — doing so corrupts each tab's NavigatorState and
// // // // // triggers '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // // import '../providers/auth_provider.dart';
// // // // import '../providers/user_provider.dart';
// // // // import '../screens/login_page.dart';
// // // // import '../screens/profile_setup_screen.dart';
// // // // import '../widgets/nav_bar.dart';

// // // // class AuthGate extends ConsumerWidget {
// // // //   const AuthGate({super.key});

// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     final authState = ref.watch(authStateProvider);

// // // //     return authState.when(
// // // //       // ── Cold start — Firebase restoring session ────────────────────────
// // // //       loading: () => const _SplashScreen(),

// // // //       error: (err, _) => Scaffold(
// // // //         body: Center(child: Text('Auth error: $err')),
// // // //       ),

// // // //       data: (fbUser) {
// // // //         // ── Logout guard — MUST be checked before fbUser == null ───────
// // // //         //
// // // //         // Without this, signOut() makes fbUser null in under one frame.
// // // //         // AuthGate hits the fbUser == null branch and jumps directly to
// // // //         // LoginPage, flashing the last visible AppShell screen.
// // // //         //
// // // //         // With this flag set synchronously before signOut() is called,
// // // //         // the very next frame renders SplashScreen instead. By the time
// // // //         // fbUser turns null, we're already on SplashScreen, so the
// // // //         // transition is clean: AppShell → SplashScreen → LoginPage.
// // // //         final isLoggingOut = ref.watch(isLoggingOutProvider);
// // // //         if (isLoggingOut) return const _SplashScreen();

// // // //         // ── Not signed in ──────────────────────────────────────────────
// // // //         if (fbUser == null) {
// // // //           // Reset the logout flag now that sign-out is complete.
// // // //           // Done in a postFrameCallback so we don't mutate provider
// // // //           // state during a build, which would cause a Riverpod assertion.
// // // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //             ref.read(isLoggingOutProvider.notifier).done();
// // // //           });
// // // //           return const LoginPage();
// // // //         }

// // // //         // ── Signed-in user ─────────────────────────────────────────────
// // // //         // showSplash = true when AsyncLoading AND:
// // // //         //   • no previous value at all (first load / fresh rebuild), OR
// // // //         //   • previous value was null (just logged out, re-logging in)
// // // //         //
// // // //         // showSplash = false when AsyncLoading AND:
// // // //         //   • previous value was a real AppUser (soft refresh) — NavBar stays
// // // //         //
// // // //         // This prevents ProfileSetupScreen flashing during logout and
// // // //         // during re-login to the same account.
// // // //         final showSplash = ref.watch(
// // // //           currentUserProvider.select((async) {
// // // //             if (async is! AsyncLoading) return false;
// // // //             if (async.hasValue && async.value != null)
// // // //               return false;
// // // //             return true;
// // // //           }),
// // // //         );

// // // //         if (showSplash) return const _SplashScreen();

// // // //         final hasProfile = ref.watch(
// // // //           currentUserProvider.select(
// // // //             (async) => async.asData?.value != null,
// // // //           ),
// // // //         );

// // // //         return hasProfile
// // // //             ? AppShell(uid: fbUser.uid)
// // // //             : const ProfileSetupScreen();
// // // //       },
// // // //     );
// // // //   }
// // // // }

// // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // Splash — shown during cold-start auth resolution and logout transition
// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class _SplashScreen extends StatelessWidget {
// // // //   const _SplashScreen();

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;
// // // //     return Scaffold(
// // // //       backgroundColor: isDark
// // // //           ? const Color(0xFF0D0D0D)
// // // //           : const Color(0xFFF8F9FA),
// // // //       body: const Center(
// // // //         child: SizedBox(
// // // //           width: 28,
// // // //           height: 28,
// // // //           child: CircularProgressIndicator(
// // // //             color: Color(0xFFE91E8C),
// // // //             strokeWidth: 2.5,
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/screens/auth_gate.dart
// // // //
// // // // Root navigator for the app.
// // // //
// // // // Routing logic:
// // // //   Firebase null               → LoginPage
// // // //   Firebase user, logging out  → SplashScreen  (until fbUser turns null)
// // // //   Firebase user, first load   → SplashScreen
// // // //   Firebase user, no profile   → ProfileSetupScreen
// // // //   Firebase user, has profile  → AppShell
// // // //
// // // // AuthGate must NEVER unmount PersistentBottomNavBar on a transient
// // // // AsyncLoading tick — doing so corrupts each tab's NavigatorState and
// // // // triggers '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // import '../providers/auth_provider.dart';
// // // import '../providers/user_provider.dart';
// // // import '../screens/login_page.dart';
// // // import '../screens/profile_setup_screen.dart';
// // // import '../widgets/nav_bar.dart';

// // // class AuthGate extends ConsumerWidget {
// // //   const AuthGate({super.key});

// // //   @override
// // //   Widget build(BuildContext context, WidgetRef ref) {
// // //     final authState = ref.watch(authStateProvider);

// // //     return authState.when(
// // //       // ── Cold start — Firebase restoring session ────────────────────────
// // //       loading: () => const _SplashScreen(),

// // //       error: (err, _) => Scaffold(
// // //         body: Center(child: Text('Auth error: $err')),
// // //       ),

// // //       data: (fbUser) {
// // //         // ── Not signed in ──────────────────────────────────────────────
// // //         // This branch is reached when sign-out completes (fbUser → null).
// // //         // Reset the logout flag here via postFrameCallback (safe — no
// // //         // widget state mutation during build) then go to LoginPage.
// // //         if (fbUser == null) {
// // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // //             ref.read(isLoggingOutProvider.notifier).done();
// // //           });
// // //           return const LoginPage();
// // //         }

// // //         // ── Logout in progress — fbUser still non-null ─────────────────
// // //         // signOut() is awaited but Firebase hasn't emitted null yet.
// // //         // Show SplashScreen so AppShell content doesn't flash during
// // //         // the brief window between .start() and fbUser turning null.
// // //         final isLoggingOut = ref.watch(isLoggingOutProvider);
// // //         if (isLoggingOut) return const _SplashScreen();

// // //         // ── Signed-in user — wait for profile load ─────────────────────
// // //         // showSplash = true  → AsyncLoading with no cached user (first load)
// // //         // showSplash = false → AsyncLoading with cached user (soft refresh,
// // //         //                      keep NavBar alive to avoid navigator crashes)
// // //         final showSplash = ref.watch(
// // //           currentUserProvider.select((async) {
// // //             if (async is! AsyncLoading) return false;
// // //             if (async.hasValue && async.value != null)
// // //               return false;
// // //             return true;
// // //           }),
// // //         );

// // //         if (showSplash) return const _SplashScreen();

// // //         final hasProfile = ref.watch(
// // //           currentUserProvider.select(
// // //             (async) => async.asData?.value != null,
// // //           ),
// // //         );

// // //         return hasProfile
// // //             ? AppShell(uid: fbUser.uid)
// // //             : const ProfileSetupScreen();
// // //       },
// // //     );
// // //   }
// // // }

// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // Splash — cold-start + logout transition
// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class _SplashScreen extends StatelessWidget {
// // //   const _SplashScreen();

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;
// // //     return Scaffold(
// // //       backgroundColor: isDark
// // //           ? const Color(0xFF0D0D0D)
// // //           : const Color(0xFFF8F9FA),
// // //       body: const Center(
// // //         child: SizedBox(
// // //           width: 28,
// // //           height: 28,
// // //           child: CircularProgressIndicator(
// // //             color: Color(0xFFE91E8C),
// // //             strokeWidth: 2.5,
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/screens/auth_gate.dart
// // //
// // // Root navigator for the app.
// // //
// // // Routing logic:
// // //   Firebase null               → LoginPage
// // //   Firebase user, logging out  → SplashScreen
// // //   Firebase user, loading      → SplashScreen (unless soft-refresh with cached user)
// // //   Firebase user, no profile   → ProfileSetupScreen
// // //   Firebase user, has profile  → AppShell
// // //
// // // AuthGate must NEVER unmount AppShell on a transient AsyncLoading tick —
// // // doing so corrupts each tab's NavigatorState and triggers
// // // '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // import '../providers/auth_provider.dart';
// // import '../providers/user_provider.dart';
// // import '../screens/login_page.dart';
// // import '../screens/profile_setup_screen.dart';
// // import '../widgets/nav_bar.dart';

// // class AuthGate extends ConsumerWidget {
// //   const AuthGate({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final authState = ref.watch(authStateProvider);

// //     return authState.when(
// //       // ── Cold start — Firebase restoring session ────────────────────────
// //       loading: () => const _SplashScreen(),

// //       error: (err, _) => Scaffold(
// //         body: Center(child: Text('Auth error: $err')),
// //       ),

// //       data: (fbUser) {
// //         // ── Not signed in ──────────────────────────────────────────────
// //         if (fbUser == null) {
// //           // Reset logout flag after sign-out completes.
// //           // postFrameCallback keeps this out of the build phase.
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             ref.read(isLoggingOutProvider.notifier).done();
// //           });
// //           return const LoginPage();
// //         }

// //         // ── Logout in progress ─────────────────────────────────────────
// //         // isLoggingOut is set synchronously before signOut() is called,
// //         // so fbUser is still non-null here. Show SplashScreen so the
// //         // AppShell content doesn't flash before fbUser turns null.
// //         final isLoggingOut = ref.watch(isLoggingOutProvider);
// //         if (isLoggingOut) return const _SplashScreen();

// //         // ── Wait for profile load ──────────────────────────────────────
// //         final userAsync = ref.watch(currentUserProvider);

// //         // Loading state — two cases:
// //         //
// //         // (a) Cached non-null user present (soft refresh, e.g. PUT /api/me):
// //         //     Keep AppShell alive so tab NavigatorStates aren't destroyed.
// //         //
// //         // (b) No cached user (login transition, or brief race window where
// //         //     AuthGate rebuilds before user_provider transitions to
// //         //     AsyncLoading after fbUser changes):
// //         //     Show SplashScreen so ProfileSetupScreen never flashes.
// //         if (userAsync.isLoading) {
// //           return (userAsync.hasValue && userAsync.value != null)
// //               ? AppShell(uid: fbUser.uid)
// //               : const _SplashScreen();
// //         }

// //         if (userAsync.hasError) return const _SplashScreen();

// //         // ── Data resolved ──────────────────────────────────────────────
// //         final user = userAsync.value;
// //         return user != null
// //             ? AppShell(uid: fbUser.uid)
// //             : const ProfileSetupScreen();
// //       },
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Splash — cold-start + logout + login transition
// // // ─────────────────────────────────────────────────────────────────────────────

// // class _SplashScreen extends StatelessWidget {
// //   const _SplashScreen();

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;
// //     return Scaffold(
// //       backgroundColor: isDark
// //           ? const Color(0xFF0D0D0D)
// //           : const Color(0xFFF8F9FA),
// //       body: const Center(
// //         child: SizedBox(
// //           width: 28,
// //           height: 28,
// //           child: CircularProgressIndicator(
// //             color: Color(0xFFE91E8C),
// //             strokeWidth: 2.5,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/screens/auth_gate.dart
// //
// // Root navigator for the app.
// //
// // Routing logic:
// //   Firebase null               → LoginPage
// //   Firebase user, logging out  → SplashScreen
// //   Firebase user, loading      → SplashScreen (unless soft-refresh with cached user)
// //   Firebase user, no profile   → ProfileSetupScreen
// //   Firebase user, has profile  → AppShell
// //
// // AuthGate must NEVER unmount AppShell on a transient AsyncLoading tick —
// // doing so corrupts each tab's NavigatorState and triggers
// // '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../providers/auth_provider.dart';
// // import '../models/app_user.dart';
// import '../providers/user_provider.dart';
// import '../screens/login_page.dart';
// import '../screens/profile_setup_screen.dart';
// import '../widgets/nav_bar.dart';

// class AuthGate extends ConsumerWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);

//     return authState.when(
//       // ── Cold start — Firebase restoring session ────────────────────────
//       loading: () => const _SplashScreen(),

//       error: (err, _) => Scaffold(
//         body: Center(child: Text('Auth error: $err')),
//       ),

//       data: (fbUser) {
//         // ── Not signed in ──────────────────────────────────────────────
//         if (fbUser == null) {
//           // Reset logout flag after sign-out completes.
//           // postFrameCallback keeps this out of the build phase.
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             ref.read(isLoggingOutProvider.notifier).done();
//           });
//           return const LoginPage();
//         }

//         // ── Logout in progress ─────────────────────────────────────────
//         // isLoggingOut is set synchronously before signOut() is called,
//         // so fbUser is still non-null here. Show SplashScreen so the
//         // AppShell content doesn't flash before fbUser turns null.
//         final isLoggingOut = ref.watch(isLoggingOutProvider);
//         if (isLoggingOut) return const _SplashScreen();

//         // ── Wait for profile load ──────────────────────────────────────
//         final userAsync = ref.watch(currentUserProvider);

//         // Loading state — two cases:
//         //
//         // (a) Cached non-null user present (soft refresh, e.g. PUT /api/me):
//         //     Keep AppShell alive so tab NavigatorStates aren't destroyed.
//         //
//         // (b) No cached user (login transition, or brief race window where
//         //     AuthGate rebuilds before user_provider transitions to
//         //     AsyncLoading after fbUser changes):
//         //     Show SplashScreen so ProfileSetupScreen never flashes.
//         if (userAsync.isLoading) {
//           return (userAsync.hasValue && userAsync.value != null)
//               ? AppShell(uid: fbUser.uid)
//               : const _SplashScreen();
//         }

//         if (userAsync.hasError) return const _SplashScreen();

//         // ── Data resolved ──────────────────────────────────────────────
//         final user = userAsync.value;

//         // ── Stale-state guard ──────────────────────────────────────────
//         // Riverpod has a one-frame window where authStateProvider has
//         // already emitted the new fbUser but currentUserProvider hasn't
//         // rebuilt yet — it still holds the previous session's AppUser.
//         // Without this guard: AuthGate sees non-null user → AppShell
//         // flashes for one frame before the rebuild resolves to null
//         // → ProfileSetupScreen. The uid check catches this instantly.
//         if (user != null && user.uid != fbUser.uid) {
//           return const _SplashScreen();
//         }

//         return user != null
//             ? AppShell(uid: fbUser.uid)
//             : const ProfileSetupScreen();
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Splash — cold-start + logout + login transition
// // ─────────────────────────────────────────────────────────────────────────────

// class _SplashScreen extends StatelessWidget {
//   const _SplashScreen();

//   @override
//   Widget build(BuildContext context) {
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: isDark
//           ? const Color(0xFF0D0D0D)
//           : const Color(0xFFF8F9FA),
//       body: const Center(
//         child: SizedBox(
//           width: 28,
//           height: 28,
//           child: CircularProgressIndicator(
//             color: Color(0xFFE91E8C),
//             strokeWidth: 2.5,
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/auth_gate.dart
//
// Root navigator for the app.
//
// Routing logic:
//   Firebase null               → LoginPage
//   Firebase user, logging out  → SplashScreen
//   Firebase user, loading      → SplashScreen (unless soft-refresh with cached user)
//   Firebase user, no profile   → ProfileSetupScreen
//   Firebase user, has profile  → AppShell
//
// AuthGate must NEVER unmount AppShell on a transient AsyncLoading tick —
// doing so corrupts each tab's NavigatorState and triggers
// '_history.isNotEmpty' crashes on swipe-back devices (Realme, OnePlus).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_page.dart';
import '../screens/profile_setup_screen.dart';
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
        return user != null
            ? AppShell(uid: fbUser.uid)
            : const ProfileSetupScreen();
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

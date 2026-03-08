import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/nav_bar.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the startup process (ensures it runs once)
    final startup = ref.watch(startupProvider);

    return startup.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Startup Error: $err")),
      ),
      data: (_) {
        // 2. Once startup is done, reactively watch the user state
        final authState = ref.watch(authStateProvider);

        return authState.when(
          data: (user) {
            if (user == null) {
              return const Scaffold(
                body: Center(
                  child: Text("Login failed or logged out"),
                ),
              );
            }
            return PersistentBottomNavBar(uid: user.uid);
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            body: Center(
              child: Text("Auth Stream Error: $error"),
            ),
          ),
        );
      },
    );
  }
}

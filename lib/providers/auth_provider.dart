// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:cheerchat/services/auth_service.dart';

// // // // Provides the reactive stream of the user's auth state
// // // final authStateProvider = StreamProvider<User?>((ref) {
// // //   return FirebaseAuth.instance.authStateChanges();
// // // });

// // // // Ensures the startup logic runs exactly once per app lifecycle
// // // final startupProvider = FutureProvider<void>((ref) async {
// // //   await ref
// // //       .read(authServiceProvider)
// // //       .signInAnonymouslyIfNeeded();
// // // });
// // // lib/providers/auth_provider.dart
// // //
// // // startupProvider no longer auto-signs in anonymously.
// // // Anonymous sign-in is now explicit via LoginPage "Browse as Guest".

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // Reactive stream of Firebase auth state
// // final authStateProvider = StreamProvider<User?>((ref) {
// //   return FirebaseAuth.instance.authStateChanges();
// // });

// // // Startup hook — reserved for future init tasks (e.g. fetch remote config)
// // // Keep as FutureProvider so AuthGate can still await it if needed.
// // final startupProvider = FutureProvider<void>((ref) async {
// //   // No-op for now. Add Firebase Remote Config fetch, etc. here.
// // });
// // lib/providers/auth_provider.dart

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Reactive stream of Firebase auth state
// final authStateProvider = StreamProvider<User?>((ref) {
//   return FirebaseAuth.instance.authStateChanges();
// });

// // Startup hook — reserved for future init tasks (Remote Config, etc.)
// final startupProvider = FutureProvider<void>((ref) async {});
// lib/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive stream of Firebase auth state.
/// Watched by AuthGate and user_provider.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Startup hook — reserved for future init tasks (Remote Config, etc.)
final startupProvider = FutureProvider<void>((ref) async {});

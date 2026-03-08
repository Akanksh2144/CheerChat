import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheerchat/services/auth_service.dart';

// Provides the reactive stream of the user's auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Ensures the startup logic runs exactly once per app lifecycle
final startupProvider = FutureProvider<void>((ref) async {
  await ref
      .read(authServiceProvider)
      .signInAnonymouslyIfNeeded();
});


// lib/services/auth_service.dart
//
// Firebase Auth — Phone, Google, Facebook (stubbed) wired.
//
// pubspec.yaml — add:
//   google_sign_in: ^6.2.1
//
// Android — SHA-1 fingerprint must be in Firebase Console → Project Settings.
//   Run: cd android && ./gradlew signingReport
//
// iOS — add REVERSED_CLIENT_ID from GoogleService-Info.plist to Info.plist:
//   CFBundleURLTypes > CFBundleURLSchemes > com.googleusercontent.apps.YOUR_ID

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Phone OTP — Step 1 ────────────────────────────────────────────────────

  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function(UserCredential) onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android instant-verify (SMS auto-read)
        try {
          final result = await _auth.signInWithCredential(
            credential,
          );
          onAutoVerified(result);
        } catch (e) {
          onError(
            'Auto-verification failed. Please enter the code manually.',
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(
          '[AuthService] Phone verify failed: ${e.code} ${e.message}',
        );
        switch (e.code) {
          case 'invalid-phone-number':
            onError(
              'Invalid phone number. Check the country code and number.',
            );
          case 'too-many-requests':
            onError(
              'Too many attempts. Please try again later.',
            );
          case 'quota-exceeded':
            onError('SMS quota exceeded. Try again tomorrow.');
          case 'captcha-check-failed':
            onError('reCAPTCHA check failed. Please try again.');
          default:
            onError(
              e.message ?? 'Verification failed. Try again.',
            );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint(
          '[AuthService] OTP sent. vid: $verificationId',
        );
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('[AuthService] SMS auto-retrieval timeout');
      },
    );
  }

  // ── Phone OTP — Step 2 ────────────────────────────────────────────────────

  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    debugPrint(
      '[AuthService] Phone sign-in complete: ${result.user?.uid}',
    );
    return result;
  }

  // ── Google ────────────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      debugPrint(
        '[AuthService] Google sign-in cancelled by user',
      );
      return null; // user cancelled — not an error
    }

    final googleAuth = await googleUser.authentication;

    if (googleAuth.accessToken == null &&
        googleAuth.idToken == null) {
      throw FirebaseAuthException(
        code: 'token-missing',
        message: 'Failed to get Google authentication tokens.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    debugPrint(
      '[AuthService] Google sign-in: ${result.user?.uid}',
    );
    return result;
  }

  // ── Facebook — STUB (not yet enabled) ────────────────────────────────────
  // To wire up: add flutter_facebook_auth: ^7.0.1 to pubspec.yaml
  // and follow AUTH_SETUP.md for Android/iOS config.

  Future<UserCredential?> signInWithFacebook() async {
    throw UnimplementedError('Facebook sign-in coming soon.');
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
    debugPrint('[AuthService] Signed out.');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _auth.currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('[AuthService] Failed to get token: $e');
      return null;
    }
  }
}

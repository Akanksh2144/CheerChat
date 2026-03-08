// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final authServiceProvider = Provider((ref) => AuthService());

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance;

//   Future<void> signInAnonymouslyIfNeeded() async {
//     // 1. Wait for Firebase to restore any existing session from local cache
//     await _auth.authStateChanges().first;

//     // 2. Only sign in if the cache came back empty
//     if (_auth.currentUser == null) {
//       try {
//         final cred = await _auth.signInAnonymously();

//         // 3. ZERO READ OPTIMIZATION: Only write to Firestore if it's a brand new account
//         if (cred.additionalUserInfo?.isNewUser == true) {
//           await _createInitialUserDoc(cred.user!);
//         }
//       } catch (e) {
//         debugPrint("Error during anonymous sign-in: $e");
//       }
//     }
//   }

//   Future<void> _createInitialUserDoc(User user) async {
//     final userDoc = _firestore.collection('users').doc(user.uid);
//     await userDoc.set({
//       'uid': user.uid,
//       'isAnonymous': user.isAnonymous,
//       'name': 'User${user.uid.substring(0, 6)}',
//       'photoUrl': '',
//       'role': 'user',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
// }
// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheerchat/models/app_user.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isSigningIn = false;

  Future<void> signInAnonymouslyIfNeeded() async {
    if (_isSigningIn) return;
    _isSigningIn = true;

    try {
      await _auth.authStateChanges().first;
      if (_auth.currentUser != null) return;

      const maxRetries = 3;
      int retryCount = 0;

      while (retryCount < maxRetries) {
        try {
          final cred = await _auth.signInAnonymously();

          if (cred.additionalUserInfo?.isNewUser == true) {
            await _createInitialUserDoc(cred.user!);
          }

          debugPrint(
            "[AuthService] Successfully signed in anonymously.",
          );
          return;
        } on FirebaseAuthException catch (e) {
          debugPrint("[AuthService] signIn error: ${e.code}");

          if (e.code != 'network-request-failed') rethrow;

          retryCount++;
          if (retryCount >= maxRetries) {
            debugPrint(
              "[AuthService] Max auth retries reached.",
            );
            rethrow;
          }

          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } finally {
      _isSigningIn = false;
    }
  }

  Future<void> _createInitialUserDoc(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    final newUser = AppUser(
      uid: user.uid,
      name: 'User${user.uid.substring(0, 6)}',
      role: 'user', 
      coins: 0, 
      isOnline: false, 
    );

    final userData = newUser.toMap();
    userData['createdAt'] = FieldValue.serverTimestamp();

    await userDoc.set(userData);
    debugPrint("[AuthService] Initial user document created for ${user.uid}");
  }
}

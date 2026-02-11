// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:judotalk/widgets/nav_bar.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Global key to access the scaffold messenger
// final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
//     GlobalKey<ScaffoldMessengerState>();

// // void main() {
// //   runApp(const MyApp());
// // }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   final auth = FirebaseAuth.instance;

//   if (auth.currentUser == null) {
//     await auth.signInAnonymously();
//   }
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Connect App',
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       theme: ThemeData(useMaterial3: true),
//       home: PersistentBottomNavBar(),
//     );
//   }
// }

// // class MyApp extends StatelessWidget {
// //   const MyApp({Key? key}) : super(key: key);
// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       scaffoldMessengerKey: scaffoldMessengerKey,
// //       theme: ThemeData(
// //         scaffoldBackgroundColor: const Color(0xFFECE5DD),
// //       ),
// //       home: const MyHomePage(title: 'Agora Chat Quickstart'),
// //     );
// //   }
// // }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:judotalk/widgets/nav_bar.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // REMOVED: await auth.signInAnonymously(); -> Moved to UI
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connect App',
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(useMaterial3: true),
      // We wrap the home in an AuthGuard
      home: const AuthGuard(),
    );
  }
}

/// This widget handles the "Check Login" logic
class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  // We use a Future to track the login process
  late Future<User?> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = _signInIfNeeded();
  }

  Future<User?> _signInIfNeeded() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      // Sign in anonymously if no user exists
      final cred = await auth.signInAnonymously();
      return cred.user;
    }
    return auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authFuture,
      builder: (context, snapshot) {
        // 1. While waiting, show a Loading Spinner (Splash)
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If error, show error message
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Login Failed: ${snapshot.error}"),
            ),
          );
        }

        // 3. Success! Go to Main App
        return const PersistentBottomNavBar();
      },
    );
  }
}

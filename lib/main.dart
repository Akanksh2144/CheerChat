import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:judotalk/widgets/nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global key to access the scaffold messenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// void main() {
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
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
      home: PersistenBottomNavBar(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFFECE5DD),
//       ),
//       home: const MyHomePage(title: 'Agora Chat Quickstart'),
//     );
//   }
// }

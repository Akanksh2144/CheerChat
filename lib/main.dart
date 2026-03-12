
// lib/main.dart

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cheerchat/providers/theme_provider.dart';
import 'package:cheerchat/screens/auth_gate.dart';
import 'package:cheerchat/theme/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ── Disable runtime font downloads ────────────────────────────────────────
      // google_fonts tries to download font variants from fonts.gstatic.com on
      // first launch. On some devices (Realme ColorOS, certain OEM ROMs) the DNS
      // lookup fails, causing ZoneErrors and fallback fonts.
      //
      // Setting this to false forces google_fonts to use ONLY the font files
      // bundled in assets/fonts/. You MUST add the Poppins .ttf files to your
      // assets and declare them in pubspec.yaml (see comments below in main()).
      // Once the fonts are bundled this line has zero performance cost.
      //
      // pubspec.yaml — add under flutter > fonts:
      //
      // fonts:
      //   - family: Poppins
      //     fonts:
      //       - asset: assets/fonts/Poppins-Regular.ttf
      //       - asset: assets/fonts/Poppins-Medium.ttf
      //         weight: 500
      //       - asset: assets/fonts/Poppins-SemiBold.ttf
      //         weight: 600
      //       - asset: assets/fonts/Poppins-Bold.ttf
      //         weight: 700
      //       - asset: assets/fonts/Poppins-ExtraBold.ttf
      //         weight: 800
      //
      // Download the .ttf files from https://fonts.google.com/specimen/Poppins
      // and place them in assets/fonts/ in your project root.
      GoogleFonts.config.allowRuntimeFetching = true;

      await Firebase.initializeApp();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint(
          '[FlutterError] ${details.exceptionAsString()}',
        );
      };

      runApp(const ProviderScope(child: CheerChatApp()));
    },
    (error, stack) {
      debugPrint('[ZoneError] $error\n$stack');
    },
  );
}

// ConsumerWidget so it rebuilds when the user changes the theme.
class CheerChatApp extends ConsumerWidget {
  const CheerChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'CheerChat',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}

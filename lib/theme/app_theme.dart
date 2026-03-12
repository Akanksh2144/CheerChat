// lib/theme/app_theme.dart
//
// Light and dark ThemeData for CheerChat.
// Both themes wire AppColors as a ThemeExtension so every widget
// can call AppColors.of(context) to get the right palette.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Dark ──────────────────────────────────────────────────────────────────

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.bg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.dark.pink,
      secondary: AppColors.dark.gold,
      surface: AppColors.dark.surface,
    ),
    extensions: const [AppColors.dark],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.bg,
      foregroundColor: AppColors.dark.textPrimary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    dividerColor: AppColors.dark.divider,
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ),
    splashColor: AppColors.dark.pink.withOpacity(0.06),
    highlightColor: AppColors.dark.surface.withOpacity(0.5),
  );

  // ── Light ─────────────────────────────────────────────────────────────────

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.bg,
    colorScheme: ColorScheme.light(
      primary: AppColors.light.pink,
      secondary: AppColors.light.gold,
      surface: AppColors.light.surface,
    ),
    extensions: const [AppColors.light],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.bg,
      foregroundColor: AppColors.light.textPrimary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    dividerColor: AppColors.light.divider,
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ),
    splashColor: AppColors.light.pink.withOpacity(0.06),
    highlightColor: AppColors.light.surface.withOpacity(0.5),
  );
}

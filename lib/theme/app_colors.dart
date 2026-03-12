// lib/theme/app_colors.dart
//
// Single source of truth for every color in the app.
// Screens call:  final c = AppColors.of(context);
//                c.bg, c.pink, c.textPrimary ...
//
// Adding a new color? Add the field here, set values in light/dark,
// and update the copyWith + lerp methods below.

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color divider;

  // ── Brand ──────────────────────────────────────────────────────────────────
  final Color pink;
  final Color gold;
  final Color green;

  // ── Typography ─────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;

  // ── Component-specific ────────────────────────────────────────────────────
  /// Dark inner circle inside story-ring bubbles
  final Color bubbleInner;

  /// Avatar placeholder background
  final Color avatarFallback;

  /// Avatar placeholder icon
  final Color avatarIcon;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.divider,
    required this.pink,
    required this.gold,
    required this.green,
    required this.textPrimary,
    required this.textSecondary,
    required this.bubbleInner,
    required this.avatarFallback,
    required this.avatarIcon,
  });

  // ── Convenience accessor ──────────────────────────────────────────────────

  /// Usage:  final c = AppColors.of(context);
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  // ── Variants ──────────────────────────────────────────────────────────────

  static const AppColors dark = AppColors(
    bg: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    card: Color(0xFF222222),
    border: Color(0xFF2A2A2A),
    divider: Color(0xFF1F1F1F),
    pink: Color(0xFFE91E8C),
    gold: Color(0xFFFFCA28),
    green: Color(0xFF4CAF50),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
    bubbleInner: Color(0xFF141414),
    avatarFallback: Color(0xFF2A1520),
    avatarIcon: Color(0xFF9E9E9E),
  );

  static const AppColors light = AppColors(
    bg: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFF1F3F5),
    border: Color(0xFFE8E8E8),
    divider: Color(0xFFE0E0E0),
    pink: Color(0xFFD81B60),
    gold: Color(0xFFF9A825),
    green: Color(0xFF388E3C),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF757575),
    bubbleInner: Color(0xFFF5F5F5),
    avatarFallback: Color(0xFFFCE4EC),
    avatarIcon: Color(0xFFBDBDBD),
  );

  // ── ThemeExtension boilerplate ────────────────────────────────────────────

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? border,
    Color? divider,
    Color? pink,
    Color? gold,
    Color? green,
    Color? textPrimary,
    Color? textSecondary,
    Color? bubbleInner,
    Color? avatarFallback,
    Color? avatarIcon,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      pink: pink ?? this.pink,
      gold: gold ?? this.gold,
      green: green ?? this.green,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      bubbleInner: bubbleInner ?? this.bubbleInner,
      avatarFallback: avatarFallback ?? this.avatarFallback,
      avatarIcon: avatarIcon ?? this.avatarIcon,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      green: Color.lerp(green, other.green, t)!,
      textPrimary: Color.lerp(
        textPrimary,
        other.textPrimary,
        t,
      )!,
      textSecondary: Color.lerp(
        textSecondary,
        other.textSecondary,
        t,
      )!,
      bubbleInner: Color.lerp(
        bubbleInner,
        other.bubbleInner,
        t,
      )!,
      avatarFallback: Color.lerp(
        avatarFallback,
        other.avatarFallback,
        t,
      )!,
      avatarIcon: Color.lerp(avatarIcon, other.avatarIcon, t)!,
    );
  }
}

// lib/providers/theme_provider.dart
//
// Persists the user's theme preference using Riverpod v2 (Notifier).
//
// Usage:
//   final mode = ref.watch(themeModeProvider);
//   ref.read(themeModeProvider.notifier).toggle();
//   ref.read(themeModeProvider.notifier).set(ThemeMode.dark);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemePrefKey = 'cheerchat_theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Start with system, then load persisted value asynchronously.
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemePrefKey);
    if (stored == 'light') {
      state = ThemeMode.light;
    } else if (stored == 'dark') {
      state = ThemeMode.dark;
    }
    // 'system' or missing → keep default
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemePrefKey, mode.name);
  }

  Future<void> toggle() async {
    await set(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(
      ThemeModeNotifier.new,
    );

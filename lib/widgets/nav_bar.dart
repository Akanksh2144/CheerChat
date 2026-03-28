// lib/widgets/nav_bar.dart
//
// Custom bottom nav — IndexedStack keeps all tabs alive (no re-init on switch).
// Back-button behaviour:
//   • Any non-home tab  → jump to tab 0
//   • Home tab (1st)    → "Press back again to exit" snackbar
//   • Home tab (2nd, <2s) → exit

import 'dart:async';

// import 'package:cheerchat/screens/chat_screen.dart';
import 'package:cheerchat/screens/hosts_grid_view.dart';
import 'package:cheerchat/screens/inbox_screen.dart';
import 'package:cheerchat/screens/profile_screen.dart';
import 'package:cheerchat/screens/random_call_screen.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.uid});
  final String uid;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _exitArmed = false;
  Timer? _exitTimer;

  static const _screens = [
    HostsGridViewScreen(),
    RandomCallScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    if (_index == i) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    // Reset exit arm when leaving home tab
    if (i != 0) {
      _exitTimer?.cancel();
      _exitArmed = false;
    }
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Not on home → go home
    if (_index != 0) {
      setState(() => _index = 0);
      _exitTimer?.cancel();
      _exitArmed = false;
      return false;
    }
    // On home, second press → exit
    if (_exitArmed) {
      _exitTimer?.cancel();
      return true;
    }
    // On home, first press → arm
    _exitArmed = true;
    _exitTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _exitArmed = false;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Press back again to exit'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        final shouldExit = await _onWillPop();
        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: _NavBar(
          index: _index,
          onTap: _onTap,
          c: c,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ── Custom nav bar ────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.index,
    required this.onTap,
    required this.c,
    required this.isDark,
  });

  final int index;
  final ValueChanged<int> onTap;
  final AppColors c;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          top: BorderSide(color: c.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.4 : 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              icon: FontAwesomeIcons.earthAmericas,
              label: 'Connect',
              selected: index == 0,
              onTap: () => onTap(0),
              c: c,
            ),
            // _NavItem(icon: Icons.abc, label: "chat", selected: index == 4, onTap: () => onTap(4), c: c),
            _NavItem(
              icon: FontAwesomeIcons.shuffle,
              label: 'Random',
              selected: index == 1,
              onTap: () => onTap(1),
              c: c,
            ),
            _NavItem(
              icon: FontAwesomeIcons.solidMessage,
              label: 'Inbox',
              selected: index == 2,
              onTap: () => onTap(2),
              c: c,
            ),

            _NavItem(
              icon: FontAwesomeIcons.user,
              label: 'Profile',
              selected: index == 3,
              onTap: () => onTap(3),
              c: c,
            ),

          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.c,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: FaIcon(
                  icon,
                  size: 20,
                  color: selected ? c.pink : c.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: selected ? c.pink : c.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 2,
                width: selected ? 18 : 0,
                decoration: BoxDecoration(
                  color: c.pink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// // lib/ui_test_runner.dart
// //
// // Standalone entry point for UI testing without a backend or real Agora token.
// // Run this instead of main.dart when you want to preview screens in isolation.
// //
// // Usage:
// //   flutter run -t lib/ui_test_runner.dart

import 'package:cheerchat/data/hosts_data.dart';
import 'package:cheerchat/screens/ongoing_call_screen.dart';
import 'package:cheerchat/screens/profile_details_screen.dart';
import 'package:cheerchat/screens/hosts_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CheerChat UI Sandbox',
        home: UITestMenu(),
      ),
    ),
  );
}

class UITestMenu extends StatelessWidget {
  const UITestMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('UI Sandbox'),
        backgroundColor: Colors.pink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(
            context,
            icon: Icons.video_call,
            label: 'Ongoing Call Screen (test mode)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OngoingCallScreen(
                  host: dummyHosts.first,
                  initialCoins: 1000,
                  testMode: true,
                  isAlreadyFollowing: false,
                ),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.person,
            label: 'Host Profile Details',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileDetailsScreen(host: dummyHosts[2]),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.grid_view,
            label: 'Hosts Grid View',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HostsGridViewScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(icon, color: Colors.pink),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white30,
          size: 14,
        ),
        onTap: onTap,
      ),
    );
  }
}

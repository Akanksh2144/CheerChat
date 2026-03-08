// import 'package:flutter/material.dart';
// import 'package:cheerchat/screens_notcompleted/ongoing_call_screen.dart';
// import 'package:cheerchat/ui_test_runner.dart';

// class RandomCallScreen extends StatefulWidget {
//   const RandomCallScreen({super.key});

//   @override
//   State<RandomCallScreen> createState() =>
//       _RandomCallScreenState();
// }

// class _RandomCallScreenState extends State<RandomCallScreen>
//     with TickerProviderStateMixin {
//   bool isSearching =
//       true; // State to toggle between Radar and Video Call
//   late AnimationController _rippleController;

//   @override
//   void initState() {
//     super.initState();
//     // Animation for the "Radar" ripple effect
//     _rippleController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _rippleController.dispose();
//     super.dispose();
//   }

//   void _toggleState() {
//     setState(() {
//       isSearching = !isSearching;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // LAYER 1: The Background (Video Feed or Blur)
//           _buildBackground(),

//           // LAYER 2: The Main UI Content
//           // SafeArea(
//           //   child: isSearching
//           //       ? _buildSearchingUI()
//           //       // : _buildActiveCallUI(),
//           //       : OngoingCallScreen(
//           //           agoraService:
//           //               FakeAgoraService(), // 👉 Injecting the Fake
//           //           channelId: 'test_room',
//           //           token: 'dummy_token',
//           //           localUid: 1,
//           //         ),
//           // ),
//           isSearching
//               ? _buildSearchingUI()
//               // : _buildActiveCallUI(),
//               : OngoingCallScreen(
//                   agoraService:
//                       FakeAgoraService(), // 👉 Injecting the Fake
//                   channelId: 'test_room',
//                   token: 'dummy_token',
//                   localUid: 1,
//                 ),

//           // DEBUG BUTTON: To switch modes for testing
//           Positioned(
//             top: 50,
//             right: 20,
//             child: TextButton.icon(
//               onPressed: _toggleState,
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 foregroundColor: Colors.white,
//               ),
//               icon: Icon(
//                 isSearching ? Icons.videocam : Icons.search,
//               ),
//               label: Text(
//                 isSearching
//                     ? "Simulate Connect"
//                     : "Simulate Search",
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // BACKGROUND LAYER
//   // ---------------------------------------------------------------------------
//   Widget _buildBackground() {
//     if (isSearching) {
//       // Dark background for searching
//       return Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
//           ),
//         ),
//       );
//     } else {
//       // Placeholder for Agora/Zego Video Feed
//       return Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: const NetworkImage(
//               "https://images.unsplash.com/photo-1494790108377-be9c29b29330?fit=crop&w=687&q=80",
//             ), // Placeholder Host Image
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(
//                 0.1,
//               ), // Slight overlay for text readability
//               BlendMode.darken,
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // STATE A: SEARCHING / RADAR UI
//   // ---------------------------------------------------------------------------
//   Widget _buildSearchingUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Radar Animation
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               _buildRipple(200),
//               _buildRipple(280),
//               _buildRipple(360),
//               const CircleAvatar(
//                 radius: 60,
//                 backgroundImage: NetworkImage(
//                   "https://i.pravatar.cc/300",
//                 ), // Current User's Image
//               ),
//             ],
//           ),
//           const SizedBox(height: 50),
//           const Text(
//             "Finding a Host...",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Matching based on your preferences",
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRipple(double size) {
//     return AnimatedBuilder(
//       animation: _rippleController,
//       builder: (context, child) {
//         return Container(
//           width: size * _rippleController.value,
//           height: size * _rippleController.value,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.pinkAccent.withOpacity(
//                 1.0 - _rippleController.value,
//               ),
//               width: 2,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // STATE B: ACTIVE CALL UI
//   // ---------------------------------------------------------------------------
//   Widget _buildActiveCallUI() {
//     return Column(
//       children: [
//         // --- TOP BAR (Host Info & Timer) ---
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//             vertical: 10,
//           ),
//           child: Row(
//             children: [
//               // Host Profile Pill
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 20,
//                       backgroundImage: NetworkImage(
//                         "https://images.unsplash.com/photo-1494790108377-be9c29b29330?fit=crop&w=100&q=80",
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: const [
//                         Text(
//                           "Jessica, 24",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           "🇺🇸 USA",
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 15),
//                     const Icon(
//                       Icons.add_circle,
//                       color: Colors.pinkAccent,
//                     ), // Follow button
//                     const SizedBox(width: 8),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               // Coin/Timer Badge
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.amber),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.monetization_on,
//                       color: Colors.amber,
//                       size: 16,
//                     ),
//                     SizedBox(width: 5),
//                     Text(
//                       "02:45",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const Spacer(),

//         // --- RIGHT SIDE (Gifts) ---
//         Align(
//           alignment: Alignment.centerRight,
//           child: Padding(
//             padding: const EdgeInsets.only(
//               right: 16.0,
//               bottom: 20,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildSideButton(
//                   Icons.card_giftcard,
//                   "Gift",
//                   Colors.pinkAccent,
//                   () {
//                     // TODO: Open Gift Bottom Sheet
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 _buildSideButton(
//                   Icons.favorite,
//                   "Like",
//                   Colors.white,
//                   () {},
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // --- BOTTOM BAR (Controls) ---
//         Container(
//           padding: const EdgeInsets.only(bottom: 30, top: 20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//               colors: [
//                 Colors.black.withOpacity(0.8),
//                 Colors.transparent,
//               ],
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildControlBtn(
//                 Icons.mic,
//                 Colors.white.withOpacity(0.2),
//               ),
//               _buildControlBtn(
//                 Icons.videocam,
//                 Colors.white.withOpacity(0.2),
//               ),

//               // End Call Button
//               FloatingActionButton(
//                 onPressed:
//                     _toggleState, // Ends call and goes back to search
//                 backgroundColor: Colors.redAccent,
//                 child: const Icon(
//                   Icons.call_end,
//                   color: Colors.white,
//                 ),
//               ),

//               _buildControlBtn(
//                 Icons.cameraswitch,
//                 Colors.white.withOpacity(0.2),
//               ),
//               _buildControlBtn(
//                 Icons.chat_bubble,
//                 Colors.white.withOpacity(0.2),
//               ), // Text Chat
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildControlBtn(IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//       child: Icon(icon, color: Colors.white, size: 28),
//     );
//   }

//   Widget _buildSideButton(
//     IconData icon,
//     String label,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   color.withOpacity(0.8),
//                   color.withOpacity(0.4),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.3),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Icon(icon, color: Colors.white, size: 28),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               shadows: [
//                 Shadow(blurRadius: 2, color: Colors.black),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// lib/screens/random_call_screen.dart

import 'dart:math';
import 'package:cheerchat/data/hosts_data.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum _State { idle, searching }

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});
  @override
  State<RandomCallScreen> createState() =>
      _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen>
    with TickerProviderStateMixin {
  _State _state = _State.idle;

  // Idle — slow breathing glow on the button
  late AnimationController _breatheCtrl;

  // Idle — two rings orbit at different speeds
  late AnimationController _orbit1Ctrl;
  late AnimationController _orbit2Ctrl;

  // Searching — radar sweep
  late AnimationController _radarCtrl;

  // Searching — ripple rings expanding outward
  late AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _orbit1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _orbit2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    )..repeat();

    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _orbit1Ctrl.dispose();
    _orbit2Ctrl.dispose();
    _radarCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _startSearch() {
    HapticFeedback.heavyImpact();
    setState(() => _state = _State.searching);
    _radarCtrl.repeat();
    _rippleCtrl.repeat();
    _matchHost();
  }

  void _cancel() {
    _radarCtrl.stop();
    _radarCtrl.reset();
    _rippleCtrl.stop();
    _rippleCtrl.reset();
    setState(() => _state = _State.idle);
  }

  Future<void> _matchHost() async {
    final online = dummyHosts
        .where((h) => h.status == HostStatus.online)
        .toList();
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    if (online.isEmpty) {
      _cancel();
      _showSnackbar(
        'No hosts available right now. Try again soon!',
      );
      return;
    }

    final host = online[Random().nextInt(online.length)];
    _cancel();
    // TODO: pushScreenWithoutNavBar(context, OngoingCallScreen(...));
    debugPrint('Matched: ${host.displayName}');
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07070F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Starfield(),
          _state == _State.idle
              ? _buildIdle()
              : _buildSearching(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IDLE UI
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildIdle() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 48),

          // Header
          Text(
            'RANDOM CALL',
            style: GoogleFonts.orbitron(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Meet someone new',
            style: GoogleFonts.dmSans(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(),

          // Central portal button with orbiting rings
          SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ambient glow
                AnimatedBuilder(
                  animation: _breatheCtrl,
                  builder: (_, __) => Container(
                    width: 280 + (_breatheCtrl.value * 20),
                    height: 280 + (_breatheCtrl.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2D78)
                              .withValues(
                                alpha:
                                    0.12 +
                                    _breatheCtrl.value * 0.08,
                              ),
                          blurRadius:
                              60 + _breatheCtrl.value * 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),

                // Orbit ring 1
                AnimatedBuilder(
                  animation: _orbit1Ctrl,
                  builder: (_, __) => Transform.rotate(
                    angle: _orbit1Ctrl.value * 2 * pi,
                    child: _OrbitRing(
                      radius: 118,
                      dotColor: const Color(0xFFFF2D78),
                      dotCount: 5,
                      ringOpacity: 0.15,
                    ),
                  ),
                ),

                // Orbit ring 2 — counter-rotate, different color
                AnimatedBuilder(
                  animation: _orbit2Ctrl,
                  builder: (_, __) => Transform.rotate(
                    angle: -_orbit2Ctrl.value * 2 * pi,
                    child: _OrbitRing(
                      radius: 140,
                      dotColor: const Color(0xFF7B61FF),
                      dotCount: 3,
                      ringOpacity: 0.10,
                    ),
                  ),
                ),

                // Tap to call button
                GestureDetector(
                  onTap: _startSearch,
                  child: AnimatedBuilder(
                    animation: _breatheCtrl,
                    builder: (_, child) => Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFFFF5FA0),
                            Color(0xFFCC0050),
                          ],
                          center: Alignment(-0.3, -0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2D78)
                                .withValues(
                                  alpha:
                                      0.45 +
                                      _breatheCtrl.value * 0.2,
                                ),
                            blurRadius:
                                35 + _breatheCtrl.value * 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'START',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom hint
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${dummyHosts.where((h) => h.status == HostStatus.online).length} hosts online now',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCHING UI
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearching() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 48),

          Text(
            'CONNECTING',
            style: GoogleFonts.orbitron(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          _DotLoader(),

          const Spacer(),

          SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding ripple rings
                _buildRipple(260, offset: 0.0),
                _buildRipple(260, offset: 0.33),
                _buildRipple(260, offset: 0.66),

                // Radar sweep
                AnimatedBuilder(
                  animation: _radarCtrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(220, 220),
                    painter: _RadarPainter(_radarCtrl.value),
                  ),
                ),

                // Center avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFFFF2D78,
                      ).withValues(alpha: 0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFFF2D78,
                        ).withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://i.pravatar.cc/200?img=5',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Cancel
          Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: GestureDetector(
              onTap: _cancel,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(double maxSize, {required double offset}) {
    return AnimatedBuilder(
      animation: _rippleCtrl,
      builder: (_, __) {
        final t = (_rippleCtrl.value + (1.0 - offset)) % 1.0;
        return Container(
          width: maxSize * t,
          height: maxSize * t,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(
                0xFFFF2D78,
              ).withValues(alpha: (1 - t) * 0.5),
              width: 1.2,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orbit ring widget — ring + evenly spaced dot blobs
// ─────────────────────────────────────────────────────────────────────────────
class _OrbitRing extends StatelessWidget {
  const _OrbitRing({
    required this.radius,
    required this.dotColor,
    required this.dotCount,
    required this.ringOpacity,
  });
  final double radius;
  final Color dotColor;
  final int dotCount;
  final double ringOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _OrbitPainter(
          radius: radius,
          dotColor: dotColor,
          dotCount: dotCount,
          ringOpacity: ringOpacity,
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.radius,
    required this.dotColor,
    required this.dotCount,
    required this.ringOpacity,
  });
  final double radius;
  final Color dotColor;
  final int dotCount;
  final double ringOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = dotColor.withValues(alpha: ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Dots
    final dotPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.8);
    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * pi / dotCount) * i;
      final pos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawCircle(pos, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Radar sweep painter
// ─────────────────────────────────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  _RadarPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFF2D78).withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFF2D78).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Inner rings
    for (final r in [radius * 0.33, radius * 0.66]) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = const Color(
            0xFFFF2D78,
          ).withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // Sweep
    final sweepAngle = -pi / 2 + progress * 2 * pi;
    final sweepPaint = Paint()
      ..shader =
          SweepGradient(
            startAngle: sweepAngle - pi / 3,
            endAngle: sweepAngle,
            colors: [
              Colors.transparent,
              const Color(0xFFFF2D78).withValues(alpha: 0.55),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: radius),
          )
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweepAngle - pi / 3,
      pi / 3,
      true,
      sweepPaint,
    );

    // Leading edge line
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * cos(sweepAngle),
        center.dy + radius * sin(sweepAngle),
      ),
      Paint()
        ..color = const Color(0xFFFF2D78).withValues(alpha: 0.7)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated "..." dot loader
// ─────────────────────────────────────────────────────────────────────────────
class _DotLoader extends StatefulWidget {
  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final dots = (_ctrl.value * 4).floor() % 4;
        return Text(
          'Finding a host${'.' * dots}',
          style: GoogleFonts.dmSans(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 13,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtle star field background
// ─────────────────────────────────────────────────────────────────────────────
class _Starfield extends StatelessWidget {
  final List<_Star> stars = List.generate(60, (i) {
    final rng = Random(i * 31337);
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 1.5 + 0.4,
      opacity: rng.nextDouble() * 0.4 + 0.1,
    );
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarfieldPainter(stars));
  }
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
  final double x, y, size, opacity;
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter(this.stars);
  final List<_Star> stars;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        Paint()
          ..color = Colors.white.withValues(alpha: s.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => false;
}

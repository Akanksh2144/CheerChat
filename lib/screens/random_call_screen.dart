
// // lib/screens/random_call_screen.dart
// //
// // Intentionally always-dark immersive UI — space/radar aesthetic.
// // Background stays hardcoded near-black regardless of app theme.
// // Pink accent + snackbar pull from AppColors so the brand color
// // stays consistent if AppColors.dark.pink is ever updated.

// import 'dart:math';
// import 'package:cheerchat/data/hosts_data.dart';
// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// enum _State { idle, searching }

// class RandomCallScreen extends StatefulWidget {
//   const RandomCallScreen({super.key});
//   @override
//   State<RandomCallScreen> createState() =>
//       _RandomCallScreenState();
// }

// class _RandomCallScreenState extends State<RandomCallScreen>
//     with TickerProviderStateMixin {
//   _State _state = _State.idle;

//   late AnimationController _breatheCtrl;
//   late AnimationController _orbit1Ctrl;
//   late AnimationController _orbit2Ctrl;
//   late AnimationController _radarCtrl;
//   late AnimationController _rippleCtrl;

//   // Always-dark accent colors — intentional, this is a video call screen
//   static const Color _pink = Color(0xFFFF2D78);
//   static const Color _purple = Color(0xFF7B61FF);
//   // bg is dynamic — see _bgColor() below

//   @override
//   void initState() {
//     super.initState();
//     _breatheCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     )..repeat(reverse: true);

//     _orbit1Ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     )..repeat();

//     _orbit2Ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2700),
//     )..repeat();

//     _radarCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );

//     _rippleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );
//   }

//   @override
//   void dispose() {
//     _breatheCtrl.dispose();
//     _orbit1Ctrl.dispose();
//     _orbit2Ctrl.dispose();
//     _radarCtrl.dispose();
//     _rippleCtrl.dispose();
//     super.dispose();
//   }

//   void _startSearch() {
//     HapticFeedback.heavyImpact();
//     setState(() => _state = _State.searching);
//     _radarCtrl.repeat();
//     _rippleCtrl.repeat();
//     _matchHost();
//   }

//   void _cancel() {
//     _radarCtrl.stop();
//     _radarCtrl.reset();
//     _rippleCtrl.stop();
//     _rippleCtrl.reset();
//     setState(() => _state = _State.idle);
//   }

//   Future<void> _matchHost() async {
//     final online = dummyHosts
//         .where((h) => h.status == HostStatus.online)
//         .toList();
//     await Future.delayed(const Duration(seconds: 4));
//     if (!mounted) return;

//     if (online.isEmpty) {
//       _cancel();
//       _showSnackbar(
//         'No hosts available right now. Try again soon!',
//       );
//       return;
//     }

//     final host = online[Random().nextInt(online.length)];
//     _cancel();
//     // TODO: pushScreenWithoutNavBar(context, OngoingCallScreen(...));
//     debugPrint('Matched: ${host.displayName}');
//   }

//   void _showSnackbar(String msg) {
//     // Use app pink for the snackbar even on this always-dark screen
//     final pink = AppColors.of(context).pink;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: pink.withOpacity(0.15),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: pink.withOpacity(0.3)),
//         ),
//       ),
//     );
//   }

//   // Dynamic background — dark/light aware
//   Color _bgColor(BuildContext context) {
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     return isDark
//         ? const Color(0xFF07070F)
//         : const Color(0xFFFFF0F8);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: Theme.of(context).brightness == Brightness.dark
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: _bgColor(context),
//         body: Stack(
//           fit: StackFit.expand,
//           children: [
//             const _Starfield(),
//             _state == _State.idle
//                 ? _buildIdle(isDark)
//                 : _buildSearching(isDark),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Idle UI ───────────────────────────────────────────────────────────────

//   Widget _buildIdle(bool isDark) {
//     return SafeArea(
//       child: Column(
//         children: [
//           const SizedBox(height: 48),
//           Text(
//             'RANDOM CALL',
//             style: GoogleFonts.orbitron(
//               color: (isDark ? Colors.white : Colors.black)
//                   .withOpacity(0.85),
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 5,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Meet someone new',
//             style: GoogleFonts.dmSans(
//               color: (isDark ? Colors.white : Colors.black)
//                   .withOpacity(0.4),
//               fontSize: 13,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const Spacer(),

//           // Central portal button
//           SizedBox(
//             width: 320,
//             height: 320,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Ambient breathing glow
//                 AnimatedBuilder(
//                   animation: _breatheCtrl,
//                   builder: (_, __) => Container(
//                     width: 280 + (_breatheCtrl.value * 20),
//                     height: 280 + (_breatheCtrl.value * 20),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: _pink.withOpacity(
//                             0.12 + _breatheCtrl.value * 0.08,
//                           ),
//                           blurRadius:
//                               60 + _breatheCtrl.value * 30,
//                           spreadRadius: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Orbit ring 1
//                 AnimatedBuilder(
//                   animation: _orbit1Ctrl,
//                   builder: (_, __) => Transform.rotate(
//                     angle: _orbit1Ctrl.value * 2 * pi,
//                     child: const _OrbitRing(
//                       radius: 118,
//                       dotColor: _pink,
//                       dotCount: 5,
//                       ringOpacity: 0.15,
//                     ),
//                   ),
//                 ),

//                 // Orbit ring 2 — counter-rotate
//                 AnimatedBuilder(
//                   animation: _orbit2Ctrl,
//                   builder: (_, __) => Transform.rotate(
//                     angle: -_orbit2Ctrl.value * 2 * pi,
//                     child: const _OrbitRing(
//                       radius: 140,
//                       dotColor: _purple,
//                       dotCount: 3,
//                       ringOpacity: 0.10,
//                     ),
//                   ),
//                 ),

//                 // Tap-to-call button
//                 GestureDetector(
//                   onTap: _startSearch,
//                   child: AnimatedBuilder(
//                     animation: _breatheCtrl,
//                     builder: (_, child) => Container(
//                       width: 130,
//                       height: 130,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: const RadialGradient(
//                           colors: [
//                             Color(0xFFFF5FA0),
//                             Color(0xFFCC0050),
//                           ],
//                           center: Alignment(-0.3, -0.4),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _pink.withOpacity(
//                               0.45 + _breatheCtrl.value * 0.2,
//                             ),
//                             blurRadius:
//                                 35 + _breatheCtrl.value * 15,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: child,
//                     ),
//                     child: Column(
//                       mainAxisAlignment:
//                           MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.videocam_rounded,
//                           color: Colors.white,
//                           size: 38,
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           'START',
//                           style: GoogleFonts.orbitron(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Spacer(),

//           // Online count
//           Padding(
//             padding: const EdgeInsets.only(bottom: 40),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 6,
//                   height: 6,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFF00E676),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '${dummyHosts.where((h) => h.status == HostStatus.online).length}'
//                   ' hosts online now',
//                   style: GoogleFonts.dmSans(
//                     color: (isDark ? Colors.white : Colors.black)
//                         .withOpacity(0.45),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Searching UI ──────────────────────────────────────────────────────────

//   Widget _buildSearching(bool isDark) {
//     return SafeArea(
//       child: Column(
//         children: [
//           const SizedBox(height: 48),
//           Text(
//             'CONNECTING',
//             style: GoogleFonts.orbitron(
//               color: (isDark ? Colors.white : Colors.black)
//                   .withOpacity(0.85),
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 5,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const _DotLoader(),

//           const Spacer(),

//           SizedBox(
//             width: 320,
//             height: 320,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 _buildRipple(260, offset: 0.0),
//                 _buildRipple(260, offset: 0.33),
//                 _buildRipple(260, offset: 0.66),

//                 AnimatedBuilder(
//                   animation: _radarCtrl,
//                   builder: (_, __) => CustomPaint(
//                     size: const Size(220, 220),
//                     painter: _RadarPainter(
//                       _radarCtrl.value,
//                       _pink,
//                     ),
//                   ),
//                 ),

//                 // Center avatar placeholder
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: _pink.withOpacity(0.8),
//                       width: 2,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: _pink.withOpacity(0.3),
//                         blurRadius: 20,
//                       ),
//                     ],
//                     image: const DecorationImage(
//                       image: NetworkImage(
//                         'https://i.pravatar.cc/200?img=5',
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Spacer(),

//           // Cancel button
//           Padding(
//             padding: const EdgeInsets.only(bottom: 48),
//             child: GestureDetector(
//               onTap: _cancel,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 36,
//                   vertical: 15,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(40),
//                   border: Border.all(
//                     color: (isDark ? Colors.white : Colors.black)
//                         .withOpacity(0.15),
//                   ),
//                   color: (isDark ? Colors.white : Colors.black)
//                       .withOpacity(0.05),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: GoogleFonts.dmSans(
//                     color: (isDark ? Colors.white : Colors.black)
//                         .withOpacity(0.65),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRipple(double maxSize, {required double offset}) {
//     return AnimatedBuilder(
//       animation: _rippleCtrl,
//       builder: (_, __) {
//         final t = (_rippleCtrl.value + (1.0 - offset)) % 1.0;
//         return Container(
//           width: maxSize * t,
//           height: maxSize * t,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: _pink.withOpacity((1 - t) * 0.5),
//               width: 1.2,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Orbit ring ────────────────────────────────────────────────────────────────

// class _OrbitRing extends StatelessWidget {
//   const _OrbitRing({
//     required this.radius,
//     required this.dotColor,
//     required this.dotCount,
//     required this.ringOpacity,
//   });
//   final double radius;
//   final Color dotColor;
//   final int dotCount;
//   final double ringOpacity;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: radius * 2,
//       height: radius * 2,
//       child: CustomPaint(
//         painter: _OrbitPainter(
//           radius: radius,
//           dotColor: dotColor,
//           dotCount: dotCount,
//           ringOpacity: ringOpacity,
//         ),
//       ),
//     );
//   }
// }

// class _OrbitPainter extends CustomPainter {
//   const _OrbitPainter({
//     required this.radius,
//     required this.dotColor,
//     required this.dotCount,
//     required this.ringOpacity,
//   });
//   final double radius;
//   final Color dotColor;
//   final int dotCount;
//   final double ringOpacity;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     canvas.drawCircle(
//       center,
//       radius,
//       Paint()
//         ..color = dotColor.withOpacity(ringOpacity)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1,
//     );
//     final dotPaint = Paint()..color = dotColor.withOpacity(0.8);
//     for (int i = 0; i < dotCount; i++) {
//       final angle = (2 * pi / dotCount) * i;
//       canvas.drawCircle(
//         Offset(
//           center.dx + radius * cos(angle),
//           center.dy + radius * sin(angle),
//         ),
//         3.5,
//         dotPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(_OrbitPainter old) => false;
// }

// // ── Radar sweep painter ───────────────────────────────────────────────────────

// class _RadarPainter extends CustomPainter {
//   const _RadarPainter(this.progress, this.pink);
//   final double progress;
//   final Color pink;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     canvas.drawCircle(
//       center,
//       radius,
//       Paint()
//         ..color = pink.withOpacity(0.06)
//         ..style = PaintingStyle.fill,
//     );

//     canvas.drawCircle(
//       center,
//       radius,
//       Paint()
//         ..color = pink.withOpacity(0.25)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.2,
//     );

//     for (final r in [radius * 0.33, radius * 0.66]) {
//       canvas.drawCircle(
//         center,
//         r,
//         Paint()
//           ..color = pink.withOpacity(0.12)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 0.8,
//       );
//     }

//     final sweepAngle = -pi / 2 + progress * 2 * pi;
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       sweepAngle - pi / 3,
//       pi / 3,
//       true,
//       Paint()
//         ..shader =
//             SweepGradient(
//               startAngle: sweepAngle - pi / 3,
//               endAngle: sweepAngle,
//               colors: [
//                 Colors.transparent,
//                 pink.withOpacity(0.55),
//               ],
//             ).createShader(
//               Rect.fromCircle(center: center, radius: radius),
//             )
//         ..style = PaintingStyle.fill,
//     );

//     canvas.drawLine(
//       center,
//       Offset(
//         center.dx + radius * cos(sweepAngle),
//         center.dy + radius * sin(sweepAngle),
//       ),
//       Paint()
//         ..color = pink.withOpacity(0.7)
//         ..strokeWidth = 1.5,
//     );
//   }

//   @override
//   bool shouldRepaint(_RadarPainter old) =>
//       old.progress != progress;
// }

// // ── Dot loader ────────────────────────────────────────────────────────────────

// class _DotLoader extends StatefulWidget {
//   const _DotLoader();
//   @override
//   State<_DotLoader> createState() => _DotLoaderState();
// }

// class _DotLoaderState extends State<_DotLoader>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, __) {
//         final dots = (_ctrl.value * 4).floor() % 4;
//         return Text(
//           'Finding a host${'.' * dots}',
//           style: GoogleFonts.dmSans(
//             color:
//                 (Theme.of(context).brightness == Brightness.dark
//                         ? Colors.white
//                         : Colors.black)
//                     .withOpacity(0.4),
//             fontSize: 13,
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Starfield background ──────────────────────────────────────────────────────

// class _Starfield extends StatelessWidget {
//   const _Starfield();

//   @override
//   Widget build(BuildContext context) {
//     final stars = List.generate(60, (i) {
//       final rng = Random(i * 31337);
//       return _Star(
//         x: rng.nextDouble(),
//         y: rng.nextDouble(),
//         size: rng.nextDouble() * 1.5 + 0.4,
//         opacity: rng.nextDouble() * 0.4 + 0.1,
//       );
//     });
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     final starColor = isDark
//         ? const Color(0xFFFFFFFF)
//         : const Color(0xFFFF2D78);
//     return CustomPaint(
//       painter: _StarfieldPainter(stars, starColor),
//     );
//   }
// }

// class _Star {
//   const _Star({
//     required this.x,
//     required this.y,
//     required this.size,
//     required this.opacity,
//   });
//   final double x, y, size, opacity;
// }

// class _StarfieldPainter extends CustomPainter {
//   const _StarfieldPainter(this.stars, this.starColor);
//   final List<_Star> stars;
//   final Color starColor;

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final s in stars) {
//       canvas.drawCircle(
//         Offset(s.x * size.width, s.y * size.height),
//         s.size,
//         Paint()..color = starColor.withOpacity(s.opacity),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(_StarfieldPainter old) =>
//       old.starColor != starColor;
// }
// lib/screens/random_call_screen.dart
//
// Intentionally always-dark immersive UI — space/radar aesthetic.
// Background stays hardcoded near-black regardless of app theme.
// Pink accent + snackbar pull from AppColors so the brand color
// stays consistent if AppColors.dark.pink is ever updated.

import 'dart:math';
import 'package:cheerchat/data/hosts_data.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/theme/app_colors.dart';
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

  late AnimationController _breatheCtrl;
  late AnimationController _orbit1Ctrl;
  late AnimationController _orbit2Ctrl;
  late AnimationController _radarCtrl;
  late AnimationController _rippleCtrl;

  // Always-dark accent colors — intentional, this is a video call screen
  static const Color _pink = Color(0xFFFF2D78);
  static const Color _purple = Color(0xFF7B61FF);
  // bg is dynamic — see _bgColor() below

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
    // TODO: Navigator.of(context, rootNavigator: true).push(
    //         AppTransitions.scaleUp(OngoingCallScreen(host: host, ...)));
    debugPrint('Matched: ${host.displayName}');
  }

  void _showSnackbar(String msg) {
    // Use app pink for the snackbar even on this always-dark screen
    final pink = AppColors.of(context).pink;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: pink.withOpacity(0.15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: pink.withOpacity(0.3)),
        ),
      ),
    );
  }

  // Dynamic background — dark/light aware
  Color _bgColor(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF07070F)
        : const Color(0xFFFFF0F8);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor(context),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _Starfield(),
            _state == _State.idle
                ? _buildIdle(isDark)
                : _buildSearching(isDark),
          ],
        ),
      ),
    );
  }

  // ── Idle UI ───────────────────────────────────────────────────────────────

  Widget _buildIdle(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Text(
            'RANDOM CALL',
            style: GoogleFonts.orbitron(
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Meet someone new',
            style: GoogleFonts.dmSans(
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(0.4),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),

          // Central portal button
          SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient breathing glow
                AnimatedBuilder(
                  animation: _breatheCtrl,
                  builder: (_, __) => Container(
                    width: 280 + (_breatheCtrl.value * 20),
                    height: 280 + (_breatheCtrl.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _pink.withOpacity(
                            0.12 + _breatheCtrl.value * 0.08,
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
                    child: const _OrbitRing(
                      radius: 118,
                      dotColor: _pink,
                      dotCount: 5,
                      ringOpacity: 0.15,
                    ),
                  ),
                ),

                // Orbit ring 2 — counter-rotate
                AnimatedBuilder(
                  animation: _orbit2Ctrl,
                  builder: (_, __) => Transform.rotate(
                    angle: -_orbit2Ctrl.value * 2 * pi,
                    child: const _OrbitRing(
                      radius: 140,
                      dotColor: _purple,
                      dotCount: 3,
                      ringOpacity: 0.10,
                    ),
                  ),
                ),

                // Tap-to-call button
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
                            color: _pink.withOpacity(
                              0.45 + _breatheCtrl.value * 0.2,
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

          // Online count
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
                  '${dummyHosts.where((h) => h.status == HostStatus.online).length}'
                  ' hosts online now',
                  style: GoogleFonts.dmSans(
                    color: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.45),
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

  // ── Searching UI ──────────────────────────────────────────────────────────

  Widget _buildSearching(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Text(
            'CONNECTING',
            style: GoogleFonts.orbitron(
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          const _DotLoader(),

          const Spacer(),

          SizedBox(
            width: 320,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildRipple(260, offset: 0.0),
                _buildRipple(260, offset: 0.33),
                _buildRipple(260, offset: 0.66),

                AnimatedBuilder(
                  animation: _radarCtrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(220, 220),
                    painter: _RadarPainter(
                      _radarCtrl.value,
                      _pink,
                    ),
                  ),
                ),

                // Center avatar placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _pink.withOpacity(0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _pink.withOpacity(0.3),
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

          // Cancel button
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
                    color: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.15),
                  ),
                  color: (isDark ? Colors.white : Colors.black)
                      .withOpacity(0.05),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    color: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.65),
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
              color: _pink.withOpacity((1 - t) * 0.5),
              width: 1.2,
            ),
          ),
        );
      },
    );
  }
}

// ── Orbit ring ────────────────────────────────────────────────────────────────

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
  const _OrbitPainter({
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
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = dotColor.withOpacity(ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final dotPaint = Paint()..color = dotColor.withOpacity(0.8);
    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * pi / dotCount) * i;
      canvas.drawCircle(
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        3.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => false;
}

// ── Radar sweep painter ───────────────────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  const _RadarPainter(this.progress, this.pink);
  final double progress;
  final Color pink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = pink.withOpacity(0.06)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = pink.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    for (final r in [radius * 0.33, radius * 0.66]) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = pink.withOpacity(0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    final sweepAngle = -pi / 2 + progress * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweepAngle - pi / 3,
      pi / 3,
      true,
      Paint()
        ..shader =
            SweepGradient(
              startAngle: sweepAngle - pi / 3,
              endAngle: sweepAngle,
              colors: [
                Colors.transparent,
                pink.withOpacity(0.55),
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: radius),
            )
        ..style = PaintingStyle.fill,
    );

    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * cos(sweepAngle),
        center.dy + radius * sin(sweepAngle),
      ),
      Paint()
        ..color = pink.withOpacity(0.7)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress;
}

// ── Dot loader ────────────────────────────────────────────────────────────────

class _DotLoader extends StatefulWidget {
  const _DotLoader();
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
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.4),
            fontSize: 13,
          ),
        );
      },
    );
  }
}

// ── Starfield background ──────────────────────────────────────────────────────

class _Starfield extends StatelessWidget {
  const _Starfield();

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(60, (i) {
      final rng = Random(i * 31337);
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 1.5 + 0.4,
        opacity: rng.nextDouble() * 0.4 + 0.1,
      );
    });
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final starColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFFF2D78);
    return CustomPaint(
      painter: _StarfieldPainter(stars, starColor),
    );
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
  const _StarfieldPainter(this.stars, this.starColor);
  final List<_Star> stars;
  final Color starColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        Paint()..color = starColor.withOpacity(s.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) =>
      old.starColor != starColor;
}

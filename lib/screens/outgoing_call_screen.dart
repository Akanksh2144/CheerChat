// // // // // lib/screens/outgoing_call_screen.dart
// // // // //
// // // // // Shown to the CALLER while waiting for the host to accept/decline.
// // // // // Polls GET /api/calls/:sessionId/status every 2 seconds.
// // // // // - 'ongoing'  → still ringing
// // // // // - 'accepted' → host accepted → push OngoingCallScreen
// // // // // - 'ended'    → host declined → "Call Declined" snackbar → pop

// // // // import 'dart:async';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/services/call_api_service.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // class OutgoingCallScreen extends ConsumerStatefulWidget {
// // // //   const OutgoingCallScreen({
// // // //     super.key,
// // // //     required this.host,
// // // //     required this.initialCoins,
// // // //     required this.sessionId,
// // // //     required this.channelId,
// // // //     required this.token,
// // // //     required this.callerUid,
// // // //     this.isAlreadyFollowing = false,
// // // //   });

// // // //   final HostModel host;
// // // //   final int initialCoins;
// // // //   final String sessionId;
// // // //   final String channelId;
// // // //   final String token;
// // // //   final int callerUid;
// // // //   final bool isAlreadyFollowing;

// // // //   @override
// // // //   ConsumerState<OutgoingCallScreen> createState() =>
// // // //       _OutgoingCallScreenState();
// // // // }

// // // // class _OutgoingCallScreenState
// // // //     extends ConsumerState<OutgoingCallScreen>
// // // //     with TickerProviderStateMixin {
// // // //   Timer? _pollTimer;
// // // //   Timer? _timeoutTimer;
// // // //   int _secondsElapsed = 0;
// // // //   Timer? _tickTimer;
// // // //   bool _resolved = false;

// // // //   late final AnimationController _ringCtrl;
// // // //   late final AnimationController _pulseCtrl;
// // // //   late final Animation<double> _pulseAnim;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();

// // // //     _ringCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 2400),
// // // //     )..repeat();

// // // //     _pulseCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 1000),
// // // //     )..repeat(reverse: true);

// // // //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pulseCtrl,
// // // //         curve: Curves.easeInOut,
// // // //       ),
// // // //     );

// // // //     // Tick counter
// // // //     _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// // // //       if (mounted) setState(() => _secondsElapsed++);
// // // //     });

// // // //     // Poll backend every 2 seconds
// // // //     _pollTimer = Timer.periodic(
// // // //       const Duration(seconds: 2),
// // // //       (_) => _poll(),
// // // //     );

// // // //     // Auto-cancel after 20 seconds
// // // //     _timeoutTimer = Timer(const Duration(seconds: 20), () {
// // // //       if (!_resolved) _cancel(showMessage: 'No answer');
// // // //     });
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pollTimer?.cancel();
// // // //     _timeoutTimer?.cancel();
// // // //     _tickTimer?.cancel();
// // // //     _ringCtrl.dispose();
// // // //     _pulseCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   Future<void> _poll() async {
// // // //     if (_resolved) return;
// // // //     try {
// // // //       final callApi = ref.read(callApiServiceProvider);
// // // //       final status = await callApi.getSessionStatus(
// // // //         widget.sessionId,
// // // //       );

// // // //       if (!mounted || _resolved) return;

// // // //       if (status == 'accepted') {
// // // //         _resolved = true;
// // // //         _pollTimer?.cancel();
// // // //         _timeoutTimer?.cancel();
// // // //         // Host accepted — push to OngoingCallScreen
// // // //         Navigator.of(context).pushReplacement(
// // // //           MaterialPageRoute(
// // // //             builder: (_) => OngoingCallScreen(
// // // //               host: widget.host,
// // // //               initialCoins: widget.initialCoins,
// // // //               sessionId: widget.sessionId,
// // // //               channelId: widget.channelId,
// // // //               token: widget.token,
// // // //               localUid: widget.callerUid,
// // // //               isAlreadyFollowing: widget.isAlreadyFollowing,
// // // //             ),
// // // //           ),
// // // //         );
// // // //       } else if (status == 'ended') {
// // // //         _resolved = true;
// // // //         _cancel(showMessage: 'Call Declined');
// // // //       }
// // // //     } catch (_) {}
// // // //   }

// // // //   void _cancel({String? showMessage}) {
// // // //     if (_resolved && showMessage == null) return;
// // // //     _resolved = true;
// // // //     _pollTimer?.cancel();
// // // //     _timeoutTimer?.cancel();

// // // //     // End the session server-side
// // // //     final callApi = ref.read(callApiServiceProvider);
// // // //     callApi.endCall(
// // // //       sessionId: widget.sessionId,
// // // //       endedBy: 'caller',
// // // //     );

// // // //     if (mounted) {
// // // //       if (showMessage != null) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(
// // // //             content: Text(showMessage),
// // // //             backgroundColor: Colors.grey.shade800,
// // // //             behavior: SnackBarBehavior.floating,
// // // //             duration: const Duration(seconds: 2),
// // // //             shape: RoundedRectangleBorder(
// // // //               borderRadius: BorderRadius.circular(12),
// // // //             ),
// // // //           ),
// // // //         );
// // // //       }
// // // //       Navigator.of(context).pop();
// // // //     }
// // // //   }

// // // //   String get _formattedTime {
// // // //     final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
// // // //     final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
// // // //     return '$m:$s';
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return PopScope(
// // // //       canPop: false,
// // // //       onPopInvokedWithResult: (didPop, _) {
// // // //         if (!didPop) _cancel();
// // // //       },
// // // //       child: Scaffold(
// // // //         body: Container(
// // // //           decoration: const BoxDecoration(
// // // //             gradient: LinearGradient(
// // // //               begin: Alignment.topCenter,
// // // //               end: Alignment.bottomCenter,
// // // //               colors: [
// // // //                 Color(0xFF1A0A2E),
// // // //                 Color(0xFF16213E),
// // // //                 Color(0xFF0A0A14),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           child: SafeArea(
// // // //             child: Column(
// // // //               children: [
// // // //                 const Spacer(flex: 1),
// // // //                 // "Calling..." label
// // // //                 Container(
// // // //                   padding: const EdgeInsets.symmetric(
// // // //                     horizontal: 20,
// // // //                     vertical: 8,
// // // //                   ),
// // // //                   decoration: BoxDecoration(
// // // //                     color: Colors.green.withOpacity(0.12),
// // // //                     borderRadius: BorderRadius.circular(20),
// // // //                     border: Border.all(
// // // //                       color: Colors.green.withOpacity(0.2),
// // // //                     ),
// // // //                   ),
// // // //                   child: Row(
// // // //                     mainAxisSize: MainAxisSize.min,
// // // //                     children: [
// // // //                       _PulsingDot(color: Colors.green),
// // // //                       const SizedBox(width: 10),
// // // //                       Text(
// // // //                         'Calling  •  $_formattedTime',
// // // //                         style: const TextStyle(
// // // //                           color: Colors.green,
// // // //                           fontSize: 13,
// // // //                           fontWeight: FontWeight.w600,
// // // //                           letterSpacing: 0.5,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const Spacer(flex: 2),
// // // //                 // Animated rings + avatar
// // // //                 SizedBox(
// // // //                   width: 220,
// // // //                   height: 220,
// // // //                   child: Stack(
// // // //                     alignment: Alignment.center,
// // // //                     children: [
// // // //                       // Ring 1
// // // //                       AnimatedBuilder(
// // // //                         animation: _ringCtrl,
// // // //                         builder: (_, __) {
// // // //                           final val = _ringCtrl.value;
// // // //                           return Container(
// // // //                             width: 160 + (60 * val),
// // // //                             height: 160 + (60 * val),
// // // //                             decoration: BoxDecoration(
// // // //                               shape: BoxShape.circle,
// // // //                               border: Border.all(
// // // //                                 color: Colors.pink.withOpacity(
// // // //                                   0.25 * (1 - val),
// // // //                                 ),
// // // //                                 width: 2,
// // // //                               ),
// // // //                             ),
// // // //                           );
// // // //                         },
// // // //                       ),
// // // //                       // Ring 2 (offset)
// // // //                       AnimatedBuilder(
// // // //                         animation: _ringCtrl,
// // // //                         builder: (_, __) {
// // // //                           final val =
// // // //                               (_ringCtrl.value + 0.5) % 1.0;
// // // //                           return Container(
// // // //                             width: 160 + (60 * val),
// // // //                             height: 160 + (60 * val),
// // // //                             decoration: BoxDecoration(
// // // //                               shape: BoxShape.circle,
// // // //                               border: Border.all(
// // // //                                 color: Colors.pink.withOpacity(
// // // //                                   0.15 * (1 - val),
// // // //                                 ),
// // // //                                 width: 1.5,
// // // //                               ),
// // // //                             ),
// // // //                           );
// // // //                         },
// // // //                       ),
// // // //                       // Avatar
// // // //                       ScaleTransition(
// // // //                         scale: _pulseAnim,
// // // //                         child: Container(
// // // //                           width: 130,
// // // //                           height: 130,
// // // //                           decoration: BoxDecoration(
// // // //                             shape: BoxShape.circle,
// // // //                             gradient: LinearGradient(
// // // //                               begin: Alignment.topLeft,
// // // //                               end: Alignment.bottomRight,
// // // //                               colors: [
// // // //                                 Colors.pink.withOpacity(0.5),
// // // //                                 Colors.purple.withOpacity(0.3),
// // // //                               ],
// // // //                             ),
// // // //                             boxShadow: [
// // // //                               BoxShadow(
// // // //                                 color: Colors.pink.withOpacity(
// // // //                                   0.3,
// // // //                                 ),
// // // //                                 blurRadius: 30,
// // // //                                 spreadRadius: 5,
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                           child:
// // // //                               widget.host.profilePhotoUrl != null
// // // //                               ? ClipOval(
// // // //                                   child: Image.network(
// // // //                                     widget.host.profilePhotoUrl!,
// // // //                                     fit: BoxFit.cover,
// // // //                                     errorBuilder: (_, __, ___) =>
// // // //                                         const Icon(
// // // //                                           Icons.person,
// // // //                                           size: 56,
// // // //                                           color: Colors.white70,
// // // //                                         ),
// // // //                                   ),
// // // //                                 )
// // // //                               : const Icon(
// // // //                                   Icons.person,
// // // //                                   size: 56,
// // // //                                   color: Colors.white70,
// // // //                                 ),
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 28),
// // // //                 // Host name
// // // //                 Text(
// // // //                   widget.host.displayName,
// // // //                   style: GoogleFonts.lato(
// // // //                     color: Colors.white,
// // // //                     fontSize: 28,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 8),
// // // //                 Text(
// // // //                   'Ringing...',
// // // //                   style: TextStyle(
// // // //                     color: Colors.white.withOpacity(0.4),
// // // //                     fontSize: 15,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 6),
// // // //                 Text(
// // // //                   '${widget.host.priceCoins} coins/min',
// // // //                   style: TextStyle(
// // // //                     color: Colors.amber.withOpacity(0.6),
// // // //                     fontSize: 12,
// // // //                   ),
// // // //                 ),
// // // //                 const Spacer(flex: 3),
// // // //                 // Cancel button
// // // //                 GestureDetector(
// // // //                   onTap: () =>
// // // //                       _cancel(showMessage: 'Call cancelled'),
// // // //                   child: Container(
// // // //                     width: 72,
// // // //                     height: 72,
// // // //                     decoration: BoxDecoration(
// // // //                       shape: BoxShape.circle,
// // // //                       gradient: const LinearGradient(
// // // //                         begin: Alignment.topLeft,
// // // //                         end: Alignment.bottomRight,
// // // //                         colors: [
// // // //                           Color(0xFFFF4444),
// // // //                           Color(0xFFCC0000),
// // // //                         ],
// // // //                       ),
// // // //                       boxShadow: [
// // // //                         BoxShadow(
// // // //                           color: Colors.red.withOpacity(0.4),
// // // //                           blurRadius: 16,
// // // //                           offset: const Offset(0, 4),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     child: const Icon(
// // // //                       Icons.call_end_rounded,
// // // //                       color: Colors.white,
// // // //                       size: 32,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 12),
// // // //                 Text(
// // // //                   'Cancel',
// // // //                   style: TextStyle(
// // // //                     color: Colors.white.withOpacity(0.4),
// // // //                     fontSize: 13,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 50),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // ── Pulsing green dot ────────────────────────────────────────────────────────

// // // // class _PulsingDot extends StatefulWidget {
// // // //   const _PulsingDot({required this.color});
// // // //   final Color color;

// // // //   @override
// // // //   State<_PulsingDot> createState() => _PulsingDotState();
// // // // }

// // // // class _PulsingDotState extends State<_PulsingDot>
// // // //     with SingleTickerProviderStateMixin {
// // // //   late final AnimationController _ctrl;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _ctrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 800),
// // // //     )..repeat(reverse: true);
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _ctrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return AnimatedBuilder(
// // // //       animation: _ctrl,
// // // //       builder: (_, __) => Container(
// // // //         width: 8,
// // // //         height: 8,
// // // //         decoration: BoxDecoration(
// // // //           shape: BoxShape.circle,
// // // //           color: widget.color.withOpacity(
// // // //             0.5 + 0.5 * _ctrl.value,
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/screens/outgoing_call_screen.dart
// // // //
// // // // Shown to the CALLER while waiting for the host to accept/decline.
// // // // Polls GET /api/calls/:sessionId/status every 2 seconds.
// // // // - 'ongoing'  → still ringing
// // // // - 'accepted' → host accepted → push OngoingCallScreen
// // // // - 'ended'    → host declined → "Call Declined" snackbar → pop

// // // import 'dart:async';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // class OutgoingCallScreen extends ConsumerStatefulWidget {
// // //   const OutgoingCallScreen({
// // //     super.key,
// // //     required this.host,
// // //     required this.initialCoins,
// // //     required this.sessionId,
// // //     required this.channelId,
// // //     required this.token,
// // //     required this.callerUid,
// // //     this.isAlreadyFollowing = false,
// // //   });

// // //   final HostModel host;
// // //   final int initialCoins;
// // //   final String sessionId;
// // //   final String channelId;
// // //   final String token;
// // //   final int callerUid;
// // //   final bool isAlreadyFollowing;

// // //   @override
// // //   ConsumerState<OutgoingCallScreen> createState() =>
// // //       _OutgoingCallScreenState();
// // // }

// // // class _OutgoingCallScreenState extends ConsumerState<OutgoingCallScreen>
// // //     with TickerProviderStateMixin {
// // //   Timer? _pollTimer;
// // //   Timer? _timeoutTimer;
// // //   int _secondsElapsed = 0;
// // //   Timer? _tickTimer;
// // //   bool _resolved = false;

// // //   late final AnimationController _ringCtrl;
// // //   late final AnimationController _pulseCtrl;
// // //   late final Animation<double> _pulseAnim;

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     _ringCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 2400),
// // //     )..repeat();

// // //     _pulseCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 1000),
// // //     )..repeat(reverse: true);

// // //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
// // //       CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
// // //     );

// // //     // Tick counter
// // //     _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// // //       if (mounted) setState(() => _secondsElapsed++);
// // //     });

// // //     // Poll backend every 2 seconds
// // //     _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());

// // //     // Auto-cancel after 20 seconds
// // //     _timeoutTimer = Timer(const Duration(seconds: 20), () {
// // //       if (!_resolved) _cancel(showMessage: 'No answer');
// // //     });
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pollTimer?.cancel();
// // //     _timeoutTimer?.cancel();
// // //     _tickTimer?.cancel();
// // //     _ringCtrl.dispose();
// // //     _pulseCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   Future<void> _poll() async {
// // //     if (_resolved) return;
// // //     try {
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final status = await callApi.getSessionStatus(widget.sessionId);

// // //       if (!mounted || _resolved) return;

// // //       if (status == 'accepted') {
// // //         _resolved = true;
// // //         _pollTimer?.cancel();
// // //         _timeoutTimer?.cancel();
// // //         // Host accepted — push to OngoingCallScreen
// // //         Navigator.of(context).pushReplacement(
// // //           MaterialPageRoute(
// // //             builder: (_) => OngoingCallScreen(
// // //               host: widget.host,
// // //               initialCoins: widget.initialCoins,
// // //               sessionId: widget.sessionId,
// // //               channelId: widget.channelId,
// // //               token: widget.token,
// // //               localUid: widget.callerUid,
// // //               isAlreadyFollowing: widget.isAlreadyFollowing,
// // //             ),
// // //           ),
// // //         );
// // //       } else if (status == 'ended') {
// // //         _resolved = true;
// // //         _cancel(showMessage: 'Call Declined');
// // //       }
// // //     } catch (_) {}
// // //   }

// // //   void _cancel({String? showMessage}) {
// // //     if (_resolved && showMessage == null) return;
// // //     _resolved = true;
// // //     _pollTimer?.cancel();
// // //     _timeoutTimer?.cancel();

// // //     // End the session server-side
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.endCall(sessionId: widget.sessionId, endedBy: 'caller');

// // //     if (mounted) {
// // //       if (showMessage != null) {
// // //         ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
// // //           SnackBar(
// // //             content: Text(showMessage),
// // //             backgroundColor: Colors.grey.shade800,
// // //             behavior: SnackBarBehavior.floating,
// // //             duration: const Duration(milliseconds: 1500),
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(12),
// // //             ),
// // //           ),
// // //         );
// // //       }
// // //       Navigator.of(context).pop();
// // //     }
// // //   }

// // //   String get _formattedTime {
// // //     final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
// // //     final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
// // //     return '$m:$s';
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return PopScope(
// // //       canPop: false,
// // //       onPopInvokedWithResult: (didPop, _) {
// // //         if (!didPop) _cancel();
// // //       },
// // //       child: Scaffold(
// // //         body: Container(
// // //           decoration: const BoxDecoration(
// // //             gradient: LinearGradient(
// // //               begin: Alignment.topCenter,
// // //               end: Alignment.bottomCenter,
// // //               colors: [
// // //                 Color(0xFF1A0A2E),
// // //                 Color(0xFF16213E),
// // //                 Color(0xFF0A0A14),
// // //               ],
// // //             ),
// // //           ),
// // //           child: SafeArea(
// // //             child: Column(
// // //               children: [
// // //                 const Spacer(flex: 1),
// // //                 // "Calling..." label
// // //                 Container(
// // //                   padding: const EdgeInsets.symmetric(
// // //                     horizontal: 20,
// // //                     vertical: 8,
// // //                   ),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.green.withOpacity(0.12),
// // //                     borderRadius: BorderRadius.circular(20),
// // //                     border: Border.all(
// // //                       color: Colors.green.withOpacity(0.2),
// // //                     ),
// // //                   ),
// // //                   child: Row(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       _PulsingDot(color: Colors.green),
// // //                       const SizedBox(width: 10),
// // //                       Text(
// // //                         'Calling  •  $_formattedTime',
// // //                         style: const TextStyle(
// // //                           color: Colors.green,
// // //                           fontSize: 13,
// // //                           fontWeight: FontWeight.w600,
// // //                           letterSpacing: 0.5,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const Spacer(flex: 2),
// // //                 // Animated rings + avatar
// // //                 SizedBox(
// // //                   width: 220,
// // //                   height: 220,
// // //                   child: Stack(
// // //                     alignment: Alignment.center,
// // //                     children: [
// // //                       // Ring 1
// // //                       AnimatedBuilder(
// // //                         animation: _ringCtrl,
// // //                         builder: (_, __) {
// // //                           final val = _ringCtrl.value;
// // //                           return Container(
// // //                             width: 160 + (60 * val),
// // //                             height: 160 + (60 * val),
// // //                             decoration: BoxDecoration(
// // //                               shape: BoxShape.circle,
// // //                               border: Border.all(
// // //                                 color: Colors.pink
// // //                                     .withOpacity(0.25 * (1 - val)),
// // //                                 width: 2,
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                       // Ring 2 (offset)
// // //                       AnimatedBuilder(
// // //                         animation: _ringCtrl,
// // //                         builder: (_, __) {
// // //                           final val = (_ringCtrl.value + 0.5) % 1.0;
// // //                           return Container(
// // //                             width: 160 + (60 * val),
// // //                             height: 160 + (60 * val),
// // //                             decoration: BoxDecoration(
// // //                               shape: BoxShape.circle,
// // //                               border: Border.all(
// // //                                 color: Colors.pink
// // //                                     .withOpacity(0.15 * (1 - val)),
// // //                                 width: 1.5,
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                       // Avatar
// // //                       ScaleTransition(
// // //                         scale: _pulseAnim,
// // //                         child: Container(
// // //                           width: 130,
// // //                           height: 130,
// // //                           decoration: BoxDecoration(
// // //                             shape: BoxShape.circle,
// // //                             gradient: LinearGradient(
// // //                               begin: Alignment.topLeft,
// // //                               end: Alignment.bottomRight,
// // //                               colors: [
// // //                                 Colors.pink.withOpacity(0.5),
// // //                                 Colors.purple.withOpacity(0.3),
// // //                               ],
// // //                             ),
// // //                             boxShadow: [
// // //                               BoxShadow(
// // //                                 color: Colors.pink.withOpacity(0.3),
// // //                                 blurRadius: 30,
// // //                                 spreadRadius: 5,
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           child: widget.host.profilePhotoUrl != null
// // //                               ? ClipOval(
// // //                                   child: Image.network(
// // //                                     widget.host.profilePhotoUrl!,
// // //                                     fit: BoxFit.cover,
// // //                                     errorBuilder: (_, __, ___) =>
// // //                                         const Icon(
// // //                                       Icons.person,
// // //                                       size: 56,
// // //                                       color: Colors.white70,
// // //                                     ),
// // //                                   ),
// // //                                 )
// // //                               : const Icon(
// // //                                   Icons.person,
// // //                                   size: 56,
// // //                                   color: Colors.white70,
// // //                                 ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 28),
// // //                 // Host name
// // //                 Text(
// // //                   widget.host.displayName,
// // //                   style: GoogleFonts.lato(
// // //                     color: Colors.white,
// // //                     fontSize: 28,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 Text(
// // //                   'Ringing...',
// // //                   style: TextStyle(
// // //                     color: Colors.white.withOpacity(0.4),
// // //                     fontSize: 15,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 6),
// // //                 Text(
// // //                   '${widget.host.priceCoins} coins/min',
// // //                   style: TextStyle(
// // //                     color: Colors.amber.withOpacity(0.6),
// // //                     fontSize: 12,
// // //                   ),
// // //                 ),
// // //                 const Spacer(flex: 3),
// // //                 // Cancel button
// // //                 GestureDetector(
// // //                   onTap: () => _cancel(showMessage: 'Call cancelled'),
// // //                   child: Container(
// // //                     width: 72,
// // //                     height: 72,
// // //                     decoration: BoxDecoration(
// // //                       shape: BoxShape.circle,
// // //                       gradient: const LinearGradient(
// // //                         begin: Alignment.topLeft,
// // //                         end: Alignment.bottomRight,
// // //                         colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
// // //                       ),
// // //                       boxShadow: [
// // //                         BoxShadow(
// // //                           color: Colors.red.withOpacity(0.4),
// // //                           blurRadius: 16,
// // //                           offset: const Offset(0, 4),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     child: const Icon(
// // //                       Icons.call_end_rounded,
// // //                       color: Colors.white,
// // //                       size: 32,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 12),
// // //                 Text(
// // //                   'Cancel',
// // //                   style: TextStyle(
// // //                     color: Colors.white.withOpacity(0.4),
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 50),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ── Pulsing green dot ────────────────────────────────────────────────────────

// // // class _PulsingDot extends StatefulWidget {
// // //   const _PulsingDot({required this.color});
// // //   final Color color;

// // //   @override
// // //   State<_PulsingDot> createState() => _PulsingDotState();
// // // }

// // // class _PulsingDotState extends State<_PulsingDot>
// // //     with SingleTickerProviderStateMixin {
// // //   late final AnimationController _ctrl;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _ctrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 800),
// // //     )..repeat(reverse: true);
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _ctrl.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return AnimatedBuilder(
// // //       animation: _ctrl,
// // //       builder: (_, __) => Container(
// // //         width: 8,
// // //         height: 8,
// // //         decoration: BoxDecoration(
// // //           shape: BoxShape.circle,
// // //           color: widget.color.withOpacity(0.5 + 0.5 * _ctrl.value),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/screens/outgoing_call_screen.dart
// // //
// // // Shown to the CALLER while waiting for the host to accept/decline.
// // // Polls GET /api/calls/:sessionId/status every 2 seconds.

// // import 'dart:async';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // class OutgoingCallScreen extends ConsumerStatefulWidget {
// //   const OutgoingCallScreen({
// //     super.key,
// //     required this.host,
// //     required this.initialCoins,
// //     required this.sessionId,
// //     required this.channelId,
// //     required this.token,
// //     required this.callerUid,
// //     this.isAlreadyFollowing = false,
// //   });

// //   final HostModel host;
// //   final int initialCoins;
// //   final String sessionId;
// //   final String channelId;
// //   final String token;
// //   final int callerUid;
// //   final bool isAlreadyFollowing;

// //   @override
// //   ConsumerState<OutgoingCallScreen> createState() =>
// //       _OutgoingCallScreenState();
// // }

// // class _OutgoingCallScreenState
// //     extends ConsumerState<OutgoingCallScreen>
// //     with TickerProviderStateMixin {
// //   Timer? _pollTimer;
// //   Timer? _timeoutTimer;
// //   Timer? _tickTimer;
// //   int _secondsElapsed = 0;
// //   bool _resolved = false;

// //   late final AnimationController _ring1Ctrl;
// //   late final AnimationController _ring2Ctrl;
// //   late final AnimationController _pulseCtrl;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _ring1Ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 2200),
// //     )..repeat();

// //     _ring2Ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 2200),
// //     );
// //     Future.delayed(const Duration(milliseconds: 1100), () {
// //       if (mounted) _ring2Ctrl.repeat();
// //     });

// //     _pulseCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1200),
// //     )..repeat(reverse: true);

// //     _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// //       if (mounted) setState(() => _secondsElapsed++);
// //     });

// //     _pollTimer = Timer.periodic(
// //       const Duration(seconds: 2),
// //       (_) => _poll(),
// //     );

// //     _timeoutTimer = Timer(const Duration(seconds: 20), () {
// //       if (!_resolved) _cancel(showMessage: 'No answer');
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _pollTimer?.cancel();
// //     _timeoutTimer?.cancel();
// //     _tickTimer?.cancel();
// //     _ring1Ctrl.dispose();
// //     _ring2Ctrl.dispose();
// //     _pulseCtrl.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _poll() async {
// //     if (_resolved) return;
// //     try {
// //       final callApi = ref.read(callApiServiceProvider);
// //       final status = await callApi.getSessionStatus(
// //         widget.sessionId,
// //       );
// //       if (!mounted || _resolved) return;

// //       if (status == 'accepted') {
// //         _resolved = true;
// //         _pollTimer?.cancel();
// //         _timeoutTimer?.cancel();
// //         Navigator.of(context).pushReplacement(
// //           MaterialPageRoute(
// //             builder: (_) => OngoingCallScreen(
// //               host: widget.host,
// //               initialCoins: widget.initialCoins,
// //               sessionId: widget.sessionId,
// //               channelId: widget.channelId,
// //               token: widget.token,
// //               localUid: widget.callerUid,
// //               isAlreadyFollowing: widget.isAlreadyFollowing,
// //             ),
// //           ),
// //         );
// //       } else if (status == 'ended') {
// //         _resolved = true;
// //         _cancel(showMessage: 'Call Declined');
// //       }
// //     } catch (_) {}
// //   }

// //   void _cancel({String? showMessage}) {
// //     if (_resolved && showMessage == null) return;
// //     _resolved = true;
// //     _pollTimer?.cancel();
// //     _timeoutTimer?.cancel();

// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.endCall(
// //       sessionId: widget.sessionId,
// //       endedBy: 'caller',
// //     );

// //     if (mounted) {
// //       if (showMessage != null) {
// //         ScaffoldMessenger.of(context)
// //           ..clearSnackBars()
// //           ..showSnackBar(
// //             SnackBar(
// //               content: Text(showMessage),
// //               duration: const Duration(milliseconds: 1500),
// //               backgroundColor: Colors.grey.shade800,
// //               behavior: SnackBarBehavior.floating,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //           );
// //       }
// //       Navigator.of(context).pop();
// //     }
// //   }

// //   String get _formattedTime {
// //     final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
// //     final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
// //     return '$m:$s';
// //   }

// //   Widget _buildRing(AnimationController ctrl, double maxSize) {
// //     return AnimatedBuilder(
// //       animation: ctrl,
// //       builder: (_, __) {
// //         final val = ctrl.value;
// //         final size = maxSize * 0.6 + (maxSize * 0.4 * val);
// //         return Container(
// //           width: size,
// //           height: size,
// //           decoration: BoxDecoration(
// //             shape: BoxShape.circle,
// //             border: Border.all(
// //               color: const Color(
// //                 0xFFE91E63,
// //               ).withOpacity(0.3 * (1 - val)),
// //               width: 2 * (1 - val) + 0.5,
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final mq = MediaQuery.of(context);
// //     final sw = mq.size.width;
// //     final sh = mq.size.height;
// //     final avatarSize = (sw * 0.32).clamp(100.0, 150.0);
// //     final ringArea = avatarSize + 80;

// //     return PopScope(
// //       canPop: false,
// //       onPopInvokedWithResult: (didPop, _) {
// //         if (!didPop) _cancel();
// //       },
// //       child: Scaffold(
// //         body: SizedBox.expand(
// //           child: DecoratedBox(
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   Color(0xFF1A0A2E),
// //                   Color(0xFF16213E),
// //                   Color(0xFF0A0A14),
// //                 ],
// //               ),
// //             ),
// //             child: SafeArea(
// //               child: Column(
// //                 children: [
// //                   SizedBox(height: sh * 0.06),

// //                   // Calling badge
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 20,
// //                       vertical: 10,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(24),
// //                       border: Border.all(
// //                         color: Colors.green.withOpacity(0.2),
// //                       ),
// //                     ),
// //                     child: Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         AnimatedBuilder(
// //                           animation: _pulseCtrl,
// //                           builder: (_, __) => Container(
// //                             width: 8,
// //                             height: 8,
// //                             decoration: BoxDecoration(
// //                               shape: BoxShape.circle,
// //                               color: Colors.green.withOpacity(
// //                                 0.5 + 0.5 * _pulseCtrl.value,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 10),
// //                         Text(
// //                           'Calling  •  $_formattedTime',
// //                           style: GoogleFonts.poppins(
// //                             color: Colors.green.shade300,
// //                             fontSize: 13,
// //                             fontWeight: FontWeight.w600,
// //                             letterSpacing: 0.3,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   const Spacer(flex: 2),

// //                   // Rings + Avatar
// //                   SizedBox(
// //                     width: ringArea,
// //                     height: ringArea,
// //                     child: Stack(
// //                       alignment: Alignment.center,
// //                       children: [
// //                         _buildRing(_ring1Ctrl, ringArea),
// //                         _buildRing(_ring2Ctrl, ringArea),
// //                         // Avatar
// //                         ScaleTransition(
// //                           scale:
// //                               Tween<double>(
// //                                 begin: 0.97,
// //                                 end: 1.03,
// //                               ).animate(
// //                                 CurvedAnimation(
// //                                   parent: _pulseCtrl,
// //                                   curve: Curves.easeInOut,
// //                                 ),
// //                               ),
// //                           child: Container(
// //                             width: avatarSize,
// //                             height: avatarSize,
// //                             decoration: BoxDecoration(
// //                               shape: BoxShape.circle,
// //                               gradient: const LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [
// //                                   Color(0xFFE91E63),
// //                                   Color(0xFF9C27B0),
// //                                 ],
// //                               ),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: const Color(
// //                                     0xFFE91E63,
// //                                   ).withOpacity(0.35),
// //                                   blurRadius: 40,
// //                                   spreadRadius: 8,
// //                                 ),
// //                               ],
// //                             ),
// //                             child: ClipOval(
// //                               child:
// //                                   widget.host.profilePhotoUrl !=
// //                                       null
// //                                   ? Image.network(
// //                                       widget
// //                                           .host
// //                                           .profilePhotoUrl!,
// //                                       fit: BoxFit.cover,
// //                                       errorBuilder:
// //                                           (_, __, ___) => Icon(
// //                                             Icons.person_rounded,
// //                                             size:
// //                                                 avatarSize *
// //                                                 0.45,
// //                                             color:
// //                                                 Colors.white70,
// //                                           ),
// //                                     )
// //                                   : Icon(
// //                                       Icons.person_rounded,
// //                                       size: avatarSize * 0.45,
// //                                       color: Colors.white70,
// //                                     ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   SizedBox(height: sh * 0.04),

// //                   // Host name
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 24,
// //                     ),
// //                     child: Text(
// //                       widget.host.displayName,
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.white,
// //                         fontSize: (sw * 0.07).clamp(22.0, 32.0),
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                       textAlign: TextAlign.center,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //                   Text(
// //                     'Ringing...',
// //                     style: TextStyle(
// //                       color: Colors.white.withOpacity(0.35),
// //                       fontSize: 15,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     '${widget.host.priceCoins} coins/min',
// //                     style: TextStyle(
// //                       color: Colors.amber.withOpacity(0.5),
// //                       fontSize: 12,
// //                     ),
// //                   ),

// //                   const Spacer(flex: 3),

// //                   // Cancel button
// //                   GestureDetector(
// //                     onTap: () =>
// //                         _cancel(showMessage: 'Call cancelled'),
// //                     child: Container(
// //                       width: (sw * 0.17).clamp(64.0, 78.0),
// //                       height: (sw * 0.17).clamp(64.0, 78.0),
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         gradient: const LinearGradient(
// //                           begin: Alignment.topLeft,
// //                           end: Alignment.bottomRight,
// //                           colors: [
// //                             Color(0xFFFF4444),
// //                             Color(0xFFCC0000),
// //                           ],
// //                         ),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.red.withOpacity(0.4),
// //                             blurRadius: 20,
// //                             offset: const Offset(0, 6),
// //                           ),
// //                         ],
// //                       ),
// //                       child: const Icon(
// //                         Icons.call_end_rounded,
// //                         color: Colors.white,
// //                         size: 30,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Text(
// //                     'Cancel',
// //                     style: TextStyle(
// //                       color: Colors.white.withOpacity(0.3),
// //                       fontSize: 13,
// //                     ),
// //                   ),
// //                   SizedBox(height: mq.padding.bottom + 30),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/screens/outgoing_call_screen.dart
// //
// // Shown to the CALLER while waiting for the host to accept/decline.
// // Polls GET /api/calls/:sessionId/status every 2 seconds.

// import 'dart:async';

// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/screens/ongoing_call_screen.dart';
// import 'package:cheerchat/services/call_api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';

// class OutgoingCallScreen extends ConsumerStatefulWidget {
//   const OutgoingCallScreen({
//     super.key,
//     required this.host,
//     required this.initialCoins,
//     required this.sessionId,
//     required this.channelId,
//     required this.token,
//     required this.callerUid,
//     this.isAlreadyFollowing = false,
//   });

//   final HostModel host;
//   final int initialCoins;
//   final String sessionId;
//   final String channelId;
//   final String token;
//   final int callerUid;
//   final bool isAlreadyFollowing;

//   @override
//   ConsumerState<OutgoingCallScreen> createState() =>
//       _OutgoingCallScreenState();
// }

// class _OutgoingCallScreenState
//     extends ConsumerState<OutgoingCallScreen>
//     with TickerProviderStateMixin {
//   Timer? _pollTimer;
//   Timer? _timeoutTimer;
//   Timer? _tickTimer;
//   int _secondsElapsed = 0;
//   bool _resolved = false;

//   late final AnimationController _ring1Ctrl;
//   late final AnimationController _ring2Ctrl;
//   late final AnimationController _pulseCtrl;

//   @override
//   void initState() {
//     super.initState();

//     _ring1Ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     )..repeat();

//     _ring2Ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     );
//     Future.delayed(const Duration(milliseconds: 1100), () {
//       if (mounted) _ring2Ctrl.repeat();
//     });

//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);

//     _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _secondsElapsed++);
//     });

//     _pollTimer = Timer.periodic(
//       const Duration(seconds: 2),
//       (_) => _poll(),
//     );

//     _timeoutTimer = Timer(const Duration(seconds: 20), () {
//       if (!_resolved) _cancel(showMessage: 'No answer');
//     });
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
//     _tickTimer?.cancel();
//     _ring1Ctrl.dispose();
//     _ring2Ctrl.dispose();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _poll() async {
//     if (_resolved) return;
//     try {
//       final callApi = ref.read(callApiServiceProvider);
//       final status = await callApi.getSessionStatus(
//         widget.sessionId,
//       );
//       if (!mounted || _resolved) return;

//       if (status == 'accepted') {
//         _resolved = true;
//         _pollTimer?.cancel();
//         _timeoutTimer?.cancel();
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => OngoingCallScreen(
//               host: widget.host,
//               initialCoins: widget.initialCoins,
//               sessionId: widget.sessionId,
//               channelId: widget.channelId,
//               token: widget.token,
//               localUid: widget.callerUid,
//               isAlreadyFollowing: widget.isAlreadyFollowing,
//             ),
//           ),
//         );
//       } else if (status == 'ended') {
//         _resolved = true;
//         _cancel(showMessage: 'Call Declined');
//       }
//     } catch (_) {}
//   }

//   void _cancel({String? showMessage}) {
//     if (_resolved && showMessage == null) return;
//     _resolved = true;
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();

//     final callApi = ref.read(callApiServiceProvider);
//     callApi.endCall(
//       sessionId: widget.sessionId,
//       endedBy: 'caller',
//     );

//     if (mounted) {
//       if (showMessage != null) {
//         ScaffoldMessenger.of(context)
//           ..clearSnackBars()
//           ..showSnackBar(
//             SnackBar(
//               content: Text(showMessage),
//               duration: const Duration(milliseconds: 1500),
//               backgroundColor: Colors.grey.shade800,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           );
//       }
//       Navigator.of(context).pop();
//     }
//   }

//   String get _formattedTime {
//     final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
//     final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   Widget _buildRing(AnimationController ctrl, double maxSize) {
//     return AnimatedBuilder(
//       animation: ctrl,
//       builder: (_, __) {
//         final val = ctrl.value;
//         final size = maxSize * 0.6 + (maxSize * 0.4 * val);
//         return Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: const Color(
//                 0xFFE91E63,
//               ).withOpacity(0.3 * (1 - val)),
//               width: 2 * (1 - val) + 0.5,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final sw = mq.size.width;
//     final sh = mq.size.height;
//     final avatarSize = (sw * 0.32).clamp(100.0, 150.0);
//     final ringArea = avatarSize + 80;

//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, _) {
//         if (!didPop) _cancel();
//       },
//       child: Scaffold(
//         body: SizedBox.expand(
//           child: DecoratedBox(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF1A0A2E),
//                   Color(0xFF16213E),
//                   Color(0xFF0A0A14),
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   SizedBox(height: sh * 0.06),

//                   // Calling badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(
//                         color: Colors.green.withOpacity(0.2),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         AnimatedBuilder(
//                           animation: _pulseCtrl,
//                           builder: (_, __) => Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.green.withOpacity(
//                                 0.5 + 0.5 * _pulseCtrl.value,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           'Calling  •  $_formattedTime',
//                           style: GoogleFonts.poppins(
//                             color: Colors.green.shade300,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const Spacer(flex: 2),

//                   // Rings + Avatar
//                   SizedBox(
//                     width: ringArea,
//                     height: ringArea,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         _buildRing(_ring1Ctrl, ringArea),
//                         _buildRing(_ring2Ctrl, ringArea),
//                         // Avatar
//                         ScaleTransition(
//                           scale:
//                               Tween<double>(
//                                 begin: 0.97,
//                                 end: 1.03,
//                               ).animate(
//                                 CurvedAnimation(
//                                   parent: _pulseCtrl,
//                                   curve: Curves.easeInOut,
//                                 ),
//                               ),
//                           child: Container(
//                             width: avatarSize,
//                             height: avatarSize,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: const LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Color(0xFFE91E63),
//                                   Color(0xFF9C27B0),
//                                 ],
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(
//                                     0xFFE91E63,
//                                   ).withOpacity(0.35),
//                                   blurRadius: 40,
//                                   spreadRadius: 8,
//                                 ),
//                               ],
//                             ),
//                             child: ClipOval(
//                               child:
//                                   widget.host.profilePhotoUrl !=
//                                       null
//                                   ? Image.network(
//                                       widget
//                                           .host
//                                           .profilePhotoUrl!,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (_, __, ___) => Icon(
//                                             Icons.person_rounded,
//                                             size:
//                                                 avatarSize *
//                                                 0.45,
//                                             color:
//                                                 Colors.white70,
//                                           ),
//                                     )
//                                   : Icon(
//                                       Icons.person_rounded,
//                                       size: avatarSize * 0.45,
//                                       color: Colors.white70,
//                                     ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: sh * 0.04),

//                   // Host name
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                     ),
//                     child: Text(
//                       widget.host.displayName,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: (sw * 0.07).clamp(22.0, 32.0),
//                         fontWeight: FontWeight.w700,
//                       ),
//                       textAlign: TextAlign.center,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Ringing...',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.35),
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${widget.host.priceCoins} coins/min',
//                     style: TextStyle(
//                       color: Colors.amber.withOpacity(0.5),
//                       fontSize: 12,
//                     ),
//                   ),

//                   const Spacer(flex: 3),

//                   // Cancel button
//                   GestureDetector(
//                     onTap: () =>
//                         _cancel(showMessage: 'Call cancelled'),
//                     child: Container(
//                       width: (sw * 0.17).clamp(64.0, 78.0),
//                       height: (sw * 0.17).clamp(64.0, 78.0),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: const LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Color(0xFFFF4444),
//                             Color(0xFFCC0000),
//                           ],
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.red.withOpacity(0.4),
//                             blurRadius: 20,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.call_end_rounded,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.3),
//                       fontSize: 13,
//                     ),
//                   ),
//                   SizedBox(height: mq.padding.bottom + 30),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/outgoing_call_screen.dart
//
// Shown to the CALLER while waiting for the host to accept/decline.
// Polls GET /api/calls/:sessionId/status every 2 seconds.

import 'dart:async';

import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/screens/ongoing_call_screen.dart';
import 'package:cheerchat/services/call_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class OutgoingCallScreen extends ConsumerStatefulWidget {
  const OutgoingCallScreen({
    super.key,
    required this.host,
    required this.initialCoins,
    required this.sessionId,
    required this.channelId,
    required this.token,
    required this.callerUid,
    this.isAlreadyFollowing = false,
  });

  final HostModel host;
  final int initialCoins;
  final String sessionId;
  final String channelId;
  final String token;
  final int callerUid;
  final bool isAlreadyFollowing;

  @override
  ConsumerState<OutgoingCallScreen> createState() =>
      _OutgoingCallScreenState();
}

class _OutgoingCallScreenState
    extends ConsumerState<OutgoingCallScreen>
    with TickerProviderStateMixin {
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  bool _resolved = false;

  late final AnimationController _ring1Ctrl;
  late final AnimationController _ring2Ctrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _ring1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _ring2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _ring2Ctrl.repeat();
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _poll(),
    );

    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!_resolved) _cancel(showMessage: 'No answer');
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_resolved) return;
    try {
      final callApi = ref.read(callApiServiceProvider);
      final status = await callApi.getSessionStatus(
        widget.sessionId,
      );
      if (!mounted || _resolved) return;

      if (status == 'accepted') {
        _resolved = true;
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OngoingCallScreen(
              host: widget.host,
              initialCoins: widget.initialCoins,
              sessionId: widget.sessionId,
              channelId: widget.channelId,
              token: widget.token,
              localUid: widget.callerUid,
              isAlreadyFollowing: widget.isAlreadyFollowing,
            ),
          ),
        );
      } else if (status == 'ended') {
        _resolved = true;
        _cancel(showMessage: 'Call Declined');
      }
    } catch (_) {}
  }

  void _cancel({String? showMessage}) {
    if (_resolved && showMessage == null) return;
    _resolved = true;
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();

    final callApi = ref.read(callApiServiceProvider);
    callApi.endCall(
      sessionId: widget.sessionId,
      endedBy: 'caller',
    );

    if (mounted) {
      if (showMessage != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(showMessage),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.grey.shade800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
      }
      Navigator.of(context).pop();
    }
  }

  Widget _buildRing(AnimationController ctrl, double maxSize) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final val = ctrl.value;
        final size = maxSize * 0.6 + (maxSize * 0.4 * val);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(
                0xFFE91E63,
              ).withOpacity(0.3 * (1 - val)),
              width: 2 * (1 - val) + 0.5,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final avatarSize = (sw * 0.32).clamp(100.0, 150.0);
    final ringArea = avatarSize + 80;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0A2E),
                  Color(0xFF16213E),
                  Color(0xFF0A0A14),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: sh * 0.06),

                  const Spacer(flex: 2),

                  // Rings + Avatar
                  SizedBox(
                    width: ringArea,
                    height: ringArea,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRing(_ring1Ctrl, ringArea),
                        _buildRing(_ring2Ctrl, ringArea),
                        // Avatar
                        ScaleTransition(
                          scale:
                              Tween<double>(
                                begin: 0.97,
                                end: 1.03,
                              ).animate(
                                CurvedAnimation(
                                  parent: _pulseCtrl,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                          child: Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFE91E63),
                                  Color(0xFF9C27B0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE91E63,
                                  ).withOpacity(0.35),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  widget.host.profilePhotoUrl !=
                                      null
                                  ? Image.network(
                                      widget
                                          .host
                                          .profilePhotoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Icon(
                                            Icons.person_rounded,
                                            size:
                                                avatarSize *
                                                0.45,
                                            color:
                                                Colors.white70,
                                          ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: avatarSize * 0.45,
                                      color: Colors.white70,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sh * 0.04),

                  // Host name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Text(
                      widget.host.displayName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: (sw * 0.07).clamp(22.0, 32.0),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ringing...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.host.priceCoins} coins/min',
                    style: TextStyle(
                      color: Colors.amber.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Cancel button
                  GestureDetector(
                    onTap: () =>
                        _cancel(showMessage: 'Call cancelled'),
                    child: Container(
                      width: (sw * 0.17).clamp(64.0, 78.0),
                      height: (sw * 0.17).clamp(64.0, 78.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF4444),
                            Color(0xFFCC0000),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: mq.padding.bottom + 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

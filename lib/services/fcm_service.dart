// // // // // // // lib/services/fcm_service.dart
// // // // // // //
// // // // // // // Firebase Cloud Messaging — handles:
// // // // // // //   1. Permission request + token registration
// // // // // // //   2. Token refresh → re-register with backend
// // // // // // //   3. Foreground messages → local notification or in-app overlay
// // // // // // //   4. Background messages → system notification
// // // // // // //   5. Notification taps → navigate to correct screen

// // // // // // import 'dart:io';
// // // // // // import 'dart:convert';

// // // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // // import 'package:flutter/foundation.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // // // // import 'package:cheerchat/providers/notification_provider.dart';
// // // // // // import 'package:cheerchat/services/api_service.dart';

// // // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // // Top-level background handler (must be a top-level function)
// // // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // // @pragma('vm:entry-point')
// // // // // // Future<void> firebaseMessagingBackgroundHandler(
// // // // // //   RemoteMessage message,
// // // // // // ) async {
// // // // // //   // Background messages are automatically shown as system notifications
// // // // // //   // by Firebase on Android. Nothing extra needed here unless you want
// // // // // //   // to do background processing (e.g. wake lock for calls).
// // // // // //   debugPrint('[FCM] Background message: ${message.data}');
// // // // // // }

// // // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // // FCM Service
// // // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // // final fcmServiceProvider = Provider((ref) => FcmService(ref));

// // // // // // class FcmService {
// // // // // //   final Ref _ref;
// // // // // //   final FirebaseMessaging _messaging =
// // // // // //       FirebaseMessaging.instance;
// // // // // //   bool _initialized = false;

// // // // // //   FcmService(this._ref);

// // // // // //   /// Call once after user is authenticated and API service is ready.
// // // // // //   Future<void> initialize() async {
// // // // // //     if (_initialized) return;
// // // // // //     _initialized = true;
// // // // // //     // 1. Request permission
// // // // // //     final settings = await _messaging.requestPermission(
// // // // // //       alert: true,
// // // // // //       badge: true,
// // // // // //       sound: true,
// // // // // //       provisional: false,
// // // // // //     );

// // // // // //     if (settings.authorizationStatus ==
// // // // // //         AuthorizationStatus.denied) {
// // // // // //       debugPrint('[FCM] Notification permission denied.');
// // // // // //       return;
// // // // // //     }

// // // // // //     debugPrint(
// // // // // //       '[FCM] Permission: ${settings.authorizationStatus}',
// // // // // //     );

// // // // // //     // 2. Get token and register with backend
// // // // // //     final token = await _messaging.getToken();
// // // // // //     if (token != null) {
// // // // // //       await _registerToken(token);
// // // // // //     }

// // // // // //     // 3. Listen for token refresh
// // // // // //     _messaging.onTokenRefresh.listen((newToken) {
// // // // // //       _registerToken(newToken);
// // // // // //     });

// // // // // //     // 4. Handle foreground messages
// // // // // //     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

// // // // // //     // 5. Handle notification taps (app was in background/terminated)
// // // // // //     FirebaseMessaging.onMessageOpenedApp.listen(
// // // // // //       _handleNotificationTap,
// // // // // //     );

// // // // // //     // 6. Check if app was opened from a terminated state via notification
// // // // // //     final initialMessage = await _messaging.getInitialMessage();
// // // // // //     if (initialMessage != null) {
// // // // // //       _handleNotificationTap(initialMessage);
// // // // // //     }

// // // // // //     debugPrint('[FCM] Service initialized.');
// // // // // //   }

// // // // // //   /// Register FCM token with backend.
// // // // // //   Future<void> _registerToken(String token) async {
// // // // // //     debugPrint(
// // // // // //       '[FCM] Registering token: ${token.substring(0, 20)}...',
// // // // // //     );
// // // // // //     final api = _ref.read(apiServiceProvider);
// // // // // //     await registerFcmToken(
// // // // // //       api,
// // // // // //       token: token,
// // // // // //       platform: Platform.isIOS ? 'ios' : 'android',
// // // // // //     );
// // // // // //   }

// // // // // //   /// Handle messages while app is in the foreground.
// // // // // //   void _handleForegroundMessage(RemoteMessage message) {
// // // // // //     debugPrint('[FCM] Foreground: ${message.data}');

// // // // // //     final type = message.data['type'];

// // // // // //     switch (type) {
// // // // // //       case 'incoming_call':
// // // // // //         // Show incoming call screen overlay
// // // // // //         _showIncomingCall(message.data);
// // // // // //         break;
// // // // // //       case 'gift_received':
// // // // // //       case 'new_message':
// // // // // //       case 'level_up':
// // // // // //       case 'host_online':
// // // // // //       case 'low_balance':
// // // // // //         // Refresh notification count
// // // // // //         _ref
// // // // // //             .read(unreadNotificationCountProvider.notifier)
// // // // // //             .refresh();
// // // // // //         break;
// // // // // //     }
// // // // // //   }

// // // // // //   /// Handle notification taps — navigate to the right screen.
// // // // // //   void _handleNotificationTap(RemoteMessage message) {
// // // // // //     debugPrint('[FCM] Notification tapped: ${message.data}');

// // // // // //     final type = message.data['type'];

// // // // // //     switch (type) {
// // // // // //       case 'incoming_call':
// // // // // //         _showIncomingCall(message.data);
// // // // // //         break;
// // // // // //       // Other types can navigate to specific screens later
// // // // // //       // case 'gift_received': → navigate to gifts tab
// // // // // //       // case 'new_message': → navigate to chat
// // // // // //       // case 'host_online': → navigate to host profile
// // // // // //     }
// // // // // //   }

// // // // // //   /// Show the incoming call screen.
// // // // // //   void _showIncomingCall(Map<String, dynamic> data) {
// // // // // //     final callerName = data['caller_name'] ?? 'Unknown';
// // // // // //     final channelName = data['channel_name'] ?? '';
// // // // // //     final callerId = data['caller_id'] ?? '';

// // // // // //     debugPrint(
// // // // // //       '[FCM] Incoming call from $callerName on channel $channelName',
// // // // // //     );

// // // // // //     // Navigate to incoming call screen using the global navigator key
// // // // // //     final context = _navigatorKey?.currentContext;
// // // // // //     if (context != null) {
// // // // // //       Navigator.of(context, rootNavigator: true).push(
// // // // // //         MaterialPageRoute(
// // // // // //           builder: (_) => _IncomingCallOverlay(
// // // // // //             callerName: callerName,
// // // // // //             channelName: channelName,
// // // // // //             callerId: callerId,
// // // // // //             ref: _ref,
// // // // // //           ),
// // // // // //         ),
// // // // // //       );
// // // // // //     }
// // // // // //   }

// // // // // //   /// Set the navigator key (call from main.dart)
// // // // // //   static GlobalKey<NavigatorState>? _navigatorKey;
// // // // // //   static void setNavigatorKey(GlobalKey<NavigatorState> key) {
// // // // // //     _navigatorKey = key;
// // // // // //   }
// // // // // // }

// // // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // // Incoming Call Overlay Screen
// // // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // // class _IncomingCallOverlay extends StatefulWidget {
// // // // // //   const _IncomingCallOverlay({
// // // // // //     required this.callerName,
// // // // // //     required this.channelName,
// // // // // //     required this.callerId,
// // // // // //     required this.ref,
// // // // // //   });

// // // // // //   final String callerName;
// // // // // //   final String channelName;
// // // // // //   final String callerId;
// // // // // //   final Ref ref;

// // // // // //   @override
// // // // // //   State<_IncomingCallOverlay> createState() =>
// // // // // //       _IncomingCallOverlayState();
// // // // // // }

// // // // // // class _IncomingCallOverlayState
// // // // // //     extends State<_IncomingCallOverlay>
// // // // // //     with SingleTickerProviderStateMixin {
// // // // // //   late final AnimationController _pulseCtrl;
// // // // // //   late final Animation<double> _pulseAnim;
// // // // // //   bool _isAccepting = false;

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _pulseCtrl = AnimationController(
// // // // // //       vsync: this,
// // // // // //       duration: const Duration(milliseconds: 1200),
// // // // // //     )..repeat(reverse: true);
// // // // // //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
// // // // // //       CurvedAnimation(
// // // // // //         parent: _pulseCtrl,
// // // // // //         curve: Curves.easeInOut,
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _pulseCtrl.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   Future<void> _acceptCall() async {
// // // // // //     if (_isAccepting) return;
// // // // // //     setState(() => _isAccepting = true);

// // // // // //     try {
// // // // // //       // Get Agora token for this channel as the host (uid=2)
// // // // // //       final api = widget.ref.read(apiServiceProvider);
// // // // // //       final res = await api.post(
// // // // // //         '/api/calls/accept',
// // // // // //         body: {'channel_name': widget.channelName},
// // // // // //       );

// // // // // //       if (!mounted) return;

// // // // // //       if (res.ok) {
// // // // // //         final token = res.data['host_token'] as String;
// // // // // //         final channelId = res.data['channel_name'] as String;
// // // // // //         final sessionId = res.data['session_id'] as String;

// // // // // //         // Import dynamically to avoid circular deps
// // // // // //         // Navigate to OngoingCallScreen as the HOST
// // // // // //         Navigator.of(context).pushReplacement(
// // // // // //           MaterialPageRoute(
// // // // // //             builder: (_) => _AcceptedCallRedirect(
// // // // // //               token: token,
// // // // // //               channelId: channelId,
// // // // // //               sessionId: sessionId,
// // // // // //               callerName: widget.callerName,
// // // // // //               hostUid: 2,
// // // // // //             ),
// // // // // //           ),
// // // // // //         );
// // // // // //       } else {
// // // // // //         // Call may have ended already
// // // // // //         if (mounted) {
// // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // //             SnackBar(
// // // // // //               content: Text(res.error ?? 'Call ended'),
// // // // // //               backgroundColor: Colors.orange,
// // // // // //               behavior: SnackBarBehavior.floating,
// // // // // //             ),
// // // // // //           );
// // // // // //           Navigator.of(context).pop();
// // // // // //         }
// // // // // //       }
// // // // // //     } catch (_) {
// // // // // //       if (mounted) Navigator.of(context).pop();
// // // // // //     }
// // // // // //   }

// // // // // //   void _rejectCall() {
// // // // // //     // TODO: POST /api/calls/reject to notify caller
// // // // // //     Navigator.of(context).pop();
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       backgroundColor: const Color(0xFF1A1A2E),
// // // // // //       body: SafeArea(
// // // // // //         child: Column(
// // // // // //           children: [
// // // // // //             const Spacer(flex: 2),
// // // // // //             // Pulsing avatar
// // // // // //             ScaleTransition(
// // // // // //               scale: _pulseAnim,
// // // // // //               child: Container(
// // // // // //                 width: 120,
// // // // // //                 height: 120,
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   shape: BoxShape.circle,
// // // // // //                   color: Colors.pink.withOpacity(0.2),
// // // // // //                   border: Border.all(
// // // // // //                     color: Colors.pink.withOpacity(0.5),
// // // // // //                     width: 3,
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 child: const Icon(
// // // // // //                   Icons.person,
// // // // // //                   size: 60,
// // // // // //                   color: Colors.white54,
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(height: 30),
// // // // // //             Text(
// // // // // //               widget.callerName,
// // // // // //               style: const TextStyle(
// // // // // //                 color: Colors.white,
// // // // // //                 fontSize: 28,
// // // // // //                 fontWeight: FontWeight.bold,
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(height: 10),
// // // // // //             const Text(
// // // // // //               'Incoming video call...',
// // // // // //               style: TextStyle(
// // // // // //                 color: Colors.white60,
// // // // // //                 fontSize: 16,
// // // // // //               ),
// // // // // //             ),
// // // // // //             const Spacer(flex: 3),
// // // // // //             // Accept / Reject buttons
// // // // // //             Padding(
// // // // // //               padding: const EdgeInsets.symmetric(
// // // // // //                 horizontal: 60,
// // // // // //               ),
// // // // // //               child: Row(
// // // // // //                 mainAxisAlignment:
// // // // // //                     MainAxisAlignment.spaceBetween,
// // // // // //                 children: [
// // // // // //                   // Reject
// // // // // //                   Column(
// // // // // //                     children: [
// // // // // //                       GestureDetector(
// // // // // //                         onTap: _rejectCall,
// // // // // //                         child: Container(
// // // // // //                           width: 70,
// // // // // //                           height: 70,
// // // // // //                           decoration: const BoxDecoration(
// // // // // //                             color: Colors.redAccent,
// // // // // //                             shape: BoxShape.circle,
// // // // // //                           ),
// // // // // //                           child: const Icon(
// // // // // //                             Icons.call_end,
// // // // // //                             color: Colors.white,
// // // // // //                             size: 32,
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 12),
// // // // // //                       const Text(
// // // // // //                         'Decline',
// // // // // //                         style: TextStyle(
// // // // // //                           color: Colors.white60,
// // // // // //                           fontSize: 14,
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                   // Accept
// // // // // //                   Column(
// // // // // //                     children: [
// // // // // //                       GestureDetector(
// // // // // //                         onTap: _acceptCall,
// // // // // //                         child: Container(
// // // // // //                           width: 70,
// // // // // //                           height: 70,
// // // // // //                           decoration: const BoxDecoration(
// // // // // //                             color: Colors.green,
// // // // // //                             shape: BoxShape.circle,
// // // // // //                           ),
// // // // // //                           child: _isAccepting
// // // // // //                               ? const SizedBox(
// // // // // //                                   width: 30,
// // // // // //                                   height: 30,
// // // // // //                                   child:
// // // // // //                                       CircularProgressIndicator(
// // // // // //                                         color: Colors.white,
// // // // // //                                         strokeWidth: 2.5,
// // // // // //                                       ),
// // // // // //                                 )
// // // // // //                               : const Icon(
// // // // // //                                   Icons.videocam,
// // // // // //                                   color: Colors.white,
// // // // // //                                   size: 32,
// // // // // //                                 ),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 12),
// // // // // //                       const Text(
// // // // // //                         'Accept',
// // // // // //                         style: TextStyle(
// // // // // //                           color: Colors.white60,
// // // // // //                           fontSize: 14,
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(height: 60),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // // Redirect widget — pushes OngoingCallScreen after accepting
// // // // // // // This exists to avoid importing OngoingCallScreen inside the FCM service
// // // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // // class _AcceptedCallRedirect extends StatefulWidget {
// // // // // //   const _AcceptedCallRedirect({
// // // // // //     required this.token,
// // // // // //     required this.channelId,
// // // // // //     required this.sessionId,
// // // // // //     required this.callerName,
// // // // // //     required this.hostUid,
// // // // // //   });

// // // // // //   final String token;
// // // // // //   final String channelId;
// // // // // //   final String sessionId;
// // // // // //   final String callerName;
// // // // // //   final int hostUid;

// // // // // //   @override
// // // // // //   State<_AcceptedCallRedirect> createState() =>
// // // // // //       _AcceptedCallRedirectState();
// // // // // // }

// // // // // // class _AcceptedCallRedirectState
// // // // // //     extends State<_AcceptedCallRedirect> {
// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     // Delay to let the widget mount, then navigate
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       // We need to import OngoingCallScreen here
// // // // // //       // For now, show a placeholder that joins the Agora channel
// // // // // //       // In production, this would push OngoingCallScreen
// // // // // //       debugPrint(
// // // // // //         '[FCM] Accepted call: channel=${widget.channelId}, token=${widget.token.substring(0, 20)}...',
// // // // // //       );
// // // // // //     });
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     // This is a temporary placeholder
// // // // // //     // In production: push OngoingCallScreen with host model built from call data
// // // // // //     return Scaffold(
// // // // // //       backgroundColor: const Color(0xFF1A1A2E),
// // // // // //       body: Center(
// // // // // //         child: Column(
// // // // // //           mainAxisSize: MainAxisSize.min,
// // // // // //           children: [
// // // // // //             const CircularProgressIndicator(color: Colors.pink),
// // // // // //             const SizedBox(height: 20),
// // // // // //             Text(
// // // // // //               'Connecting to ${widget.callerName}...',
// // // // // //               style: const TextStyle(
// // // // // //                 color: Colors.white,
// // // // // //                 fontSize: 16,
// // // // // //               ),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // // lib/services/fcm_service.dart
// // // // // //
// // // // // // Firebase Cloud Messaging — handles:
// // // // // //   1. Permission request + token registration
// // // // // //   2. Token refresh → re-register with backend
// // // // // //   3. Foreground messages → local notification or in-app overlay
// // // // // //   4. Background messages → system notification
// // // // // //   5. Notification taps → navigate to correct screen

// // // // // import 'dart:io';

// // // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // // import 'package:flutter/foundation.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // // // import 'package:cheerchat/providers/notification_provider.dart';
// // // // // import 'package:cheerchat/services/api_service.dart';
// // // // // import 'package:cheerchat/models/host_model.dart';
// // // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';

// // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // Top-level background handler (must be a top-level function)
// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // @pragma('vm:entry-point')
// // // // // Future<void> firebaseMessagingBackgroundHandler(
// // // // //   RemoteMessage message,
// // // // // ) async {
// // // // //   // Background messages are automatically shown as system notifications
// // // // //   // by Firebase on Android. Nothing extra needed here unless you want
// // // // //   // to do background processing (e.g. wake lock for calls).
// // // // //   debugPrint('[FCM] Background message: ${message.data}');
// // // // // }

// // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // FCM Service
// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // final fcmServiceProvider = Provider((ref) => FcmService(ref));

// // // // // class FcmService {
// // // // //   final Ref _ref;
// // // // //   final FirebaseMessaging _messaging =
// // // // //       FirebaseMessaging.instance;
// // // // //   bool _initialized = false;

// // // // //   FcmService(this._ref);

// // // // //   /// Call once after user is authenticated and API service is ready.
// // // // //   Future<void> initialize() async {
// // // // //     if (_initialized) return;
// // // // //     _initialized = true;
// // // // //     // 1. Request permission
// // // // //     final settings = await _messaging.requestPermission(
// // // // //       alert: true,
// // // // //       badge: true,
// // // // //       sound: true,
// // // // //       provisional: false,
// // // // //     );

// // // // //     if (settings.authorizationStatus ==
// // // // //         AuthorizationStatus.denied) {
// // // // //       debugPrint('[FCM] Notification permission denied.');
// // // // //       return;
// // // // //     }

// // // // //     debugPrint(
// // // // //       '[FCM] Permission: ${settings.authorizationStatus}',
// // // // //     );

// // // // //     // 2. Get token and register with backend
// // // // //     final token = await _messaging.getToken();
// // // // //     if (token != null) {
// // // // //       await _registerToken(token);
// // // // //     }

// // // // //     // 3. Listen for token refresh
// // // // //     _messaging.onTokenRefresh.listen((newToken) {
// // // // //       _registerToken(newToken);
// // // // //     });

// // // // //     // 4. Handle foreground messages
// // // // //     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

// // // // //     // 5. Handle notification taps (app was in background/terminated)
// // // // //     FirebaseMessaging.onMessageOpenedApp.listen(
// // // // //       _handleNotificationTap,
// // // // //     );

// // // // //     // 6. Check if app was opened from a terminated state via notification
// // // // //     final initialMessage = await _messaging.getInitialMessage();
// // // // //     if (initialMessage != null) {
// // // // //       _handleNotificationTap(initialMessage);
// // // // //     }

// // // // //     debugPrint('[FCM] Service initialized.');
// // // // //   }

// // // // //   /// Register FCM token with backend.
// // // // //   Future<void> _registerToken(String token) async {
// // // // //     debugPrint(
// // // // //       '[FCM] Registering token: ${token.substring(0, 20)}...',
// // // // //     );
// // // // //     final api = _ref.read(apiServiceProvider);
// // // // //     await registerFcmToken(
// // // // //       api,
// // // // //       token: token,
// // // // //       platform: Platform.isIOS ? 'ios' : 'android',
// // // // //     );
// // // // //   }

// // // // //   /// Handle messages while app is in the foreground.
// // // // //   void _handleForegroundMessage(RemoteMessage message) {
// // // // //     debugPrint('[FCM] Foreground: ${message.data}');

// // // // //     final type = message.data['type'];

// // // // //     switch (type) {
// // // // //       case 'incoming_call':
// // // // //         // Show incoming call screen overlay
// // // // //         _showIncomingCall(message.data);
// // // // //         break;
// // // // //       case 'gift_received':
// // // // //       case 'new_message':
// // // // //       case 'level_up':
// // // // //       case 'host_online':
// // // // //       case 'low_balance':
// // // // //         // Refresh notification count
// // // // //         _ref
// // // // //             .read(unreadNotificationCountProvider.notifier)
// // // // //             .refresh();
// // // // //         break;
// // // // //     }
// // // // //   }

// // // // //   /// Handle notification taps — navigate to the right screen.
// // // // //   void _handleNotificationTap(RemoteMessage message) {
// // // // //     debugPrint('[FCM] Notification tapped: ${message.data}');

// // // // //     final type = message.data['type'];

// // // // //     switch (type) {
// // // // //       case 'incoming_call':
// // // // //         _showIncomingCall(message.data);
// // // // //         break;
// // // // //       // Other types can navigate to specific screens later
// // // // //       // case 'gift_received': → navigate to gifts tab
// // // // //       // case 'new_message': → navigate to chat
// // // // //       // case 'host_online': → navigate to host profile
// // // // //     }
// // // // //   }

// // // // //   /// Show the incoming call screen.
// // // // //   void _showIncomingCall(Map<String, dynamic> data) {
// // // // //     final callerName = data['caller_name'] ?? 'Unknown';
// // // // //     final channelName = data['channel_name'] ?? '';
// // // // //     final callerId = data['caller_id'] ?? '';

// // // // //     debugPrint(
// // // // //       '[FCM] Incoming call from $callerName on channel $channelName',
// // // // //     );

// // // // //     // Navigate to incoming call screen using the global navigator key
// // // // //     final context = _navigatorKey?.currentContext;
// // // // //     if (context != null) {
// // // // //       Navigator.of(context, rootNavigator: true).push(
// // // // //         MaterialPageRoute(
// // // // //           builder: (_) => _IncomingCallOverlay(
// // // // //             callerName: callerName,
// // // // //             channelName: channelName,
// // // // //             callerId: callerId,
// // // // //             ref: _ref,
// // // // //           ),
// // // // //         ),
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   /// Set the navigator key (call from main.dart)
// // // // //   static GlobalKey<NavigatorState>? _navigatorKey;
// // // // //   static void setNavigatorKey(GlobalKey<NavigatorState> key) {
// // // // //     _navigatorKey = key;
// // // // //   }
// // // // // }

// // // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // // Incoming Call Overlay Screen
// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // class _IncomingCallOverlay extends StatefulWidget {
// // // // //   const _IncomingCallOverlay({
// // // // //     required this.callerName,
// // // // //     required this.channelName,
// // // // //     required this.callerId,
// // // // //     required this.ref,
// // // // //   });

// // // // //   final String callerName;
// // // // //   final String channelName;
// // // // //   final String callerId;
// // // // //   final Ref ref;

// // // // //   @override
// // // // //   State<_IncomingCallOverlay> createState() =>
// // // // //       _IncomingCallOverlayState();
// // // // // }

// // // // // class _IncomingCallOverlayState
// // // // //     extends State<_IncomingCallOverlay>
// // // // //     with SingleTickerProviderStateMixin {
// // // // //   late final AnimationController _pulseCtrl;
// // // // //   late final Animation<double> _pulseAnim;
// // // // //   bool _isAccepting = false;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _pulseCtrl = AnimationController(
// // // // //       vsync: this,
// // // // //       duration: const Duration(milliseconds: 1200),
// // // // //     )..repeat(reverse: true);
// // // // //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
// // // // //       CurvedAnimation(
// // // // //         parent: _pulseCtrl,
// // // // //         curve: Curves.easeInOut,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _pulseCtrl.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   Future<void> _acceptCall() async {
// // // // //     if (_isAccepting) return;
// // // // //     setState(() => _isAccepting = true);

// // // // //     try {
// // // // //       final api = widget.ref.read(apiServiceProvider);
// // // // //       final res = await api.post(
// // // // //         '/api/calls/accept',
// // // // //         body: {'channel_name': widget.channelName},
// // // // //       );

// // // // //       if (!mounted) return;

// // // // //       if (res.ok) {
// // // // //         final token = res.data['host_token'] as String;
// // // // //         final channelId = res.data['channel_name'] as String;
// // // // //         final sessionId = res.data['session_id'] as String;
// // // // //         final pricePerMin =
// // // // //             (res.data['price_per_minute'] as num?)?.toInt() ?? 0;

// // // // //         // Build a minimal HostModel representing the caller
// // // // //         final callerHost = HostModel(
// // // // //           userId: widget.callerId,
// // // // //           publicId: 0,
// // // // //           displayName: widget.callerName,
// // // // //           countryCode: '',
// // // // //           language: '',
// // // // //           priceCoins: pricePerMin,
// // // // //           level: 1,
// // // // //           status: HostStatus.online,
// // // // //         );

// // // // //         // Navigate to OngoingCallScreen as the HOST (uid=2)
// // // // //         // Host doesn't pay coins, so pass a large initialCoins value
// // // // //         Navigator.of(context).pushReplacement(
// // // // //           MaterialPageRoute(
// // // // //             builder: (_) => OngoingCallScreen(
// // // // //               host: callerHost,
// // // // //               initialCoins: 999999,
// // // // //               sessionId: sessionId,
// // // // //               channelId: channelId,
// // // // //               token: token,
// // // // //               localUid: 2,
// // // // //             ),
// // // // //           ),
// // // // //         );
// // // // //       } else {
// // // // //         if (mounted) {
// // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // //             SnackBar(
// // // // //               content: Text(res.error ?? 'Call ended'),
// // // // //               backgroundColor: Colors.orange,
// // // // //               behavior: SnackBarBehavior.floating,
// // // // //             ),
// // // // //           );
// // // // //           Navigator.of(context).pop();
// // // // //         }
// // // // //       }
// // // // //     } catch (_) {
// // // // //       if (mounted) Navigator.of(context).pop();
// // // // //     }
// // // // //   }

// // // // //   void _rejectCall() {
// // // // //     // TODO: POST /api/calls/reject to notify caller
// // // // //     Navigator.of(context).pop();
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: const Color(0xFF1A1A2E),
// // // // //       body: SafeArea(
// // // // //         child: Column(
// // // // //           children: [
// // // // //             const Spacer(flex: 2),
// // // // //             // Pulsing avatar
// // // // //             ScaleTransition(
// // // // //               scale: _pulseAnim,
// // // // //               child: Container(
// // // // //                 width: 120,
// // // // //                 height: 120,
// // // // //                 decoration: BoxDecoration(
// // // // //                   shape: BoxShape.circle,
// // // // //                   color: Colors.pink.withOpacity(0.2),
// // // // //                   border: Border.all(
// // // // //                     color: Colors.pink.withOpacity(0.5),
// // // // //                     width: 3,
// // // // //                   ),
// // // // //                 ),
// // // // //                 child: const Icon(
// // // // //                   Icons.person,
// // // // //                   size: 60,
// // // // //                   color: Colors.white54,
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 30),
// // // // //             Text(
// // // // //               widget.callerName,
// // // // //               style: const TextStyle(
// // // // //                 color: Colors.white,
// // // // //                 fontSize: 28,
// // // // //                 fontWeight: FontWeight.bold,
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 10),
// // // // //             const Text(
// // // // //               'Incoming video call...',
// // // // //               style: TextStyle(
// // // // //                 color: Colors.white60,
// // // // //                 fontSize: 16,
// // // // //               ),
// // // // //             ),
// // // // //             const Spacer(flex: 3),
// // // // //             // Accept / Reject buttons
// // // // //             Padding(
// // // // //               padding: const EdgeInsets.symmetric(
// // // // //                 horizontal: 60,
// // // // //               ),
// // // // //               child: Row(
// // // // //                 mainAxisAlignment:
// // // // //                     MainAxisAlignment.spaceBetween,
// // // // //                 children: [
// // // // //                   // Reject
// // // // //                   Column(
// // // // //                     children: [
// // // // //                       GestureDetector(
// // // // //                         onTap: _rejectCall,
// // // // //                         child: Container(
// // // // //                           width: 70,
// // // // //                           height: 70,
// // // // //                           decoration: const BoxDecoration(
// // // // //                             color: Colors.redAccent,
// // // // //                             shape: BoxShape.circle,
// // // // //                           ),
// // // // //                           child: const Icon(
// // // // //                             Icons.call_end,
// // // // //                             color: Colors.white,
// // // // //                             size: 32,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //                       const SizedBox(height: 12),
// // // // //                       const Text(
// // // // //                         'Decline',
// // // // //                         style: TextStyle(
// // // // //                           color: Colors.white60,
// // // // //                           fontSize: 14,
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                   // Accept
// // // // //                   Column(
// // // // //                     children: [
// // // // //                       GestureDetector(
// // // // //                         onTap: _acceptCall,
// // // // //                         child: Container(
// // // // //                           width: 70,
// // // // //                           height: 70,
// // // // //                           decoration: const BoxDecoration(
// // // // //                             color: Colors.green,
// // // // //                             shape: BoxShape.circle,
// // // // //                           ),
// // // // //                           child: _isAccepting
// // // // //                               ? const SizedBox(
// // // // //                                   width: 30,
// // // // //                                   height: 30,
// // // // //                                   child:
// // // // //                                       CircularProgressIndicator(
// // // // //                                         color: Colors.white,
// // // // //                                         strokeWidth: 2.5,
// // // // //                                       ),
// // // // //                                 )
// // // // //                               : const Icon(
// // // // //                                   Icons.videocam,
// // // // //                                   color: Colors.white,
// // // // //                                   size: 32,
// // // // //                                 ),
// // // // //                         ),
// // // // //                       ),
// // // // //                       const SizedBox(height: 12),
// // // // //                       const Text(
// // // // //                         'Accept',
// // // // //                         style: TextStyle(
// // // // //                           color: Colors.white60,
// // // // //                           fontSize: 14,
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 60),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // lib/services/fcm_service.dart
// // // // //
// // // // // Firebase Cloud Messaging — handles:
// // // // //   1. Permission request + token registration
// // // // //   2. Token refresh → re-register with backend
// // // // //   3. Foreground messages → local notification or in-app overlay
// // // // //   4. Background messages → system notification
// // // // //   5. Notification taps → navigate to correct screen

// // // // import 'dart:io';

// // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // import 'package:flutter/foundation.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // // import 'package:cheerchat/providers/notification_provider.dart';
// // // // import 'package:cheerchat/services/api_service.dart';
// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';

// // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // Top-level background handler (must be a top-level function)
// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // @pragma('vm:entry-point')
// // // // Future<void> firebaseMessagingBackgroundHandler(
// // // //   RemoteMessage message,
// // // // ) async {
// // // //   // Background messages are automatically shown as system notifications
// // // //   // by Firebase on Android. Nothing extra needed here unless you want
// // // //   // to do background processing (e.g. wake lock for calls).
// // // //   debugPrint('[FCM] Background message: ${message.data}');
// // // // }

// // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // FCM Service
// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // final fcmServiceProvider = Provider((ref) => FcmService(ref));

// // // // class FcmService {
// // // //   final Ref _ref;
// // // //   final FirebaseMessaging _messaging =
// // // //       FirebaseMessaging.instance;
// // // //   bool _initialized = false;

// // // //   FcmService(this._ref);

// // // //   /// Call once after user is authenticated and API service is ready.
// // // //   Future<void> initialize() async {
// // // //     if (_initialized) return;
// // // //     _initialized = true;
// // // //     // 1. Request permission
// // // //     final settings = await _messaging.requestPermission(
// // // //       alert: true,
// // // //       badge: true,
// // // //       sound: true,
// // // //       provisional: false,
// // // //     );

// // // //     if (settings.authorizationStatus ==
// // // //         AuthorizationStatus.denied) {
// // // //       debugPrint('[FCM] Notification permission denied.');
// // // //       return;
// // // //     }

// // // //     debugPrint(
// // // //       '[FCM] Permission: ${settings.authorizationStatus}',
// // // //     );

// // // //     // 2. Get token and register with backend
// // // //     final token = await _messaging.getToken();
// // // //     if (token != null) {
// // // //       await _registerToken(token);
// // // //     }

// // // //     // 3. Listen for token refresh
// // // //     _messaging.onTokenRefresh.listen((newToken) {
// // // //       _registerToken(newToken);
// // // //     });

// // // //     // 4. Handle foreground messages
// // // //     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

// // // //     // 5. Handle notification taps (app was in background/terminated)
// // // //     FirebaseMessaging.onMessageOpenedApp.listen(
// // // //       _handleNotificationTap,
// // // //     );

// // // //     // 6. Check if app was opened from a terminated state via notification
// // // //     final initialMessage = await _messaging.getInitialMessage();
// // // //     if (initialMessage != null) {
// // // //       _handleNotificationTap(initialMessage);
// // // //     }

// // // //     debugPrint('[FCM] Service initialized.');
// // // //   }

// // // //   /// Register FCM token with backend.
// // // //   Future<void> _registerToken(String token) async {
// // // //     debugPrint(
// // // //       '[FCM] Registering token: ${token.substring(0, 20)}...',
// // // //     );
// // // //     final api = _ref.read(apiServiceProvider);
// // // //     await registerFcmToken(
// // // //       api,
// // // //       token: token,
// // // //       platform: Platform.isIOS ? 'ios' : 'android',
// // // //     );
// // // //   }

// // // //   /// Handle messages while app is in the foreground.
// // // //   void _handleForegroundMessage(RemoteMessage message) {
// // // //     debugPrint('[FCM] Foreground: ${message.data}');

// // // //     final type = message.data['type'];

// // // //     switch (type) {
// // // //       case 'incoming_call':
// // // //         // Show incoming call screen overlay
// // // //         _showIncomingCall(message.data);
// // // //         break;
// // // //       case 'gift_received':
// // // //       case 'new_message':
// // // //       case 'level_up':
// // // //       case 'host_online':
// // // //       case 'low_balance':
// // // //         // Refresh notification count
// // // //         _ref
// // // //             .read(unreadNotificationCountProvider.notifier)
// // // //             .refresh();
// // // //         break;
// // // //     }
// // // //   }

// // // //   /// Handle notification taps — navigate to the right screen.
// // // //   void _handleNotificationTap(RemoteMessage message) {
// // // //     debugPrint('[FCM] Notification tapped: ${message.data}');

// // // //     final type = message.data['type'];

// // // //     switch (type) {
// // // //       case 'incoming_call':
// // // //         _showIncomingCall(message.data);
// // // //         break;
// // // //       // Other types can navigate to specific screens later
// // // //       // case 'gift_received': → navigate to gifts tab
// // // //       // case 'new_message': → navigate to chat
// // // //       // case 'host_online': → navigate to host profile
// // // //     }
// // // //   }

// // // //   /// Show the incoming call screen.
// // // //   void _showIncomingCall(Map<String, dynamic> data) {
// // // //     final callerName = data['caller_name'] ?? 'Unknown';
// // // //     final channelName = data['channel_name'] ?? '';
// // // //     final callerId = data['caller_id'] ?? '';

// // // //     debugPrint(
// // // //       '[FCM] Incoming call from $callerName on channel $channelName',
// // // //     );

// // // //     // Navigate to incoming call screen using the global navigator key
// // // //     final context = _navigatorKey?.currentContext;
// // // //     if (context != null) {
// // // //       Navigator.of(context, rootNavigator: true).push(
// // // //         MaterialPageRoute(
// // // //           builder: (_) => _IncomingCallOverlay(
// // // //             callerName: callerName,
// // // //             channelName: channelName,
// // // //             callerId: callerId,
// // // //             ref: _ref,
// // // //           ),
// // // //         ),
// // // //       );
// // // //     }
// // // //   }

// // // //   /// Set the navigator key (call from main.dart)
// // // //   static GlobalKey<NavigatorState>? _navigatorKey;
// // // //   static void setNavigatorKey(GlobalKey<NavigatorState> key) {
// // // //     _navigatorKey = key;
// // // //   }
// // // // }

// // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // Incoming Call Overlay Screen
// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class _IncomingCallOverlay extends StatefulWidget {
// // // //   const _IncomingCallOverlay({
// // // //     required this.callerName,
// // // //     required this.channelName,
// // // //     required this.callerId,
// // // //     required this.ref,
// // // //   });

// // // //   final String callerName;
// // // //   final String channelName;
// // // //   final String callerId;
// // // //   final Ref ref;

// // // //   @override
// // // //   State<_IncomingCallOverlay> createState() =>
// // // //       _IncomingCallOverlayState();
// // // // }

// // // // class _IncomingCallOverlayState
// // // //     extends State<_IncomingCallOverlay>
// // // //     with TickerProviderStateMixin {
// // // //   late final AnimationController _pulseCtrl;
// // // //   late final Animation<double> _pulseAnim;
// // // //   late final AnimationController _ringCtrl;
// // // //   late final Animation<double> _ringAnim;
// // // //   bool _isAccepting = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _pulseCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 1200),
// // // //     )..repeat(reverse: true);
// // // //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pulseCtrl,
// // // //         curve: Curves.easeInOut,
// // // //       ),
// // // //     );
// // // //     _ringCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 2000),
// // // //     )..repeat();
// // // //     _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
// // // //       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pulseCtrl.dispose();
// // // //     _ringCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   Future<void> _acceptCall() async {
// // // //     if (_isAccepting) return;
// // // //     setState(() => _isAccepting = true);

// // // //     try {
// // // //       final api = widget.ref.read(apiServiceProvider);
// // // //       final res = await api.post(
// // // //         '/api/calls/accept',
// // // //         body: {'channel_name': widget.channelName},
// // // //       );

// // // //       if (!mounted) return;

// // // //       if (res.ok) {
// // // //         final token = res.data['host_token'] as String;
// // // //         final channelId = res.data['channel_name'] as String;
// // // //         final sessionId = res.data['session_id'] as String;
// // // //         final pricePerMin =
// // // //             (res.data['price_per_minute'] as num?)?.toInt() ?? 0;

// // // //         final callerHost = HostModel(
// // // //           userId: widget.callerId,
// // // //           publicId: 0,
// // // //           displayName: widget.callerName,
// // // //           countryCode: '',
// // // //           language: '',
// // // //           priceCoins: pricePerMin,
// // // //           level: 1,
// // // //           status: HostStatus.online,
// // // //         );

// // // //         Navigator.of(context).pushReplacement(
// // // //           MaterialPageRoute(
// // // //             builder: (_) => OngoingCallScreen(
// // // //               host: callerHost,
// // // //               initialCoins: 999999,
// // // //               sessionId: sessionId,
// // // //               channelId: channelId,
// // // //               token: token,
// // // //               localUid: 2,
// // // //             ),
// // // //           ),
// // // //         );
// // // //       } else {
// // // //         if (mounted) {
// // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // //             SnackBar(
// // // //               content: Text(res.error ?? 'Call ended'),
// // // //               backgroundColor: Colors.orange,
// // // //               behavior: SnackBarBehavior.floating,
// // // //             ),
// // // //           );
// // // //           Navigator.of(context).pop();
// // // //         }
// // // //       }
// // // //     } catch (_) {
// // // //       if (mounted) Navigator.of(context).pop();
// // // //     }
// // // //   }

// // // //   void _rejectCall() {
// // // //     Navigator.of(context).pop();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       body: Container(
// // // //         decoration: const BoxDecoration(
// // // //           gradient: LinearGradient(
// // // //             begin: Alignment.topLeft,
// // // //             end: Alignment.bottomRight,
// // // //             colors: [
// // // //               Color(0xFF0F0C29),
// // // //               Color(0xFF302B63),
// // // //               Color(0xFF24243E),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         child: SafeArea(
// // // //           child: Column(
// // // //             children: [
// // // //               const Spacer(flex: 1),
// // // //               // "Incoming Call" label
// // // //               Container(
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 20,
// // // //                   vertical: 8,
// // // //                 ),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.white.withOpacity(0.08),
// // // //                   borderRadius: BorderRadius.circular(20),
// // // //                 ),
// // // //                 child: Row(
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     Container(
// // // //                       width: 8,
// // // //                       height: 8,
// // // //                       decoration: const BoxDecoration(
// // // //                         color: Colors.green,
// // // //                         shape: BoxShape.circle,
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(width: 8),
// // // //                     const Text(
// // // //                       'Incoming Video Call',
// // // //                       style: TextStyle(
// // // //                         color: Colors.white70,
// // // //                         fontSize: 13,
// // // //                         fontWeight: FontWeight.w500,
// // // //                         letterSpacing: 0.5,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               const Spacer(flex: 1),
// // // //               // Animated rings + avatar
// // // //               SizedBox(
// // // //                 width: 200,
// // // //                 height: 200,
// // // //                 child: Stack(
// // // //                   alignment: Alignment.center,
// // // //                   children: [
// // // //                     // Animated expanding ring
// // // //                     AnimatedBuilder(
// // // //                       animation: _ringAnim,
// // // //                       builder: (_, __) => Container(
// // // //                         width: 140 + (60 * _ringAnim.value),
// // // //                         height: 140 + (60 * _ringAnim.value),
// // // //                         decoration: BoxDecoration(
// // // //                           shape: BoxShape.circle,
// // // //                           border: Border.all(
// // // //                             color: Colors.pink.withOpacity(
// // // //                               0.3 * (1 - _ringAnim.value),
// // // //                             ),
// // // //                             width: 2,
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     // Static outer ring
// // // //                     Container(
// // // //                       width: 150,
// // // //                       height: 150,
// // // //                       decoration: BoxDecoration(
// // // //                         shape: BoxShape.circle,
// // // //                         border: Border.all(
// // // //                           color: Colors.pink.withOpacity(0.15),
// // // //                           width: 1.5,
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     // Pulsing avatar
// // // //                     ScaleTransition(
// // // //                       scale: _pulseAnim,
// // // //                       child: Container(
// // // //                         width: 120,
// // // //                         height: 120,
// // // //                         decoration: BoxDecoration(
// // // //                           shape: BoxShape.circle,
// // // //                           gradient: LinearGradient(
// // // //                             begin: Alignment.topLeft,
// // // //                             end: Alignment.bottomRight,
// // // //                             colors: [
// // // //                               Colors.pink.withOpacity(0.4),
// // // //                               Colors.purple.withOpacity(0.3),
// // // //                             ],
// // // //                           ),
// // // //                           boxShadow: [
// // // //                             BoxShadow(
// // // //                               color: Colors.pink.withOpacity(
// // // //                                 0.3,
// // // //                               ),
// // // //                               blurRadius: 30,
// // // //                               spreadRadius: 5,
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                         child: const Icon(
// // // //                           Icons.person,
// // // //                           size: 56,
// // // //                           color: Colors.white70,
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 28),
// // // //               // Caller name
// // // //               Text(
// // // //                 widget.callerName,
// // // //                 style: const TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontSize: 30,
// // // //                   fontWeight: FontWeight.bold,
// // // //                   letterSpacing: 0.5,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 8),
// // // //               Text(
// // // //                 'wants to video call you',
// // // //                 style: TextStyle(
// // // //                   color: Colors.white.withOpacity(0.45),
// // // //                   fontSize: 15,
// // // //                 ),
// // // //               ),
// // // //               const Spacer(flex: 3),
// // // //               // Accept / Reject buttons
// // // //               Padding(
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 50,
// // // //                 ),
// // // //                 child: Row(
// // // //                   mainAxisAlignment:
// // // //                       MainAxisAlignment.spaceBetween,
// // // //                   children: [
// // // //                     // Decline
// // // //                     Column(
// // // //                       children: [
// // // //                         GestureDetector(
// // // //                           onTap: _rejectCall,
// // // //                           child: Container(
// // // //                             width: 72,
// // // //                             height: 72,
// // // //                             decoration: BoxDecoration(
// // // //                               shape: BoxShape.circle,
// // // //                               gradient: const LinearGradient(
// // // //                                 begin: Alignment.topLeft,
// // // //                                 end: Alignment.bottomRight,
// // // //                                 colors: [
// // // //                                   Color(0xFFFF4444),
// // // //                                   Color(0xFFCC0000),
// // // //                                 ],
// // // //                               ),
// // // //                               boxShadow: [
// // // //                                 BoxShadow(
// // // //                                   color: Colors.red.withOpacity(
// // // //                                     0.4,
// // // //                                   ),
// // // //                                   blurRadius: 16,
// // // //                                   offset: const Offset(0, 4),
// // // //                                 ),
// // // //                               ],
// // // //                             ),
// // // //                             child: const Icon(
// // // //                               Icons.call_end_rounded,
// // // //                               color: Colors.white,
// // // //                               size: 32,
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                         const SizedBox(height: 12),
// // // //                         Text(
// // // //                           'Decline',
// // // //                           style: TextStyle(
// // // //                             color: Colors.white.withOpacity(0.5),
// // // //                             fontSize: 13,
// // // //                             fontWeight: FontWeight.w500,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     // Accept
// // // //                     Column(
// // // //                       children: [
// // // //                         GestureDetector(
// // // //                           onTap: _acceptCall,
// // // //                           child: Container(
// // // //                             width: 72,
// // // //                             height: 72,
// // // //                             decoration: BoxDecoration(
// // // //                               shape: BoxShape.circle,
// // // //                               gradient: const LinearGradient(
// // // //                                 begin: Alignment.topLeft,
// // // //                                 end: Alignment.bottomRight,
// // // //                                 colors: [
// // // //                                   Color(0xFF00E676),
// // // //                                   Color(0xFF00C853),
// // // //                                 ],
// // // //                               ),
// // // //                               boxShadow: [
// // // //                                 BoxShadow(
// // // //                                   color: Colors.green
// // // //                                       .withOpacity(0.4),
// // // //                                   blurRadius: 16,
// // // //                                   offset: const Offset(0, 4),
// // // //                                 ),
// // // //                               ],
// // // //                             ),
// // // //                             child: _isAccepting
// // // //                                 ? const SizedBox(
// // // //                                     width: 30,
// // // //                                     height: 30,
// // // //                                     child:
// // // //                                         CircularProgressIndicator(
// // // //                                           color: Colors.white,
// // // //                                           strokeWidth: 2.5,
// // // //                                         ),
// // // //                                   )
// // // //                                 : const Icon(
// // // //                                     Icons.videocam_rounded,
// // // //                                     color: Colors.white,
// // // //                                     size: 32,
// // // //                                   ),
// // // //                           ),
// // // //                         ),
// // // //                         const SizedBox(height: 12),
// // // //                         Text(
// // // //                           'Accept',
// // // //                           style: TextStyle(
// // // //                             color: Colors.white.withOpacity(0.5),
// // // //                             fontSize: 13,
// // // //                             fontWeight: FontWeight.w500,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 50),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/services/fcm_service.dart
// // // //
// // // // Firebase Cloud Messaging — handles:
// // // //   1. Permission request + token registration
// // // //   2. Token refresh → re-register with backend
// // // //   3. Foreground messages → local notification or in-app overlay
// // // //   4. Background messages → system notification
// // // //   5. Notification taps → navigate to correct screen

// // // import 'dart:io';

// // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // // import 'package:cheerchat/providers/notification_provider.dart';
// // // import 'package:cheerchat/services/api_service.dart';
// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';

// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // Top-level background handler (must be a top-level function)
// // // // ─────────────────────────────────────────────────────────────────────────────

// // // @pragma('vm:entry-point')
// // // Future<void> firebaseMessagingBackgroundHandler(
// // //   RemoteMessage message,
// // // ) async {
// // //   // Background messages are automatically shown as system notifications
// // //   // by Firebase on Android. Nothing extra needed here unless you want
// // //   // to do background processing (e.g. wake lock for calls).
// // //   debugPrint('[FCM] Background message: ${message.data}');
// // // }

// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // FCM Service
// // // // ─────────────────────────────────────────────────────────────────────────────

// // // final fcmServiceProvider = Provider((ref) => FcmService(ref));

// // // class FcmService {
// // //   final Ref _ref;
// // //   final FirebaseMessaging _messaging =
// // //       FirebaseMessaging.instance;
// // //   bool _initialized = false;

// // //   FcmService(this._ref);

// // //   /// Call once after user is authenticated and API service is ready.
// // //   Future<void> initialize() async {
// // //     if (_initialized) return;
// // //     _initialized = true;
// // //     // 1. Request permission
// // //     final settings = await _messaging.requestPermission(
// // //       alert: true,
// // //       badge: true,
// // //       sound: true,
// // //       provisional: false,
// // //     );

// // //     if (settings.authorizationStatus ==
// // //         AuthorizationStatus.denied) {
// // //       debugPrint('[FCM] Notification permission denied.');
// // //       return;
// // //     }

// // //     debugPrint(
// // //       '[FCM] Permission: ${settings.authorizationStatus}',
// // //     );

// // //     // 2. Get token and register with backend
// // //     final token = await _messaging.getToken();
// // //     if (token != null) {
// // //       await _registerToken(token);
// // //     }

// // //     // 3. Listen for token refresh
// // //     _messaging.onTokenRefresh.listen((newToken) {
// // //       _registerToken(newToken);
// // //     });

// // //     // 4. Handle foreground messages
// // //     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

// // //     // 5. Handle notification taps (app was in background/terminated)
// // //     FirebaseMessaging.onMessageOpenedApp.listen(
// // //       _handleNotificationTap,
// // //     );

// // //     // 6. Check if app was opened from a terminated state via notification
// // //     final initialMessage = await _messaging.getInitialMessage();
// // //     if (initialMessage != null) {
// // //       _handleNotificationTap(initialMessage);
// // //     }

// // //     debugPrint('[FCM] Service initialized.');
// // //   }

// // //   /// Register FCM token with backend.
// // //   Future<void> _registerToken(String token) async {
// // //     debugPrint(
// // //       '[FCM] Registering token: ${token.substring(0, 20)}...',
// // //     );
// // //     final api = _ref.read(apiServiceProvider);
// // //     await registerFcmToken(
// // //       api,
// // //       token: token,
// // //       platform: Platform.isIOS ? 'ios' : 'android',
// // //     );
// // //   }

// // //   /// Handle messages while app is in the foreground.
// // //   void _handleForegroundMessage(RemoteMessage message) {
// // //     debugPrint('[FCM] Foreground: ${message.data}');

// // //     final type = message.data['type'];

// // //     switch (type) {
// // //       case 'incoming_call':
// // //         // Show incoming call screen overlay
// // //         _showIncomingCall(message.data);
// // //         break;
// // //       case 'gift_received':
// // //       case 'new_message':
// // //       case 'level_up':
// // //       case 'host_online':
// // //       case 'low_balance':
// // //         // Refresh notification count
// // //         _ref
// // //             .read(unreadNotificationCountProvider.notifier)
// // //             .refresh();
// // //         break;
// // //     }
// // //   }

// // //   /// Handle notification taps — navigate to the right screen.
// // //   void _handleNotificationTap(RemoteMessage message) {
// // //     debugPrint('[FCM] Notification tapped: ${message.data}');

// // //     final type = message.data['type'];

// // //     switch (type) {
// // //       case 'incoming_call':
// // //         _showIncomingCall(message.data);
// // //         break;
// // //       // Other types can navigate to specific screens later
// // //       // case 'gift_received': → navigate to gifts tab
// // //       // case 'new_message': → navigate to chat
// // //       // case 'host_online': → navigate to host profile
// // //     }
// // //   }

// // //   /// Show the incoming call screen.
// // //   void _showIncomingCall(Map<String, dynamic> data) {
// // //     final callerName = data['caller_name'] ?? 'Unknown';
// // //     final channelName = data['channel_name'] ?? '';
// // //     final callerId = data['caller_id'] ?? '';

// // //     debugPrint(
// // //       '[FCM] Incoming call from $callerName on channel $channelName',
// // //     );

// // //     // Navigate to incoming call screen using the global navigator key
// // //     final context = _navigatorKey?.currentContext;
// // //     if (context != null) {
// // //       Navigator.of(context, rootNavigator: true).push(
// // //         MaterialPageRoute(
// // //           builder: (_) => _IncomingCallOverlay(
// // //             callerName: callerName,
// // //             channelName: channelName,
// // //             callerId: callerId,
// // //             ref: _ref,
// // //           ),
// // //         ),
// // //       );
// // //     }
// // //   }

// // //   /// Set the navigator key (call from main.dart)
// // //   static GlobalKey<NavigatorState>? _navigatorKey;
// // //   static void setNavigatorKey(GlobalKey<NavigatorState> key) {
// // //     _navigatorKey = key;
// // //   }
// // // }

// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // Incoming Call Overlay Screen
// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class _IncomingCallOverlay extends StatefulWidget {
// // //   const _IncomingCallOverlay({
// // //     required this.callerName,
// // //     required this.channelName,
// // //     required this.callerId,
// // //     required this.ref,
// // //   });

// // //   final String callerName;
// // //   final String channelName;
// // //   final String callerId;
// // //   final Ref ref;

// // //   @override
// // //   State<_IncomingCallOverlay> createState() =>
// // //       _IncomingCallOverlayState();
// // // }

// // // class _IncomingCallOverlayState
// // //     extends State<_IncomingCallOverlay>
// // //     with TickerProviderStateMixin {
// // //   late final AnimationController _pulseCtrl;
// // //   late final Animation<double> _pulseAnim;
// // //   late final AnimationController _ringCtrl;
// // //   late final Animation<double> _ringAnim;
// // //   bool _isAccepting = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _pulseCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 1200),
// // //     )..repeat(reverse: true);
// // //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
// // //       CurvedAnimation(
// // //         parent: _pulseCtrl,
// // //         curve: Curves.easeInOut,
// // //       ),
// // //     );
// // //     _ringCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 2000),
// // //     )..repeat();
// // //     _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
// // //       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pulseCtrl.dispose();
// // //     _ringCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   Future<void> _acceptCall() async {
// // //     if (_isAccepting) return;
// // //     setState(() => _isAccepting = true);

// // //     try {
// // //       final api = widget.ref.read(apiServiceProvider);
// // //       final res = await api.post(
// // //         '/api/calls/accept',
// // //         body: {'channel_name': widget.channelName},
// // //       );

// // //       if (!mounted) return;

// // //       if (res.ok) {
// // //         final token = res.data['host_token'] as String;
// // //         final channelId = res.data['channel_name'] as String;
// // //         final sessionId = res.data['session_id'] as String;
// // //         final pricePerMin =
// // //             (res.data['price_per_minute'] as num?)?.toInt() ?? 0;

// // //         final callerHost = HostModel(
// // //           userId: widget.callerId,
// // //           publicId: 0,
// // //           displayName: widget.callerName,
// // //           countryCode: '',
// // //           language: '',
// // //           priceCoins: pricePerMin,
// // //           level: 1,
// // //           status: HostStatus.online,
// // //         );

// // //         Navigator.of(context).pushReplacement(
// // //           MaterialPageRoute(
// // //             builder: (_) => OngoingCallScreen(
// // //               host: callerHost,
// // //               initialCoins: 999999,
// // //               sessionId: sessionId,
// // //               channelId: channelId,
// // //               token: token,
// // //               localUid: 2,
// // //             ),
// // //           ),
// // //         );
// // //       } else {
// // //         if (mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             SnackBar(
// // //               content: Text(res.error ?? 'Call ended'),
// // //               backgroundColor: Colors.orange,
// // //               behavior: SnackBarBehavior.floating,
// // //             ),
// // //           );
// // //           Navigator.of(context).pop();
// // //         }
// // //       }
// // //     } catch (_) {
// // //       if (mounted) Navigator.of(context).pop();
// // //     }
// // //   }

// // //   void _rejectCall() async {
// // //     // Tell the backend to end the session so caller gets notified
// // //     try {
// // //       final api = widget.ref.read(apiServiceProvider);
// // //       await api.post(
// // //         '/api/calls/reject',
// // //         body: {'channel_name': widget.channelName},
// // //       );
// // //     } catch (_) {}
// // //     if (mounted) Navigator.of(context).pop();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: Container(
// // //         decoration: const BoxDecoration(
// // //           gradient: LinearGradient(
// // //             begin: Alignment.topLeft,
// // //             end: Alignment.bottomRight,
// // //             colors: [
// // //               Color(0xFF0F0C29),
// // //               Color(0xFF302B63),
// // //               Color(0xFF24243E),
// // //             ],
// // //           ),
// // //         ),
// // //         child: SafeArea(
// // //           child: Column(
// // //             children: [
// // //               const Spacer(flex: 1),
// // //               // "Incoming Call" label
// // //               Container(
// // //                 padding: const EdgeInsets.symmetric(
// // //                   horizontal: 20,
// // //                   vertical: 8,
// // //                 ),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white.withOpacity(0.08),
// // //                   borderRadius: BorderRadius.circular(20),
// // //                 ),
// // //                 child: Row(
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     Container(
// // //                       width: 8,
// // //                       height: 8,
// // //                       decoration: const BoxDecoration(
// // //                         color: Colors.green,
// // //                         shape: BoxShape.circle,
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 8),
// // //                     const Text(
// // //                       'Incoming Video Call',
// // //                       style: TextStyle(
// // //                         color: Colors.white70,
// // //                         fontSize: 13,
// // //                         fontWeight: FontWeight.w500,
// // //                         letterSpacing: 0.5,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const Spacer(flex: 1),
// // //               // Animated rings + avatar
// // //               SizedBox(
// // //                 width: 200,
// // //                 height: 200,
// // //                 child: Stack(
// // //                   alignment: Alignment.center,
// // //                   children: [
// // //                     // Animated expanding ring
// // //                     AnimatedBuilder(
// // //                       animation: _ringAnim,
// // //                       builder: (_, __) => Container(
// // //                         width: 140 + (60 * _ringAnim.value),
// // //                         height: 140 + (60 * _ringAnim.value),
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           border: Border.all(
// // //                             color: Colors.pink.withOpacity(
// // //                               0.3 * (1 - _ringAnim.value),
// // //                             ),
// // //                             width: 2,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     // Static outer ring
// // //                     Container(
// // //                       width: 150,
// // //                       height: 150,
// // //                       decoration: BoxDecoration(
// // //                         shape: BoxShape.circle,
// // //                         border: Border.all(
// // //                           color: Colors.pink.withOpacity(0.15),
// // //                           width: 1.5,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     // Pulsing avatar
// // //                     ScaleTransition(
// // //                       scale: _pulseAnim,
// // //                       child: Container(
// // //                         width: 120,
// // //                         height: 120,
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           gradient: LinearGradient(
// // //                             begin: Alignment.topLeft,
// // //                             end: Alignment.bottomRight,
// // //                             colors: [
// // //                               Colors.pink.withOpacity(0.4),
// // //                               Colors.purple.withOpacity(0.3),
// // //                             ],
// // //                           ),
// // //                           boxShadow: [
// // //                             BoxShadow(
// // //                               color: Colors.pink.withOpacity(
// // //                                 0.3,
// // //                               ),
// // //                               blurRadius: 30,
// // //                               spreadRadius: 5,
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         child: const Icon(
// // //                           Icons.person,
// // //                           size: 56,
// // //                           color: Colors.white70,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 28),
// // //               // Caller name
// // //               Text(
// // //                 widget.callerName,
// // //                 style: const TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 30,
// // //                   fontWeight: FontWeight.bold,
// // //                   letterSpacing: 0.5,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               Text(
// // //                 'wants to video call you',
// // //                 style: TextStyle(
// // //                   color: Colors.white.withOpacity(0.45),
// // //                   fontSize: 15,
// // //                 ),
// // //               ),
// // //               const Spacer(flex: 3),
// // //               // Accept / Reject buttons
// // //               Padding(
// // //                 padding: const EdgeInsets.symmetric(
// // //                   horizontal: 50,
// // //                 ),
// // //                 child: Row(
// // //                   mainAxisAlignment:
// // //                       MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     // Decline
// // //                     Column(
// // //                       children: [
// // //                         GestureDetector(
// // //                           onTap: _rejectCall,
// // //                           child: Container(
// // //                             width: 72,
// // //                             height: 72,
// // //                             decoration: BoxDecoration(
// // //                               shape: BoxShape.circle,
// // //                               gradient: const LinearGradient(
// // //                                 begin: Alignment.topLeft,
// // //                                 end: Alignment.bottomRight,
// // //                                 colors: [
// // //                                   Color(0xFFFF4444),
// // //                                   Color(0xFFCC0000),
// // //                                 ],
// // //                               ),
// // //                               boxShadow: [
// // //                                 BoxShadow(
// // //                                   color: Colors.red.withOpacity(
// // //                                     0.4,
// // //                                   ),
// // //                                   blurRadius: 16,
// // //                                   offset: const Offset(0, 4),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                             child: const Icon(
// // //                               Icons.call_end_rounded,
// // //                               color: Colors.white,
// // //                               size: 32,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 12),
// // //                         Text(
// // //                           'Decline',
// // //                           style: TextStyle(
// // //                             color: Colors.white.withOpacity(0.5),
// // //                             fontSize: 13,
// // //                             fontWeight: FontWeight.w500,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     // Accept
// // //                     Column(
// // //                       children: [
// // //                         GestureDetector(
// // //                           onTap: _acceptCall,
// // //                           child: Container(
// // //                             width: 72,
// // //                             height: 72,
// // //                             decoration: BoxDecoration(
// // //                               shape: BoxShape.circle,
// // //                               gradient: const LinearGradient(
// // //                                 begin: Alignment.topLeft,
// // //                                 end: Alignment.bottomRight,
// // //                                 colors: [
// // //                                   Color(0xFF00E676),
// // //                                   Color(0xFF00C853),
// // //                                 ],
// // //                               ),
// // //                               boxShadow: [
// // //                                 BoxShadow(
// // //                                   color: Colors.green
// // //                                       .withOpacity(0.4),
// // //                                   blurRadius: 16,
// // //                                   offset: const Offset(0, 4),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                             child: _isAccepting
// // //                                 ? const SizedBox(
// // //                                     width: 30,
// // //                                     height: 30,
// // //                                     child:
// // //                                         CircularProgressIndicator(
// // //                                           color: Colors.white,
// // //                                           strokeWidth: 2.5,
// // //                                         ),
// // //                                   )
// // //                                 : const Icon(
// // //                                     Icons.videocam_rounded,
// // //                                     color: Colors.white,
// // //                                     size: 32,
// // //                                   ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 12),
// // //                         Text(
// // //                           'Accept',
// // //                           style: TextStyle(
// // //                             color: Colors.white.withOpacity(0.5),
// // //                             fontSize: 13,
// // //                             fontWeight: FontWeight.w500,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 50),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/services/fcm_service.dart
// // //
// // // Firebase Cloud Messaging — handles:
// // //   1. Permission request + token registration
// // //   2. Token refresh → re-register with backend
// // //   3. Foreground messages → local notification or in-app overlay
// // //   4. Background messages → system notification
// // //   5. Notification taps → navigate to correct screen

// // import 'dart:io';

// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // import 'package:cheerchat/providers/notification_provider.dart';
// // import 'package:cheerchat/services/api_service.dart';
// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Top-level background handler (must be a top-level function)
// // // ─────────────────────────────────────────────────────────────────────────────

// // @pragma('vm:entry-point')
// // Future<void> firebaseMessagingBackgroundHandler(
// //   RemoteMessage message,
// // ) async {
// //   // Background messages are automatically shown as system notifications
// //   // by Firebase on Android. Nothing extra needed here unless you want
// //   // to do background processing (e.g. wake lock for calls).
// //   debugPrint('[FCM] Background message: ${message.data}');
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // FCM Service
// // // ─────────────────────────────────────────────────────────────────────────────

// // final fcmServiceProvider = Provider((ref) => FcmService(ref));

// // class FcmService {
// //   final Ref _ref;
// //   final FirebaseMessaging _messaging =
// //       FirebaseMessaging.instance;
// //   bool _initialized = false;

// //   FcmService(this._ref);

// //   /// Call once after user is authenticated and API service is ready.
// //   Future<void> initialize() async {
// //     if (_initialized) return;
// //     _initialized = true;
// //     // 1. Request permission
// //     final settings = await _messaging.requestPermission(
// //       alert: true,
// //       badge: true,
// //       sound: true,
// //       provisional: false,
// //     );

// //     if (settings.authorizationStatus ==
// //         AuthorizationStatus.denied) {
// //       debugPrint('[FCM] Notification permission denied.');
// //       return;
// //     }

// //     debugPrint(
// //       '[FCM] Permission: ${settings.authorizationStatus}',
// //     );

// //     // 2. Get token and register with backend
// //     final token = await _messaging.getToken();
// //     if (token != null) {
// //       await _registerToken(token);
// //     }

// //     // 3. Listen for token refresh
// //     _messaging.onTokenRefresh.listen((newToken) {
// //       _registerToken(newToken);
// //     });

// //     // 4. Handle foreground messages
// //     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

// //     // 5. Handle notification taps (app was in background/terminated)
// //     FirebaseMessaging.onMessageOpenedApp.listen(
// //       _handleNotificationTap,
// //     );

// //     // 6. Check if app was opened from a terminated state via notification
// //     final initialMessage = await _messaging.getInitialMessage();
// //     if (initialMessage != null) {
// //       _handleNotificationTap(initialMessage);
// //     }

// //     debugPrint('[FCM] Service initialized.');
// //   }

// //   /// Register FCM token with backend.
// //   Future<void> _registerToken(String token) async {
// //     debugPrint(
// //       '[FCM] Registering token: ${token.substring(0, 20)}...',
// //     );
// //     final api = _ref.read(apiServiceProvider);
// //     await registerFcmToken(
// //       api,
// //       token: token,
// //       platform: Platform.isIOS ? 'ios' : 'android',
// //     );
// //   }

// //   /// Handle messages while app is in the foreground.
// //   void _handleForegroundMessage(RemoteMessage message) {
// //     debugPrint('[FCM] Foreground: ${message.data}');

// //     final type = message.data['type'];

// //     switch (type) {
// //       case 'incoming_call':
// //         // Show incoming call screen overlay
// //         _showIncomingCall(message.data);
// //         break;
// //       case 'gift_received':
// //       case 'new_message':
// //       case 'level_up':
// //       case 'host_online':
// //       case 'low_balance':
// //         // Refresh notification count
// //         _ref
// //             .read(unreadNotificationCountProvider.notifier)
// //             .refresh();
// //         break;
// //     }
// //   }

// //   /// Handle notification taps — navigate to the right screen.
// //   void _handleNotificationTap(RemoteMessage message) {
// //     debugPrint('[FCM] Notification tapped: ${message.data}');

// //     final type = message.data['type'];

// //     switch (type) {
// //       case 'incoming_call':
// //         _showIncomingCall(message.data);
// //         break;
// //       // Other types can navigate to specific screens later
// //       // case 'gift_received': → navigate to gifts tab
// //       // case 'new_message': → navigate to chat
// //       // case 'host_online': → navigate to host profile
// //     }
// //   }

// //   /// Show the incoming call screen.
// //   void _showIncomingCall(Map<String, dynamic> data) {
// //     final callerName = data['caller_name'] ?? 'Unknown';
// //     final channelName = data['channel_name'] ?? '';
// //     final callerId = data['caller_id'] ?? '';

// //     debugPrint(
// //       '[FCM] Incoming call from $callerName on channel $channelName',
// //     );

// //     // Navigate to incoming call screen using the global navigator key
// //     final context = _navigatorKey?.currentContext;
// //     if (context != null) {
// //       Navigator.of(context, rootNavigator: true).push(
// //         MaterialPageRoute(
// //           builder: (_) => _IncomingCallOverlay(
// //             callerName: callerName,
// //             channelName: channelName,
// //             callerId: callerId,
// //             ref: _ref,
// //           ),
// //         ),
// //       );
// //     }
// //   }

// //   /// Set the navigator key (call from main.dart)
// //   static GlobalKey<NavigatorState>? _navigatorKey;
// //   static void setNavigatorKey(GlobalKey<NavigatorState> key) {
// //     _navigatorKey = key;
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Incoming Call Overlay Screen
// // // ─────────────────────────────────────────────────────────────────────────────

// // class _IncomingCallOverlay extends StatefulWidget {
// //   const _IncomingCallOverlay({
// //     required this.callerName,
// //     required this.channelName,
// //     required this.callerId,
// //     required this.ref,
// //   });

// //   final String callerName;
// //   final String channelName;
// //   final String callerId;
// //   final Ref ref;

// //   @override
// //   State<_IncomingCallOverlay> createState() =>
// //       _IncomingCallOverlayState();
// // }

// // class _IncomingCallOverlayState
// //     extends State<_IncomingCallOverlay>
// //     with TickerProviderStateMixin {
// //   late final AnimationController _pulseCtrl;
// //   late final Animation<double> _pulseAnim;
// //   late final AnimationController _ringCtrl;
// //   late final Animation<double> _ringAnim;
// //   bool _isAccepting = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pulseCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1200),
// //     )..repeat(reverse: true);
// //     _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
// //       CurvedAnimation(
// //         parent: _pulseCtrl,
// //         curve: Curves.easeInOut,
// //       ),
// //     );
// //     _ringCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 2000),
// //     )..repeat();
// //     _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pulseCtrl.dispose();
// //     _ringCtrl.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _acceptCall() async {
// //     if (_isAccepting) return;
// //     setState(() => _isAccepting = true);

// //     try {
// //       final api = widget.ref.read(apiServiceProvider);
// //       final res = await api.post(
// //         '/api/calls/accept',
// //         body: {'channel_name': widget.channelName},
// //       );

// //       if (!mounted) return;

// //       if (res.ok) {
// //         final token = res.data['host_token'] as String;
// //         final channelId = res.data['channel_name'] as String;
// //         final sessionId = res.data['session_id'] as String;
// //         final pricePerMin =
// //             (res.data['price_per_minute'] as num?)?.toInt() ?? 0;

// //         final callerHost = HostModel(
// //           userId: widget.callerId,
// //           publicId: 0,
// //           displayName: widget.callerName,
// //           countryCode: '',
// //           language: '',
// //           priceCoins: pricePerMin,
// //           level: 1,
// //           status: HostStatus.online,
// //         );

// //         Navigator.of(context).pushReplacement(
// //           MaterialPageRoute(
// //             builder: (_) => OngoingCallScreen(
// //               host: callerHost,
// //               initialCoins: 999999,
// //               sessionId: sessionId,
// //               channelId: channelId,
// //               token: token,
// //               localUid: 2,
// //             ),
// //           ),
// //         );
// //       } else {
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text(res.error ?? 'Call ended'),
// //               backgroundColor: Colors.orange,
// //               behavior: SnackBarBehavior.floating,
// //             ),
// //           );
// //           Navigator.of(context).pop();
// //         }
// //       }
// //     } catch (_) {
// //       if (mounted) Navigator.of(context).pop();
// //     }
// //   }

// //   void _rejectCall() async {
// //     // Tell the backend to end the session so caller gets notified
// //     try {
// //       final api = widget.ref.read(apiServiceProvider);
// //       await api.post(
// //         '/api/calls/reject',
// //         body: {'channel_name': widget.channelName},
// //       );
// //     } catch (_) {}
// //     if (mounted) Navigator.of(context).pop();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFF0F0C29),
// //               Color(0xFF302B63),
// //               Color(0xFF24243E),
// //             ],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               const Spacer(flex: 1),
// //               // "Incoming Call" label
// //               Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 20,
// //                   vertical: 8,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.08),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Container(
// //                       width: 8,
// //                       height: 8,
// //                       decoration: const BoxDecoration(
// //                         color: Colors.green,
// //                         shape: BoxShape.circle,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     const Text(
// //                       'Incoming Video Call',
// //                       style: TextStyle(
// //                         color: Colors.white70,
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w500,
// //                         letterSpacing: 0.5,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const Spacer(flex: 1),
// //               // Animated rings + avatar
// //               SizedBox(
// //                 width: 200,
// //                 height: 200,
// //                 child: Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     // Animated expanding ring
// //                     AnimatedBuilder(
// //                       animation: _ringAnim,
// //                       builder: (_, __) => Container(
// //                         width: 140 + (60 * _ringAnim.value),
// //                         height: 140 + (60 * _ringAnim.value),
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(
// //                             color: Colors.pink.withOpacity(
// //                               0.3 * (1 - _ringAnim.value),
// //                             ),
// //                             width: 2,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     // Static outer ring
// //                     Container(
// //                       width: 150,
// //                       height: 150,
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         border: Border.all(
// //                           color: Colors.pink.withOpacity(0.15),
// //                           width: 1.5,
// //                         ),
// //                       ),
// //                     ),
// //                     // Pulsing avatar
// //                     ScaleTransition(
// //                       scale: _pulseAnim,
// //                       child: Container(
// //                         width: 120,
// //                         height: 120,
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           gradient: LinearGradient(
// //                             begin: Alignment.topLeft,
// //                             end: Alignment.bottomRight,
// //                             colors: [
// //                               Colors.pink.withOpacity(0.4),
// //                               Colors.purple.withOpacity(0.3),
// //                             ],
// //                           ),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.pink.withOpacity(
// //                                 0.3,
// //                               ),
// //                               blurRadius: 30,
// //                               spreadRadius: 5,
// //                             ),
// //                           ],
// //                         ),
// //                         child: const Icon(
// //                           Icons.person,
// //                           size: 56,
// //                           color: Colors.white70,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 28),
// //               // Caller name
// //               Text(
// //                 widget.callerName,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 30,
// //                   fontWeight: FontWeight.bold,
// //                   letterSpacing: 0.5,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 'wants to video call you',
// //                 style: TextStyle(
// //                   color: Colors.white.withOpacity(0.45),
// //                   fontSize: 15,
// //                 ),
// //               ),
// //               const Spacer(flex: 3),
// //               // Accept / Reject buttons
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 50,
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment:
// //                       MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     // Decline
// //                     Column(
// //                       children: [
// //                         GestureDetector(
// //                           onTap: _rejectCall,
// //                           child: Container(
// //                             width: 72,
// //                             height: 72,
// //                             decoration: BoxDecoration(
// //                               shape: BoxShape.circle,
// //                               gradient: const LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [
// //                                   Color(0xFFFF4444),
// //                                   Color(0xFFCC0000),
// //                                 ],
// //                               ),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: Colors.red.withOpacity(
// //                                     0.4,
// //                                   ),
// //                                   blurRadius: 16,
// //                                   offset: const Offset(0, 4),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: const Icon(
// //                               Icons.call_end_rounded,
// //                               color: Colors.white,
// //                               size: 32,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 12),
// //                         Text(
// //                           'Decline',
// //                           style: TextStyle(
// //                             color: Colors.white.withOpacity(0.5),
// //                             fontSize: 13,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     // Accept
// //                     Column(
// //                       children: [
// //                         GestureDetector(
// //                           onTap: _acceptCall,
// //                           child: Container(
// //                             width: 72,
// //                             height: 72,
// //                             decoration: BoxDecoration(
// //                               shape: BoxShape.circle,
// //                               gradient: const LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [
// //                                   Color(0xFF00E676),
// //                                   Color(0xFF00C853),
// //                                 ],
// //                               ),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: Colors.green
// //                                       .withOpacity(0.4),
// //                                   blurRadius: 16,
// //                                   offset: const Offset(0, 4),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: _isAccepting
// //                                 ? const SizedBox(
// //                                     width: 30,
// //                                     height: 30,
// //                                     child:
// //                                         CircularProgressIndicator(
// //                                           color: Colors.white,
// //                                           strokeWidth: 2.5,
// //                                         ),
// //                                   )
// //                                 : const Icon(
// //                                     Icons.videocam_rounded,
// //                                     color: Colors.white,
// //                                     size: 32,
// //                                   ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 12),
// //                         Text(
// //                           'Accept',
// //                           style: TextStyle(
// //                             color: Colors.white.withOpacity(0.5),
// //                             fontSize: 13,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 50),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/services/fcm_service.dart
// //
// // Firebase Cloud Messaging — handles:
// //   1. Permission request + token registration
// //   2. Token refresh → re-register with backend
// //   3. Foreground messages → local notification or in-app overlay
// //   4. Background messages → system notification
// //   5. Notification taps → navigate to correct screen

// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:cheerchat/providers/notification_provider.dart';
// import 'package:cheerchat/services/api_service.dart';
// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/screens/ongoing_call_screen.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Top-level background handler (must be a top-level function)
// // ─────────────────────────────────────────────────────────────────────────────

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(
//   RemoteMessage message,
// ) async {
//   // Background messages are automatically shown as system notifications
//   // by Firebase on Android. Nothing extra needed here unless you want
//   // to do background processing (e.g. wake lock for calls).
//   debugPrint('[FCM] Background message: ${message.data}');
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // FCM Service
// // ─────────────────────────────────────────────────────────────────────────────

// final fcmServiceProvider = Provider((ref) => FcmService(ref));

// class FcmService {
//   final Ref _ref;
//   final FirebaseMessaging _messaging =
//       FirebaseMessaging.instance;
//   bool _initialized = false;

//   FcmService(this._ref);

//   /// Call once after user is authenticated and API service is ready.
//   Future<void> initialize() async {
//     if (_initialized) return;
//     _initialized = true;
//     // 1. Request permission
//     final settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     if (settings.authorizationStatus ==
//         AuthorizationStatus.denied) {
//       debugPrint('[FCM] Notification permission denied.');
//       return;
//     }

//     debugPrint(
//       '[FCM] Permission: ${settings.authorizationStatus}',
//     );

//     // 2. Get token and register with backend
//     final token = await _messaging.getToken();
//     if (token != null) {
//       await _registerToken(token);
//     }

//     // 3. Listen for token refresh
//     _messaging.onTokenRefresh.listen((newToken) {
//       _registerToken(newToken);
//     });

//     // 4. Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // 5. Handle notification taps (app was in background/terminated)
//     FirebaseMessaging.onMessageOpenedApp.listen(
//       _handleNotificationTap,
//     );

//     // 6. Check if app was opened from a terminated state via notification
//     final initialMessage = await _messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleNotificationTap(initialMessage);
//     }

//     debugPrint('[FCM] Service initialized.');
//   }

//   /// Register FCM token with backend.
//   Future<void> _registerToken(String token) async {
//     debugPrint(
//       '[FCM] Registering token: ${token.substring(0, 20)}...',
//     );
//     final api = _ref.read(apiServiceProvider);
//     await registerFcmToken(
//       api,
//       token: token,
//       platform: Platform.isIOS ? 'ios' : 'android',
//     );
//   }

//   /// Handle messages while app is in the foreground.
//   void _handleForegroundMessage(RemoteMessage message) {
//     debugPrint('[FCM] Foreground: ${message.data}');

//     final type = message.data['type'];

//     switch (type) {
//       case 'incoming_call':
//         // Show incoming call screen overlay
//         _showIncomingCall(message.data);
//         break;
//       case 'gift_received':
//       case 'new_message':
//       case 'level_up':
//       case 'host_online':
//       case 'low_balance':
//         // Refresh notification count
//         _ref
//             .read(unreadNotificationCountProvider.notifier)
//             .refresh();
//         break;
//     }
//   }

//   /// Handle notification taps — navigate to the right screen.
//   void _handleNotificationTap(RemoteMessage message) {
//     debugPrint('[FCM] Notification tapped: ${message.data}');

//     final type = message.data['type'];

//     switch (type) {
//       case 'incoming_call':
//         _showIncomingCall(message.data);
//         break;
//       // Other types can navigate to specific screens later
//       // case 'gift_received': → navigate to gifts tab
//       // case 'new_message': → navigate to chat
//       // case 'host_online': → navigate to host profile
//     }
//   }

//   /// Show the incoming call screen.
//   void _showIncomingCall(Map<String, dynamic> data) {
//     final callerName = data['caller_name'] ?? 'Unknown';
//     final channelName = data['channel_name'] ?? '';
//     final callerId = data['caller_id'] ?? '';

//     debugPrint(
//       '[FCM] Incoming call from $callerName on channel $channelName',
//     );

//     // Navigate to incoming call screen using the global navigator key
//     final context = _navigatorKey?.currentContext;
//     if (context != null) {
//       Navigator.of(context, rootNavigator: true).push(
//         MaterialPageRoute(
//           builder: (_) => _IncomingCallOverlay(
//             callerName: callerName,
//             channelName: channelName,
//             callerId: callerId,
//             ref: _ref,
//           ),
//         ),
//       );
//     }
//   }

//   /// Set the navigator key (call from main.dart)
//   static GlobalKey<NavigatorState>? _navigatorKey;
//   static void setNavigatorKey(GlobalKey<NavigatorState> key) {
//     _navigatorKey = key;
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Incoming Call Overlay Screen
// // ─────────────────────────────────────────────────────────────────────────────

// class _IncomingCallOverlay extends StatefulWidget {
//   const _IncomingCallOverlay({
//     required this.callerName,
//     required this.channelName,
//     required this.callerId,
//     required this.ref,
//   });

//   final String callerName;
//   final String channelName;
//   final String callerId;
//   final Ref ref;

//   @override
//   State<_IncomingCallOverlay> createState() =>
//       _IncomingCallOverlayState();
// }

// class _IncomingCallOverlayState
//     extends State<_IncomingCallOverlay>
//     with TickerProviderStateMixin {
//   late final AnimationController _pulseCtrl;
//   late final Animation<double> _pulseAnim;
//   late final AnimationController _ringCtrl;
//   late final Animation<double> _ringAnim;
//   bool _isAccepting = false;

//   @override
//   void initState() {
//     super.initState();
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(
//         parent: _pulseCtrl,
//         curve: Curves.easeInOut,
//       ),
//     );
//     _ringCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat();
//     _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseCtrl.dispose();
//     _ringCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _acceptCall() async {
//     if (_isAccepting) return;
//     setState(() => _isAccepting = true);

//     try {
//       final api = widget.ref.read(apiServiceProvider);
//       final res = await api.post(
//         '/api/calls/accept',
//         body: {'channel_name': widget.channelName},
//       );

//       if (!mounted) return;

//       if (res.ok) {
//         final token = res.data['host_token'] as String;
//         final channelId = res.data['channel_name'] as String;
//         final sessionId = res.data['session_id'] as String;
//         final pricePerMin =
//             (res.data['price_per_minute'] as num?)?.toInt() ?? 0;

//         final callerHost = HostModel(
//           userId: widget.callerId,
//           publicId: 0,
//           displayName: widget.callerName,
//           countryCode: '',
//           language: '',
//           priceCoins: pricePerMin,
//           level: 1,
//           status: HostStatus.online,
//         );

//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => OngoingCallScreen(
//               host: callerHost,
//               initialCoins: 999999,
//               sessionId: sessionId,
//               channelId: channelId,
//               token: token,
//               localUid: 2,
//             ),
//           ),
//         );
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context)
//             ..clearSnackBars()
//             ..showSnackBar(
//               SnackBar(
//                 content: Text(res.error ?? 'Call ended'),
//                 duration: const Duration(milliseconds: 1500),
//                 backgroundColor: Colors.orange,
//                 behavior: SnackBarBehavior.floating,
//               ),
//             );
//           Navigator.of(context).pop();
//         }
//       }
//     } catch (_) {
//       if (mounted) Navigator.of(context).pop();
//     }
//   }

//   void _rejectCall() async {
//     // Tell the backend to end the session so caller gets notified
//     try {
//       final api = widget.ref.read(apiServiceProvider);
//       await api.post(
//         '/api/calls/reject',
//         body: {'channel_name': widget.channelName},
//       );
//     } catch (_) {}
//     if (mounted) Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0F0C29),
//               Color(0xFF302B63),
//               Color(0xFF24243E),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const Spacer(flex: 1),
//               // "Incoming Call" label
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Incoming Video Call',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(flex: 1),
//               // Animated rings + avatar
//               SizedBox(
//                 width: 200,
//                 height: 200,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Animated expanding ring
//                     AnimatedBuilder(
//                       animation: _ringAnim,
//                       builder: (_, __) => Container(
//                         width: 140 + (60 * _ringAnim.value),
//                         height: 140 + (60 * _ringAnim.value),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.pink.withOpacity(
//                               0.3 * (1 - _ringAnim.value),
//                             ),
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Static outer ring
//                     Container(
//                       width: 150,
//                       height: 150,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.pink.withOpacity(0.15),
//                           width: 1.5,
//                         ),
//                       ),
//                     ),
//                     // Pulsing avatar
//                     ScaleTransition(
//                       scale: _pulseAnim,
//                       child: Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               Colors.pink.withOpacity(0.4),
//                               Colors.purple.withOpacity(0.3),
//                             ],
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.pink.withOpacity(
//                                 0.3,
//                               ),
//                               blurRadius: 30,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.person,
//                           size: 56,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 28),
//               // Caller name
//               Text(
//                 widget.callerName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'wants to video call you',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.45),
//                   fontSize: 15,
//                 ),
//               ),
//               const Spacer(flex: 3),
//               // Accept / Reject buttons
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 50,
//                 ),
//                 child: Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Decline
//                     Column(
//                       children: [
//                         GestureDetector(
//                           onTap: _rejectCall,
//                           child: Container(
//                             width: 72,
//                             height: 72,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: const LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Color(0xFFFF4444),
//                                   Color(0xFFCC0000),
//                                 ],
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.red.withOpacity(
//                                     0.4,
//                                   ),
//                                   blurRadius: 16,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.call_end_rounded,
//                               color: Colors.white,
//                               size: 32,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           'Decline',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.5),
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Accept
//                     Column(
//                       children: [
//                         GestureDetector(
//                           onTap: _acceptCall,
//                           child: Container(
//                             width: 72,
//                             height: 72,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: const LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Color(0xFF00E676),
//                                   Color(0xFF00C853),
//                                 ],
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.green
//                                       .withOpacity(0.4),
//                                   blurRadius: 16,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: _isAccepting
//                                 ? const SizedBox(
//                                     width: 30,
//                                     height: 30,
//                                     child:
//                                         CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2.5,
//                                         ),
//                                   )
//                                 : const Icon(
//                                     Icons.videocam_rounded,
//                                     color: Colors.white,
//                                     size: 32,
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           'Accept',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.5),
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/services/fcm_service.dart
//
// Firebase Cloud Messaging — handles:
//   1. Permission request + token registration
//   2. Token refresh → re-register with backend
//   3. Foreground messages → local notification or in-app overlay
//   4. Background messages → system notification
//   5. Notification taps → navigate to correct screen

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/providers/notification_provider.dart';
import 'package:cheerchat/services/api_service.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/screens/ongoing_call_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level background handler (must be a top-level function)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Background messages are automatically shown as system notifications
  // by Firebase on Android. Nothing extra needed here unless you want
  // to do background processing (e.g. wake lock for calls).
  debugPrint('[FCM] Background message: ${message.data}');
}

// ─────────────────────────────────────────────────────────────────────────────
// FCM Service
// ─────────────────────────────────────────────────────────────────────────────

final fcmServiceProvider = Provider((ref) => FcmService(ref));

class FcmService {
  final Ref _ref;
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;
  bool _initialized = false;

  FcmService(this._ref);

  /// Call once after user is authenticated and API service is ready.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    // 1. Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      debugPrint('[FCM] Notification permission denied.');
      return;
    }

    debugPrint(
      '[FCM] Permission: ${settings.authorizationStatus}',
    );

    // 2. Get token and register with backend
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // 3. Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken);
    });

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle notification taps (app was in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );

    // 6. Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    debugPrint('[FCM] Service initialized.');
  }

  /// Register FCM token with backend.
  Future<void> _registerToken(String token) async {
    debugPrint(
      '[FCM] Registering token: ${token.substring(0, 20)}...',
    );
    final api = _ref.read(apiServiceProvider);
    await registerFcmToken(
      api,
      token: token,
      platform: Platform.isIOS ? 'ios' : 'android',
    );
  }

  /// Handle messages while app is in the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.data}');

    final type = message.data['type'];

    switch (type) {
      case 'incoming_call':
        // Show incoming call screen overlay
        _showIncomingCall(message.data);
        break;
      case 'gift_received':
      case 'new_message':
      case 'level_up':
      case 'host_online':
      case 'low_balance':
        // Refresh notification count
        _ref
            .read(unreadNotificationCountProvider.notifier)
            .refresh();
        break;
    }
  }

  /// Handle notification taps — navigate to the right screen.
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');

    final type = message.data['type'];

    switch (type) {
      case 'incoming_call':
        _showIncomingCall(message.data);
        break;
      // Other types can navigate to specific screens later
      // case 'gift_received': → navigate to gifts tab
      // case 'new_message': → navigate to chat
      // case 'host_online': → navigate to host profile
    }
  }

  /// Show the incoming call screen.
  void _showIncomingCall(Map<String, dynamic> data) {
    final callerName = data['caller_name'] ?? 'Unknown';
    final channelName = data['channel_name'] ?? '';
    final callerId = data['caller_id'] ?? '';

    debugPrint(
      '[FCM] Incoming call from $callerName on channel $channelName',
    );

    // Navigate to incoming call screen using the global navigator key
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => _IncomingCallOverlay(
            callerName: callerName,
            channelName: channelName,
            callerId: callerId,
            ref: _ref,
          ),
        ),
      );
    }
  }

  /// Set the navigator key (call from main.dart)
  static GlobalKey<NavigatorState>? _navigatorKey;
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Incoming Call Overlay Screen
// ─────────────────────────────────────────────────────────────────────────────

class _IncomingCallOverlay extends StatefulWidget {
  const _IncomingCallOverlay({
    required this.callerName,
    required this.channelName,
    required this.callerId,
    required this.ref,
  });

  final String callerName;
  final String channelName;
  final String callerId;
  final Ref ref;

  @override
  State<_IncomingCallOverlay> createState() =>
      _IncomingCallOverlayState();
}

class _IncomingCallOverlayState
    extends State<_IncomingCallOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: Curves.easeInOut,
      ),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  Future<void> _acceptCall() async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    try {
      final api = widget.ref.read(apiServiceProvider);
      final res = await api.post(
        '/api/calls/accept',
        body: {'channel_name': widget.channelName},
      );

      if (!mounted) return;

      if (res.ok) {
        final token = res.data['host_token'] as String;
        final channelId = res.data['channel_name'] as String;
        final sessionId = res.data['session_id'] as String;
        final pricePerMin =
            (res.data['price_per_minute'] as num?)?.toInt() ?? 0;

        final callerHost = HostModel(
          userId: widget.callerId,
          publicId: 0,
          displayName: widget.callerName,
          countryCode: '',
          language: '',
          priceCoins: pricePerMin,
          level: 1,
          status: HostStatus.online,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OngoingCallScreen(
              host: callerHost,
              initialCoins: 999999,
              sessionId: sessionId,
              channelId: channelId,
              token: token,
              localUid: 2,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(res.error ?? 'Call ended'),
                duration: const Duration(milliseconds: 1500),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          Navigator.of(context).pop();
        }
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _rejectCall() async {
    // Tell the backend to end the session so caller gets notified
    try {
      final api = widget.ref.read(apiServiceProvider);
      await api.post(
        '/api/calls/reject',
        body: {'channel_name': widget.channelName},
      );
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),
              // "Incoming Call" label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Incoming Video Call',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Animated rings + avatar
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated expanding ring
                    AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (_, __) => Container(
                        width: 140 + (60 * _ringAnim.value),
                        height: 140 + (60 * _ringAnim.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.pink.withOpacity(
                              0.3 * (1 - _ringAnim.value),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Static outer ring
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.pink.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Pulsing avatar
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.pink.withOpacity(0.4),
                              Colors.purple.withOpacity(0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(
                                0.3,
                              ),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Caller name
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'wants to video call you',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 15,
                ),
              ),
              const Spacer(flex: 3),
              // Accept / Reject buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _rejectCall,
                          child: Container(
                            width: 72,
                            height: 72,
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
                                  color: Colors.red.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.call_end_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Accept
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _acceptCall,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF00E676),
                                  Color(0xFF00C853),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green
                                      .withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isAccepting
                                ? const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                  )
                                : const Icon(
                                    Icons.videocam_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

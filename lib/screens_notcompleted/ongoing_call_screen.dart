// // // // import 'package:flutter/material.dart';
// // // // import 'package:cheerchat/services/agora_service.dart';

// // // // class OngoingCallScreen extends StatefulWidget {
// // // //   final AgoraService agoraService;
// // // //   final String channelId;
// // // //   final String token;
// // // //   final int localUid;

// // // //   const OngoingCallScreen({
// // // //     super.key,
// // // //     required this.agoraService,
// // // //     required this.channelId,
// // // //     required this.token,
// // // //     required this.localUid,
// // // //   });

// // // //   @override
// // // //   State<OngoingCallScreen> createState() =>
// // // //       _OngoingCallScreenState();
// // // // }

// // // // class _OngoingCallScreenState extends State<OngoingCallScreen> {
// // // //   bool _isConnecting = true;

// // // //   // Movable PIP Position
// // // //   Offset _pipOffset = const Offset(20, 100);

// // // //   // UI Toggle Logic
// // // //   bool _uiVisible = true;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _startCall();
// // // //   }

// // // //   void _showRechargeMenu(BuildContext context) {
// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: Colors.transparent,
// // // //       builder: (context) => Container(
// // // //         decoration: const BoxDecoration(
// // // //           color: Color(0xFF1A1A1A),
// // // //           borderRadius: BorderRadius.vertical(
// // // //             top: Radius.circular(20),
// // // //           ),
// // // //         ),
// // // //         padding: const EdgeInsets.all(20),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Container(
// // // //               width: 40,
// // // //               height: 4,
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.white24,
// // // //                 borderRadius: BorderRadius.circular(2),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 20),
// // // //             const Text(
// // // //               "Wallet Balance",
// // // //               style: TextStyle(
// // // //                 color: Colors.white70,
// // // //                 fontSize: 14,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             const Row(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 Icon(
// // // //                   Icons.monetization_on,
// // // //                   color: Colors.amber,
// // // //                   size: 28,
// // // //                 ),
// // // //                 SizedBox(width: 8),
// // // //                 Text(
// // // //                   "1,250",
// // // //                   style: TextStyle(
// // // //                     color: Colors.white,
// // // //                     fontSize: 32,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const Divider(height: 40, color: Colors.white10),
// // // //             const Align(
// // // //               alignment: Alignment.centerLeft,
// // // //               child: Text(
// // // //                 "Quick Recharge",
// // // //                 style: TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontSize: 16,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 15),
// // // //             // Example Recharge Options
// // // //             _buildRechargeOption("500 Coins", "\$4.99"),
// // // //             _buildRechargeOption("1200 Coins", "\$9.99"),
// // // //             _buildRechargeOption("3000 Coins", "\$24.99"),
// // // //             const SizedBox(height: 20),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildRechargeOption(String coins, String price) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.only(bottom: 12.0),
// // // //       child: InkWell(
// // // //         onTap: () {
// // // //           // TODO: Integrate Payment Gateway
// // // //         },
// // // //         child: Container(
// // // //           padding: const EdgeInsets.symmetric(
// // // //             horizontal: 16,
// // // //             vertical: 12,
// // // //           ),
// // // //           decoration: BoxDecoration(
// // // //             color: Colors.white.withOpacity(0.05),
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             border: Border.all(color: Colors.white10),
// // // //           ),
// // // //           child: Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Row(
// // // //                 children: [
// // // //                   const Icon(
// // // //                     Icons.monetization_on,
// // // //                     color: Colors.amber,
// // // //                     size: 20,
// // // //                   ),
// // // //                   const SizedBox(width: 10),
// // // //                   Text(
// // // //                     coins,
// // // //                     style: const TextStyle(
// // // //                       color: Colors.white,
// // // //                       fontSize: 16,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //               Container(
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 12,
// // // //                   vertical: 6,
// // // //                 ),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.amber,
// // // //                   borderRadius: BorderRadius.circular(20),
// // // //                 ),
// // // //                 child: Text(
// // // //                   price,
// // // //                   style: const TextStyle(
// // // //                     color: Colors.black,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _startCall() async {
// // // //     try {
// // // //       await widget.agoraService.initialize(
// // // //         appId: "YOUR_AGORA_APP_ID",
// // // //         fetchNewToken: () async => "NEW_TOKEN",
// // // //       );
// // // //       await widget.agoraService.join(
// // // //         token: widget.token,
// // // //         channelId: widget.channelId,
// // // //         uid: widget.localUid,
// // // //       );
// // // //       if (mounted) setState(() => _isConnecting = false);
// // // //     } catch (e) {
// // // //       if (mounted) Navigator.pop(context);
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.black,
// // // //       body: GestureDetector(
// // // //         onTap: () => setState(() => _uiVisible = !_uiVisible),
// // // //         behavior: HitTestBehavior.opaque,
// // // //         child: Stack(
// // // //           children: [
// // // //             // Layer 1: Full Screen Remote Video
// // // //             _buildRemoteVideoBackground(),

// // // //             // Layer 2: Movable PIP (Always draggable)
// // // //             _buildMovablePIP(),

// // // //             // Layer 3: Hideable UI Elements
// // // //             if (_uiVisible) ...[
// // // //               _buildTopBar(),
// // // //               _buildChatOverlay(),
// // // //               _buildRightSideButtons(),
// // // //               _buildBottomInput(),
// // // //             ],
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildRemoteVideoBackground() {
// // // //     return ValueListenableBuilder<Set<int>>(
// // // //       valueListenable: widget.agoraService.remoteUids,
// // // //       builder: (context, uids, _) {
// // // //         if (uids.isEmpty) {
// // // //           return const Center(
// // // //             child: Text(
// // // //               "Connecting...",
// // // //               style: TextStyle(color: Colors.white),
// // // //             ),
// // // //           );
// // // //         }
// // // //         return SizedBox.expand(
// // // //           child: widget.agoraService.buildRemoteVideo(
// // // //             uids.first,
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   Widget _buildMovablePIP() {
// // // //     return Positioned(
// // // //       left: _pipOffset.dx,
// // // //       top: _pipOffset.dy,
// // // //       child: GestureDetector(
// // // //         onPanUpdate: (details) {
// // // //           setState(() {
// // // //             _pipOffset += details.delta;
// // // //           });
// // // //         },
// // // //         child: Container(
// // // //           width: 110,
// // // //           height: 150,
// // // //           decoration: BoxDecoration(
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             border: Border.all(color: Colors.white24),
// // // //             boxShadow: const [
// // // //               BoxShadow(blurRadius: 10, color: Colors.black45),
// // // //             ],
// // // //           ),
// // // //           clipBehavior: Clip.antiAlias,
// // // //           child: widget.agoraService.buildLocalVideo(),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildTopBar() {
// // // //     return Positioned(
// // // //       top: 50,
// // // //       left: 16,
// // // //       right: 16,
// // // //       child: Row(
// // // //         children: [
// // // //           // User Info
// // // //           Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               horizontal: 12,
// // // //               vertical: 6,
// // // //             ),
// // // //             decoration: BoxDecoration(
// // // //               color: Colors.black45,
// // // //               borderRadius: BorderRadius.circular(20),
// // // //             ),
// // // //             child: const Text(
// // // //               "Jessica, 24",
// // // //               style: TextStyle(
// // // //                 color: Colors.white,
// // // //                 fontWeight: FontWeight.bold,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           const Spacer(),
// // // //           // Timer
// // // //           Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               horizontal: 10,
// // // //               vertical: 6,
// // // //             ),
// // // //             decoration: BoxDecoration(
// // // //               color: Colors.black45,
// // // //               borderRadius: BorderRadius.circular(20),
// // // //             ),
// // // //             child: const Text(
// // // //               "00:00",
// // // //               style: TextStyle(color: Colors.white),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(width: 10),
// // // //           // End Call (Top Right)
// // // //           GestureDetector(
// // // //             onTap: () => widget.agoraService.leave().then(
// // // //               (_) => Navigator.pop(context),
// // // //             ),
// // // //             child: Container(
// // // //               padding: const EdgeInsets.all(8),
// // // //               decoration: const BoxDecoration(
// // // //                 color: Colors.redAccent,
// // // //                 shape: BoxShape.circle,
// // // //               ),
// // // //               child: const Icon(
// // // //                 Icons.call_end,
// // // //                 color: Colors.white,
// // // //                 size: 20,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildRightSideButtons() {
// // // //     return Positioned(
// // // //       bottom: 100, // Above chat bar
// // // //       right: 16,
// // // //       child: Column(
// // // //         children: [
// // // //           _buildActionButton(
// // // //             Icons.monetization_on,
// // // //             Colors.amber,
// // // //             () => _showRechargeMenu(context),
// // // //           ),
// // // //           const SizedBox(height: 15),
// // // //           _buildActionButton(
// // // //             Icons.card_giftcard,
// // // //             Colors.pinkAccent,
// // // //             () {},
// // // //           ),
// // // //           const SizedBox(height: 15),
// // // //           _buildActionButton(
// // // //             Icons.cameraswitch,
// // // //             Colors.white24,
// // // //             widget.agoraService.switchCamera,
// // // //           ),
// // // //           const SizedBox(height: 15),
// // // //           ValueListenableBuilder<bool>(
// // // //             valueListenable: widget.agoraService.isAudioMuted,
// // // //             builder: (context, muted, _) => _buildActionButton(
// // // //               muted ? Icons.mic_off : Icons.mic,
// // // //               muted ? Colors.red : Colors.white24,
// // // //               widget.agoraService.toggleMuteAudio,
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildChatOverlay() {
// // // //     return Positioned(
// // // //       bottom: 100,
// // // //       left: 16,
// // // //       right: 80, // Leave room for side buttons
// // // //       height: 180,
// // // //       child: ListView.builder(
// // // //         reverse: true, // Latest messages at bottom
// // // //         itemCount: 5,
// // // //         itemBuilder: (context, index) => const Padding(
// // // //           padding: EdgeInsets.only(bottom: 8.0),
// // // //           child: Text(
// // // //             "User: Message appears here without background",
// // // //             style: TextStyle(
// // // //               color: Colors.white,
// // // //               shadows: [
// // // //                 Shadow(blurRadius: 4, color: Colors.black),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildBottomInput() {
// // // //     return Align(
// // // //       alignment: Alignment.bottomCenter,
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(10.0),
// // // //         child: TextField(
// // // //           style: const TextStyle(color: Colors.white),
// // // //           decoration: InputDecoration(
// // // //             // Swapped FaIcon for standard Icon and added slight right padding
// // // //             suffixIcon: const Padding(
// // // //               padding: EdgeInsets.only(right: 8.0),
// // // //               child: Icon(
// // // //                 Icons.send,
// // // //                 size: 28,
// // // //                 color: Colors.white,
// // // //               ),
// // // //             ),
// // // //             hintText: "Say something...",
// // // //             hintStyle: const TextStyle(color: Colors.white60),
// // // //             filled: true,
// // // //             fillColor: Colors.black38,
// // // //             border: OutlineInputBorder(
// // // //               borderRadius: BorderRadius.circular(30),
// // // //               borderSide: BorderSide.none,
// // // //             ),
// // // //             // Added vertical padding to balance the height and center the icon
// // // //             contentPadding: const EdgeInsets.symmetric(
// // // //               horizontal: 20,
// // // //               vertical: 16,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildActionButton(
// // // //     IconData icon,
// // // //     Color color,
// // // //     VoidCallback onTap,
// // // //   ) {
// // // //     return GestureDetector(
// // // //       onTap: onTap,
// // // //       child: Container(
// // // //         padding: const EdgeInsets.all(12),
// // // //         decoration: BoxDecoration(
// // // //           color: color,
// // // //           shape: BoxShape.circle,
// // // //         ),
// // // //         child: Icon(icon, color: Colors.white, size: 26),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'dart:async';

// // // import 'package:cheerchat/constants/app_constants.dart';
// // // import 'package:cheerchat/constants/gift_constants.dart';
// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/services/agora_service.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ---------------------------------------------------------------------------
// // // // OngoingCallScreen
// // // //
// // // // Entry point — caller passes host + their current coin balance + Agora creds.
// // // // The screen owns AgoraService lifecycle entirely (creates → joins → disposes).
// // // //
// // // // How to push this screen:
// // // //   Navigator.push(context, MaterialPageRoute(
// // // //     builder: (_) => OngoingCallScreen(
// // // //       host: host,
// // // //       initialCoins: userCoins,
// // // //       channelId: 'channel_abc',
// // // //       token: 'agora_token_from_server',
// // // //       localUid: myUid,
// // // //     ),
// // // //   ));
// // // // ---------------------------------------------------------------------------
// // // // class OngoingCallScreen extends StatefulWidget {
// // // //   const OngoingCallScreen({
// // // //     super.key,
// // // //     required this.host,
// // // //     required this.initialCoins,
// // // //     required this.channelId,
// // // //     required this.token,
// // // //     required this.localUid,
// // // //   });

// // // //   final HostModel host;

// // // //   /// User's current wallet balance — used for local UI display only.
// // // //   /// Real deduction happens server-side via Node.js billing ticks.
// // // //   final int initialCoins;

// // // //   final String channelId;
// // // //   final String token;
// // // //   final int localUid;

// // // //   @override
// // // //   State<OngoingCallScreen> createState() =>
// // // //       _OngoingCallScreenState();
// // // // }

// // // // class _OngoingCallScreenState extends State<OngoingCallScreen>
// // // //     with WidgetsBindingObserver {
// // // //   // ── Agora ────────────────────────────────────────────────────────────────
// // // //   late final AgoraService _agora;

// // // //   // ── Call state ───────────────────────────────────────────────────────────
// // // //   bool _isConnecting = true;
// // // //   bool _callEnded = false;
// // // //   String? _errorMessage;

// // // //   // ── Timer & coins ────────────────────────────────────────────────────────
// // // //   Timer? _durationTimer;
// // // //   Timer? _coinDrainTimer;
// // // //   int _elapsedSeconds = 0;
// // // //   late int _coinsRemaining;

// // // //   // ── UI state ─────────────────────────────────────────────────────────────
// // // //   bool _uiVisible = true;
// // // //   Offset _pipOffset = const Offset(20, 120);

// // // //   // Chat overlay messages (live chat during call — stub list for now)
// // // //   // TODO: wire up real Firestore messages for the call channel
// // // //   final List<_ChatMessage> _chatMessages = [];
// // // //   final TextEditingController _chatController =
// // // //       TextEditingController();
// // // //   final FocusNode _chatFocus = FocusNode();

// // // //   // ── Getters ──────────────────────────────────────────────────────────────
// // // //   bool get _isLowCoins =>
// // // //       _coinsRemaining <
// // // //       widget.host.priceCoins *
// // // //           AppConstants.lowCoinWarningMinutes;

// // // //   String get _formattedDuration {
// // // //     final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
// // // //     final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
// // // //     return '$m:$s';
// // // //   }

// // // //   int get _coinsSpent => widget.initialCoins - _coinsRemaining;

// // // //   // ── Lifecycle ─────────────────────────────────────────────────────────────
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     WidgetsBinding.instance.addObserver(this);
// // // //     _coinsRemaining = widget.initialCoins;
// // // //     _agora = AgoraService(
// // // //       onBillableSessionStart: _onBillableSessionStart,
// // // //       onBillableSessionEnd: _onBillableSessionEnd,
// // // //     );
// // // //     _startCall();
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     WidgetsBinding.instance.removeObserver(this);
// // // //     _durationTimer?.cancel();
// // // //     _coinDrainTimer?.cancel();
// // // //     _chatController.dispose();
// // // //     _chatFocus.dispose();
// // // //     _agora.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // // //     // Pause local video when app goes to background
// // // //     if (state == AppLifecycleState.paused) {
// // // //       _agora.toggleMuteVideo();
// // // //     } else if (state == AppLifecycleState.resumed) {
// // // //       // Re-enable if it was muted by lifecycle only
// // // //     }
// // // //   }

// // // //   // ── Agora init ───────────────────────────────────────────────────────────
// // // //   Future<void> _startCall() async {
// // // //     try {
// // // //       await _agora.initialize(
// // // //         appId: AppConstants.agoraAppId,
// // // //         fetchNewToken: () async {
// // // //           // TODO: GET /api/calls/token?channel=channelId
// // // //           // For now return the same token (valid for ~24h in testing)
// // // //           return widget.token;
// // // //         },
// // // //       );
// // // //       await _agora.join(
// // // //         token: widget.token,
// // // //         channelId: widget.channelId,
// // // //         uid: widget.localUid,
// // // //       );

// // // //       // Listen for first remote user to clear the "connecting" overlay
// // // //       _agora.remoteUids.addListener(_onRemoteUidsChanged);
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         setState(() => _errorMessage = e.toString());
// // // //       }
// // // //     }
// // // //   }

// // // //   void _onRemoteUidsChanged() {
// // // //     if (_agora.remoteUids.value.isNotEmpty && _isConnecting) {
// // // //       if (mounted) setState(() => _isConnecting = false);
// // // //     }
// // // //     if (_agora.remoteUids.value.isEmpty &&
// // // //         !_isConnecting &&
// // // //         !_callEnded) {
// // // //       // Host left — end call
// // // //       _endCall(hostLeft: true);
// // // //     }
// // // //   }

// // // //   // ── Billing callbacks (fired by AgoraService) ────────────────────────────
// // // //   void _onBillableSessionStart() {
// // // //     // Tick duration every second
// // // //     _durationTimer = Timer.periodic(const Duration(seconds: 1), (
// // // //       _,
// // // //     ) {
// // // //       if (mounted) setState(() => _elapsedSeconds++);
// // // //     });

// // // //     // Drain coins once per minute (local UI only — server does real billing)
// // // //     _coinDrainTimer = Timer.periodic(
// // // //       const Duration(seconds: 60),
// // // //       (_) {
// // // //         if (!mounted) return;
// // // //         setState(() {
// // // //           _coinsRemaining =
// // // //               (_coinsRemaining - widget.host.priceCoins).clamp(
// // // //                 0,
// // // //                 9999999,
// // // //               );
// // // //         });
// // // //         if (_coinsRemaining <= 0) _endCall(outOfCoins: true);
// // // //       },
// // // //     );
// // // //   }

// // // //   void _onBillableSessionEnd() {
// // // //     _durationTimer?.cancel();
// // // //     _coinDrainTimer?.cancel();
// // // //   }

// // // //   // ── End call ──────────────────────────────────────────────────────────────
// // // //   Future<void> _endCall({
// // // //     bool hostLeft = false,
// // // //     bool outOfCoins = false,
// // // //   }) async {
// // // //     if (_callEnded) return;
// // // //     _durationTimer?.cancel();
// // // //     _coinDrainTimer?.cancel();
// // // //     await _agora.leave();
// // // //     if (mounted) setState(() => _callEnded = true);
// // // //     // TODO: POST /api/calls/end { channelId, duration: _elapsedSeconds }
// // // //   }

// // // //   // ── Chat ──────────────────────────────────────────────────────────────────
// // // //   void _sendChatMessage() {
// // // //     final text = _chatController.text.trim();
// // // //     if (text.isEmpty) return;
// // // //     setState(() {
// // // //       _chatMessages.add(_ChatMessage(text: text, isLocal: true));
// // // //     });
// // // //     _chatController.clear();
// // // //     // TODO: send via Firestore call-channel subcollection
// // // //   }

// // // //   // ── Build ─────────────────────────────────────────────────────────────────
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     // Keep status bar hidden during call
// // // //     SystemChrome.setEnabledSystemUIMode(
// // // //       SystemUiMode.immersiveSticky,
// // // //     );

// // // //     return PopScope(
// // // //       canPop: false, // Back gesture must go through _endCall
// // // //       onPopInvokedWithResult: (didPop, _) async {
// // // //         if (!didPop) await _endCall();
// // // //       },
// // // //       child: Scaffold(
// // // //         backgroundColor: Colors.black,
// // // //         body: GestureDetector(
// // // //           onTap: () {
// // // //             _chatFocus.unfocus();
// // // //             setState(() => _uiVisible = !_uiVisible);
// // // //           },
// // // //           behavior: HitTestBehavior.opaque,
// // // //           child: Stack(
// // // //             children: [
// // // //               // ── Layer 1: Remote video (full screen) ──────────────────────
// // // //               _buildRemoteVideo(),

// // // //               // ── Layer 2: Draggable local PIP ─────────────────────────────
// // // //               _buildPip(),

// // // //               // ── Layer 3: Hideable HUD ─────────────────────────────────────
// // // //               if (_uiVisible && !_callEnded) ...[
// // // //                 _buildTopBar(),
// // // //                 _buildCoinBar(),
// // // //                 if (_isLowCoins) _buildLowCoinBanner(),
// // // //                 _buildChatOverlay(),
// // // //                 _buildRightActions(),
// // // //                 _buildBottomInput(),
// // // //               ],

// // // //               // ── Layer 4: Connecting overlay ───────────────────────────────
// // // //               if (_isConnecting && !_callEnded)
// // // //                 _buildConnectingOverlay(),

// // // //               // ── Layer 5: Error overlay ────────────────────────────────────
// // // //               if (_errorMessage != null) _buildErrorOverlay(),

// // // //               // ── Layer 6: Call ended summary ───────────────────────────────
// // // //               if (_callEnded) _buildCallEndedOverlay(),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Remote video ──────────────────────────────────────────────────────────
// // // //   Widget _buildRemoteVideo() {
// // // //     return ValueListenableBuilder<Set<int>>(
// // // //       valueListenable: _agora.remoteUids,
// // // //       builder: (_, uids, __) {
// // // //         if (uids.isEmpty) {
// // // //           return Container(
// // // //             color: const Color(0xFF1A1A2E),
// // // //             child: Center(
// // // //               child: Column(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   if (widget.host.profilePhotoUrl != null)
// // // //                     CircleAvatar(
// // // //                       radius: 56,
// // // //                       backgroundImage: NetworkImage(
// // // //                         widget.host.profilePhotoUrl!,
// // // //                       ),
// // // //                     )
// // // //                   else
// // // //                     CircleAvatar(
// // // //                       radius: 56,
// // // //                       backgroundColor: Colors.pink.withValues(
// // // //                         alpha: 0.3,
// // // //                       ),
// // // //                       child: const Icon(
// // // //                         Icons.person,
// // // //                         color: Colors.white70,
// // // //                         size: 56,
// // // //                       ),
// // // //                     ),
// // // //                   const SizedBox(height: 20),
// // // //                   Text(
// // // //                     widget.host.displayName,
// // // //                     style: GoogleFonts.lato(
// // // //                       color: Colors.white,
// // // //                       fontSize: 22,
// // // //                       fontWeight: FontWeight.bold,
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 8),
// // // //                   const _PulsingDots(),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           );
// // // //         }
// // // //         return SizedBox.expand(
// // // //           child: _agora.buildRemoteVideo(uids.first),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   // ── Local PIP ─────────────────────────────────────────────────────────────
// // // //   Widget _buildPip() {
// // // //     return Positioned(
// // // //       left: _pipOffset.dx,
// // // //       top: _pipOffset.dy,
// // // //       child: GestureDetector(
// // // //         onPanUpdate: (d) {
// // // //           final size = MediaQuery.of(context).size;
// // // //           setState(() {
// // // //             _pipOffset = Offset(
// // // //               (_pipOffset.dx + d.delta.dx).clamp(
// // // //                 0,
// // // //                 size.width - 110,
// // // //               ),
// // // //               (_pipOffset.dy + d.delta.dy).clamp(
// // // //                 0,
// // // //                 size.height - 150,
// // // //               ),
// // // //             );
// // // //           });
// // // //         },
// // // //         child: Container(
// // // //           width: 110,
// // // //           height: 150,
// // // //           decoration: BoxDecoration(
// // // //             borderRadius: BorderRadius.circular(14),
// // // //             border: Border.all(
// // // //               color: Colors.white30,
// // // //               width: 1.5,
// // // //             ),
// // // //             boxShadow: const [
// // // //               BoxShadow(blurRadius: 12, color: Colors.black54),
// // // //             ],
// // // //           ),
// // // //           clipBehavior: Clip.antiAlias,
// // // //           child: _agora.buildLocalVideo(),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Top bar ───────────────────────────────────────────────────────────────
// // // //   Widget _buildTopBar() {
// // // //     final safePad = MediaQuery.of(context).padding.top;
// // // //     return Positioned(
// // // //       top: safePad + 12,
// // // //       left: 16,
// // // //       right: 16,
// // // //       child: Row(
// // // //         children: [
// // // //           // Host info chip
// // // //           _glassChip(
// // // //             child: Row(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 if (widget.host.profilePhotoUrl != null)
// // // //                   CircleAvatar(
// // // //                     radius: 12,
// // // //                     backgroundImage: NetworkImage(
// // // //                       widget.host.profilePhotoUrl!,
// // // //                     ),
// // // //                   )
// // // //                 else
// // // //                   const CircleAvatar(
// // // //                     radius: 12,
// // // //                     backgroundColor: Colors.pink,
// // // //                     child: Icon(
// // // //                       Icons.person,
// // // //                       size: 12,
// // // //                       color: Colors.white,
// // // //                     ),
// // // //                   ),
// // // //                 const SizedBox(width: 8),
// // // //                 Text(
// // // //                   '${widget.host.displayName}, ${widget.host.age ?? '—'}',
// // // //                   style: const TextStyle(
// // // //                     color: Colors.white,
// // // //                     fontWeight: FontWeight.bold,
// // // //                     fontSize: 13,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),

// // // //           const Spacer(),

// // // //           // Live timer
// // // //           _glassChip(
// // // //             child: Row(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 Container(
// // // //                   width: 7,
// // // //                   height: 7,
// // // //                   decoration: const BoxDecoration(
// // // //                     color: Colors.greenAccent,
// // // //                     shape: BoxShape.circle,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 6),
// // // //                 Text(
// // // //                   _formattedDuration,
// // // //                   style: GoogleFonts.lato(
// // // //                     color: Colors.white,
// // // //                     fontSize: 13,
// // // //                     fontWeight: FontWeight.w600,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),

// // // //           const SizedBox(width: 10),

// // // //           // End call
// // // //           GestureDetector(
// // // //             onTap: () => _endCall(),
// // // //             child: Container(
// // // //               padding: const EdgeInsets.all(10),
// // // //               decoration: const BoxDecoration(
// // // //                 color: Colors.redAccent,
// // // //                 shape: BoxShape.circle,
// // // //               ),
// // // //               child: const Icon(
// // // //                 Icons.call_end,
// // // //                 color: Colors.white,
// // // //                 size: 22,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Coin bar ──────────────────────────────────────────────────────────────
// // // //   Widget _buildCoinBar() {
// // // //     final safePad = MediaQuery.of(context).padding.top;
// // // //     return Positioned(
// // // //       top: safePad + 68,
// // // //       left: 16,
// // // //       child: _glassChip(
// // // //         color: _isLowCoins
// // // //             ? Colors.red.withValues(alpha: 0.6)
// // // //             : Colors.black54,
// // // //         child: Row(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.monetization_on,
// // // //               color: Colors.amber,
// // // //               size: 15,
// // // //             ),
// // // //             const SizedBox(width: 5),
// // // //             Text(
// // // //               _coinsRemaining.toString(),
// // // //               style: GoogleFonts.lato(
// // // //                 color: Colors.white,
// // // //                 fontWeight: FontWeight.bold,
// // // //                 fontSize: 13,
// // // //               ),
// // // //             ),
// // // //             Text(
// // // //               '  •  ${widget.host.priceCoins}/min',
// // // //               style: const TextStyle(
// // // //                 color: Colors.white60,
// // // //                 fontSize: 11,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Low coin warning ──────────────────────────────────────────────────────
// // // //   Widget _buildLowCoinBanner() {
// // // //     return Positioned(
// // // //       top: MediaQuery.of(context).padding.top + 108,
// // // //       left: 16,
// // // //       right: 16,
// // // //       child: Container(
// // // //         padding: const EdgeInsets.symmetric(
// // // //           horizontal: 14,
// // // //           vertical: 9,
// // // //         ),
// // // //         decoration: BoxDecoration(
// // // //           color: Colors.orange.shade800.withValues(alpha: 0.9),
// // // //           borderRadius: BorderRadius.circular(12),
// // // //         ),
// // // //         child: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.warning_amber_rounded,
// // // //               color: Colors.white,
// // // //               size: 16,
// // // //             ),
// // // //             const SizedBox(width: 8),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 'Low balance! Recharge to keep the call going.',
// // // //                 style: const TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontSize: 12,
// // // //                   fontWeight: FontWeight.w600,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             GestureDetector(
// // // //               onTap: () => _showRechargeSheet(),
// // // //               child: Container(
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 10,
// // // //                   vertical: 4,
// // // //                 ),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.white,
// // // //                   borderRadius: BorderRadius.circular(20),
// // // //                 ),
// // // //                 child: Text(
// // // //                   'Recharge',
// // // //                   style: TextStyle(
// // // //                     color: Colors.orange.shade800,
// // // //                     fontSize: 11,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Chat overlay ──────────────────────────────────────────────────────────
// // // //   Widget _buildChatOverlay() {
// // // //     return Positioned(
// // // //       bottom: 80,
// // // //       left: 16,
// // // //       right: 80,
// // // //       height: 180,
// // // //       child: ListView.builder(
// // // //         reverse: true,
// // // //         itemCount: _chatMessages.length,
// // // //         itemBuilder: (_, i) {
// // // //           final msg =
// // // //               _chatMessages[_chatMessages.length - 1 - i];
// // // //           return Padding(
// // // //             padding: const EdgeInsets.only(bottom: 6),
// // // //             child: Text(
// // // //               '${msg.isLocal ? 'You' : widget.host.displayName}: ${msg.text}',
// // // //               style: const TextStyle(
// // // //                 color: Colors.white,
// // // //                 fontSize: 13,
// // // //                 shadows: [
// // // //                   Shadow(blurRadius: 4, color: Colors.black87),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Right side action buttons ─────────────────────────────────────────────
// // // //   Widget _buildRightActions() {
// // // //     return Positioned(
// // // //       bottom: 90,
// // // //       right: 16,
// // // //       child: Column(
// // // //         children: [
// // // //           // Recharge / coins
// // // //           _actionButton(
// // // //             icon: Icons.monetization_on,
// // // //             color: Colors.amber,
// // // //             onTap: _showRechargeSheet,
// // // //           ),
// // // //           const SizedBox(height: 14),

// // // //           // Gift
// // // //           _actionButton(
// // // //             icon: Icons.card_giftcard,
// // // //             color: Colors.pinkAccent,
// // // //             onTap: _showGiftSheet,
// // // //           ),
// // // //           const SizedBox(height: 14),

// // // //           // Switch camera
// // // //           _actionButton(
// // // //             icon: Icons.cameraswitch_rounded,
// // // //             color: Colors.white24,
// // // //             onTap: _agora.switchCamera,
// // // //           ),
// // // //           const SizedBox(height: 14),

// // // //           // Mute audio toggle
// // // //           ValueListenableBuilder<bool>(
// // // //             valueListenable: _agora.isAudioMuted,
// // // //             builder: (_, muted, __) => _actionButton(
// // // //               icon: muted
// // // //                   ? Icons.mic_off_rounded
// // // //                   : Icons.mic_rounded,
// // // //               color: muted ? Colors.red : Colors.white24,
// // // //               onTap: _agora.toggleMuteAudio,
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 14),

// // // //           // Mute video toggle
// // // //           ValueListenableBuilder<bool>(
// // // //             valueListenable: _agora.isVideoMuted,
// // // //             builder: (_, muted, __) => _actionButton(
// // // //               icon: muted
// // // //                   ? Icons.videocam_off_rounded
// // // //                   : Icons.videocam_rounded,
// // // //               color: muted ? Colors.red : Colors.white24,
// // // //               onTap: _agora.toggleMuteVideo,
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom chat input ─────────────────────────────────────────────────────
// // // //   Widget _buildBottomInput() {
// // // //     final bottomPad = MediaQuery.of(context).padding.bottom;
// // // //     return Positioned(
// // // //       bottom: bottomPad,
// // // //       left: 0,
// // // //       right: 0,
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.symmetric(
// // // //           horizontal: 12,
// // // //           vertical: 8,
// // // //         ),
// // // //         child: Row(
// // // //           children: [
// // // //             Expanded(
// // // //               child: TextField(
// // // //                 controller: _chatController,
// // // //                 focusNode: _chatFocus,
// // // //                 style: const TextStyle(color: Colors.white),
// // // //                 onSubmitted: (_) => _sendChatMessage(),
// // // //                 decoration: InputDecoration(
// // // //                   hintText: 'Say something...',
// // // //                   hintStyle: const TextStyle(
// // // //                     color: Colors.white54,
// // // //                   ),
// // // //                   filled: true,
// // // //                   fillColor: Colors.black45,
// // // //                   contentPadding: const EdgeInsets.symmetric(
// // // //                     horizontal: 18,
// // // //                     vertical: 12,
// // // //                   ),
// // // //                   border: OutlineInputBorder(
// // // //                     borderRadius: BorderRadius.circular(30),
// // // //                     borderSide: BorderSide.none,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(width: 8),
// // // //             GestureDetector(
// // // //               onTap: _sendChatMessage,
// // // //               child: Container(
// // // //                 padding: const EdgeInsets.all(12),
// // // //                 decoration: const BoxDecoration(
// // // //                   color: Colors.pink,
// // // //                   shape: BoxShape.circle,
// // // //                 ),
// // // //                 child: const Icon(
// // // //                   Icons.send_rounded,
// // // //                   color: Colors.white,
// // // //                   size: 18,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Connecting overlay ────────────────────────────────────────────────────
// // // //   Widget _buildConnectingOverlay() {
// // // //     return Container(
// // // //       color: Colors.black54,
// // // //       child: Center(
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             const CircularProgressIndicator(color: Colors.pink),
// // // //             const SizedBox(height: 20),
// // // //             Text(
// // // //               'Connecting to ${widget.host.displayName}...',
// // // //               style: GoogleFonts.lato(
// // // //                 color: Colors.white,
// // // //                 fontSize: 16,
// // // //                 fontWeight: FontWeight.w600,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Error overlay ─────────────────────────────────────────────────────────
// // // //   Widget _buildErrorOverlay() {
// // // //     return Container(
// // // //       color: Colors.black87,
// // // //       child: Center(
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(32),
// // // //           child: Column(
// // // //             mainAxisSize: MainAxisSize.min,
// // // //             children: [
// // // //               const Icon(
// // // //                 Icons.error_outline,
// // // //                 color: Colors.redAccent,
// // // //                 size: 48,
// // // //               ),
// // // //               const SizedBox(height: 16),
// // // //               Text(
// // // //                 'Could not connect',
// // // //                 style: GoogleFonts.lato(
// // // //                   color: Colors.white,
// // // //                   fontSize: 18,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 8),
// // // //               Text(
// // // //                 _errorMessage ?? '',
// // // //                 textAlign: TextAlign.center,
// // // //                 style: const TextStyle(
// // // //                   color: Colors.white60,
// // // //                   fontSize: 13,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 28),
// // // //               FilledButton(
// // // //                 onPressed: () => Navigator.of(context).pop(),
// // // //                 style: FilledButton.styleFrom(
// // // //                   backgroundColor: Colors.pink,
// // // //                 ),
// // // //                 child: const Text('Go Back'),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Call ended summary overlay ────────────────────────────────────────────
// // // //   Widget _buildCallEndedOverlay() {
// // // //     return Container(
// // // //       color: Colors.black87,
// // // //       child: Center(
// // // //         child: Container(
// // // //           margin: const EdgeInsets.symmetric(horizontal: 32),
// // // //           padding: const EdgeInsets.all(28),
// // // //           decoration: BoxDecoration(
// // // //             color: const Color(0xFF1A1A2E),
// // // //             borderRadius: BorderRadius.circular(24),
// // // //           ),
// // // //           child: Column(
// // // //             mainAxisSize: MainAxisSize.min,
// // // //             children: [
// // // //               Container(
// // // //                 padding: const EdgeInsets.all(18),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.pink.withValues(alpha: 0.15),
// // // //                   shape: BoxShape.circle,
// // // //                 ),
// // // //                 child: const Icon(
// // // //                   Icons.call_end,
// // // //                   color: Colors.pink,
// // // //                   size: 36,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //               Text(
// // // //                 'Call Ended',
// // // //                 style: GoogleFonts.lato(
// // // //                   color: Colors.white,
// // // //                   fontSize: 22,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 6),
// // // //               Text(
// // // //                 'with ${widget.host.displayName}',
// // // //                 style: const TextStyle(
// // // //                   color: Colors.white54,
// // // //                   fontSize: 14,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 24),
// // // //               _summaryRow(
// // // //                 Icons.timer_outlined,
// // // //                 'Duration',
// // // //                 _formattedDuration,
// // // //               ),
// // // //               const SizedBox(height: 10),
// // // //               _summaryRow(
// // // //                 Icons.monetization_on,
// // // //                 'Coins Spent',
// // // //                 '$_coinsSpent coins',
// // // //               ),
// // // //               const SizedBox(height: 10),
// // // //               _summaryRow(
// // // //                 Icons.account_balance_wallet_outlined,
// // // //                 'Remaining',
// // // //                 '$_coinsRemaining coins',
// // // //               ),
// // // //               const SizedBox(height: 28),
// // // //               SizedBox(
// // // //                 width: double.infinity,
// // // //                 child: FilledButton(
// // // //                   onPressed: () {
// // // //                     SystemChrome.setEnabledSystemUIMode(
// // // //                       SystemUiMode.edgeToEdge,
// // // //                     );
// // // //                     Navigator.of(context).pop();
// // // //                   },
// // // //                   style: FilledButton.styleFrom(
// // // //                     backgroundColor: Colors.pink,
// // // //                     padding: const EdgeInsets.symmetric(
// // // //                       vertical: 14,
// // // //                     ),
// // // //                     shape: RoundedRectangleBorder(
// // // //                       borderRadius: BorderRadius.circular(14),
// // // //                     ),
// // // //                   ),
// // // //                   child: Text(
// // // //                     'Done',
// // // //                     style: GoogleFonts.lato(
// // // //                       fontWeight: FontWeight.bold,
// // // //                       fontSize: 16,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Gift sheet ────────────────────────────────────────────────────────────
// // // //   void _showGiftSheet() {
// // // //     showModalBottomSheet<void>(
// // // //       context: context,
// // // //       backgroundColor: Colors.transparent,
// // // //       isScrollControlled: true,
// // // //       builder: (_) => Container(
// // // //         height: MediaQuery.of(context).size.height * 0.52,
// // // //         decoration: const BoxDecoration(
// // // //           color: Color(0xFF1A1A1A),
// // // //           borderRadius: BorderRadius.vertical(
// // // //             top: Radius.circular(24),
// // // //           ),
// // // //         ),
// // // //         child: Column(
// // // //           children: [
// // // //             const SizedBox(height: 12),
// // // //             Container(
// // // //               width: 40,
// // // //               height: 4,
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.white24,
// // // //                 borderRadius: BorderRadius.circular(2),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //             Text(
// // // //               'Send a Gift',
// // // //               style: GoogleFonts.lato(
// // // //                 color: Colors.white,
// // // //                 fontSize: 16,
// // // //                 fontWeight: FontWeight.bold,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //             Expanded(
// // // //               child: GridView.builder(
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 16,
// // // //                 ),
// // // //                 gridDelegate:
// // // //                     const SliverGridDelegateWithFixedCrossAxisCount(
// // // //                       crossAxisCount: 4,
// // // //                       mainAxisSpacing: 12,
// // // //                       crossAxisSpacing: 12,
// // // //                       childAspectRatio: 0.85,
// // // //                     ),
// // // //                 itemCount: GiftAssets.all.length,
// // // //                 itemBuilder: (_, i) {
// // // //                   final asset = GiftAssets.all[i];
// // // //                   final name = asset
// // // //                       .split('/')
// // // //                       .last
// // // //                       .replaceAll('.png', '')
// // // //                       .replaceAll('_', ' ');
// // // //                   return GestureDetector(
// // // //                     onTap: () {
// // // //                       Navigator.pop(context);
// // // //                       // TODO: POST /api/gifts/send { hostId, giftAsset: asset }
// // // //                       ScaffoldMessenger.of(context).showSnackBar(
// // // //                         SnackBar(
// // // //                           content: Text('Gift sent! 🎁'),
// // // //                           backgroundColor: Colors.pink,
// // // //                           behavior: SnackBarBehavior.floating,
// // // //                           shape: RoundedRectangleBorder(
// // // //                             borderRadius: BorderRadius.circular(
// // // //                               12,
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                       );
// // // //                     },
// // // //                     child: Column(
// // // //                       mainAxisAlignment:
// // // //                           MainAxisAlignment.center,
// // // //                       children: [
// // // //                         Expanded(
// // // //                           child: Image.asset(
// // // //                             asset,
// // // //                             fit: BoxFit.contain,
// // // //                             errorBuilder: (_, __, ___) =>
// // // //                                 const Icon(
// // // //                                   Icons.card_giftcard,
// // // //                                   color: Colors.pink,
// // // //                                   size: 32,
// // // //                                 ),
// // // //                           ),
// // // //                         ),
// // // //                         const SizedBox(height: 4),
// // // //                         Text(
// // // //                           name,
// // // //                           maxLines: 1,
// // // //                           overflow: TextOverflow.ellipsis,
// // // //                           style: const TextStyle(
// // // //                             color: Colors.white70,
// // // //                             fontSize: 10,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Recharge sheet ────────────────────────────────────────────────────────
// // // //   void _showRechargeSheet() {
// // // //     showModalBottomSheet<void>(
// // // //       context: context,
// // // //       backgroundColor: Colors.transparent,
// // // //       builder: (_) => Container(
// // // //         decoration: const BoxDecoration(
// // // //           color: Color(0xFF1A1A1A),
// // // //           borderRadius: BorderRadius.vertical(
// // // //             top: Radius.circular(24),
// // // //           ),
// // // //         ),
// // // //         padding: const EdgeInsets.all(20),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Container(
// // // //               width: 40,
// // // //               height: 4,
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.white24,
// // // //                 borderRadius: BorderRadius.circular(2),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 20),
// // // //             const Text(
// // // //               'Wallet Balance',
// // // //               style: TextStyle(
// // // //                 color: Colors.white70,
// // // //                 fontSize: 14,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 const Icon(
// // // //                   Icons.monetization_on,
// // // //                   color: Colors.amber,
// // // //                   size: 28,
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 Text(
// // // //                   _coinsRemaining.toString(),
// // // //                   style: GoogleFonts.lato(
// // // //                     color: Colors.white,
// // // //                     fontSize: 32,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const Divider(height: 36, color: Colors.white10),
// // // //             const Align(
// // // //               alignment: Alignment.centerLeft,
// // // //               child: Text(
// // // //                 'Quick Recharge',
// // // //                 style: TextStyle(
// // // //                   color: Colors.white,
// // // //                   fontSize: 16,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 14),
// // // //             _rechargeOption(500, '₹49'),
// // // //             _rechargeOption(1200, '₹99'),
// // // //             _rechargeOption(3000, '₹249'),
// // // //             const SizedBox(height: 8),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _rechargeOption(int coins, String price) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.only(bottom: 10),
// // // //       child: InkWell(
// // // //         onTap: () {
// // // //           Navigator.pop(context);
// // // //           // TODO: launch Razorpay/Stripe payment flow
// // // //           // On success: setState(() => _coinsRemaining += coins);
// // // //         },
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         child: Container(
// // // //           padding: const EdgeInsets.symmetric(
// // // //             horizontal: 16,
// // // //             vertical: 12,
// // // //           ),
// // // //           decoration: BoxDecoration(
// // // //             color: Colors.white.withValues(alpha: 0.05),
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             border: Border.all(color: Colors.white10),
// // // //           ),
// // // //           child: Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Row(
// // // //                 children: [
// // // //                   const Icon(
// // // //                     Icons.monetization_on,
// // // //                     color: Colors.amber,
// // // //                     size: 20,
// // // //                   ),
// // // //                   const SizedBox(width: 10),
// // // //                   Text(
// // // //                     '$coins Coins',
// // // //                     style: const TextStyle(
// // // //                       color: Colors.white,
// // // //                       fontSize: 15,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //               Container(
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 14,
// // // //                   vertical: 6,
// // // //                 ),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.amber,
// // // //                   borderRadius: BorderRadius.circular(20),
// // // //                 ),
// // // //                 child: Text(
// // // //                   price,
// // // //                   style: const TextStyle(
// // // //                     color: Colors.black,
// // // //                     fontWeight: FontWeight.bold,
// // // //                     fontSize: 13,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Shared helpers ────────────────────────────────────────────────────────
// // // //   Widget _glassChip({required Widget child, Color? color}) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(
// // // //         horizontal: 12,
// // // //         vertical: 7,
// // // //       ),
// // // //       decoration: BoxDecoration(
// // // //         color: color ?? Colors.black54,
// // // //         borderRadius: BorderRadius.circular(20),
// // // //       ),
// // // //       child: child,
// // // //     );
// // // //   }

// // // //   Widget _actionButton({
// // // //     required IconData icon,
// // // //     required Color color,
// // // //     required VoidCallback onTap,
// // // //   }) {
// // // //     return GestureDetector(
// // // //       onTap: onTap,
// // // //       child: Container(
// // // //         padding: const EdgeInsets.all(12),
// // // //         decoration: BoxDecoration(
// // // //           color: color,
// // // //           shape: BoxShape.circle,
// // // //         ),
// // // //         child: Icon(icon, color: Colors.white, size: 24),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _summaryRow(IconData icon, String label, String value) {
// // // //     return Row(
// // // //       children: [
// // // //         Icon(icon, color: Colors.white38, size: 18),
// // // //         const SizedBox(width: 10),
// // // //         Text(
// // // //           label,
// // // //           style: const TextStyle(
// // // //             color: Colors.white54,
// // // //             fontSize: 14,
// // // //           ),
// // // //         ),
// // // //         const Spacer(),
// // // //         Text(
// // // //           value,
// // // //           style: const TextStyle(
// // // //             color: Colors.white,
// // // //             fontSize: 14,
// // // //             fontWeight: FontWeight.w600,
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // // }

// // // // // ---------------------------------------------------------------------------
// // // // // Pulsing dots — shown while waiting for host to join
// // // // // ---------------------------------------------------------------------------
// // // // class _PulsingDots extends StatefulWidget {
// // // //   const _PulsingDots();

// // // //   @override
// // // //   State<_PulsingDots> createState() => _PulsingDotsState();
// // // // }

// // // // class _PulsingDotsState extends State<_PulsingDots>
// // // //     with SingleTickerProviderStateMixin {
// // // //   late final AnimationController _ctrl;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _ctrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 900),
// // // //     )..repeat(reverse: true);
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _ctrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return FadeTransition(
// // // //       opacity: _ctrl,
// // // //       child: Text(
// // // //         'Connecting...',
// // // //         style: GoogleFonts.lato(
// // // //           color: Colors.white60,
// // // //           fontSize: 14,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // ---------------------------------------------------------------------------
// // // // // Internal chat message model
// // // // // ---------------------------------------------------------------------------
// // // // class _ChatMessage {
// // // //   const _ChatMessage({
// // // //     required this.text,
// // // //     required this.isLocal,
// // // //   });
// // // //   final String text;
// // // //   final bool isLocal;
// // // // }
// // // import 'dart:async';

// // // import 'package:cheerchat/constants/app_constants.dart';
// // // import 'package:cheerchat/constants/gift_constants.dart';
// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/services/agora_service.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ---------------------------------------------------------------------------
// // // // OngoingCallScreen
// // // //
// // // // Entry point — caller passes host + their current coin balance + Agora creds.
// // // // The screen owns AgoraService lifecycle entirely (creates → joins → disposes).
// // // //
// // // // How to push this screen:
// // // //   Navigator.push(context, MaterialPageRoute(
// // // //     builder: (_) => OngoingCallScreen(
// // // //       host: host,
// // // //       initialCoins: userCoins,
// // // //       channelId: 'channel_abc',
// // // //       token: 'agora_token_from_server',
// // // //       localUid: myUid,
// // // //     ),
// // // //   ));
// // // // ---------------------------------------------------------------------------
// // // class OngoingCallScreen extends StatefulWidget {
// // //   const OngoingCallScreen({
// // //     super.key,
// // //     required this.host,
// // //     required this.initialCoins,
// // //     this.channelId = 'test_channel',
// // //     this.token = 'test_token',
// // //     this.localUid = 0,
// // //     this.testMode = false,
// // //   });

// // //   final HostModel host;

// // //   /// User's current wallet balance — used for local UI display only.
// // //   /// Real deduction happens server-side via Node.js billing ticks.
// // //   final int initialCoins;

// // //   final String channelId;
// // //   final String token;
// // //   final int localUid;

// // //   /// When true: skips Agora entirely, simulates a connected call after 2s.
// // //   /// Use this to test the UI without a real Agora App ID or token.
// // //   final bool testMode;

// // //   @override
// // //   State<OngoingCallScreen> createState() => _OngoingCallScreenState();
// // // }

// // // class _OngoingCallScreenState extends State<OngoingCallScreen>
// // //     with WidgetsBindingObserver {
// // //   // ── Agora ────────────────────────────────────────────────────────────────
// // //   late final AgoraService _agora;

// // //   // ── Call state ───────────────────────────────────────────────────────────
// // //   bool _isConnecting = true;
// // //   bool _callEnded = false;
// // //   String? _errorMessage;

// // //   // ── Timer & coins ────────────────────────────────────────────────────────
// // //   Timer? _durationTimer;
// // //   Timer? _coinDrainTimer;
// // //   int _elapsedSeconds = 0;
// // //   late int _coinsRemaining;

// // //   // ── UI state ─────────────────────────────────────────────────────────────
// // //   bool _uiVisible = true;
// // //   Offset _pipOffset = const Offset(20, 120);

// // //   // Chat overlay messages (live chat during call — stub list for now)
// // //   // TODO: wire up real Firestore messages for the call channel
// // //   final List<_ChatMessage> _chatMessages = [];
// // //   final TextEditingController _chatController = TextEditingController();
// // //   final FocusNode _chatFocus = FocusNode();

// // //   // ── Getters ──────────────────────────────────────────────────────────────
// // //   bool get _isLowCoins =>
// // //       _coinsRemaining <
// // //       widget.host.priceCoins * AppConstants.lowCoinWarningMinutes;

// // //   String get _formattedDuration {
// // //     final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
// // //     final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
// // //     return '$m:$s';
// // //   }

// // //   int get _coinsSpent => widget.initialCoins - _coinsRemaining;

// // //   // ── Lifecycle ─────────────────────────────────────────────────────────────
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //     _coinsRemaining = widget.initialCoins;
// // //     _agora = AgoraService(
// // //       onBillableSessionStart: _onBillableSessionStart,
// // //       onBillableSessionEnd: _onBillableSessionEnd,
// // //     );
// // //     _startCall();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     WidgetsBinding.instance.removeObserver(this);
// // //     _durationTimer?.cancel();
// // //     _coinDrainTimer?.cancel();
// // //     _chatController.dispose();
// // //     _chatFocus.dispose();
// // //     _agora.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // //     // Pause local video when app goes to background
// // //     if (state == AppLifecycleState.paused) {
// // //       _agora.toggleMuteVideo();
// // //     } else if (state == AppLifecycleState.resumed) {
// // //       // Re-enable if it was muted by lifecycle only
// // //     }
// // //   }

// // //   // ── Agora init ───────────────────────────────────────────────────────────
// // //   Future<void> _startCall() async {
// // //     if (widget.testMode) {
// // //       // Test mode: skip Agora, simulate host joining after 2 seconds
// // //       await Future.delayed(const Duration(seconds: 2));
// // //       if (!mounted) return;
// // //       setState(() => _isConnecting = false);
// // //       _onBillableSessionStart();
// // //       return;
// // //     }

// // //     // Real mode
// // //     try {
// // //       await _agora.initialize(
// // //         appId: AppConstants.agoraAppId,
// // //         fetchNewToken: () async {
// // //           // TODO: GET /api/calls/token?channel=channelId
// // //           return widget.token;
// // //         },
// // //       );
// // //       await _agora.join(
// // //         token: widget.token,
// // //         channelId: widget.channelId,
// // //         uid: widget.localUid,
// // //       );
// // //       _agora.remoteUids.addListener(_onRemoteUidsChanged);
// // //     } catch (e) {
// // //       if (mounted) setState(() => _errorMessage = e.toString());
// // //     }
// // //   }

// // //   void _onRemoteUidsChanged() {
// // //     if (_agora.remoteUids.value.isNotEmpty && _isConnecting) {
// // //       if (mounted) setState(() => _isConnecting = false);
// // //     }
// // //     if (_agora.remoteUids.value.isEmpty && !_isConnecting && !_callEnded) {
// // //       // Host left — end call
// // //       _endCall(hostLeft: true);
// // //     }
// // //   }

// // //   // ── Billing callbacks (fired by AgoraService) ────────────────────────────
// // //   void _onBillableSessionStart() {
// // //     // Tick duration every second
// // //     _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// // //       if (mounted) setState(() => _elapsedSeconds++);
// // //     });

// // //     // Drain coins once per minute (local UI only — server does real billing)
// // //     _coinDrainTimer =
// // //         Timer.periodic(const Duration(seconds: 60), (_) {
// // //       if (!mounted) return;
// // //       setState(() {
// // //         _coinsRemaining =
// // //             (_coinsRemaining - widget.host.priceCoins).clamp(0, 9999999);
// // //       });
// // //       if (_coinsRemaining <= 0) _endCall(outOfCoins: true);
// // //     });
// // //   }

// // //   void _onBillableSessionEnd() {
// // //     _durationTimer?.cancel();
// // //     _coinDrainTimer?.cancel();
// // //   }

// // //   // ── End call ──────────────────────────────────────────────────────────────
// // //   Future<void> _endCall({
// // //     bool hostLeft = false,
// // //     bool outOfCoins = false,
// // //   }) async {
// // //     if (_callEnded) return;
// // //     _durationTimer?.cancel();
// // //     _coinDrainTimer?.cancel();
// // //     if (!widget.testMode) await _agora.leave();
// // //     if (mounted) setState(() => _callEnded = true);
// // //     // TODO: POST /api/calls/end { channelId, duration: _elapsedSeconds }
// // //   }

// // //   // ── Chat ──────────────────────────────────────────────────────────────────
// // //   void _sendChatMessage() {
// // //     final text = _chatController.text.trim();
// // //     if (text.isEmpty) return;
// // //     setState(() {
// // //       _chatMessages.add(_ChatMessage(text: text, isLocal: true));
// // //     });
// // //     _chatController.clear();
// // //     // TODO: send via Firestore call-channel subcollection
// // //   }

// // //   // ── Build ─────────────────────────────────────────────────────────────────
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Keep status bar hidden during call
// // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// // //     return PopScope(
// // //       canPop: false, // Back gesture must go through _endCall
// // //       onPopInvokedWithResult: (didPop, _) async {
// // //         if (!didPop) await _endCall();
// // //       },
// // //       child: Scaffold(
// // //         backgroundColor: Colors.black,
// // //         body: GestureDetector(
// // //           onTap: () {
// // //             _chatFocus.unfocus();
// // //             setState(() => _uiVisible = !_uiVisible);
// // //           },
// // //           behavior: HitTestBehavior.opaque,
// // //           child: Stack(
// // //             children: [
// // //               // ── Layer 1: Remote video (full screen) ──────────────────────
// // //               _buildRemoteVideo(),

// // //               // ── Layer 2: Draggable local PIP ─────────────────────────────
// // //               _buildPip(),

// // //               // ── Layer 3: Hideable HUD ─────────────────────────────────────
// // //               if (_uiVisible && !_callEnded) ...[
// // //                 _buildTopBar(),
// // //                 _buildCoinBar(),
// // //                 if (_isLowCoins) _buildLowCoinBanner(),
// // //                 _buildChatOverlay(),
// // //                 _buildRightActions(),
// // //                 _buildBottomInput(),
// // //               ],

// // //               // ── Layer 4: Connecting overlay ───────────────────────────────
// // //               if (_isConnecting && !_callEnded) _buildConnectingOverlay(),

// // //               // ── Layer 5: Error overlay ────────────────────────────────────
// // //               if (_errorMessage != null) _buildErrorOverlay(),

// // //               // ── Layer 6: Call ended summary ───────────────────────────────
// // //               if (_callEnded) _buildCallEndedOverlay(),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Remote video ──────────────────────────────────────────────────────────
// // //   Widget _buildRemoteVideo() {
// // //     // Test mode: show a solid background with host avatar instead of real video
// // //     if (widget.testMode) {
// // //       return Container(
// // //         decoration: const BoxDecoration(
// // //           gradient: LinearGradient(
// // //             begin: Alignment.topCenter,
// // //             end: Alignment.bottomCenter,
// // //             colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
// // //           ),
// // //         ),
// // //         child: _isConnecting
// // //             ? null
// // //             : Center(
// // //                 child: Column(
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     CircleAvatar(
// // //                       radius: 72,
// // //                       backgroundColor: Colors.pink.withValues(alpha: 0.2),
// // //                       backgroundImage: widget.host.profilePhotoUrl != null
// // //                           ? NetworkImage(widget.host.profilePhotoUrl!)
// // //                           : null,
// // //                       child: widget.host.profilePhotoUrl == null
// // //                           ? const Icon(Icons.person, size: 72, color: Colors.white38)
// // //                           : null,
// // //                     ),
// // //                     const SizedBox(height: 14),
// // //                     Text(
// // //                       widget.host.displayName,
// // //                       style: GoogleFonts.lato(
// // //                         color: Colors.white70,
// // //                         fontSize: 16,
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 6),
// // //                     const Text(
// // //                       '[ Test Mode — No real video ]',
// // //                       style: TextStyle(color: Colors.white30, fontSize: 12),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //       );
// // //     }

// // //     return ValueListenableBuilder<Set<int>>(
// // //       valueListenable: _agora.remoteUids,
// // //       builder: (_, uids, __) {
// // //         if (uids.isEmpty) {
// // //           return Container(
// // //             color: const Color(0xFF1A1A2E),
// // //             child: Center(
// // //               child: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   if (widget.host.profilePhotoUrl != null)
// // //                     CircleAvatar(
// // //                       radius: 56,
// // //                       backgroundImage:
// // //                           NetworkImage(widget.host.profilePhotoUrl!),
// // //                     )
// // //                   else
// // //                     CircleAvatar(
// // //                       radius: 56,
// // //                       backgroundColor: Colors.pink.withValues(alpha: 0.3),
// // //                       child: const Icon(Icons.person,
// // //                           color: Colors.white70, size: 56),
// // //                     ),
// // //                   const SizedBox(height: 20),
// // //                   Text(
// // //                     widget.host.displayName,
// // //                     style: GoogleFonts.lato(
// // //                       color: Colors.white,
// // //                       fontSize: 22,
// // //                       fontWeight: FontWeight.bold,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 8),
// // //                   const _PulsingDots(),
// // //                 ],
// // //               ),
// // //             ),
// // //           );
// // //         }
// // //         return SizedBox.expand(
// // //           child: _agora.buildRemoteVideo(uids.first),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   // ── Local PIP ─────────────────────────────────────────────────────────────
// // //   Widget _buildPip() {
// // //     return Positioned(
// // //       left: _pipOffset.dx,
// // //       top: _pipOffset.dy,
// // //       child: GestureDetector(
// // //         onPanUpdate: (d) {
// // //           final size = MediaQuery.of(context).size;
// // //           setState(() {
// // //             _pipOffset = Offset(
// // //               (_pipOffset.dx + d.delta.dx).clamp(0, size.width - 110),
// // //               (_pipOffset.dy + d.delta.dy).clamp(0, size.height - 150),
// // //             );
// // //           });
// // //         },
// // //         child: Container(
// // //           width: 110,
// // //           height: 150,
// // //           decoration: BoxDecoration(
// // //             borderRadius: BorderRadius.circular(14),
// // //             border: Border.all(color: Colors.white30, width: 1.5),
// // //             boxShadow: const [
// // //               BoxShadow(blurRadius: 12, color: Colors.black54),
// // //             ],
// // //           ),
// // //           clipBehavior: Clip.antiAlias,
// // //           child: widget.testMode
// // //               ? Container(
// // //                   color: const Color(0xFF2A2A2A),
// // //                   child: const Center(
// // //                     child: Icon(Icons.videocam, color: Colors.white30, size: 28),
// // //                   ),
// // //                 )
// // //               : _agora.buildLocalVideo(),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Top bar ───────────────────────────────────────────────────────────────
// // //   Widget _buildTopBar() {
// // //     final safePad = MediaQuery.of(context).padding.top;
// // //     return Positioned(
// // //       top: safePad + 12,
// // //       left: 16,
// // //       right: 16,
// // //       child: Row(
// // //         children: [
// // //           // Host info chip
// // //           _glassChip(
// // //             child: Row(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 if (widget.host.profilePhotoUrl != null)
// // //                   CircleAvatar(
// // //                     radius: 12,
// // //                     backgroundImage:
// // //                         NetworkImage(widget.host.profilePhotoUrl!),
// // //                   )
// // //                 else
// // //                   const CircleAvatar(
// // //                     radius: 12,
// // //                     backgroundColor: Colors.pink,
// // //                     child: Icon(Icons.person, size: 12, color: Colors.white),
// // //                   ),
// // //                 const SizedBox(width: 8),
// // //                 Text(
// // //                   '${widget.host.displayName}, ${widget.host.age ?? '—'}',
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           const Spacer(),

// // //           // Live timer
// // //           _glassChip(
// // //             child: Row(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 Container(
// // //                   width: 7,
// // //                   height: 7,
// // //                   decoration: const BoxDecoration(
// // //                     color: Colors.greenAccent,
// // //                     shape: BoxShape.circle,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 6),
// // //                 Text(
// // //                   _formattedDuration,
// // //                   style: GoogleFonts.lato(
// // //                     color: Colors.white,
// // //                     fontSize: 13,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),

// // //           const SizedBox(width: 10),

// // //           // End call
// // //           GestureDetector(
// // //             onTap: () => _endCall(),
// // //             child: Container(
// // //               padding: const EdgeInsets.all(10),
// // //               decoration: const BoxDecoration(
// // //                 color: Colors.redAccent,
// // //                 shape: BoxShape.circle,
// // //               ),
// // //               child: const Icon(Icons.call_end, color: Colors.white, size: 22),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Coin bar ──────────────────────────────────────────────────────────────
// // //   Widget _buildCoinBar() {
// // //     final safePad = MediaQuery.of(context).padding.top;
// // //     return Positioned(
// // //       top: safePad + 68,
// // //       left: 16,
// // //       child: _glassChip(
// // //         color: _isLowCoins
// // //             ? Colors.red.withValues(alpha: 0.6)
// // //             : Colors.black54,
// // //         child: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             const Icon(Icons.monetization_on, color: Colors.amber, size: 15),
// // //             const SizedBox(width: 5),
// // //             Text(
// // //               _coinsRemaining.toString(),
// // //               style: GoogleFonts.lato(
// // //                 color: Colors.white,
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 13,
// // //               ),
// // //             ),
// // //             Text(
// // //               '  •  ${widget.host.priceCoins}/min',
// // //               style: const TextStyle(color: Colors.white60, fontSize: 11),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Low coin warning ──────────────────────────────────────────────────────
// // //   Widget _buildLowCoinBanner() {
// // //     return Positioned(
// // //       top: MediaQuery.of(context).padding.top + 108,
// // //       left: 16,
// // //       right: 16,
// // //       child: Container(
// // //         padding:
// // //             const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
// // //         decoration: BoxDecoration(
// // //           color: Colors.orange.shade800.withValues(alpha: 0.9),
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //         child: Row(
// // //           children: [
// // //             const Icon(Icons.warning_amber_rounded,
// // //                 color: Colors.white, size: 16),
// // //             const SizedBox(width: 8),
// // //             Expanded(
// // //               child: Text(
// // //                 'Low balance! Recharge to keep the call going.',
// // //                 style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 12,
// // //                     fontWeight: FontWeight.w600),
// // //               ),
// // //             ),
// // //             GestureDetector(
// // //               onTap: () => _showRechargeSheet(),
// // //               child: Container(
// // //                 padding:
// // //                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(20),
// // //                 ),
// // //                 child: Text(
// // //                   'Recharge',
// // //                   style: TextStyle(
// // //                     color: Colors.orange.shade800,
// // //                     fontSize: 11,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Chat overlay ──────────────────────────────────────────────────────────
// // //   Widget _buildChatOverlay() {
// // //     return Positioned(
// // //       bottom: 80,
// // //       left: 16,
// // //       right: 80,
// // //       height: 180,
// // //       child: ListView.builder(
// // //         reverse: true,
// // //         itemCount: _chatMessages.length,
// // //         itemBuilder: (_, i) {
// // //           final msg = _chatMessages[_chatMessages.length - 1 - i];
// // //           return Padding(
// // //             padding: const EdgeInsets.only(bottom: 6),
// // //             child: Text(
// // //               '${msg.isLocal ? 'You' : widget.host.displayName}: ${msg.text}',
// // //               style: const TextStyle(
// // //                 color: Colors.white,
// // //                 fontSize: 13,
// // //                 shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
// // //               ),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Right side action buttons ─────────────────────────────────────────────
// // //   Widget _buildRightActions() {
// // //     return Positioned(
// // //       bottom: 90,
// // //       right: 16,
// // //       child: Column(
// // //         children: [
// // //           // Recharge / coins
// // //           _actionButton(
// // //             icon: Icons.monetization_on,
// // //             color: Colors.amber,
// // //             onTap: _showRechargeSheet,
// // //           ),
// // //           const SizedBox(height: 14),

// // //           // Gift
// // //           _actionButton(
// // //             icon: Icons.card_giftcard,
// // //             color: Colors.pinkAccent,
// // //             onTap: _showGiftSheet,
// // //           ),
// // //           const SizedBox(height: 14),

// // //           // Switch camera
// // //           _actionButton(
// // //             icon: Icons.cameraswitch_rounded,
// // //             color: Colors.white24,
// // //             onTap: _agora.switchCamera,
// // //           ),
// // //           const SizedBox(height: 14),

// // //           // Mute audio toggle
// // //           ValueListenableBuilder<bool>(
// // //             valueListenable: _agora.isAudioMuted,
// // //             builder: (_, muted, __) => _actionButton(
// // //               icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
// // //               color: muted ? Colors.red : Colors.white24,
// // //               onTap: _agora.toggleMuteAudio,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 14),

// // //           // Mute video toggle
// // //           ValueListenableBuilder<bool>(
// // //             valueListenable: _agora.isVideoMuted,
// // //             builder: (_, muted, __) => _actionButton(
// // //               icon: muted ? Icons.videocam_off_rounded : Icons.videocam_rounded,
// // //               color: muted ? Colors.red : Colors.white24,
// // //               onTap: _agora.toggleMuteVideo,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom chat input ─────────────────────────────────────────────────────
// // //   Widget _buildBottomInput() {
// // //     final bottomPad = MediaQuery.of(context).padding.bottom;
// // //     return Positioned(
// // //       bottom: bottomPad,
// // //       left: 0,
// // //       right: 0,
// // //       child: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //         child: Row(
// // //           children: [
// // //             Expanded(
// // //               child: TextField(
// // //                 controller: _chatController,
// // //                 focusNode: _chatFocus,
// // //                 style: const TextStyle(color: Colors.white),
// // //                 onSubmitted: (_) => _sendChatMessage(),
// // //                 decoration: InputDecoration(
// // //                   hintText: 'Say something...',
// // //                   hintStyle: const TextStyle(color: Colors.white54),
// // //                   filled: true,
// // //                   fillColor: Colors.black45,
// // //                   contentPadding: const EdgeInsets.symmetric(
// // //                       horizontal: 18, vertical: 12),
// // //                   border: OutlineInputBorder(
// // //                     borderRadius: BorderRadius.circular(30),
// // //                     borderSide: BorderSide.none,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(width: 8),
// // //             GestureDetector(
// // //               onTap: _sendChatMessage,
// // //               child: Container(
// // //                 padding: const EdgeInsets.all(12),
// // //                 decoration: const BoxDecoration(
// // //                   color: Colors.pink,
// // //                   shape: BoxShape.circle,
// // //                 ),
// // //                 child: const Icon(Icons.send_rounded,
// // //                     color: Colors.white, size: 18),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Connecting overlay ────────────────────────────────────────────────────
// // //   Widget _buildConnectingOverlay() {
// // //     return Container(
// // //       color: Colors.black54,
// // //       child: Center(
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             const CircularProgressIndicator(color: Colors.pink),
// // //             const SizedBox(height: 20),
// // //             Text(
// // //               'Connecting to ${widget.host.displayName}...',
// // //               style: GoogleFonts.lato(
// // //                   color: Colors.white,
// // //                   fontSize: 16,
// // //                   fontWeight: FontWeight.w600),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Error overlay ─────────────────────────────────────────────────────────
// // //   Widget _buildErrorOverlay() {
// // //     return Container(
// // //       color: Colors.black87,
// // //       child: Center(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(32),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
// // //               const SizedBox(height: 16),
// // //               Text(
// // //                 'Could not connect',
// // //                 style: GoogleFonts.lato(
// // //                     color: Colors.white,
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.bold),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               Text(
// // //                 _errorMessage ?? '',
// // //                 textAlign: TextAlign.center,
// // //                 style: const TextStyle(color: Colors.white60, fontSize: 13),
// // //               ),
// // //               const SizedBox(height: 28),
// // //               FilledButton(
// // //                 onPressed: () => Navigator.of(context).pop(),
// // //                 style: FilledButton.styleFrom(backgroundColor: Colors.pink),
// // //                 child: const Text('Go Back'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Call ended summary overlay ────────────────────────────────────────────
// // //   Widget _buildCallEndedOverlay() {
// // //     return Container(
// // //       color: Colors.black87,
// // //       child: Center(
// // //         child: Container(
// // //           margin: const EdgeInsets.symmetric(horizontal: 32),
// // //           padding: const EdgeInsets.all(28),
// // //           decoration: BoxDecoration(
// // //             color: const Color(0xFF1A1A2E),
// // //             borderRadius: BorderRadius.circular(24),
// // //           ),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               Container(
// // //                 padding: const EdgeInsets.all(18),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.pink.withValues(alpha: 0.15),
// // //                   shape: BoxShape.circle,
// // //                 ),
// // //                 child: const Icon(Icons.call_end,
// // //                     color: Colors.pink, size: 36),
// // //               ),
// // //               const SizedBox(height: 20),
// // //               Text(
// // //                 'Call Ended',
// // //                 style: GoogleFonts.lato(
// // //                   color: Colors.white,
// // //                   fontSize: 22,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 6),
// // //               Text(
// // //                 'with ${widget.host.displayName}',
// // //                 style: const TextStyle(color: Colors.white54, fontSize: 14),
// // //               ),
// // //               const SizedBox(height: 24),
// // //               _summaryRow(
// // //                 Icons.timer_outlined,
// // //                 'Duration',
// // //                 _formattedDuration,
// // //               ),
// // //               const SizedBox(height: 10),
// // //               _summaryRow(
// // //                 Icons.monetization_on,
// // //                 'Coins Spent',
// // //                 '$_coinsSpent coins',
// // //               ),
// // //               const SizedBox(height: 10),
// // //               _summaryRow(
// // //                 Icons.account_balance_wallet_outlined,
// // //                 'Remaining',
// // //                 '$_coinsRemaining coins',
// // //               ),
// // //               const SizedBox(height: 28),
// // //               SizedBox(
// // //                 width: double.infinity,
// // //                 child: FilledButton(
// // //                   onPressed: () {
// // //                     SystemChrome.setEnabledSystemUIMode(
// // //                         SystemUiMode.edgeToEdge);
// // //                     Navigator.of(context).pop();
// // //                   },
// // //                   style: FilledButton.styleFrom(
// // //                     backgroundColor: Colors.pink,
// // //                     padding: const EdgeInsets.symmetric(vertical: 14),
// // //                     shape: RoundedRectangleBorder(
// // //                       borderRadius: BorderRadius.circular(14),
// // //                     ),
// // //                   ),
// // //                   child: Text(
// // //                     'Done',
// // //                     style: GoogleFonts.lato(
// // //                         fontWeight: FontWeight.bold, fontSize: 16),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Gift sheet ────────────────────────────────────────────────────────────
// // //   void _showGiftSheet() {
// // //     showModalBottomSheet<void>(
// // //       context: context,
// // //       backgroundColor: Colors.transparent,
// // //       isScrollControlled: true,
// // //       builder: (_) => Container(
// // //         height: MediaQuery.of(context).size.height * 0.52,
// // //         decoration: const BoxDecoration(
// // //           color: Color(0xFF1A1A1A),
// // //           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// // //         ),
// // //         child: Column(
// // //           children: [
// // //             const SizedBox(height: 12),
// // //             Container(
// // //               width: 40,
// // //               height: 4,
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white24,
// // //                 borderRadius: BorderRadius.circular(2),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             Text(
// // //               'Send a Gift',
// // //               style: GoogleFonts.lato(
// // //                 color: Colors.white,
// // //                 fontSize: 16,
// // //                 fontWeight: FontWeight.bold,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 12),
// // //             Expanded(
// // //               child: GridView.builder(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                 gridDelegate:
// // //                     const SliverGridDelegateWithFixedCrossAxisCount(
// // //                   crossAxisCount: 4,
// // //                   mainAxisSpacing: 12,
// // //                   crossAxisSpacing: 12,
// // //                   childAspectRatio: 0.85,
// // //                 ),
// // //                 itemCount: GiftAssets.all.length,
// // //                 itemBuilder: (_, i) {
// // //                   final asset = GiftAssets.all[i];
// // //                   final name = asset
// // //                       .split('/')
// // //                       .last
// // //                       .replaceAll('.png', '')
// // //                       .replaceAll('_', ' ');
// // //                   return GestureDetector(
// // //                     onTap: () {
// // //                       Navigator.pop(context);
// // //                       // TODO: POST /api/gifts/send { hostId, giftAsset: asset }
// // //                       ScaffoldMessenger.of(context).showSnackBar(
// // //                         SnackBar(
// // //                           content: Text('Gift sent! 🎁'),
// // //                           backgroundColor: Colors.pink,
// // //                           behavior: SnackBarBehavior.floating,
// // //                           shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(12)),
// // //                         ),
// // //                       );
// // //                     },
// // //                     child: Column(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         Expanded(
// // //                           child: Image.asset(
// // //                             asset,
// // //                             fit: BoxFit.contain,
// // //                             errorBuilder: (_, __, ___) => const Icon(
// // //                               Icons.card_giftcard,
// // //                               color: Colors.pink,
// // //                               size: 32,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 4),
// // //                         Text(
// // //                           name,
// // //                           maxLines: 1,
// // //                           overflow: TextOverflow.ellipsis,
// // //                           style: const TextStyle(
// // //                             color: Colors.white70,
// // //                             fontSize: 10,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Recharge sheet ────────────────────────────────────────────────────────
// // //   void _showRechargeSheet() {
// // //     showModalBottomSheet<void>(
// // //       context: context,
// // //       backgroundColor: Colors.transparent,
// // //       builder: (_) => Container(
// // //         decoration: const BoxDecoration(
// // //           color: Color(0xFF1A1A1A),
// // //           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// // //         ),
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Container(
// // //               width: 40,
// // //               height: 4,
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white24,
// // //                 borderRadius: BorderRadius.circular(2),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 20),
// // //             const Text(
// // //               'Wallet Balance',
// // //               style: TextStyle(color: Colors.white70, fontSize: 14),
// // //             ),
// // //             const SizedBox(height: 8),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 const Icon(Icons.monetization_on,
// // //                     color: Colors.amber, size: 28),
// // //                 const SizedBox(width: 8),
// // //                 Text(
// // //                   _coinsRemaining.toString(),
// // //                   style: GoogleFonts.lato(
// // //                     color: Colors.white,
// // //                     fontSize: 32,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             const Divider(height: 36, color: Colors.white10),
// // //             const Align(
// // //               alignment: Alignment.centerLeft,
// // //               child: Text(
// // //                 'Quick Recharge',
// // //                 style: TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 16,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 14),
// // //             _rechargeOption(500, '₹49'),
// // //             _rechargeOption(1200, '₹99'),
// // //             _rechargeOption(3000, '₹249'),
// // //             const SizedBox(height: 8),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _rechargeOption(int coins, String price) {
// // //     return Padding(
// // //       padding: const EdgeInsets.only(bottom: 10),
// // //       child: InkWell(
// // //         onTap: () {
// // //           Navigator.pop(context);
// // //           // TODO: launch Razorpay/Stripe payment flow
// // //           // On success: setState(() => _coinsRemaining += coins);
// // //         },
// // //         borderRadius: BorderRadius.circular(12),
// // //         child: Container(
// // //           padding:
// // //               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //           decoration: BoxDecoration(
// // //             color: Colors.white.withValues(alpha: 0.05),
// // //             borderRadius: BorderRadius.circular(12),
// // //             border: Border.all(color: Colors.white10),
// // //           ),
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               Row(
// // //                 children: [
// // //                   const Icon(Icons.monetization_on,
// // //                       color: Colors.amber, size: 20),
// // //                   const SizedBox(width: 10),
// // //                   Text(
// // //                     '$coins Coins',
// // //                     style: const TextStyle(
// // //                         color: Colors.white, fontSize: 15),
// // //                   ),
// // //                 ],
// // //               ),
// // //               Container(
// // //                 padding: const EdgeInsets.symmetric(
// // //                     horizontal: 14, vertical: 6),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.amber,
// // //                   borderRadius: BorderRadius.circular(20),
// // //                 ),
// // //                 child: Text(
// // //                   price,
// // //                   style: const TextStyle(
// // //                     color: Colors.black,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Shared helpers ────────────────────────────────────────────────────────
// // //   Widget _glassChip({required Widget child, Color? color}) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
// // //       decoration: BoxDecoration(
// // //         color: color ?? Colors.black54,
// // //         borderRadius: BorderRadius.circular(20),
// // //       ),
// // //       child: child,
// // //     );
// // //   }

// // //   Widget _actionButton({
// // //     required IconData icon,
// // //     required Color color,
// // //     required VoidCallback onTap,
// // //   }) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: Container(
// // //         padding: const EdgeInsets.all(12),
// // //         decoration: BoxDecoration(color: color, shape: BoxShape.circle),
// // //         child: Icon(icon, color: Colors.white, size: 24),
// // //       ),
// // //     );
// // //   }

// // //   Widget _summaryRow(IconData icon, String label, String value) {
// // //     return Row(
// // //       children: [
// // //         Icon(icon, color: Colors.white38, size: 18),
// // //         const SizedBox(width: 10),
// // //         Text(label,
// // //             style: const TextStyle(color: Colors.white54, fontSize: 14)),
// // //         const Spacer(),
// // //         Text(value,
// // //             style: const TextStyle(
// // //                 color: Colors.white,
// // //                 fontSize: 14,
// // //                 fontWeight: FontWeight.w600)),
// // //       ],
// // //     );
// // //   }
// // // }

// // // // ---------------------------------------------------------------------------
// // // // Pulsing dots — shown while waiting for host to join
// // // // ---------------------------------------------------------------------------
// // // class _PulsingDots extends StatefulWidget {
// // //   const _PulsingDots();

// // //   @override
// // //   State<_PulsingDots> createState() => _PulsingDotsState();
// // // }

// // // class _PulsingDotsState extends State<_PulsingDots>
// // //     with SingleTickerProviderStateMixin {
// // //   late final AnimationController _ctrl;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _ctrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 900),
// // //     )..repeat(reverse: true);
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _ctrl.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return FadeTransition(
// // //       opacity: _ctrl,
// // //       child: Text(
// // //         'Connecting...',
// // //         style: GoogleFonts.lato(
// // //           color: Colors.white60,
// // //           fontSize: 14,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ---------------------------------------------------------------------------
// // // // Internal chat message model
// // // // ---------------------------------------------------------------------------
// // // class _ChatMessage {
// // //   const _ChatMessage({required this.text, required this.isLocal});
// // //   final String text;
// // //   final bool isLocal;
// // // }
// // import 'dart:async';

// // import 'package:cheerchat/constants/app_constants.dart';
// // import 'package:cheerchat/constants/gift_constants.dart';
// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/services/agora_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ---------------------------------------------------------------------------
// // // OngoingCallScreen
// // //
// // // Entry point — caller passes host + their current coin balance + Agora creds.
// // // The screen owns AgoraService lifecycle entirely (creates → joins → disposes).
// // //
// // // How to push this screen:
// // //   Navigator.push(context, MaterialPageRoute(
// // //     builder: (_) => OngoingCallScreen(
// // //       host: host,
// // //       initialCoins: userCoins,
// // //       channelId: 'channel_abc',
// // //       token: 'agora_token_from_server',
// // //       localUid: myUid,
// // //     ),
// // //   ));
// // // ---------------------------------------------------------------------------
// // class OngoingCallScreen extends StatefulWidget {
// //   const OngoingCallScreen({
// //     super.key,
// //     required this.host,
// //     required this.initialCoins,
// //     this.channelId = 'test_channel',
// //     this.token = 'test_token',
// //     this.localUid = 0,
// //     this.testMode = false,
// //   });

// //   final HostModel host;

// //   /// User's current wallet balance — used for local UI display only.
// //   /// Real deduction happens server-side via Node.js billing ticks.
// //   final int initialCoins;

// //   final String channelId;
// //   final String token;
// //   final int localUid;

// //   /// When true: skips Agora entirely, simulates a connected call after 2s.
// //   /// Use this to test the UI without a real Agora App ID or token.
// //   final bool testMode;

// //   @override
// //   State<OngoingCallScreen> createState() =>
// //       _OngoingCallScreenState();
// // }

// // class _OngoingCallScreenState extends State<OngoingCallScreen>
// //     with WidgetsBindingObserver {
// //   // ── Agora ────────────────────────────────────────────────────────────────
// //   late final AgoraService _agora;

// //   // ── Call state ───────────────────────────────────────────────────────────
// //   bool _isConnecting = true;
// //   bool _callEnded = false;
// //   String? _errorMessage;

// //   // ── Timer & coins ────────────────────────────────────────────────────────
// //   Timer? _durationTimer;
// //   Timer? _coinDrainTimer;
// //   int _elapsedSeconds = 0;
// //   late int _coinsRemaining;

// //   // ── UI state ─────────────────────────────────────────────────────────────
// //   bool _uiVisible = true;
// //   Offset _pipOffset = const Offset(20, 120);

// //   // Chat overlay messages (live chat during call — stub list for now)
// //   // TODO: wire up real Firestore messages for the call channel
// //   final List<_ChatMessage> _chatMessages = [];
// //   final TextEditingController _chatController =
// //       TextEditingController();
// //   final FocusNode _chatFocus = FocusNode();

// //   // ── Getters ──────────────────────────────────────────────────────────────
// //   bool get _isLowCoins =>
// //       _coinsRemaining <
// //       widget.host.priceCoins *
// //           AppConstants.lowCoinWarningMinutes;

// //   String get _formattedDuration {
// //     final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
// //     final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
// //     return '$m:$s';
// //   }

// //   int get _coinsSpent => widget.initialCoins - _coinsRemaining;

// //   // ── Lifecycle ─────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _coinsRemaining = widget.initialCoins;
// //     _agora = AgoraService(
// //       onBillableSessionStart: _onBillableSessionStart,
// //       onBillableSessionEnd: _onBillableSessionEnd,
// //     );
// //     _startCall();
// //   }

// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     _durationTimer?.cancel();
// //     _coinDrainTimer?.cancel();
// //     _chatController.dispose();
// //     _chatFocus.dispose();
// //     _agora.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     // Pause local video when app goes to background
// //     if (state == AppLifecycleState.paused) {
// //       _agora.toggleMuteVideo();
// //     } else if (state == AppLifecycleState.resumed) {
// //       // Re-enable if it was muted by lifecycle only
// //     }
// //   }

// //   // ── Agora init ───────────────────────────────────────────────────────────
// //   Future<void> _startCall() async {
// //     if (widget.testMode) {
// //       // Test mode: skip Agora, simulate host joining after 2 seconds
// //       await Future.delayed(const Duration(seconds: 2));
// //       if (!mounted) return;
// //       setState(() => _isConnecting = false);
// //       _onBillableSessionStart();
// //       return;
// //     }

// //     // Real mode
// //     try {
// //       await _agora.initialize(
// //         appId: AppConstants.agoraAppId,
// //         fetchNewToken: () async {
// //           // TODO: GET /api/calls/token?channel=channelId
// //           return widget.token;
// //         },
// //       );
// //       await _agora.join(
// //         token: widget.token,
// //         channelId: widget.channelId,
// //         uid: widget.localUid,
// //       );
// //       _agora.remoteUids.addListener(_onRemoteUidsChanged);
// //     } catch (e) {
// //       if (mounted) setState(() => _errorMessage = e.toString());
// //     }
// //   }

// //   void _onRemoteUidsChanged() {
// //     if (_agora.remoteUids.value.isNotEmpty && _isConnecting) {
// //       if (mounted) setState(() => _isConnecting = false);
// //     }
// //     if (_agora.remoteUids.value.isEmpty &&
// //         !_isConnecting &&
// //         !_callEnded) {
// //       // Host left — end call
// //       _endCall(hostLeft: true);
// //     }
// //   }

// //   // ── Billing callbacks (fired by AgoraService) ────────────────────────────
// //   void _onBillableSessionStart() {
// //     // Tick duration every second
// //     _durationTimer = Timer.periodic(const Duration(seconds: 1), (
// //       _,
// //     ) {
// //       if (mounted) setState(() => _elapsedSeconds++);
// //     });

// //     // Drain coins once per minute (local UI only — server does real billing)
// //     _coinDrainTimer = Timer.periodic(
// //       const Duration(seconds: 60),
// //       (_) {
// //         if (!mounted) return;
// //         setState(() {
// //           _coinsRemaining =
// //               (_coinsRemaining - widget.host.priceCoins).clamp(
// //                 0,
// //                 9999999,
// //               );
// //         });
// //         if (_coinsRemaining <= 0) _endCall(outOfCoins: true);
// //       },
// //     );
// //   }

// //   void _onBillableSessionEnd() {
// //     _durationTimer?.cancel();
// //     _coinDrainTimer?.cancel();
// //   }

// //   // ── End call ──────────────────────────────────────────────────────────────
// //   Future<void> _endCall({
// //     bool hostLeft = false,
// //     bool outOfCoins = false,
// //   }) async {
// //     if (_callEnded) return;
// //     _durationTimer?.cancel();
// //     _coinDrainTimer?.cancel();
// //     if (!widget.testMode) await _agora.leave();
// //     if (mounted) setState(() => _callEnded = true);
// //     // TODO: POST /api/calls/end { channelId, duration: _elapsedSeconds }
// //   }

// //   // ── Chat ──────────────────────────────────────────────────────────────────
// //   void _sendChatMessage() {
// //     final text = _chatController.text.trim();
// //     if (text.isEmpty) return;
// //     setState(() {
// //       _chatMessages.add(_ChatMessage(text: text, isLocal: true));
// //     });
// //     _chatController.clear();
// //     // TODO: send via Firestore call-channel subcollection
// //   }

// //   // ── Build ─────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     // Keep status bar hidden during call
// //     SystemChrome.setEnabledSystemUIMode(
// //       SystemUiMode.immersiveSticky,
// //     );

// //     return PopScope(
// //       canPop: false, // Back gesture must go through _endCall
// //       onPopInvokedWithResult: (didPop, _) async {
// //         if (!didPop) await _endCall();
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.black,
// //         body: GestureDetector(
// //           onTap: () {
// //             _chatFocus.unfocus();
// //             setState(() => _uiVisible = !_uiVisible);
// //           },
// //           behavior: HitTestBehavior.opaque,
// //           child: Stack(
// //             children: [
// //               // ── Layer 1: Remote video (full screen) ──────────────────────
// //               _buildRemoteVideo(),

// //               // ── Layer 2: Draggable local PIP ─────────────────────────────
// //               _buildPip(),

// //               // ── Layer 3: Hideable HUD ─────────────────────────────────────
// //               if (_uiVisible && !_callEnded) ...[
// //                 _buildTopBar(),
// //                 _buildChatOverlay(),
// //                 _buildRightActions(),
// //                 _buildBottomInput(),
// //               ],

// //               // ── Layer 4: Connecting overlay ───────────────────────────────
// //               if (_isConnecting && !_callEnded)
// //                 _buildConnectingOverlay(),

// //               // ── Layer 5: Error overlay ────────────────────────────────────
// //               if (_errorMessage != null) _buildErrorOverlay(),

// //               // ── Layer 6: Call ended summary ───────────────────────────────
// //               if (_callEnded) _buildCallEndedOverlay(),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Remote video ──────────────────────────────────────────────────────────
// //   Widget _buildRemoteVideo() {
// //     // Test mode: show a solid background with host avatar instead of real video
// //     if (widget.testMode) {
// //       return Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
// //           ),
// //         ),
// //         child: _isConnecting
// //             ? null
// //             : Center(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     CircleAvatar(
// //                       radius: 72,
// //                       backgroundColor: Colors.pink.withValues(
// //                         alpha: 0.2,
// //                       ),
// //                       backgroundImage:
// //                           widget.host.profilePhotoUrl != null
// //                           ? NetworkImage(
// //                               widget.host.profilePhotoUrl!,
// //                             )
// //                           : null,
// //                       child: widget.host.profilePhotoUrl == null
// //                           ? const Icon(
// //                               Icons.person,
// //                               size: 72,
// //                               color: Colors.white38,
// //                             )
// //                           : null,
// //                     ),
// //                     const SizedBox(height: 14),
// //                     Text(
// //                       widget.host.displayName,
// //                       style: GoogleFonts.lato(
// //                         color: Colors.white70,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 6),
// //                     const Text(
// //                       '[ Test Mode — No real video ]',
// //                       style: TextStyle(
// //                         color: Colors.white30,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //       );
// //     }

// //     return ValueListenableBuilder<Set<int>>(
// //       valueListenable: _agora.remoteUids,
// //       builder: (_, uids, __) {
// //         if (uids.isEmpty) {
// //           return Container(
// //             color: const Color(0xFF1A1A2E),
// //             child: Center(
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   if (widget.host.profilePhotoUrl != null)
// //                     CircleAvatar(
// //                       radius: 56,
// //                       backgroundImage: NetworkImage(
// //                         widget.host.profilePhotoUrl!,
// //                       ),
// //                     )
// //                   else
// //                     CircleAvatar(
// //                       radius: 56,
// //                       backgroundColor: Colors.pink.withValues(
// //                         alpha: 0.3,
// //                       ),
// //                       child: const Icon(
// //                         Icons.person,
// //                         color: Colors.white70,
// //                         size: 56,
// //                       ),
// //                     ),
// //                   const SizedBox(height: 20),
// //                   Text(
// //                     widget.host.displayName,
// //                     style: GoogleFonts.lato(
// //                       color: Colors.white,
// //                       fontSize: 22,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   const _PulsingDots(),
// //                 ],
// //               ),
// //             ),
// //           );
// //         }
// //         return SizedBox.expand(
// //           child: _agora.buildRemoteVideo(uids.first),
// //         );
// //       },
// //     );
// //   }

// //   // ── Local PIP ─────────────────────────────────────────────────────────────
// //   Widget _buildPip() {
// //     return Positioned(
// //       left: _pipOffset.dx,
// //       top: _pipOffset.dy,
// //       child: GestureDetector(
// //         onPanUpdate: (d) {
// //           final size = MediaQuery.of(context).size;
// //           setState(() {
// //             _pipOffset = Offset(
// //               (_pipOffset.dx + d.delta.dx).clamp(
// //                 0,
// //                 size.width - 110,
// //               ),
// //               (_pipOffset.dy + d.delta.dy).clamp(
// //                 0,
// //                 size.height - 150,
// //               ),
// //             );
// //           });
// //         },
// //         child: Container(
// //           width: 110,
// //           height: 150,
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(14),
// //             border: Border.all(
// //               color: Colors.white30,
// //               width: 1.5,
// //             ),
// //             boxShadow: const [
// //               BoxShadow(blurRadius: 12, color: Colors.black54),
// //             ],
// //           ),
// //           clipBehavior: Clip.antiAlias,
// //           child: widget.testMode
// //               ? Container(
// //                   color: const Color(0xFF2A2A2A),
// //                   child: const Center(
// //                     child: Icon(
// //                       Icons.videocam,
// //                       color: Colors.white30,
// //                       size: 28,
// //                     ),
// //                   ),
// //                 )
// //               : _agora.buildLocalVideo(),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Top bar ───────────────────────────────────────────────────────────────
// //   Widget _buildTopBar() {
// //     final safePad = MediaQuery.of(context).padding.top;
// //     return Positioned(
// //       top: safePad + 12,
// //       left: 16,
// //       right: 16,
// //       child: Row(
// //         children: [
// //           // Host info chip
// //           _glassChip(
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 if (widget.host.profilePhotoUrl != null)
// //                   CircleAvatar(
// //                     radius: 12,
// //                     backgroundImage: NetworkImage(
// //                       widget.host.profilePhotoUrl!,
// //                     ),
// //                   )
// //                 else
// //                   const CircleAvatar(
// //                     radius: 12,
// //                     backgroundColor: Colors.pink,
// //                     child: Icon(
// //                       Icons.person,
// //                       size: 12,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   '${widget.host.displayName}, ${widget.host.age ?? '—'}',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 13,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const Spacer(),

// //           // Live timer
// //           _glassChip(
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Container(
// //                   width: 7,
// //                   height: 7,
// //                   decoration: const BoxDecoration(
// //                     color: Colors.greenAccent,
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   _formattedDuration,
// //                   style: GoogleFonts.lato(
// //                     color: Colors.white,
// //                     fontSize: 13,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(width: 10),

// //           // End call
// //           GestureDetector(
// //             onTap: () => _endCall(),
// //             child: Container(
// //               padding: const EdgeInsets.all(10),
// //               decoration: const BoxDecoration(
// //                 color: Colors.redAccent,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(
// //                 Icons.call_end,
// //                 color: Colors.white,
// //                 size: 22,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Coin bar ──────────────────────────────────────────────────────────────
// //   Widget _buildCoinBar() {
// //     final safePad = MediaQuery.of(context).padding.top;
// //     return Positioned(
// //       top: safePad + 68,
// //       left: 16,
// //       child: _glassChip(
// //         color: _isLowCoins
// //             ? Colors.red.withValues(alpha: 0.6)
// //             : Colors.black54,
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Icon(
// //               Icons.monetization_on,
// //               color: Colors.amber,
// //               size: 15,
// //             ),
// //             const SizedBox(width: 5),
// //             Text(
// //               _coinsRemaining.toString(),
// //               style: GoogleFonts.lato(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 13,
// //               ),
// //             ),
// //             Text(
// //               '  •  ${widget.host.priceCoins}/min',
// //               style: const TextStyle(
// //                 color: Colors.white60,
// //                 fontSize: 11,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Low coin warning ──────────────────────────────────────────────────────
// //   Widget _buildLowCoinBanner() {
// //     return Positioned(
// //       top: MediaQuery.of(context).padding.top + 108,
// //       left: 16,
// //       right: 16,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(
// //           horizontal: 14,
// //           vertical: 9,
// //         ),
// //         decoration: BoxDecoration(
// //           color: Colors.orange.shade800.withValues(alpha: 0.9),
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: Row(
// //           children: [
// //             const Icon(
// //               Icons.warning_amber_rounded,
// //               color: Colors.white,
// //               size: 16,
// //             ),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: Text(
// //                 'Low balance! Recharge to keep the call going.',
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //             GestureDetector(
// //               onTap: () => _showRechargeSheet(),
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 10,
// //                   vertical: 4,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   'Recharge',
// //                   style: TextStyle(
// //                     color: Colors.orange.shade800,
// //                     fontSize: 11,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Chat overlay ──────────────────────────────────────────────────────────
// //   Widget _buildChatOverlay() {
// //     return Positioned(
// //       bottom: 80,
// //       left: 16,
// //       right: 80,
// //       height: 180,
// //       child: ListView.builder(
// //         reverse: true,
// //         itemCount: _chatMessages.length,
// //         itemBuilder: (_, i) {
// //           final msg =
// //               _chatMessages[_chatMessages.length - 1 - i];
// //           return Padding(
// //             padding: const EdgeInsets.only(bottom: 6),
// //             child: Text(
// //               '${msg.isLocal ? 'You' : widget.host.displayName}: ${msg.text}',
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 13,
// //                 shadows: [
// //                   Shadow(blurRadius: 4, color: Colors.black87),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Right side action buttons ─────────────────────────────────────────────
// //   Widget _buildRightActions() {
// //     return Positioned(
// //       bottom: 90,
// //       right: 16,
// //       child: Column(
// //         children: [
// //           // Recharge / coins
// //           _actionButton(
// //             icon: Icons.monetization_on,
// //             color: Colors.amber,
// //             onTap: _showRechargeSheet,
// //           ),
// //           const SizedBox(height: 14),

// //           // Gift
// //           _actionButton(
// //             icon: Icons.card_giftcard,
// //             color: Colors.pinkAccent,
// //             onTap: _showGiftSheet,
// //           ),
// //           const SizedBox(height: 14),

// //           // Switch camera
// //           _actionButton(
// //             icon: Icons.cameraswitch_rounded,
// //             color: Colors.white24,
// //             onTap: _agora.switchCamera,
// //           ),
// //           const SizedBox(height: 14),

// //           // Mute audio toggle
// //           ValueListenableBuilder<bool>(
// //             valueListenable: _agora.isAudioMuted,
// //             builder: (_, muted, __) => _actionButton(
// //               icon: muted
// //                   ? Icons.mic_off_rounded
// //                   : Icons.mic_rounded,
// //               color: muted ? Colors.red : Colors.white24,
// //               onTap: _agora.toggleMuteAudio,
// //             ),
// //           ),
// //           const SizedBox(height: 14),

// //           // Beauty effects
// //           _actionButton(
// //             icon: Icons.auto_fix_high_rounded,
// //             color: Colors.purpleAccent.withValues(alpha: 0.8),
// //             onTap: _showBeautySheet,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Bottom chat input ─────────────────────────────────────────────────────
// //   Widget _buildBottomInput() {
// //     final bottomPad = MediaQuery.of(context).padding.bottom;
// //     return Positioned(
// //       bottom: bottomPad,
// //       left: 0,
// //       right: 0,
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(
// //           horizontal: 12,
// //           vertical: 8,
// //         ),
// //         child: Row(
// //           children: [
// //             Expanded(
// //               child: TextField(
// //                 controller: _chatController,
// //                 focusNode: _chatFocus,
// //                 style: const TextStyle(color: Colors.white),
// //                 onSubmitted: (_) => _sendChatMessage(),
// //                 decoration: InputDecoration(
// //                   hintText: 'Say something...',
// //                   hintStyle: const TextStyle(
// //                     color: Colors.white54,
// //                   ),
// //                   filled: true,
// //                   fillColor: Colors.black45,
// //                   contentPadding: const EdgeInsets.symmetric(
// //                     horizontal: 18,
// //                     vertical: 12,
// //                   ),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(30),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             GestureDetector(
// //               onTap: _sendChatMessage,
// //               child: Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: const BoxDecoration(
// //                   color: Colors.pink,
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: const Icon(
// //                   Icons.send_rounded,
// //                   color: Colors.white,
// //                   size: 18,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Connecting overlay ────────────────────────────────────────────────────
// //   Widget _buildConnectingOverlay() {
// //     return Container(
// //       color: Colors.black54,
// //       child: Center(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const CircularProgressIndicator(color: Colors.pink),
// //             const SizedBox(height: 20),
// //             Text(
// //               'Connecting to ${widget.host.displayName}...',
// //               style: GoogleFonts.lato(
// //                 color: Colors.white,
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Error overlay ─────────────────────────────────────────────────────────
// //   Widget _buildErrorOverlay() {
// //     return Container(
// //       color: Colors.black87,
// //       child: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(32),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const Icon(
// //                 Icons.error_outline,
// //                 color: Colors.redAccent,
// //                 size: 48,
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 'Could not connect',
// //                 style: GoogleFonts.lato(
// //                   color: Colors.white,
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 _errorMessage ?? '',
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   color: Colors.white60,
// //                   fontSize: 13,
// //                 ),
// //               ),
// //               const SizedBox(height: 28),
// //               FilledButton(
// //                 onPressed: () => Navigator.of(context).pop(),
// //                 style: FilledButton.styleFrom(
// //                   backgroundColor: Colors.pink,
// //                 ),
// //                 child: const Text('Go Back'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Call ended summary overlay ────────────────────────────────────────────
// //   Widget _buildCallEndedOverlay() {
// //     return Container(
// //       color: Colors.black87,
// //       child: Center(
// //         child: Container(
// //           margin: const EdgeInsets.symmetric(horizontal: 32),
// //           padding: const EdgeInsets.all(28),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFF1A1A2E),
// //             borderRadius: BorderRadius.circular(24),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.all(18),
// //                 decoration: BoxDecoration(
// //                   color: Colors.pink.withValues(alpha: 0.15),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: const Icon(
// //                   Icons.call_end,
// //                   color: Colors.pink,
// //                   size: 36,
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               Text(
// //                 'Call Ended',
// //                 style: GoogleFonts.lato(
// //                   color: Colors.white,
// //                   fontSize: 22,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 6),
// //               Text(
// //                 'with ${widget.host.displayName}',
// //                 style: const TextStyle(
// //                   color: Colors.white54,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               _summaryRow(
// //                 Icons.timer_outlined,
// //                 'Duration',
// //                 _formattedDuration,
// //               ),
// //               const SizedBox(height: 10),
// //               _summaryRow(
// //                 Icons.monetization_on,
// //                 'Coins Spent',
// //                 '$_coinsSpent coins',
// //               ),
// //               const SizedBox(height: 10),
// //               _summaryRow(
// //                 Icons.account_balance_wallet_outlined,
// //                 'Remaining',
// //                 '$_coinsRemaining coins',
// //               ),
// //               const SizedBox(height: 28),
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: FilledButton(
// //                   onPressed: () {
// //                     SystemChrome.setEnabledSystemUIMode(
// //                       SystemUiMode.edgeToEdge,
// //                     );
// //                     Navigator.of(context).pop();
// //                   },
// //                   style: FilledButton.styleFrom(
// //                     backgroundColor: Colors.pink,
// //                     padding: const EdgeInsets.symmetric(
// //                       vertical: 14,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(14),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     'Done',
// //                     style: GoogleFonts.lato(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 16,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Beauty effects sheet ─────────────────────────────────────────────────
// //   void _showBeautySheet() {
// //     // TODO: integrate Banuba or BytePlus SDK for real beauty effects
// //     showModalBottomSheet<void>(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         decoration: const BoxDecoration(
// //           color: Color(0xFF1A1A1A),
// //           borderRadius: BorderRadius.vertical(
// //             top: Radius.circular(24),
// //           ),
// //         ),
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: Colors.white24,
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               'Beauty Effects',
// //               style: GoogleFonts.lato(
// //                 color: Colors.white,
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             _beautyOption(
// //               Icons.face_retouching_natural,
// //               'Smooth Skin',
// //             ),
// //             _beautyOption(Icons.wb_sunny_outlined, 'Brighten'),
// //             _beautyOption(Icons.blur_on, 'Blur Background'),
// //             _beautyOption(Icons.color_lens_outlined, 'Filters'),
// //             const SizedBox(height: 8),
// //             Container(
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: 14,
// //                 vertical: 10,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: Colors.purple.withValues(alpha: 0.15),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(
// //                   color: Colors.purple.withValues(alpha: 0.3),
// //                 ),
// //               ),
// //               child: const Row(
// //                 children: [
// //                   Icon(
// //                     Icons.info_outline,
// //                     color: Colors.purple,
// //                     size: 16,
// //                   ),
// //                   SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       'Full beauty effects coming soon via Banuba SDK',
// //                       style: TextStyle(
// //                         color: Colors.white54,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _beautyOption(IconData icon, String label) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 10),
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(
// //           horizontal: 16,
// //           vertical: 13,
// //         ),
// //         decoration: BoxDecoration(
// //           color: Colors.white.withValues(alpha: 0.05),
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: Colors.white10),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(icon, color: Colors.purpleAccent, size: 20),
// //             const SizedBox(width: 12),
// //             Text(
// //               label,
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 14,
// //               ),
// //             ),
// //             const Spacer(),
// //             const Text(
// //               'Coming soon',
// //               style: TextStyle(
// //                 color: Colors.white30,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Gift sheet ────────────────────────────────────────────────────────────
// //   void _showGiftSheet() {
// //     showModalBottomSheet<void>(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       isScrollControlled: true,
// //       builder: (_) => Container(
// //         height: MediaQuery.of(context).size.height * 0.52,
// //         decoration: const BoxDecoration(
// //           color: Color(0xFF1A1A1A),
// //           borderRadius: BorderRadius.vertical(
// //             top: Radius.circular(24),
// //           ),
// //         ),
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 12),
// //             Container(
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: Colors.white24,
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               'Send a Gift',
// //               style: GoogleFonts.lato(
// //                 color: Colors.white,
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Expanded(
// //               child: GridView.builder(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 16,
// //                 ),
// //                 gridDelegate:
// //                     const SliverGridDelegateWithFixedCrossAxisCount(
// //                       crossAxisCount: 4,
// //                       mainAxisSpacing: 12,
// //                       crossAxisSpacing: 12,
// //                       childAspectRatio: 0.85,
// //                     ),
// //                 itemCount: GiftAssets.all.length,
// //                 itemBuilder: (_, i) {
// //                   final asset = GiftAssets.all[i];
// //                   final name = asset
// //                       .split('/')
// //                       .last
// //                       .replaceAll('.png', '')
// //                       .replaceAll('_', ' ');
// //                   return GestureDetector(
// //                     onTap: () {
// //                       Navigator.pop(context);
// //                       // TODO: POST /api/gifts/send { hostId, giftAsset: asset }
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         SnackBar(
// //                           content: Text('Gift sent! 🎁'),
// //                           backgroundColor: Colors.pink,
// //                           behavior: SnackBarBehavior.floating,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(
// //                               12,
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                     child: Column(
// //                       mainAxisAlignment:
// //                           MainAxisAlignment.center,
// //                       children: [
// //                         Expanded(
// //                           child: Image.asset(
// //                             asset,
// //                             fit: BoxFit.contain,
// //                             errorBuilder: (_, __, ___) =>
// //                                 const Icon(
// //                                   Icons.card_giftcard,
// //                                   color: Colors.pink,
// //                                   size: 32,
// //                                 ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           name,
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: const TextStyle(
// //                             color: Colors.white70,
// //                             fontSize: 10,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Recharge sheet ────────────────────────────────────────────────────────
// //   void _showRechargeSheet() {
// //     showModalBottomSheet<void>(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         decoration: const BoxDecoration(
// //           color: Color(0xFF1A1A1A),
// //           borderRadius: BorderRadius.vertical(
// //             top: Radius.circular(24),
// //           ),
// //         ),
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: Colors.white24,
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             const Text(
// //               'Wallet Balance',
// //               style: TextStyle(
// //                 color: Colors.white70,
// //                 fontSize: 14,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(
// //                   Icons.monetization_on,
// //                   color: Colors.amber,
// //                   size: 28,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   _coinsRemaining.toString(),
// //                   style: GoogleFonts.lato(
// //                     color: Colors.white,
// //                     fontSize: 32,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const Divider(height: 36, color: Colors.white10),
// //             const Align(
// //               alignment: Alignment.centerLeft,
// //               child: Text(
// //                 'Quick Recharge',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 14),
// //             _rechargeOption(500, '₹49'),
// //             _rechargeOption(1200, '₹99'),
// //             _rechargeOption(3000, '₹249'),
// //             const SizedBox(height: 8),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _rechargeOption(int coins, String price) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 10),
// //       child: InkWell(
// //         onTap: () {
// //           Navigator.pop(context);
// //           // TODO: launch Razorpay/Stripe payment flow
// //           // On success: setState(() => _coinsRemaining += coins);
// //         },
// //         borderRadius: BorderRadius.circular(12),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(
// //             horizontal: 16,
// //             vertical: 12,
// //           ),
// //           decoration: BoxDecoration(
// //             color: Colors.white.withValues(alpha: 0.05),
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.white10),
// //           ),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Row(
// //                 children: [
// //                   const Icon(
// //                     Icons.monetization_on,
// //                     color: Colors.amber,
// //                     size: 20,
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Text(
// //                     '$coins Coins',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 15,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 14,
// //                   vertical: 6,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.amber,
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   price,
// //                   style: const TextStyle(
// //                     color: Colors.black,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 13,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Shared helpers ────────────────────────────────────────────────────────
// //   Widget _glassChip({required Widget child, Color? color}) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(
// //         horizontal: 12,
// //         vertical: 7,
// //       ),
// //       decoration: BoxDecoration(
// //         color: color ?? Colors.black54,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: child,
// //     );
// //   }

// //   Widget _actionButton({
// //     required IconData icon,
// //     required Color color,
// //     required VoidCallback onTap,
// //   }) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: color,
// //           shape: BoxShape.circle,
// //         ),
// //         child: Icon(icon, color: Colors.white, size: 24),
// //       ),
// //     );
// //   }

// //   Widget _summaryRow(IconData icon, String label, String value) {
// //     return Row(
// //       children: [
// //         Icon(icon, color: Colors.white38, size: 18),
// //         const SizedBox(width: 10),
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             color: Colors.white54,
// //             fontSize: 14,
// //           ),
// //         ),
// //         const Spacer(),
// //         Text(
// //           value,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 14,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // ---------------------------------------------------------------------------
// // // Pulsing dots — shown while waiting for host to join
// // // ---------------------------------------------------------------------------
// // class _PulsingDots extends StatefulWidget {
// //   const _PulsingDots();

// //   @override
// //   State<_PulsingDots> createState() => _PulsingDotsState();
// // }

// // class _PulsingDotsState extends State<_PulsingDots>
// //     with SingleTickerProviderStateMixin {
// //   late final AnimationController _ctrl;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 900),
// //     )..repeat(reverse: true);
// //   }

// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _ctrl,
// //       child: Text(
// //         'Connecting...',
// //         style: GoogleFonts.lato(
// //           color: Colors.white60,
// //           fontSize: 14,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ---------------------------------------------------------------------------
// // // Internal chat message model
// // // ---------------------------------------------------------------------------
// // class _ChatMessage {
// //   const _ChatMessage({
// //     required this.text,
// //     required this.isLocal,
// //   });
// //   final String text;
// //   final bool isLocal;
// // }
// import 'dart:async';

// import 'package:cheerchat/constants/app_constants.dart';
// import 'package:cheerchat/constants/gift_constants.dart';
// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/services/agora_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// // ---------------------------------------------------------------------------
// // OngoingCallScreen
// //
// // Entry point — caller passes host + their current coin balance + Agora creds.
// // The screen owns AgoraService lifecycle entirely (creates → joins → disposes).
// //
// // How to push this screen:
// //   Navigator.push(context, MaterialPageRoute(
// //     builder: (_) => OngoingCallScreen(
// //       host: host,
// //       initialCoins: userCoins,
// //       channelId: 'channel_abc',
// //       token: 'agora_token_from_server',
// //       localUid: myUid,
// //     ),
// //   ));
// // ---------------------------------------------------------------------------
// class OngoingCallScreen extends StatefulWidget {
//   const OngoingCallScreen({
//     super.key,
//     required this.host,
//     required this.initialCoins,
//     this.channelId = 'test_channel',
//     this.token = 'test_token',
//     this.localUid = 0,
//     this.testMode = false,
//   });

//   final HostModel host;

//   /// User's current wallet balance — used for local UI display only.
//   /// Real deduction happens server-side via Node.js billing ticks.
//   final int initialCoins;

//   final String channelId;
//   final String token;
//   final int localUid;

//   /// When true: skips Agora entirely, simulates a connected call after 2s.
//   /// Use this to test the UI without a real Agora App ID or token.
//   final bool testMode;

//   @override
//   State<OngoingCallScreen> createState() =>
//       _OngoingCallScreenState();
// }

// class _OngoingCallScreenState extends State<OngoingCallScreen>
//     with WidgetsBindingObserver {
//   // ── Agora ────────────────────────────────────────────────────────────────
//   late final AgoraService _agora;

//   // ── Call state ───────────────────────────────────────────────────────────
//   bool _isConnecting = true;
//   bool _callEnded = false;
//   String? _errorMessage;

//   // ── Timer & coins ────────────────────────────────────────────────────────
//   Timer? _durationTimer;
//   Timer? _coinDrainTimer;
//   int _elapsedSeconds = 0;
//   late int _coinsRemaining;

//   // ── UI state ─────────────────────────────────────────────────────────────
//   bool _uiVisible = true;
//   Offset _pipOffset = const Offset(20, 120);

//   // Chat overlay messages (live chat during call — stub list for now)
//   // TODO: wire up real Firestore messages for the call channel
//   final List<_ChatMessage> _chatMessages = [];
//   final TextEditingController _chatController =
//       TextEditingController();
//   final FocusNode _chatFocus = FocusNode();

//   // ── Getters ──────────────────────────────────────────────────────────────
//   bool get _isLowCoins =>
//       _coinsRemaining <
//       widget.host.priceCoins *
//           AppConstants.lowCoinWarningMinutes;

//   String get _formattedDuration {
//     final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
//     final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   int get _coinsSpent => widget.initialCoins - _coinsRemaining;

//   // ── Lifecycle ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _coinsRemaining = widget.initialCoins;
//     _agora = AgoraService(
//       onBillableSessionStart: _onBillableSessionStart,
//       onBillableSessionEnd: _onBillableSessionEnd,
//     );
//     _startCall();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _durationTimer?.cancel();
//     _coinDrainTimer?.cancel();
//     _chatController.dispose();
//     _chatFocus.dispose();
//     _agora.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Pause local video when app goes to background
//     if (state == AppLifecycleState.paused) {
//       _agora.toggleMuteVideo();
//     } else if (state == AppLifecycleState.resumed) {
//       // Re-enable if it was muted by lifecycle only
//     }
//   }

//   // ── Agora init ───────────────────────────────────────────────────────────
//   Future<void> _startCall() async {
//     if (widget.testMode) {
//       // Test mode: skip Agora, simulate host joining after 2 seconds
//       await Future.delayed(const Duration(seconds: 2));
//       if (!mounted) return;
//       setState(() => _isConnecting = false);
//       _onBillableSessionStart();
//       return;
//     }

//     // Real mode
//     try {
//       await _agora.initialize(
//         appId: AppConstants.agoraAppId,
//         fetchNewToken: () async {
//           // TODO: GET /api/calls/token?channel=channelId
//           return widget.token;
//         },
//       );
//       await _agora.join(
//         token: widget.token,
//         channelId: widget.channelId,
//         uid: widget.localUid,
//       );
//       _agora.remoteUids.addListener(_onRemoteUidsChanged);
//     } catch (e) {
//       if (mounted) setState(() => _errorMessage = e.toString());
//     }
//   }

//   void _onRemoteUidsChanged() {
//     if (_agora.remoteUids.value.isNotEmpty && _isConnecting) {
//       if (mounted) setState(() => _isConnecting = false);
//     }
//     if (_agora.remoteUids.value.isEmpty &&
//         !_isConnecting &&
//         !_callEnded) {
//       // Host left — end call
//       _endCall(hostLeft: true);
//     }
//   }

//   // ── Billing callbacks (fired by AgoraService) ────────────────────────────
//   void _onBillableSessionStart() {
//     // Tick duration every second
//     _durationTimer = Timer.periodic(const Duration(seconds: 1), (
//       _,
//     ) {
//       if (mounted) setState(() => _elapsedSeconds++);
//     });

//     // Drain coins once per minute (local UI only — server does real billing)
//     _coinDrainTimer = Timer.periodic(
//       const Duration(seconds: 60),
//       (_) {
//         if (!mounted) return;
//         setState(() {
//           _coinsRemaining =
//               (_coinsRemaining - widget.host.priceCoins).clamp(
//                 0,
//                 9999999,
//               );
//         });
//         if (_coinsRemaining <= 0) _endCall(outOfCoins: true);
//       },
//     );
//   }

//   void _onBillableSessionEnd() {
//     _durationTimer?.cancel();
//     _coinDrainTimer?.cancel();
//   }

//   // ── End call ──────────────────────────────────────────────────────────────
//   Future<void> _endCall({
//     bool hostLeft = false,
//     bool outOfCoins = false,
//   }) async {
//     if (_callEnded) return;
//     _durationTimer?.cancel();
//     _coinDrainTimer?.cancel();
//     if (!widget.testMode) await _agora.leave();
//     if (mounted) setState(() => _callEnded = true);
//     // TODO: POST /api/calls/end { channelId, duration: _elapsedSeconds }
//   }

//   // ── Chat ──────────────────────────────────────────────────────────────────
//   void _sendChatMessage() {
//     final text = _chatController.text.trim();
//     if (text.isEmpty) return;
//     setState(() {
//       _chatMessages.add(_ChatMessage(text: text, isLocal: true));
//     });
//     _chatController.clear();
//     // TODO: send via Firestore call-channel subcollection
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     // Keep status bar hidden during call
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.immersiveSticky,
//     );

//     return PopScope(
//       canPop: false, // Back gesture must go through _endCall
//       onPopInvokedWithResult: (didPop, _) async {
//         if (!didPop) await _endCall();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: GestureDetector(
//           onTap: () {
//             final keyboardOpen =
//                 MediaQuery.of(context).viewInsets.bottom > 0;
//             if (keyboardOpen) {
//               _chatFocus.unfocus();
//             } else {
//               setState(() => _uiVisible = !_uiVisible);
//             }
//           },
//           behavior: HitTestBehavior.opaque,
//           child: Stack(
//             children: [
//               // ── Layer 1: Remote video (full screen) ──────────────────────
//               _buildRemoteVideo(),

//               // ── Layer 2: Draggable local PIP ─────────────────────────────
//               _buildPip(),

//               // ── Layer 3: Hideable HUD ─────────────────────────────────────
//               if (_uiVisible && !_callEnded) ...[
//                 _buildTopBar(),
//                 _buildChatOverlay(),
//                 _buildRightActions(),
//                 _buildBottomInput(),
//               ],

//               // ── Layer 4: Connecting overlay ───────────────────────────────
//               if (_isConnecting && !_callEnded)
//                 _buildConnectingOverlay(),

//               // ── Layer 5: Error overlay ────────────────────────────────────
//               if (_errorMessage != null) _buildErrorOverlay(),

//               // ── Layer 6: Call ended summary ───────────────────────────────
//               if (_callEnded) _buildCallEndedOverlay(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Remote video ──────────────────────────────────────────────────────────
//   Widget _buildRemoteVideo() {
//     // Test mode: show a solid background with host avatar instead of real video
//     if (widget.testMode) {
//       return Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
//           ),
//         ),
//         child: _isConnecting
//             ? null
//             : Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircleAvatar(
//                       radius: 72,
//                       backgroundColor: Colors.pink.withValues(
//                         alpha: 0.2,
//                       ),
//                       backgroundImage:
//                           widget.host.profilePhotoUrl != null
//                           ? NetworkImage(
//                               widget.host.profilePhotoUrl!,
//                             )
//                           : null,
//                       child: widget.host.profilePhotoUrl == null
//                           ? const Icon(
//                               Icons.person,
//                               size: 72,
//                               color: Colors.white38,
//                             )
//                           : null,
//                     ),
//                     const SizedBox(height: 14),
//                     Text(
//                       widget.host.displayName,
//                       style: GoogleFonts.lato(
//                         color: Colors.white70,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       '[ Test Mode — No real video ]',
//                       style: TextStyle(
//                         color: Colors.white30,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       );
//     }

//     return ValueListenableBuilder<Set<int>>(
//       valueListenable: _agora.remoteUids,
//       builder: (_, uids, __) {
//         if (uids.isEmpty) {
//           return Container(
//             color: const Color(0xFF1A1A2E),
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (widget.host.profilePhotoUrl != null)
//                     CircleAvatar(
//                       radius: 56,
//                       backgroundImage: NetworkImage(
//                         widget.host.profilePhotoUrl!,
//                       ),
//                     )
//                   else
//                     CircleAvatar(
//                       radius: 56,
//                       backgroundColor: Colors.pink.withValues(
//                         alpha: 0.3,
//                       ),
//                       child: const Icon(
//                         Icons.person,
//                         color: Colors.white70,
//                         size: 56,
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   Text(
//                     widget.host.displayName,
//                     style: GoogleFonts.lato(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const _PulsingDots(),
//                 ],
//               ),
//             ),
//           );
//         }
//         return SizedBox.expand(
//           child: _agora.buildRemoteVideo(uids.first),
//         );
//       },
//     );
//   }

//   // ── Local PIP ─────────────────────────────────────────────────────────────
//   Widget _buildPip() {
//     return Positioned(
//       left: _pipOffset.dx,
//       top: _pipOffset.dy,
//       child: GestureDetector(
//         onPanUpdate: (d) {
//           final size = MediaQuery.of(context).size;
//           setState(() {
//             _pipOffset = Offset(
//               (_pipOffset.dx + d.delta.dx).clamp(
//                 0,
//                 size.width - 110,
//               ),
//               (_pipOffset.dy + d.delta.dy).clamp(
//                 0,
//                 size.height - 150,
//               ),
//             );
//           });
//         },
//         child: Container(
//           width: 110,
//           height: 150,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: Colors.white30,
//               width: 1.5,
//             ),
//             boxShadow: const [
//               BoxShadow(blurRadius: 12, color: Colors.black54),
//             ],
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: widget.testMode
//               ? Container(
//                   color: const Color(0xFF2A2A2A),
//                   child: const Center(
//                     child: Icon(
//                       Icons.videocam,
//                       color: Colors.white30,
//                       size: 28,
//                     ),
//                   ),
//                 )
//               : _agora.buildLocalVideo(),
//         ),
//       ),
//     );
//   }

//   // ── Top bar ───────────────────────────────────────────────────────────────
//   Widget _buildTopBar() {
//     final safePad = MediaQuery.of(context).padding.top;
//     return Positioned(
//       top: safePad + 12,
//       left: 16,
//       right: 16,
//       child: Row(
//         children: [
//           // Host info chip
//           _glassChip(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (widget.host.profilePhotoUrl != null)
//                   CircleAvatar(
//                     radius: 12,
//                     backgroundImage: NetworkImage(
//                       widget.host.profilePhotoUrl!,
//                     ),
//                   )
//                 else
//                   const CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.pink,
//                     child: Icon(
//                       Icons.person,
//                       size: 12,
//                       color: Colors.white,
//                     ),
//                   ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '${widget.host.displayName}, ${widget.host.age ?? '—'}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Spacer(),

//           // Live timer
//           _glassChip(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 7,
//                   height: 7,
//                   decoration: const BoxDecoration(
//                     color: Colors.greenAccent,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   _formattedDuration,
//                   style: GoogleFonts.lato(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 10),

//           // End call
//           GestureDetector(
//             onTap: () => _endCall(),
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: const BoxDecoration(
//                 color: Colors.redAccent,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.call_end,
//                 color: Colors.white,
//                 size: 22,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Coin bar ──────────────────────────────────────────────────────────────
//   Widget _buildCoinBar() {
//     final safePad = MediaQuery.of(context).padding.top;
//     return Positioned(
//       top: safePad + 68,
//       left: 16,
//       child: _glassChip(
//         color: _isLowCoins
//             ? Colors.red.withValues(alpha: 0.6)
//             : Colors.black54,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.monetization_on,
//               color: Colors.amber,
//               size: 15,
//             ),
//             const SizedBox(width: 5),
//             Text(
//               _coinsRemaining.toString(),
//               style: GoogleFonts.lato(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//               ),
//             ),
//             Text(
//               '  •  ${widget.host.priceCoins}/min',
//               style: const TextStyle(
//                 color: Colors.white60,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Low coin warning ──────────────────────────────────────────────────────
//   Widget _buildLowCoinBanner() {
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 108,
//       left: 16,
//       right: 16,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 9,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.orange.shade800.withValues(alpha: 0.9),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             const Icon(
//               Icons.warning_amber_rounded,
//               color: Colors.white,
//               size: 16,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Low balance! Recharge to keep the call going.',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () => _showRechargeSheet(),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Recharge',
//                   style: TextStyle(
//                     color: Colors.orange.shade800,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Chat overlay ──────────────────────────────────────────────────────────
//   Widget _buildChatOverlay() {
//     return Positioned(
//       bottom: 80,
//       left: 16,
//       right: 80,
//       height: 180,
//       child: ListView.builder(
//         reverse: true,
//         itemCount: _chatMessages.length,
//         itemBuilder: (_, i) {
//           final msg =
//               _chatMessages[_chatMessages.length - 1 - i];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Text(
//               '${msg.isLocal ? 'You' : widget.host.displayName}: ${msg.text}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 shadows: [
//                   Shadow(blurRadius: 4, color: Colors.black87),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── Right side action buttons ─────────────────────────────────────────────
//   Widget _buildRightActions() {
//     return Positioned(
//       bottom: 90,
//       right: 16,
//       child: Column(
//         children: [
//           // Recharge / coins
//           _actionButton(
//             icon: Icons.monetization_on,
//             color: Colors.amber,
//             onTap: _showRechargeSheet,
//           ),
//           const SizedBox(height: 14),

//           // Gift
//           _actionButton(
//             icon: Icons.card_giftcard,
//             color: Colors.pinkAccent,
//             onTap: _showGiftSheet,
//           ),
//           const SizedBox(height: 14),

//           // Switch camera
//           _actionButton(
//             icon: Icons.cameraswitch_rounded,
//             color: Colors.white24,
//             onTap: _agora.switchCamera,
//           ),
//           const SizedBox(height: 14),

//           // Mute audio toggle
//           ValueListenableBuilder<bool>(
//             valueListenable: _agora.isAudioMuted,
//             builder: (_, muted, __) => _actionButton(
//               icon: muted
//                   ? Icons.mic_off_rounded
//                   : Icons.mic_rounded,
//               color: muted ? Colors.red : Colors.white24,
//               onTap: _agora.toggleMuteAudio,
//             ),
//           ),
//           const SizedBox(height: 14),

//           // Beauty effects
//           _actionButton(
//             icon: Icons.auto_fix_high_rounded,
//             color: Colors.purpleAccent.withValues(alpha: 0.8),
//             onTap: _showBeautySheet,
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Bottom chat input ─────────────────────────────────────────────────────
//   Widget _buildBottomInput() {
//     final bottomPad = MediaQuery.of(context).padding.bottom;
//     return Positioned(
//       bottom: bottomPad,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 8,
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _chatController,
//                 focusNode: _chatFocus,
//                 style: const TextStyle(color: Colors.white),
//                 onSubmitted: (_) => _sendChatMessage(),
//                 decoration: InputDecoration(
//                   hintText: 'Say something...',
//                   hintStyle: const TextStyle(
//                     color: Colors.white54,
//                   ),
//                   filled: true,
//                   fillColor: Colors.black45,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 12,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             GestureDetector(
//               onTap: _sendChatMessage,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: const BoxDecoration(
//                   color: Colors.pink,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.send_rounded,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Connecting overlay ────────────────────────────────────────────────────
//   Widget _buildConnectingOverlay() {
//     return Container(
//       color: Colors.black54,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const CircularProgressIndicator(color: Colors.pink),
//             const SizedBox(height: 20),
//             Text(
//               'Connecting to ${widget.host.displayName}...',
//               style: GoogleFonts.lato(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Error overlay ─────────────────────────────────────────────────────────
//   Widget _buildErrorOverlay() {
//     return Container(
//       color: Colors.black87,
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.redAccent,
//                 size: 48,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Could not connect',
//                 style: GoogleFonts.lato(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _errorMessage ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white60,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 28),
//               FilledButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.pink,
//                 ),
//                 child: const Text('Go Back'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Call ended summary overlay ────────────────────────────────────────────
//   Widget _buildCallEndedOverlay() {
//     return Container(
//       color: Colors.black87,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 32),
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1A2E),
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: Colors.pink.withValues(alpha: 0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.call_end,
//                   color: Colors.pink,
//                   size: 36,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Call Ended',
//                 style: GoogleFonts.lato(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'with ${widget.host.displayName}',
//                 style: const TextStyle(
//                   color: Colors.white54,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _summaryRow(
//                 Icons.timer_outlined,
//                 'Duration',
//                 _formattedDuration,
//               ),
//               const SizedBox(height: 10),
//               _summaryRow(
//                 Icons.monetization_on,
//                 'Coins Spent',
//                 '$_coinsSpent coins',
//               ),
//               const SizedBox(height: 10),
//               _summaryRow(
//                 Icons.account_balance_wallet_outlined,
//                 'Remaining',
//                 '$_coinsRemaining coins',
//               ),
//               const SizedBox(height: 28),
//               SizedBox(
//                 width: double.infinity,
//                 child: FilledButton(
//                   onPressed: () {
//                     SystemChrome.setEnabledSystemUIMode(
//                       SystemUiMode.edgeToEdge,
//                     );
//                     Navigator.of(context).pop();
//                   },
//                   style: FilledButton.styleFrom(
//                     backgroundColor: Colors.pink,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 14,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     'Done',
//                     style: GoogleFonts.lato(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Beauty effects sheet ─────────────────────────────────────────────────
//   void _showBeautySheet() {
//     // TODO: integrate Banuba or BytePlus SDK for real beauty effects
//     showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFF1A1A1A),
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(24),
//           ),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Beauty Effects',
//               style: GoogleFonts.lato(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _beautyOption(
//               Icons.face_retouching_natural,
//               'Smooth Skin',
//             ),
//             _beautyOption(Icons.wb_sunny_outlined, 'Brighten'),
//             _beautyOption(Icons.blur_on, 'Blur Background'),
//             _beautyOption(Icons.color_lens_outlined, 'Filters'),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//                 vertical: 10,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.purple.withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.purple.withValues(alpha: 0.3),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: Colors.purple,
//                     size: 16,
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Full beauty effects coming soon via Banuba SDK',
//                       style: TextStyle(
//                         color: Colors.white54,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _beautyOption(IconData icon, String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 13,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha: 0.05),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white10),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.purpleAccent, size: 20),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//             const Spacer(),
//             const Text(
//               'Coming soon',
//               style: TextStyle(
//                 color: Colors.white30,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Gift sheet ────────────────────────────────────────────────────────────
//   void _showGiftSheet() {
//     showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         height: MediaQuery.of(context).size.height * 0.52,
//         decoration: const BoxDecoration(
//           color: Color(0xFF1A1A1A),
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(24),
//           ),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 12),
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Send a Gift',
//               style: GoogleFonts.lato(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: GridView.builder(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                       childAspectRatio: 0.85,
//                     ),
//                 itemCount: GiftAssets.all.length,
//                 itemBuilder: (_, i) {
//                   final asset = GiftAssets.all[i];
//                   final name = asset
//                       .split('/')
//                       .last
//                       .replaceAll('.png', '')
//                       .replaceAll('_', ' ');
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                       // TODO: POST /api/gifts/send { hostId, giftAsset: asset }
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Gift sent! 🎁'),
//                           backgroundColor: Colors.pink,
//                           behavior: SnackBarBehavior.floating,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                               12,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     child: Column(
//                       mainAxisAlignment:
//                           MainAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Image.asset(
//                             asset,
//                             fit: BoxFit.contain,
//                             errorBuilder: (_, __, ___) =>
//                                 const Icon(
//                                   Icons.card_giftcard,
//                                   color: Colors.pink,
//                                   size: 32,
//                                 ),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           name,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Recharge sheet ────────────────────────────────────────────────────────
//   void _showRechargeSheet() {
//     showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFF1A1A1A),
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(24),
//           ),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Wallet Balance',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.monetization_on,
//                   color: Colors.amber,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _coinsRemaining.toString(),
//                   style: GoogleFonts.lato(
//                     color: Colors.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 36, color: Colors.white10),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Quick Recharge',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//             _rechargeOption(500, '₹49'),
//             _rechargeOption(1200, '₹99'),
//             _rechargeOption(3000, '₹249'),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _rechargeOption(int coins, String price) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: InkWell(
//         onTap: () {
//           Navigator.pop(context);
//           // TODO: launch Razorpay/Stripe payment flow
//           // On success: setState(() => _coinsRemaining += coins);
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.05),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white10),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.monetization_on,
//                     color: Colors.amber,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     '$coins Coins',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.amber,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   price,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Shared helpers ────────────────────────────────────────────────────────
//   Widget _glassChip({required Widget child, Color? color}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 7,
//       ),
//       decoration: BoxDecoration(
//         color: color ?? Colors.black54,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: child,
//     );
//   }

//   Widget _actionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 24),
//       ),
//     );
//   }

//   Widget _summaryRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.white38, size: 18),
//         const SizedBox(width: 10),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white54,
//             fontSize: 14,
//           ),
//         ),
//         const Spacer(),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // Pulsing dots — shown while waiting for host to join
// // ---------------------------------------------------------------------------
// class _PulsingDots extends StatefulWidget {
//   const _PulsingDots();

//   @override
//   State<_PulsingDots> createState() => _PulsingDotsState();
// }

// class _PulsingDotsState extends State<_PulsingDots>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _ctrl,
//       child: Text(
//         'Connecting...',
//         style: GoogleFonts.lato(
//           color: Colors.white60,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // Internal chat message model
// // ---------------------------------------------------------------------------
// class _ChatMessage {
//   const _ChatMessage({
//     required this.text,
//     required this.isLocal,
//   });
//   final String text;
//   final bool isLocal;
// }
import 'dart:async';

import 'package:cheerchat/constants/app_constants.dart';
import 'package:cheerchat/constants/gift_constants.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/services/agora_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// OngoingCallScreen
//
// Entry point — caller passes host + their current coin balance + Agora creds.
// The screen owns AgoraService lifecycle entirely (creates → joins → disposes).
//
// How to push this screen:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => OngoingCallScreen(
//       host: host,
//       initialCoins: userCoins,
//       channelId: 'channel_abc',
//       token: 'agora_token_from_server',
//       localUid: myUid,
//     ),
//   ));
// ---------------------------------------------------------------------------
class OngoingCallScreen extends StatefulWidget {
  const OngoingCallScreen({
    super.key,
    required this.host,
    required this.initialCoins,
    this.channelId = 'test_channel',
    this.token = 'test_token',
    this.localUid = 0,
    this.testMode = false,
    this.isAlreadyFollowing = false,
  });

  final HostModel host;

  /// User's current wallet balance — used for local UI display only.
  /// Real deduction happens server-side via Node.js billing ticks.
  final int initialCoins;

  final String channelId;
  final String token;
  final int localUid;

  /// When true: skips Agora entirely, simulates a connected call after 2s.
  /// Use this to test the UI without a real Agora App ID or token.
  final bool testMode;

  /// If user already follows this host before joining the call,
  /// the follow button is hidden entirely.
  final bool isAlreadyFollowing;

  @override
  State<OngoingCallScreen> createState() =>
      _OngoingCallScreenState();
}

class _OngoingCallScreenState extends State<OngoingCallScreen>
    with WidgetsBindingObserver {
  // ── Agora ────────────────────────────────────────────────────────────────
  late final AgoraService _agora;

  // ── Call state ───────────────────────────────────────────────────────────
  bool _isConnecting = true;
  bool _callEnded = false;
  String? _errorMessage;

  // ── Timer & coins ────────────────────────────────────────────────────────
  Timer? _durationTimer;
  Timer? _coinDrainTimer;
  int _elapsedSeconds = 0;
  late int _coinsRemaining;

  // ── UI state ─────────────────────────────────────────────────────────────
  bool _uiVisible = true;
  late bool _isFollowed;
  Offset _pipOffset = const Offset(20, 120);

  // Chat overlay messages (live chat during call — stub list for now)
  // TODO: wire up real Firestore messages for the call channel
  final List<_ChatMessage> _chatMessages = [];
  final TextEditingController _chatController =
      TextEditingController();
  final FocusNode _chatFocus = FocusNode();

  // ── Getters ──────────────────────────────────────────────────────────────
  bool get _isLowCoins =>
      _coinsRemaining <
      widget.host.priceCoins *
          AppConstants.lowCoinWarningMinutes;

  String get _formattedDuration {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _coinsSpent => widget.initialCoins - _coinsRemaining;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coinsRemaining = widget.initialCoins;
    _isFollowed = widget.isAlreadyFollowing;
    _agora = AgoraService(
      onBillableSessionStart: _onBillableSessionStart,
      onBillableSessionEnd: _onBillableSessionEnd,
    );
    _startCall();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _coinDrainTimer?.cancel();
    _chatController.dispose();
    _chatFocus.dispose();
    _agora.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause local video when app goes to background
    if (state == AppLifecycleState.paused) {
      _agora.toggleMuteVideo();
    } else if (state == AppLifecycleState.resumed) {
      // Re-enable if it was muted by lifecycle only
    }
  }

  // ── Agora init ───────────────────────────────────────────────────────────
  Future<void> _startCall() async {
    if (widget.testMode) {
      // Test mode: skip Agora, simulate host joining after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isConnecting = false);
      _onBillableSessionStart();
      return;
    }

    // Real mode
    try {
      await _agora.initialize(
        appId: AppConstants.agoraAppId,
        fetchNewToken: () async {
          // TODO: GET /api/calls/token?channel=channelId
          return widget.token;
        },
      );
      await _agora.join(
        token: widget.token,
        channelId: widget.channelId,
        uid: widget.localUid,
      );
      _agora.remoteUids.addListener(_onRemoteUidsChanged);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  void _onRemoteUidsChanged() {
    if (_agora.remoteUids.value.isNotEmpty && _isConnecting) {
      if (mounted) setState(() => _isConnecting = false);
    }
    if (_agora.remoteUids.value.isEmpty &&
        !_isConnecting &&
        !_callEnded) {
      // Host left — end call
      _endCall(hostLeft: true);
    }
  }

  // ── Billing callbacks (fired by AgoraService) ────────────────────────────
  void _onBillableSessionStart() {
    // Tick duration every second
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    // Deduct immediately at 0:00 the moment host joins
    _deductCoins();

    // Then deduct again every 60 seconds (at 1:00, 2:00, 3:00 ...)
    _coinDrainTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        if (!mounted) return;
        _deductCoins();
      },
    );
  }

  void _deductCoins() {
    if (!mounted) return;
    setState(() {
      _coinsRemaining =
          (_coinsRemaining - widget.host.priceCoins).clamp(
            0,
            9999999,
          );
    });
    if (_coinsRemaining <= 0) _endCall(outOfCoins: true);
  }

  void _onBillableSessionEnd() {
    _durationTimer?.cancel();
    _coinDrainTimer?.cancel();
  }

  // ── End call ──────────────────────────────────────────────────────────────
  Future<void> _endCall({
    bool hostLeft = false,
    bool outOfCoins = false,
  }) async {
    if (_callEnded) return;
    _durationTimer?.cancel();
    _coinDrainTimer?.cancel();
    if (!widget.testMode) await _agora.leave();
    if (mounted) setState(() => _callEnded = true);
    // TODO: POST /api/calls/end { channelId, duration: _elapsedSeconds }
  }

  // ── Chat ──────────────────────────────────────────────────────────────────
  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add(_ChatMessage(text: text, isLocal: true));
    });
    _chatController.clear();
    // TODO: send via Firestore call-channel subcollection
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Keep status bar hidden during call
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    return PopScope(
      canPop: false, // Back gesture must go through _endCall
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _endCall();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            final keyboardOpen =
                MediaQuery.of(context).viewInsets.bottom > 0;
            if (keyboardOpen) {
              _chatFocus.unfocus();
            } else {
              setState(() => _uiVisible = !_uiVisible);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // ── Layer 1: Remote video (full screen) ──────────────────────
              _buildRemoteVideo(),

              // ── Layer 2: Draggable local PIP ─────────────────────────────
              _buildPip(),

              // ── Layer 3: Hideable HUD ─────────────────────────────────────
              if (_uiVisible && !_callEnded) ...[
                _buildTopBar(),
                _buildChatOverlay(),
                _buildRightActions(),
                _buildBottomInput(),
              ],

              // ── Layer 4: Connecting overlay ───────────────────────────────
              if (_isConnecting && !_callEnded)
                _buildConnectingOverlay(),

              // ── Layer 5: Error overlay ────────────────────────────────────
              if (_errorMessage != null) _buildErrorOverlay(),

              // ── Layer 6: Call ended summary ───────────────────────────────
              if (_callEnded) _buildCallEndedOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Remote video ──────────────────────────────────────────────────────────
  Widget _buildRemoteVideo() {
    // Test mode: show a solid background with host avatar instead of real video
    if (widget.testMode) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: _isConnecting
            ? null
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 72,
                      backgroundColor: Colors.pink.withValues(
                        alpha: 0.2,
                      ),
                      backgroundImage:
                          widget.host.profilePhotoUrl != null
                          ? NetworkImage(
                              widget.host.profilePhotoUrl!,
                            )
                          : null,
                      child: widget.host.profilePhotoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 72,
                              color: Colors.white38,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.host.displayName,
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '[ Test Mode — No real video ]',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      );
    }

    return ValueListenableBuilder<Set<int>>(
      valueListenable: _agora.remoteUids,
      builder: (_, uids, __) {
        if (uids.isEmpty) {
          return Container(
            color: const Color(0xFF1A1A2E),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.host.profilePhotoUrl != null)
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(
                        widget.host.profilePhotoUrl!,
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.pink.withValues(
                        alpha: 0.3,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 56,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    widget.host.displayName,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _PulsingDots(),
                ],
              ),
            ),
          );
        }
        return SizedBox.expand(
          child: _agora.buildRemoteVideo(uids.first),
        );
      },
    );
  }

  // ── Local PIP ─────────────────────────────────────────────────────────────
  Widget _buildPip() {
    return Positioned(
      left: _pipOffset.dx,
      top: _pipOffset.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          final size = MediaQuery.of(context).size;
          setState(() {
            _pipOffset = Offset(
              (_pipOffset.dx + d.delta.dx).clamp(
                0,
                size.width - 110,
              ),
              (_pipOffset.dy + d.delta.dy).clamp(
                0,
                size.height - 150,
              ),
            );
          });
        },
        child: Container(
          width: 110,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white30,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(blurRadius: 12, color: Colors.black54),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.testMode
              ? Container(
                  color: const Color(0xFF2A2A2A),
                  child: const Center(
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white30,
                      size: 28,
                    ),
                  ),
                )
              : _agora.buildLocalVideo(),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final safePad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: safePad + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Host info chip — name, age, country flag + optional follow button
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                if (widget.host.profilePhotoUrl != null)
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      widget.host.profilePhotoUrl!,
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.pink,
                    child: Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(width: 9),

                // Name + age + country
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.host.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.host.countryCode.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                        if (widget.host.age != null) ...[
                          const Text(
                            '  ·  ',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${widget.host.age} yrs',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                // Follow button — hidden if already following before call
                if (!widget.isAlreadyFollowing) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isFollowed = !_isFollowed);
                      // TODO: POST /api/follows { host_id: widget.host.userId }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isFollowed
                            ? Colors.white.withValues(
                                alpha: 0.15,
                              )
                            : Colors.pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isFollowed ? 'Following' : 'Follow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Live timer
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedDuration,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // End call
          GestureDetector(
            onTap: () => _endCall(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Coin bar ──────────────────────────────────────────────────────────────
  Widget _buildCoinBar() {
    final safePad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: safePad + 68,
      left: 16,
      child: _glassChip(
        color: _isLowCoins
            ? Colors.red.withValues(alpha: 0.6)
            : Colors.black54,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              _coinsRemaining.toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              '  •  ${widget.host.priceCoins}/min',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Low coin warning ──────────────────────────────────────────────────────
  Widget _buildLowCoinBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 108,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.shade800.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Low balance! Recharge to keep the call going.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showRechargeSheet(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Recharge',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chat overlay ──────────────────────────────────────────────────────────
  Widget _buildChatOverlay() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 80,
      height: 180,
      child: ListView.builder(
        reverse: true,
        itemCount: _chatMessages.length,
        itemBuilder: (_, i) {
          final msg =
              _chatMessages[_chatMessages.length - 1 - i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${msg.isLocal ? 'You' : widget.host.displayName}: ${msg.text}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black87),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Right side action buttons ─────────────────────────────────────────────
  Widget _buildRightActions() {
    return Positioned(
      bottom: 90,
      right: 16,
      child: Column(
        children: [
          // Recharge / coins
          _actionButton(
            icon: Icons.monetization_on,
            color: Colors.amber,
            onTap: _showRechargeSheet,
          ),
          const SizedBox(height: 14),

          // Gift
          _actionButton(
            icon: Icons.card_giftcard,
            color: Colors.pinkAccent,
            onTap: _showGiftSheet,
          ),
          const SizedBox(height: 14),

          // Switch camera
          _actionButton(
            icon: Icons.cameraswitch_rounded,
            color: Colors.white24,
            onTap: _agora.switchCamera,
          ),
          const SizedBox(height: 14),

          // Mute audio toggle
          ValueListenableBuilder<bool>(
            valueListenable: _agora.isAudioMuted,
            builder: (_, muted, __) => _actionButton(
              icon: muted
                  ? Icons.mic_off_rounded
                  : Icons.mic_rounded,
              color: muted ? Colors.red : Colors.white24,
              onTap: _agora.toggleMuteAudio,
            ),
          ),
          const SizedBox(height: 14),

          // Beauty effects
          _actionButton(
            icon: Icons.auto_fix_high_rounded,
            color: Colors.purpleAccent.withValues(alpha: 0.8),
            onTap: _showBeautySheet,
          ),
        ],
      ),
    );
  }

  // ── Bottom chat input ─────────────────────────────────────────────────────
  Widget _buildBottomInput() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomPad,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                focusNode: _chatFocus,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _sendChatMessage(),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: Colors.black45,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendChatMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Connecting overlay ────────────────────────────────────────────────────
  Widget _buildConnectingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.pink),
            const SizedBox(height: 20),
            Text(
              'Connecting to ${widget.host.displayName}...',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error overlay ─────────────────────────────────────────────────────────
  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not connect',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Call ended summary overlay ────────────────────────────────────────────
  Widget _buildCallEndedOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.pink,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Call Ended',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'with ${widget.host.displayName}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _summaryRow(
                Icons.timer_outlined,
                'Duration',
                _formattedDuration,
              ),
              const SizedBox(height: 10),
              _summaryRow(
                Icons.monetization_on,
                'Coins Spent',
                '$_coinsSpent coins',
              ),
              const SizedBox(height: 10),
              _summaryRow(
                Icons.account_balance_wallet_outlined,
                'Remaining',
                '$_coinsRemaining coins',
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Beauty effects sheet ─────────────────────────────────────────────────
  void _showBeautySheet() {
    // TODO: integrate Banuba or BytePlus SDK for real beauty effects
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Beauty Effects',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _beautyOption(
              Icons.face_retouching_natural,
              'Smooth Skin',
            ),
            _beautyOption(Icons.wb_sunny_outlined, 'Brighten'),
            _beautyOption(Icons.blur_on, 'Blur Background'),
            _beautyOption(Icons.color_lens_outlined, 'Filters'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Full beauty effects coming soon via Banuba SDK',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _beautyOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Text(
              'Coming soon',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gift sheet ────────────────────────────────────────────────────────────
  void _showGiftSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.52,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Send a Gift',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                itemCount: GiftAssets.all.length,
                itemBuilder: (_, i) {
                  final asset = GiftAssets.all[i];
                  final name = asset
                      .split('/')
                      .last
                      .replaceAll('.png', '')
                      .replaceAll('_', ' ');
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: POST /api/gifts/send { hostId, giftAsset: asset }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gift sent! 🎁'),
                          backgroundColor: Colors.pink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            asset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(
                                  Icons.card_giftcard,
                                  color: Colors.pink,
                                  size: 32,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Recharge sheet ────────────────────────────────────────────────────────
  void _showRechargeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Wallet Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  _coinsRemaining.toString(),
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 36, color: Colors.white10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Recharge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _rechargeOption(500, '₹49'),
            _rechargeOption(1200, '₹99'),
            _rechargeOption(3000, '₹249'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _rechargeOption(int coins, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // TODO: launch Razorpay/Stripe payment flow
          // On success: setState(() => _coinsRemaining += coins);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$coins Coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _glassChip({required Widget child, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing dots — shown while waiting for host to join
// ---------------------------------------------------------------------------
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Text(
        'Connecting...',
        style: GoogleFonts.lato(
          color: Colors.white60,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal chat message model
// ---------------------------------------------------------------------------
class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isLocal,
  });
  final String text;
  final bool isLocal;
}

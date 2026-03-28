// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/outgoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/providers/follow_provider.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     // ref.read(followStateProvider(widget.host.userId).notifier).toggle();
// //     ref
// //         .read(followNotifierProvider.notifier)
// //         .toggle(widget.host.userId);
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final walletState = ref.read(walletBalanceProvider);
// //       final coins = walletState.asData?.value.coinBalance;

// //       // Only do local check if wallet is loaded — otherwise let server validate
// //       if (coins != null && coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(
// //         hostId: widget.host.userId,
// //       );

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OutgoingCallScreen — waits for host to accept
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OutgoingCallScreen(
// //               host: widget.host.copyWith(
// //                 priceCoins: pricePerMinute,
// //               ),
// //               initialCoins: coins ?? 0,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               callerUid: callerUid,
// //               isAlreadyFollowing: ref.read(
// //                 followStateProvider(widget.host.userId),
// //               ),
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar(
// //           'Connection error. Please try again.',
// //           isError: true,
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         backgroundColor: isError
// //             ? Colors.red.shade700
// //             : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //     final isFollowed = ref.watch(
// //       followStateProvider(widget.host.userId),
// //     );
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(isFollowed),
// //               color: isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(
// //             13.0,
// //             18.0,
// //           );

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [Color(0xCC000000), Color(0x00000000)],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip(
// //                               'Lv ${widget.host.level}',
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder:
// //                       (
// //                         flightContext,
// //                         animation,
// //                         flightDirection,
// //                         fromHeroContext,
// //                         toHeroContext,
// //                       ) {
// //                         return FadeTransition(
// //                           opacity: animation,
// //                           child: toHeroContext.widget,
// //                         );
// //                       },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // // // // // lib/widgets/cards/host_card.dart
// // // // // // //
// // // // // // // Host card used in HostsGridViewScreen.
// // // // // // //
// // // // // // // Animations in this file:
// // // // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // // // //
// // // // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // // // import 'dart:math';

// // // // // // import 'package:cheerchat/models/host_model.dart';
// // // // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // // // import 'package:flag/flag_widget.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart';
// // // // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // // // import 'package:google_fonts/google_fonts.dart';

// // // // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // // // Widget _ageChip(int age) => Container(
// // // // // //   padding: const EdgeInsets.all(3.5),
// // // // // //   decoration: const BoxDecoration(
// // // // // //     shape: BoxShape.circle,
// // // // // //     gradient: LinearGradient(
// // // // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // // // //     ),
// // // // // //   ),
// // // // // //   child: Text(
// // // // // //     '$age',
// // // // // //     style: const TextStyle(
// // // // // //       fontSize: 8,
// // // // // //       fontWeight: FontWeight.bold,
// // // // // //       color: Colors.white,
// // // // // //     ),
// // // // // //   ),
// // // // // // );

// // // // // // Widget _levelChip(String level) => Container(
// // // // // //   padding: const EdgeInsets.symmetric(
// // // // // //     horizontal: 6,
// // // // // //     vertical: 3,
// // // // // //   ),
// // // // // //   decoration: BoxDecoration(
// // // // // //     borderRadius: BorderRadius.circular(8),
// // // // // //     gradient: const LinearGradient(
// // // // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // // // //     ),
// // // // // //   ),
// // // // // //   child: Text(
// // // // // //     level,
// // // // // //     style: GoogleFonts.lato(
// // // // // //       color: Colors.white,
// // // // // //       fontWeight: FontWeight.bold,
// // // // // //       fontSize: 8,
// // // // // //     ),
// // // // // //   ),
// // // // // // );

// // // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // // class HostCard extends StatefulWidget {
// // // // // //   const HostCard({required this.host, super.key});
// // // // // //   final HostModel host;

// // // // // //   @override
// // // // // //   State<HostCard> createState() => _HostCardState();
// // // // // // }

// // // // // // class _HostCardState extends State<HostCard>
// // // // // //     with TickerProviderStateMixin {
// // // // // //   bool _isFollowed = false;
// // // // // //   late int _age;

// // // // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // // // //   // Uses two separate controllers so press-in and release can have different
// // // // // //   // curves and durations (snappy down, springy up).
// // // // // //   late final AnimationController _pressCtrl;
// // // // // //   late final Animation<double> _pressScale;

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // // // //     _pressCtrl = AnimationController(
// // // // // //       vsync: this,
// // // // // //       duration: const Duration(milliseconds: 110),
// // // // // //       reverseDuration: const Duration(milliseconds: 220),
// // // // // //     );
// // // // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // // // //       CurvedAnimation(
// // // // // //         parent: _pressCtrl,
// // // // // //         curve: Curves.easeInOut,
// // // // // //         reverseCurve: Curves.elasticOut,
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _pressCtrl.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // // // //   void _toggleFollow() =>
// // // // // //       setState(() => _isFollowed = !_isFollowed);

// // // // // //   void _onCardTap() {
// // // // // //     Navigator.of(context, rootNavigator: true).push(
// // // // // //       AppTransitions.heroFade(
// // // // // //         ProfileDetailsScreen(host: widget.host),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   void _onCallTap() {
// // // // // //     HapticFeedback.mediumImpact();
// // // // // //     switch (widget.host.status) {
// // // // // //       case HostStatus.online:
// // // // // //         Navigator.of(context, rootNavigator: true).push(
// // // // // //           AppTransitions.scaleUp(
// // // // // //             OngoingCallScreen(
// // // // // //               host: widget.host,
// // // // // //               initialCoins: 1000,
// // // // // //               testMode: true,
// // // // // //               isAlreadyFollowing: false,
// // // // // //             ),
// // // // // //           ),
// // // // // //         );
// // // // // //         break;
// // // // // //       case HostStatus.busy:
// // // // // //         _autoQueue();
// // // // // //         break;
// // // // // //       case HostStatus.offline:
// // // // // //         break;
// // // // // //     }
// // // // // //   }

// // // // // //   void _autoQueue() {
// // // // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // // // //     final c = AppColors.of(context);
// // // // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // // //       SnackBar(
// // // // // //         content: Row(
// // // // // //           children: [
// // // // // //             const Icon(
// // // // // //               Icons.notifications_active_outlined,
// // // // // //               color: Colors.white,
// // // // // //               size: 18,
// // // // // //             ),
// // // // // //             const SizedBox(width: 10),
// // // // // //             Expanded(
// // // // // //               child: Text(
// // // // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // // // //                 style: const TextStyle(color: Colors.white),
// // // // // //               ),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //         backgroundColor: c.card,
// // // // // //         behavior: SnackBarBehavior.floating,
// // // // // //         duration: const Duration(seconds: 3),
// // // // // //         shape: RoundedRectangleBorder(
// // // // // //           borderRadius: BorderRadius.circular(12),
// // // // // //           side: BorderSide(color: c.border),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // // // //   Widget _statusDot() {
// // // // // //     return AnimatedContainer(
// // // // // //       duration: const Duration(milliseconds: 300),
// // // // // //       width: 10,
// // // // // //       height: 10,
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: getStatusColor(widget.host.status),
// // // // // //         shape: BoxShape.circle,
// // // // // //         border: Border.all(color: Colors.white24, width: 1),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _flagWidget() {
// // // // // //     try {
// // // // // //       return SizedBox(
// // // // // //         height: 16,
// // // // // //         width: 22,
// // // // // //         child: Flag.fromCode(
// // // // // //           widget.host.flagCode,
// // // // // //           fit: BoxFit.cover,
// // // // // //         ),
// // // // // //       );
// // // // // //     } catch (_) {
// // // // // //       return const Icon(
// // // // // //         Icons.language,
// // // // // //         color: Colors.white,
// // // // // //         size: 16,
// // // // // //       );
// // // // // //     }
// // // // // //   }

// // // // // //   Widget _backgroundImage() {
// // // // // //     final url = widget.host.profilePhotoUrl;
// // // // // //     if (url == null || url.isEmpty) {
// // // // // //       return Image.asset(
// // // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // // //         fit: BoxFit.cover,
// // // // // //       );
// // // // // //     }
// // // // // //     return Image.network(
// // // // // //       url,
// // // // // //       fit: BoxFit.cover,
// // // // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // // //         fit: BoxFit.cover,
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // // // //   Widget _followButton() {
// // // // // //     return Material(
// // // // // //       color: Colors.transparent,
// // // // // //       child: InkWell(
// // // // // //         onTap: () {
// // // // // //           HapticFeedback.lightImpact();
// // // // // //           _toggleFollow();
// // // // // //         },
// // // // // //         borderRadius: BorderRadius.circular(100),
// // // // // //         child: Padding(
// // // // // //           padding: const EdgeInsets.all(4),
// // // // // //           child: AnimatedSwitcher(
// // // // // //             duration: const Duration(milliseconds: 200),
// // // // // //             transitionBuilder: (child, animation) =>
// // // // // //                 ScaleTransition(scale: animation, child: child),
// // // // // //             child: FaIcon(
// // // // // //               _isFollowed
// // // // // //                   ? FontAwesomeIcons.solidHeart
// // // // // //                   : FontAwesomeIcons.heart,
// // // // // //               key: ValueKey(_isFollowed),
// // // // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // // // //               size: 23,
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // // // //   Widget _bottomOverlay(AppColors c) {
// // // // // //     return Positioned(
// // // // // //       left: 0,
// // // // // //       right: 0,
// // // // // //       bottom: 0,
// // // // // //       child: LayoutBuilder(
// // // // // //         builder: (context, constraints) {
// // // // // //           // Responsive font: scales 13–18 based on card width so it never
// // // // // //           // overflows on high-DPI or narrow screens.
// // // // // //           final cardWidth = constraints.maxWidth;
// // // // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // // // //             13.0,
// // // // // //             18.0,
// // // // // //           );

// // // // // //           return Container(
// // // // // //             padding: const EdgeInsets.symmetric(
// // // // // //               vertical: 10,
// // // // // //               horizontal: 12,
// // // // // //             ),
// // // // // //             decoration: const BoxDecoration(
// // // // // //               gradient: LinearGradient(
// // // // // //                 begin: Alignment.bottomCenter,
// // // // // //                 end: Alignment.topCenter,
// // // // // //                 colors: [
// // // // // //                   Color(0xCC000000), // 80% black at bottom
// // // // // //                   Color(0x00000000), // transparent at top
// // // // // //                 ],
// // // // // //                 stops: [0.0, 1.0],
// // // // // //               ),
// // // // // //             ),
// // // // // //             child: Row(
// // // // // //               children: [
// // // // // //                 Expanded(
// // // // // //                   child: Column(
// // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                     children: [
// // // // // //                       // Name row
// // // // // //                       Row(
// // // // // //                         children: [
// // // // // //                           _statusDot(),
// // // // // //                           const SizedBox(width: 4),
// // // // // //                           Expanded(
// // // // // //                             child: Text(
// // // // // //                               widget.host.displayName,
// // // // // //                               maxLines: 1,
// // // // // //                               overflow: TextOverflow.ellipsis,
// // // // // //                               style: GoogleFonts.lato(
// // // // // //                                 color: Colors.white,
// // // // // //                                 fontWeight: FontWeight.bold,
// // // // // //                                 fontSize: nameFontSize,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 4),
// // // // // //                       // Chips row — FittedBox prevents overflow on any density
// // // // // //                       FittedBox(
// // // // // //                         fit: BoxFit.scaleDown,
// // // // // //                         alignment: Alignment.centerLeft,
// // // // // //                         child: Row(
// // // // // //                           crossAxisAlignment:
// // // // // //                               CrossAxisAlignment.center,
// // // // // //                           children: [
// // // // // //                             _flagWidget(),
// // // // // //                             const SizedBox(width: 8),
// // // // // //                             _ageChip(_age),
// // // // // //                             const SizedBox(width: 8),
// // // // // //                             _levelChip(
// // // // // //                               'Lv ${widget.host.level}',
// // // // // //                             ),
// // // // // //                           ],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const SizedBox(width: 8),
// // // // // //                 // Video call button
// // // // // //                 Material(
// // // // // //                   color: c.pink,
// // // // // //                   shape: const CircleBorder(),
// // // // // //                   clipBehavior: Clip.hardEdge,
// // // // // //                   child: InkWell(
// // // // // //                     onTap: _onCallTap,
// // // // // //                     child: const Padding(
// // // // // //                       padding: EdgeInsets.all(10),
// // // // // //                       child: FaIcon(
// // // // // //                         FontAwesomeIcons.video,
// // // // // //                         color: Colors.white,
// // // // // //                         size: 25,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     final c = AppColors.of(context);
// // // // // //     final isDark =
// // // // // //         Theme.of(context).brightness == Brightness.dark;

// // // // // //     return ScaleTransition(
// // // // // //       scale: _pressScale,
// // // // // //       child: Container(
// // // // // //         decoration: BoxDecoration(
// // // // // //           borderRadius: BorderRadius.circular(12),
// // // // // //           border: isDark
// // // // // //               ? Border.all(
// // // // // //                   color: c.pink.withValues(alpha: 0.55),
// // // // // //                   width: 1.5,
// // // // // //                 )
// // // // // //               : null,
// // // // // //         ),
// // // // // //         child: ClipRRect(
// // // // // //           borderRadius: BorderRadius.circular(10.5),
// // // // // //           child: GestureDetector(
// // // // // //             behavior: HitTestBehavior.opaque,
// // // // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // // // //             onTap: _onCardTap,
// // // // // //             onDoubleTap: _toggleFollow,
// // // // // //             child: Stack(
// // // // // //               fit: StackFit.expand,
// // // // // //               children: [
// // // // // //                 // ── Photo background — Hero source ───────────────────────
// // // // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // // // //                 Hero(
// // // // // //                   tag: 'host_photo_${widget.host.userId}',
// // // // // //                   flightShuttleBuilder:
// // // // // //                       (
// // // // // //                         flightContext,
// // // // // //                         animation,
// // // // // //                         flightDirection,
// // // // // //                         fromHeroContext,
// // // // // //                         toHeroContext,
// // // // // //                       ) {
// // // // // //                         // Fade between the two hero states during flight
// // // // // //                         return FadeTransition(
// // // // // //                           opacity: animation,
// // // // // //                           child: toHeroContext.widget,
// // // // // //                         );
// // // // // //                       },
// // // // // //                   child: _backgroundImage(),
// // // // // //                 ),

// // // // // //                 // ── Follow / heart button ────────────────────────────────
// // // // // //                 Positioned(
// // // // // //                   top: 8,
// // // // // //                   right: 8,
// // // // // //                   child: _followButton(),
// // // // // //                 ),

// // // // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // // // //                 _bottomOverlay(c),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // // lib/widgets/cards/host_card.dart
// // // // // //
// // // // // // Host card used in HostsGridViewScreen.
// // // // // //
// // // // // // ✅ WIRED TO BACKEND:
// // // // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // // // //   - Busy host → CallApiService.joinQueue()
// // // // // //   - Follow heart → SocialService.follow()/unfollow()
// // // // // //   - Reads wallet balance from walletBalanceProvider
// // // // // //
// // // // // // Animations (unchanged):
// // // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // // // import 'dart:math';

// // // // // import 'package:cheerchat/models/host_model.dart';
// // // // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // // import 'package:cheerchat/services/call_api_service.dart';
// // // // // import 'package:cheerchat/services/social_service.dart';
// // // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // // import 'package:flag/flag_widget.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';

// // // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // // Widget _ageChip(int age) => Container(
// // // // //   padding: const EdgeInsets.all(3.5),
// // // // //   decoration: const BoxDecoration(
// // // // //     shape: BoxShape.circle,
// // // // //     gradient: LinearGradient(
// // // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     '$age',
// // // // //     style: const TextStyle(
// // // // //       fontSize: 8,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       color: Colors.white,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // Widget _levelChip(String level) => Container(
// // // // //   padding: const EdgeInsets.symmetric(
// // // // //     horizontal: 6,
// // // // //     vertical: 3,
// // // // //   ),
// // // // //   decoration: BoxDecoration(
// // // // //     borderRadius: BorderRadius.circular(8),
// // // // //     gradient: const LinearGradient(
// // // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     level,
// // // // //     style: GoogleFonts.lato(
// // // // //       color: Colors.white,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       fontSize: 8,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // class HostCard extends ConsumerStatefulWidget {
// // // // //   const HostCard({required this.host, super.key});
// // // // //   final HostModel host;

// // // // //   @override
// // // // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // // // }

// // // // // class _HostCardState extends ConsumerState<HostCard>
// // // // //     with TickerProviderStateMixin {
// // // // //   bool _isFollowed = false;
// // // // //   bool _isStartingCall = false;
// // // // //   late int _age;

// // // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // // //   late final AnimationController _pressCtrl;
// // // // //   late final Animation<double> _pressScale;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // // //     _pressCtrl = AnimationController(
// // // // //       vsync: this,
// // // // //       duration: const Duration(milliseconds: 110),
// // // // //       reverseDuration: const Duration(milliseconds: 220),
// // // // //     );
// // // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // // //       CurvedAnimation(
// // // // //         parent: _pressCtrl,
// // // // //         curve: Curves.easeInOut,
// // // // //         reverseCurve: Curves.elasticOut,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _pressCtrl.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // // //   void _toggleFollow() {
// // // // //     HapticFeedback.lightImpact();
// // // // //     final wasFollowed = _isFollowed;
// // // // //     setState(() => _isFollowed = !_isFollowed);

// // // // //     // Fire API call — revert on failure
// // // // //     final social = ref.read(socialServiceProvider);
// // // // //     final future = _isFollowed
// // // // //         ? social.follow(widget.host.userId)
// // // // //         : social.unfollow(widget.host.userId);

// // // // //     future.then((ok) {
// // // // //       if (!ok && mounted) {
// // // // //         setState(() => _isFollowed = wasFollowed);
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   void _onCardTap() {
// // // // //     Navigator.of(context, rootNavigator: true).push(
// // // // //       AppTransitions.heroFade(
// // // // //         ProfileDetailsScreen(host: widget.host),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Future<void> _onCallTap() async {
// // // // //     HapticFeedback.mediumImpact();

// // // // //     switch (widget.host.status) {
// // // // //       case HostStatus.online:
// // // // //         await _startCallFlow();
// // // // //         break;
// // // // //       case HostStatus.busy:
// // // // //         _autoQueue();
// // // // //         break;
// // // // //       case HostStatus.offline:
// // // // //         break;
// // // // //     }
// // // // //   }

// // // // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // // // //   Future<void> _startCallFlow() async {
// // // // //     if (_isStartingCall) return; // prevent double-tap
// // // // //     setState(() => _isStartingCall = true);

// // // // //     try {
// // // // //       // 1. Check local coin balance first (quick fail)
// // // // //       final coins = ref.read(coinBalanceProvider);
// // // // //       if (coins < widget.host.priceCoins) {
// // // // //         if (mounted) {
// // // // //           _showSnackBar(
// // // // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // // // //             isError: true,
// // // // //           );
// // // // //         }
// // // // //         return;
// // // // //       }

// // // // //       // 2. Call the backend to start the call session
// // // // //       final callApi = ref.read(callApiServiceProvider);
// // // // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // // // //       if (!mounted) return;

// // // // //       if (!res.ok) {
// // // // //         // Handle specific errors
// // // // //         final error = res.error ?? 'Could not start call';
// // // // //         if (res.statusCode == 409) {
// // // // //           // Host became busy between grid load and tap
// // // // //           _autoQueue();
// // // // //         } else if (res.statusCode == 400 &&
// // // // //             error.contains('Insufficient')) {
// // // // //           _showSnackBar(
// // // // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // // // //             isError: true,
// // // // //           );
// // // // //         } else {
// // // // //           _showSnackBar(error, isError: true);
// // // // //         }
// // // // //         return;
// // // // //       }

// // // // //       // 3. Extract server response
// // // // //       final sessionId = res.data['session_id'] as String;
// // // // //       final channelName = res.data['channel_name'] as String;
// // // // //       final callerToken = res.data['caller_token'] as String;
// // // // //       final callerUid = res.data['caller_uid'] as int;
// // // // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // // // //       // 4. Push OngoingCallScreen with REAL server values
// // // // //       if (mounted) {
// // // // //         Navigator.of(context, rootNavigator: true).push(
// // // // //           AppTransitions.scaleUp(
// // // // //             OngoingCallScreen(
// // // // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // // // //               initialCoins: coins,
// // // // //               sessionId: sessionId,
// // // // //               channelId: channelName,
// // // // //               token: callerToken,
// // // // //               localUid: callerUid,
// // // // //               isAlreadyFollowing: _isFollowed,
// // // // //             ),
// // // // //           ),
// // // // //         );

// // // // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // // // //         ref.read(walletBalanceProvider.notifier).refresh();
// // // // //       }
// // // // //     } catch (e) {
// // // // //       if (mounted) {
// // // // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // // // //       }
// // // // //     } finally {
// // // // //       if (mounted) setState(() => _isStartingCall = false);
// // // // //     }
// // // // //   }

// // // // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // // // //   void _autoQueue() {
// // // // //     final callApi = ref.read(callApiServiceProvider);
// // // // //     callApi.joinQueue(widget.host.userId);

// // // // //     final c = AppColors.of(context);
// // // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Row(
// // // // //           children: [
// // // // //             const Icon(
// // // // //               Icons.notifications_active_outlined,
// // // // //               color: Colors.white,
// // // // //               size: 18,
// // // // //             ),
// // // // //             const SizedBox(width: 10),
// // // // //             Expanded(
// // // // //               child: Text(
// // // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // // //                 style: const TextStyle(color: Colors.white),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         backgroundColor: c.card,
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         duration: const Duration(seconds: 3),
// // // // //         shape: RoundedRectangleBorder(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           side: BorderSide(color: c.border),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _showSnackBar(String message, {bool isError = false}) {
// // // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // // // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         duration: const Duration(seconds: 3),
// // // // //         shape: RoundedRectangleBorder(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // // //   Widget _statusDot() {
// // // // //     return AnimatedContainer(
// // // // //       duration: const Duration(milliseconds: 300),
// // // // //       width: 10,
// // // // //       height: 10,
// // // // //       decoration: BoxDecoration(
// // // // //         color: getStatusColor(widget.host.status),
// // // // //         shape: BoxShape.circle,
// // // // //         border: Border.all(color: Colors.white24, width: 1),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _flagWidget() {
// // // // //     try {
// // // // //       return SizedBox(
// // // // //         height: 16,
// // // // //         width: 22,
// // // // //         child: Flag.fromCode(
// // // // //           widget.host.flagCode,
// // // // //           fit: BoxFit.cover,
// // // // //         ),
// // // // //       );
// // // // //     } catch (_) {
// // // // //       return const Icon(
// // // // //         Icons.language,
// // // // //         color: Colors.white,
// // // // //         size: 16,
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   Widget _backgroundImage() {
// // // // //     final url = widget.host.profilePhotoUrl;
// // // // //     if (url == null || url.isEmpty) {
// // // // //       return Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       );
// // // // //     }
// // // // //     return Image.network(
// // // // //       url,
// // // // //       fit: BoxFit.cover,
// // // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Follow button ──────────────────────────────────────────────────────────

// // // // //   Widget _followButton() {
// // // // //     return Material(
// // // // //       color: Colors.transparent,
// // // // //       child: InkWell(
// // // // //         onTap: _toggleFollow,
// // // // //         borderRadius: BorderRadius.circular(100),
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(4),
// // // // //           child: AnimatedSwitcher(
// // // // //             duration: const Duration(milliseconds: 200),
// // // // //             transitionBuilder: (child, animation) =>
// // // // //                 ScaleTransition(scale: animation, child: child),
// // // // //             child: FaIcon(
// // // // //               _isFollowed
// // // // //                   ? FontAwesomeIcons.solidHeart
// // // // //                   : FontAwesomeIcons.heart,
// // // // //               key: ValueKey(_isFollowed),
// // // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // // //               size: 23,
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // // //   Widget _bottomOverlay(AppColors c) {
// // // // //     return Positioned(
// // // // //       left: 0,
// // // // //       right: 0,
// // // // //       bottom: 0,
// // // // //       child: LayoutBuilder(
// // // // //         builder: (context, constraints) {
// // // // //           final cardWidth = constraints.maxWidth;
// // // // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // // // //           return Container(
// // // // //             padding: const EdgeInsets.symmetric(
// // // // //               vertical: 10,
// // // // //               horizontal: 12,
// // // // //             ),
// // // // //             decoration: const BoxDecoration(
// // // // //               gradient: LinearGradient(
// // // // //                 begin: Alignment.bottomCenter,
// // // // //                 end: Alignment.topCenter,
// // // // //                 colors: [
// // // // //                   Color(0xCC000000),
// // // // //                   Color(0x00000000),
// // // // //                 ],
// // // // //                 stops: [0.0, 1.0],
// // // // //               ),
// // // // //             ),
// // // // //             child: Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: Column(
// // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                     children: [
// // // // //                       Row(
// // // // //                         children: [
// // // // //                           _statusDot(),
// // // // //                           const SizedBox(width: 4),
// // // // //                           Expanded(
// // // // //                             child: Text(
// // // // //                               widget.host.displayName,
// // // // //                               maxLines: 1,
// // // // //                               overflow: TextOverflow.ellipsis,
// // // // //                               style: GoogleFonts.lato(
// // // // //                                 color: Colors.white,
// // // // //                                 fontWeight: FontWeight.bold,
// // // // //                                 fontSize: nameFontSize,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                       const SizedBox(height: 4),
// // // // //                       FittedBox(
// // // // //                         fit: BoxFit.scaleDown,
// // // // //                         alignment: Alignment.centerLeft,
// // // // //                         child: Row(
// // // // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // // // //                           children: [
// // // // //                             _flagWidget(),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _ageChip(_age),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _levelChip('Lv ${widget.host.level}'),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 8),
// // // // //                 // Video call button — shows spinner when starting call
// // // // //                 Material(
// // // // //                   color: c.pink,
// // // // //                   shape: const CircleBorder(),
// // // // //                   clipBehavior: Clip.hardEdge,
// // // // //                   child: InkWell(
// // // // //                     onTap: _isStartingCall ? null : _onCallTap,
// // // // //                     child: Padding(
// // // // //                       padding: const EdgeInsets.all(10),
// // // // //                       child: _isStartingCall
// // // // //                           ? const SizedBox(
// // // // //                               width: 25,
// // // // //                               height: 25,
// // // // //                               child: CircularProgressIndicator(
// // // // //                                 strokeWidth: 2.5,
// // // // //                                 color: Colors.white,
// // // // //                               ),
// // // // //                             )
// // // // //                           : const FaIcon(
// // // // //                               FontAwesomeIcons.video,
// // // // //                               color: Colors.white,
// // // // //                               size: 25,
// // // // //                             ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final c = AppColors.of(context);
// // // // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // // // //     return ScaleTransition(
// // // // //       scale: _pressScale,
// // // // //       child: Container(
// // // // //         decoration: BoxDecoration(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           border: isDark
// // // // //               ? Border.all(
// // // // //                   color: c.pink.withValues(alpha: 0.55),
// // // // //                   width: 1.5,
// // // // //                 )
// // // // //               : null,
// // // // //         ),
// // // // //         child: ClipRRect(
// // // // //           borderRadius: BorderRadius.circular(10.5),
// // // // //           child: GestureDetector(
// // // // //             behavior: HitTestBehavior.opaque,
// // // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // // //             onTap: _onCardTap,
// // // // //             onDoubleTap: _toggleFollow,
// // // // //             child: Stack(
// // // // //               fit: StackFit.expand,
// // // // //               children: [
// // // // //                 Hero(
// // // // //                   tag: 'host_photo_${widget.host.userId}',
// // // // //                   flightShuttleBuilder: (
// // // // //                     flightContext,
// // // // //                     animation,
// // // // //                     flightDirection,
// // // // //                     fromHeroContext,
// // // // //                     toHeroContext,
// // // // //                   ) {
// // // // //                     return FadeTransition(
// // // // //                       opacity: animation,
// // // // //                       child: toHeroContext.widget,
// // // // //                     );
// // // // //                   },
// // // // //                   child: _backgroundImage(),
// // // // //                 ),
// // // // //                 Positioned(
// // // // //                   top: 8,
// // // // //                   right: 8,
// // // // //                   child: _followButton(),
// // // // //                 ),
// // // // //                 _bottomOverlay(c),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // ✅ WIRED TO BACKEND:
// // // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // // //   - Busy host → CallApiService.joinQueue()
// // // // //   - Follow heart → SocialService.follow()/unfollow()
// // // // //   - Reads wallet balance from walletBalanceProvider
// // // // //
// // // // // Animations (unchanged):
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/services/call_api_service.dart';
// // // // import 'package:cheerchat/services/social_service.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends ConsumerStatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends ConsumerState<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   bool _isStartingCall = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() {
// // // //     HapticFeedback.lightImpact();
// // // //     final wasFollowed = _isFollowed;
// // // //     setState(() => _isFollowed = !_isFollowed);

// // // //     // Fire API call — revert on failure
// // // //     final social = ref.read(socialServiceProvider);
// // // //     final future = _isFollowed
// // // //         ? social.follow(widget.host.userId)
// // // //         : social.unfollow(widget.host.userId);

// // // //     future.then((ok) {
// // // //       if (!ok && mounted) {
// // // //         setState(() => _isFollowed = wasFollowed);
// // // //       }
// // // //     });
// // // //   }

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _onCallTap() async {
// // // //     HapticFeedback.mediumImpact();

// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         await _startCallFlow();
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // // //   Future<void> _startCallFlow() async {
// // // //     if (_isStartingCall) return; // prevent double-tap
// // // //     setState(() => _isStartingCall = true);

// // // //     try {
// // // //       // 1. Check local coin balance first (quick fail)
// // // //       final walletState = ref.read(walletBalanceProvider);
// // // //       final coins = walletState.asData?.value?.coinBalance;

// // // //       // Only do local check if wallet is loaded — otherwise let server validate
// // // //       if (coins != null && coins < widget.host.priceCoins) {
// // // //         if (mounted) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // // //             isError: true,
// // // //           );
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 2. Call the backend to start the call session
// // // //       final callApi = ref.read(callApiServiceProvider);
// // // //       final res = await callApi.startCall(
// // // //         hostId: widget.host.userId,
// // // //       );

// // // //       if (!mounted) return;

// // // //       if (!res.ok) {
// // // //         // Handle specific errors
// // // //         final error = res.error ?? 'Could not start call';
// // // //         if (res.statusCode == 409) {
// // // //           // Host became busy between grid load and tap
// // // //           _autoQueue();
// // // //         } else if (res.statusCode == 400 &&
// // // //             error.contains('Insufficient')) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // // //             isError: true,
// // // //           );
// // // //         } else {
// // // //           _showSnackBar(error, isError: true);
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 3. Extract server response
// // // //       final sessionId = res.data['session_id'] as String;
// // // //       final channelName = res.data['channel_name'] as String;
// // // //       final callerToken = res.data['caller_token'] as String;
// // // //       final callerUid = res.data['caller_uid'] as int;
// // // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // // //       // 4. Push OngoingCallScreen with REAL server values
// // // //       if (mounted) {
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host.copyWith(
// // // //                 priceCoins: pricePerMinute,
// // // //               ),
// // // //               initialCoins: coins ?? 0,
// // // //               sessionId: sessionId,
// // // //               channelId: channelName,
// // // //               token: callerToken,
// // // //               localUid: callerUid,
// // // //               isAlreadyFollowing: _isFollowed,
// // // //             ),
// // // //           ),
// // // //         );

// // // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // // //         ref.read(walletBalanceProvider.notifier).refresh();
// // // //       }
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         _showSnackBar(
// // // //           'Connection error. Please try again.',
// // // //           isError: true,
// // // //         );
// // // //       }
// // // //     } finally {
// // // //       if (mounted) setState(() => _isStartingCall = false);
// // // //     }
// // // //   }

// // // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // // //   void _autoQueue() {
// // // //     final callApi = ref.read(callApiServiceProvider);
// // // //     callApi.joinQueue(widget.host.userId);

// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showSnackBar(String message, {bool isError = false}) {
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(
// // // //           message,
// // // //           style: const TextStyle(color: Colors.white),
// // // //         ),
// // // //         backgroundColor: isError
// // // //             ? Colors.red.shade700
// // // //             : Colors.green.shade700,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: _toggleFollow,
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // //             13.0,
// // // //             18.0,
// // // //           );

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [Color(0xCC000000), Color(0x00000000)],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment:
// // // //                               CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip(
// // // //                               'Lv ${widget.host.level}',
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button — shows spinner when starting call
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _isStartingCall ? null : _onCallTap,
// // // //                     child: Padding(
// // // //                       padding: const EdgeInsets.all(10),
// // // //                       child: _isStartingCall
// // // //                           ? const SizedBox(
// // // //                               width: 25,
// // // //                               height: 25,
// // // //                               child: CircularProgressIndicator(
// // // //                                 strokeWidth: 2.5,
// // // //                                 color: Colors.white,
// // // //                               ),
// // // //                             )
// // // //                           : const FaIcon(
// // // //                               FontAwesomeIcons.video,
// // // //                               color: Colors.white,
// // // //                               size: 25,
// // // //                             ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder:
// // // //                       (
// // // //                         flightContext,
// // // //                         animation,
// // // //                         flightDirection,
// // // //                         fromHeroContext,
// // // //                         toHeroContext,
// // // //                       ) {
// // // //                         return FadeTransition(
// // // //                           opacity: animation,
// // // //                           child: toHeroContext.widget,
// // // //                         );
// // // //                       },
// // // //                   child: _backgroundImage(),
// // // //                 ),
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // // // lib/widgets/cards/host_card.dart
// // // // // //
// // // // // // Host card used in HostsGridViewScreen.
// // // // // //
// // // // // // Animations in this file:
// // // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // // //
// // // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // // import 'dart:math';

// // // // // import 'package:cheerchat/models/host_model.dart';
// // // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // // import 'package:flag/flag_widget.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';

// // // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // // Widget _ageChip(int age) => Container(
// // // // //   padding: const EdgeInsets.all(3.5),
// // // // //   decoration: const BoxDecoration(
// // // // //     shape: BoxShape.circle,
// // // // //     gradient: LinearGradient(
// // // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     '$age',
// // // // //     style: const TextStyle(
// // // // //       fontSize: 8,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       color: Colors.white,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // Widget _levelChip(String level) => Container(
// // // // //   padding: const EdgeInsets.symmetric(
// // // // //     horizontal: 6,
// // // // //     vertical: 3,
// // // // //   ),
// // // // //   decoration: BoxDecoration(
// // // // //     borderRadius: BorderRadius.circular(8),
// // // // //     gradient: const LinearGradient(
// // // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     level,
// // // // //     style: GoogleFonts.lato(
// // // // //       color: Colors.white,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       fontSize: 8,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // class HostCard extends StatefulWidget {
// // // // //   const HostCard({required this.host, super.key});
// // // // //   final HostModel host;

// // // // //   @override
// // // // //   State<HostCard> createState() => _HostCardState();
// // // // // }

// // // // // class _HostCardState extends State<HostCard>
// // // // //     with TickerProviderStateMixin {
// // // // //   bool _isFollowed = false;
// // // // //   late int _age;

// // // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // // //   // Uses two separate controllers so press-in and release can have different
// // // // //   // curves and durations (snappy down, springy up).
// // // // //   late final AnimationController _pressCtrl;
// // // // //   late final Animation<double> _pressScale;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // // //     _pressCtrl = AnimationController(
// // // // //       vsync: this,
// // // // //       duration: const Duration(milliseconds: 110),
// // // // //       reverseDuration: const Duration(milliseconds: 220),
// // // // //     );
// // // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // // //       CurvedAnimation(
// // // // //         parent: _pressCtrl,
// // // // //         curve: Curves.easeInOut,
// // // // //         reverseCurve: Curves.elasticOut,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _pressCtrl.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // // //   void _toggleFollow() =>
// // // // //       setState(() => _isFollowed = !_isFollowed);

// // // // //   void _onCardTap() {
// // // // //     Navigator.of(context, rootNavigator: true).push(
// // // // //       AppTransitions.heroFade(
// // // // //         ProfileDetailsScreen(host: widget.host),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _onCallTap() {
// // // // //     HapticFeedback.mediumImpact();
// // // // //     switch (widget.host.status) {
// // // // //       case HostStatus.online:
// // // // //         Navigator.of(context, rootNavigator: true).push(
// // // // //           AppTransitions.scaleUp(
// // // // //             OngoingCallScreen(
// // // // //               host: widget.host,
// // // // //               initialCoins: 1000,
// // // // //               testMode: true,
// // // // //               isAlreadyFollowing: false,
// // // // //             ),
// // // // //           ),
// // // // //         );
// // // // //         break;
// // // // //       case HostStatus.busy:
// // // // //         _autoQueue();
// // // // //         break;
// // // // //       case HostStatus.offline:
// // // // //         break;
// // // // //     }
// // // // //   }

// // // // //   void _autoQueue() {
// // // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // // //     final c = AppColors.of(context);
// // // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Row(
// // // // //           children: [
// // // // //             const Icon(
// // // // //               Icons.notifications_active_outlined,
// // // // //               color: Colors.white,
// // // // //               size: 18,
// // // // //             ),
// // // // //             const SizedBox(width: 10),
// // // // //             Expanded(
// // // // //               child: Text(
// // // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // // //                 style: const TextStyle(color: Colors.white),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         backgroundColor: c.card,
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         duration: const Duration(seconds: 3),
// // // // //         shape: RoundedRectangleBorder(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           side: BorderSide(color: c.border),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // // //   Widget _statusDot() {
// // // // //     return AnimatedContainer(
// // // // //       duration: const Duration(milliseconds: 300),
// // // // //       width: 10,
// // // // //       height: 10,
// // // // //       decoration: BoxDecoration(
// // // // //         color: getStatusColor(widget.host.status),
// // // // //         shape: BoxShape.circle,
// // // // //         border: Border.all(color: Colors.white24, width: 1),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _flagWidget() {
// // // // //     try {
// // // // //       return SizedBox(
// // // // //         height: 16,
// // // // //         width: 22,
// // // // //         child: Flag.fromCode(
// // // // //           widget.host.flagCode,
// // // // //           fit: BoxFit.cover,
// // // // //         ),
// // // // //       );
// // // // //     } catch (_) {
// // // // //       return const Icon(
// // // // //         Icons.language,
// // // // //         color: Colors.white,
// // // // //         size: 16,
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   Widget _backgroundImage() {
// // // // //     final url = widget.host.profilePhotoUrl;
// // // // //     if (url == null || url.isEmpty) {
// // // // //       return Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       );
// // // // //     }
// // // // //     return Image.network(
// // // // //       url,
// // // // //       fit: BoxFit.cover,
// // // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // // //   Widget _followButton() {
// // // // //     return Material(
// // // // //       color: Colors.transparent,
// // // // //       child: InkWell(
// // // // //         onTap: () {
// // // // //           HapticFeedback.lightImpact();
// // // // //           _toggleFollow();
// // // // //         },
// // // // //         borderRadius: BorderRadius.circular(100),
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(4),
// // // // //           child: AnimatedSwitcher(
// // // // //             duration: const Duration(milliseconds: 200),
// // // // //             transitionBuilder: (child, animation) =>
// // // // //                 ScaleTransition(scale: animation, child: child),
// // // // //             child: FaIcon(
// // // // //               _isFollowed
// // // // //                   ? FontAwesomeIcons.solidHeart
// // // // //                   : FontAwesomeIcons.heart,
// // // // //               key: ValueKey(_isFollowed),
// // // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // // //               size: 23,
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // // //   Widget _bottomOverlay(AppColors c) {
// // // // //     return Positioned(
// // // // //       left: 0,
// // // // //       right: 0,
// // // // //       bottom: 0,
// // // // //       child: LayoutBuilder(
// // // // //         builder: (context, constraints) {
// // // // //           // Responsive font: scales 13–18 based on card width so it never
// // // // //           // overflows on high-DPI or narrow screens.
// // // // //           final cardWidth = constraints.maxWidth;
// // // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // // //             13.0,
// // // // //             18.0,
// // // // //           );

// // // // //           return Container(
// // // // //             padding: const EdgeInsets.symmetric(
// // // // //               vertical: 10,
// // // // //               horizontal: 12,
// // // // //             ),
// // // // //             decoration: const BoxDecoration(
// // // // //               gradient: LinearGradient(
// // // // //                 begin: Alignment.bottomCenter,
// // // // //                 end: Alignment.topCenter,
// // // // //                 colors: [
// // // // //                   Color(0xCC000000), // 80% black at bottom
// // // // //                   Color(0x00000000), // transparent at top
// // // // //                 ],
// // // // //                 stops: [0.0, 1.0],
// // // // //               ),
// // // // //             ),
// // // // //             child: Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: Column(
// // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                     children: [
// // // // //                       // Name row
// // // // //                       Row(
// // // // //                         children: [
// // // // //                           _statusDot(),
// // // // //                           const SizedBox(width: 4),
// // // // //                           Expanded(
// // // // //                             child: Text(
// // // // //                               widget.host.displayName,
// // // // //                               maxLines: 1,
// // // // //                               overflow: TextOverflow.ellipsis,
// // // // //                               style: GoogleFonts.lato(
// // // // //                                 color: Colors.white,
// // // // //                                 fontWeight: FontWeight.bold,
// // // // //                                 fontSize: nameFontSize,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                       const SizedBox(height: 4),
// // // // //                       // Chips row — FittedBox prevents overflow on any density
// // // // //                       FittedBox(
// // // // //                         fit: BoxFit.scaleDown,
// // // // //                         alignment: Alignment.centerLeft,
// // // // //                         child: Row(
// // // // //                           crossAxisAlignment:
// // // // //                               CrossAxisAlignment.center,
// // // // //                           children: [
// // // // //                             _flagWidget(),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _ageChip(_age),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _levelChip(
// // // // //                               'Lv ${widget.host.level}',
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 8),
// // // // //                 // Video call button
// // // // //                 Material(
// // // // //                   color: c.pink,
// // // // //                   shape: const CircleBorder(),
// // // // //                   clipBehavior: Clip.hardEdge,
// // // // //                   child: InkWell(
// // // // //                     onTap: _onCallTap,
// // // // //                     child: const Padding(
// // // // //                       padding: EdgeInsets.all(10),
// // // // //                       child: FaIcon(
// // // // //                         FontAwesomeIcons.video,
// // // // //                         color: Colors.white,
// // // // //                         size: 25,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final c = AppColors.of(context);
// // // // //     final isDark =
// // // // //         Theme.of(context).brightness == Brightness.dark;

// // // // //     return ScaleTransition(
// // // // //       scale: _pressScale,
// // // // //       child: Container(
// // // // //         decoration: BoxDecoration(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           border: isDark
// // // // //               ? Border.all(
// // // // //                   color: c.pink.withValues(alpha: 0.55),
// // // // //                   width: 1.5,
// // // // //                 )
// // // // //               : null,
// // // // //         ),
// // // // //         child: ClipRRect(
// // // // //           borderRadius: BorderRadius.circular(10.5),
// // // // //           child: GestureDetector(
// // // // //             behavior: HitTestBehavior.opaque,
// // // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // // //             onTap: _onCardTap,
// // // // //             onDoubleTap: _toggleFollow,
// // // // //             child: Stack(
// // // // //               fit: StackFit.expand,
// // // // //               children: [
// // // // //                 // ── Photo background — Hero source ───────────────────────
// // // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // // //                 Hero(
// // // // //                   tag: 'host_photo_${widget.host.userId}',
// // // // //                   flightShuttleBuilder:
// // // // //                       (
// // // // //                         flightContext,
// // // // //                         animation,
// // // // //                         flightDirection,
// // // // //                         fromHeroContext,
// // // // //                         toHeroContext,
// // // // //                       ) {
// // // // //                         // Fade between the two hero states during flight
// // // // //                         return FadeTransition(
// // // // //                           opacity: animation,
// // // // //                           child: toHeroContext.widget,
// // // // //                         );
// // // // //                       },
// // // // //                   child: _backgroundImage(),
// // // // //                 ),

// // // // //                 // ── Follow / heart button ────────────────────────────────
// // // // //                 Positioned(
// // // // //                   top: 8,
// // // // //                   right: 8,
// // // // //                   child: _followButton(),
// // // // //                 ),

// // // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // // //                 _bottomOverlay(c),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // ✅ WIRED TO BACKEND:
// // // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // // //   - Busy host → CallApiService.joinQueue()
// // // // //   - Follow heart → SocialService.follow()/unfollow()
// // // // //   - Reads wallet balance from walletBalanceProvider
// // // // //
// // // // // Animations (unchanged):
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/services/call_api_service.dart';
// // // // import 'package:cheerchat/services/social_service.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends ConsumerStatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends ConsumerState<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   bool _isStartingCall = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() {
// // // //     HapticFeedback.lightImpact();
// // // //     final wasFollowed = _isFollowed;
// // // //     setState(() => _isFollowed = !_isFollowed);

// // // //     // Fire API call — revert on failure
// // // //     final social = ref.read(socialServiceProvider);
// // // //     final future = _isFollowed
// // // //         ? social.follow(widget.host.userId)
// // // //         : social.unfollow(widget.host.userId);

// // // //     future.then((ok) {
// // // //       if (!ok && mounted) {
// // // //         setState(() => _isFollowed = wasFollowed);
// // // //       }
// // // //     });
// // // //   }

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _onCallTap() async {
// // // //     HapticFeedback.mediumImpact();

// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         await _startCallFlow();
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // // //   Future<void> _startCallFlow() async {
// // // //     if (_isStartingCall) return; // prevent double-tap
// // // //     setState(() => _isStartingCall = true);

// // // //     try {
// // // //       // 1. Check local coin balance first (quick fail)
// // // //       final coins = ref.read(coinBalanceProvider);
// // // //       if (coins < widget.host.priceCoins) {
// // // //         if (mounted) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // // //             isError: true,
// // // //           );
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 2. Call the backend to start the call session
// // // //       final callApi = ref.read(callApiServiceProvider);
// // // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // // //       if (!mounted) return;

// // // //       if (!res.ok) {
// // // //         // Handle specific errors
// // // //         final error = res.error ?? 'Could not start call';
// // // //         if (res.statusCode == 409) {
// // // //           // Host became busy between grid load and tap
// // // //           _autoQueue();
// // // //         } else if (res.statusCode == 400 &&
// // // //             error.contains('Insufficient')) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // // //             isError: true,
// // // //           );
// // // //         } else {
// // // //           _showSnackBar(error, isError: true);
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 3. Extract server response
// // // //       final sessionId = res.data['session_id'] as String;
// // // //       final channelName = res.data['channel_name'] as String;
// // // //       final callerToken = res.data['caller_token'] as String;
// // // //       final callerUid = res.data['caller_uid'] as int;
// // // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // // //       // 4. Push OngoingCallScreen with REAL server values
// // // //       if (mounted) {
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // // //               initialCoins: coins,
// // // //               sessionId: sessionId,
// // // //               channelId: channelName,
// // // //               token: callerToken,
// // // //               localUid: callerUid,
// // // //               isAlreadyFollowing: _isFollowed,
// // // //             ),
// // // //           ),
// // // //         );

// // // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // // //         ref.read(walletBalanceProvider.notifier).refresh();
// // // //       }
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // // //       }
// // // //     } finally {
// // // //       if (mounted) setState(() => _isStartingCall = false);
// // // //     }
// // // //   }

// // // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // // //   void _autoQueue() {
// // // //     final callApi = ref.read(callApiServiceProvider);
// // // //     callApi.joinQueue(widget.host.userId);

// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showSnackBar(String message, {bool isError = false}) {
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: _toggleFollow,
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000),
// // // //                   Color(0x00000000),
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip('Lv ${widget.host.level}'),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button — shows spinner when starting call
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _isStartingCall ? null : _onCallTap,
// // // //                     child: Padding(
// // // //                       padding: const EdgeInsets.all(10),
// // // //                       child: _isStartingCall
// // // //                           ? const SizedBox(
// // // //                               width: 25,
// // // //                               height: 25,
// // // //                               child: CircularProgressIndicator(
// // // //                                 strokeWidth: 2.5,
// // // //                                 color: Colors.white,
// // // //                               ),
// // // //                             )
// // // //                           : const FaIcon(
// // // //                               FontAwesomeIcons.video,
// // // //                               color: Colors.white,
// // // //                               size: 25,
// // // //                             ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder: (
// // // //                     flightContext,
// // // //                     animation,
// // // //                     flightDirection,
// // // //                     fromHeroContext,
// // // //                     toHeroContext,
// // // //                   ) {
// // // //                     return FadeTransition(
// // // //                       opacity: animation,
// // // //                       child: toHeroContext.widget,
// // // //                     );
// // // //                   },
// // // //                   child: _backgroundImage(),
// // // //                 ),
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/providers/follow_provider.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     ref.read(followStateProvider(widget.host.userId).notifier).toggle();
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final walletState = ref.read(walletBalanceProvider);
// // //       final coins = walletState.asData?.value?.coinBalance;

// // //       // Only do local check if wallet is loaded — otherwise let server validate
// // //       if (coins != null && coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(
// // //         hostId: widget.host.userId,
// // //       );

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(
// // //                 priceCoins: pricePerMinute,
// // //               ),
// // //               initialCoins: coins ?? 0,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: ref.read(followStateProvider(widget.host.userId)),
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar(
// // //           'Connection error. Please try again.',
// // //           isError: true,
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(
// // //           message,
// // //           style: const TextStyle(color: Colors.white),
// // //         ),
// // //         backgroundColor: isError
// // //             ? Colors.red.shade700
// // //             : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //   Widget _followButton() {
// // //     final isFollowed = ref.watch(followStateProvider(widget.host.userId));
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(isFollowed),
// // //               color: isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // //             13.0,
// // //             18.0,
// // //           );

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [Color(0xCC000000), Color(0x00000000)],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment:
// // //                               CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip(
// // //                               'Lv ${widget.host.level}',
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder:
// // //                       (
// // //                         flightContext,
// // //                         animation,
// // //                         flightDirection,
// // //                         fromHeroContext,
// // //                         toHeroContext,
// // //                       ) {
// // //                         return FadeTransition(
// // //                           opacity: animation,
// // //                           child: toHeroContext.widget,
// // //                         );
// // //                       },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // Animations in this file:
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // //
// // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends StatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   State<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends State<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // //   // Uses two separate controllers so press-in and release can have different
// // // //   // curves and durations (snappy down, springy up).
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() =>
// // // //       setState(() => _isFollowed = !_isFollowed);

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _onCallTap() {
// // // //     HapticFeedback.mediumImpact();
// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host,
// // // //               initialCoins: 1000,
// // // //               testMode: true,
// // // //               isAlreadyFollowing: false,
// // // //             ),
// // // //           ),
// // // //         );
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   void _autoQueue() {
// // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: () {
// // // //           HapticFeedback.lightImpact();
// // // //           _toggleFollow();
// // // //         },
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           // Responsive font: scales 13–18 based on card width so it never
// // // //           // overflows on high-DPI or narrow screens.
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // //             13.0,
// // // //             18.0,
// // // //           );

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000), // 80% black at bottom
// // // //                   Color(0x00000000), // transparent at top
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       // Name row
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       // Chips row — FittedBox prevents overflow on any density
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment:
// // // //                               CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip(
// // // //                               'Lv ${widget.host.level}',
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _onCallTap,
// // // //                     child: const Padding(
// // // //                       padding: EdgeInsets.all(10),
// // // //                       child: FaIcon(
// // // //                         FontAwesomeIcons.video,
// // // //                         color: Colors.white,
// // // //                         size: 25,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 // ── Photo background — Hero source ───────────────────────
// // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder:
// // // //                       (
// // // //                         flightContext,
// // // //                         animation,
// // // //                         flightDirection,
// // // //                         fromHeroContext,
// // // //                         toHeroContext,
// // // //                       ) {
// // // //                         // Fade between the two hero states during flight
// // // //                         return FadeTransition(
// // // //                           opacity: animation,
// // // //                           child: toHeroContext.widget,
// // // //                         );
// // // //                       },
// // // //                   child: _backgroundImage(),
// // // //                 ),

// // // //                 // ── Follow / heart button ────────────────────────────────
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),

// // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     final wasFollowed = _isFollowed;
// // //     setState(() => _isFollowed = !_isFollowed);

// // //     // Fire API call — revert on failure
// // //     final social = ref.read(socialServiceProvider);
// // //     final future = _isFollowed
// // //         ? social.follow(widget.host.userId)
// // //         : social.unfollow(widget.host.userId);

// // //     future.then((ok) {
// // //       if (!ok && mounted) {
// // //         setState(() => _isFollowed = wasFollowed);
// // //       }
// // //     });
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final coins = ref.read(coinBalanceProvider);
// // //       if (coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // //               initialCoins: coins,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: _isFollowed,
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000),
// // //                   Color(0x00000000),
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip('Lv ${widget.host.level}'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder: (
// // //                     flightContext,
// // //                     animation,
// // //                     flightDirection,
// // //                     fromHeroContext,
// // //                     toHeroContext,
// // //                   ) {
// // //                     return FadeTransition(
// // //                       opacity: animation,
// // //                       child: toHeroContext.widget,
// // //                     );
// // //                   },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/providers/follow_provider.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     // ref.read(followStateProvider(widget.host.userId).notifier).toggle();
// //     ref
// //         .read(followNotifierProvider.notifier)
// //         .toggle(widget.host.userId);
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final walletState = ref.read(walletBalanceProvider);
// //       final coins = walletState.asData?.value?.coinBalance;

// //       // Only do local check if wallet is loaded — otherwise let server validate
// //       if (coins != null && coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(
// //         hostId: widget.host.userId,
// //       );

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(
// //                 priceCoins: pricePerMinute,
// //               ),
// //               initialCoins: coins ?? 0,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: ref.read(followStateProvider(widget.host.userId)),
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar(
// //           'Connection error. Please try again.',
// //           isError: true,
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         backgroundColor: isError
// //             ? Colors.red.shade700
// //             : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //     final isFollowed = ref.watch(followStateProvider(widget.host.userId));
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(isFollowed),
// //               color: isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(
// //             13.0,
// //             18.0,
// //           );

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [Color(0xCC000000), Color(0x00000000)],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip(
// //                               'Lv ${widget.host.level}',
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder:
// //                       (
// //                         flightContext,
// //                         animation,
// //                         flightDirection,
// //                         fromHeroContext,
// //                         toHeroContext,
// //                       ) {
// //                         return FadeTransition(
// //                           opacity: animation,
// //                           child: toHeroContext.widget,
// //                         );
// //                       },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // // // // lib/widgets/cards/host_card.dart
// // // // // //
// // // // // // Host card used in HostsGridViewScreen.
// // // // // //
// // // // // // Animations in this file:
// // // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // // //
// // // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // // import 'dart:math';

// // // // // import 'package:cheerchat/models/host_model.dart';
// // // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // // import 'package:flag/flag_widget.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';

// // // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // // Widget _ageChip(int age) => Container(
// // // // //   padding: const EdgeInsets.all(3.5),
// // // // //   decoration: const BoxDecoration(
// // // // //     shape: BoxShape.circle,
// // // // //     gradient: LinearGradient(
// // // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     '$age',
// // // // //     style: const TextStyle(
// // // // //       fontSize: 8,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       color: Colors.white,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // Widget _levelChip(String level) => Container(
// // // // //   padding: const EdgeInsets.symmetric(
// // // // //     horizontal: 6,
// // // // //     vertical: 3,
// // // // //   ),
// // // // //   decoration: BoxDecoration(
// // // // //     borderRadius: BorderRadius.circular(8),
// // // // //     gradient: const LinearGradient(
// // // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     level,
// // // // //     style: GoogleFonts.lato(
// // // // //       color: Colors.white,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       fontSize: 8,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // class HostCard extends StatefulWidget {
// // // // //   const HostCard({required this.host, super.key});
// // // // //   final HostModel host;

// // // // //   @override
// // // // //   State<HostCard> createState() => _HostCardState();
// // // // // }

// // // // // class _HostCardState extends State<HostCard>
// // // // //     with TickerProviderStateMixin {
// // // // //   bool _isFollowed = false;
// // // // //   late int _age;

// // // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // // //   // Uses two separate controllers so press-in and release can have different
// // // // //   // curves and durations (snappy down, springy up).
// // // // //   late final AnimationController _pressCtrl;
// // // // //   late final Animation<double> _pressScale;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // // //     _pressCtrl = AnimationController(
// // // // //       vsync: this,
// // // // //       duration: const Duration(milliseconds: 110),
// // // // //       reverseDuration: const Duration(milliseconds: 220),
// // // // //     );
// // // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // // //       CurvedAnimation(
// // // // //         parent: _pressCtrl,
// // // // //         curve: Curves.easeInOut,
// // // // //         reverseCurve: Curves.elasticOut,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _pressCtrl.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // // //   void _toggleFollow() =>
// // // // //       setState(() => _isFollowed = !_isFollowed);

// // // // //   void _onCardTap() {
// // // // //     Navigator.of(context, rootNavigator: true).push(
// // // // //       AppTransitions.heroFade(
// // // // //         ProfileDetailsScreen(host: widget.host),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _onCallTap() {
// // // // //     HapticFeedback.mediumImpact();
// // // // //     switch (widget.host.status) {
// // // // //       case HostStatus.online:
// // // // //         Navigator.of(context, rootNavigator: true).push(
// // // // //           AppTransitions.scaleUp(
// // // // //             OngoingCallScreen(
// // // // //               host: widget.host,
// // // // //               initialCoins: 1000,
// // // // //               testMode: true,
// // // // //               isAlreadyFollowing: false,
// // // // //             ),
// // // // //           ),
// // // // //         );
// // // // //         break;
// // // // //       case HostStatus.busy:
// // // // //         _autoQueue();
// // // // //         break;
// // // // //       case HostStatus.offline:
// // // // //         break;
// // // // //     }
// // // // //   }

// // // // //   void _autoQueue() {
// // // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // // //     final c = AppColors.of(context);
// // // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Row(
// // // // //           children: [
// // // // //             const Icon(
// // // // //               Icons.notifications_active_outlined,
// // // // //               color: Colors.white,
// // // // //               size: 18,
// // // // //             ),
// // // // //             const SizedBox(width: 10),
// // // // //             Expanded(
// // // // //               child: Text(
// // // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // // //                 style: const TextStyle(color: Colors.white),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         backgroundColor: c.card,
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         duration: const Duration(seconds: 3),
// // // // //         shape: RoundedRectangleBorder(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           side: BorderSide(color: c.border),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // // //   Widget _statusDot() {
// // // // //     return AnimatedContainer(
// // // // //       duration: const Duration(milliseconds: 300),
// // // // //       width: 10,
// // // // //       height: 10,
// // // // //       decoration: BoxDecoration(
// // // // //         color: getStatusColor(widget.host.status),
// // // // //         shape: BoxShape.circle,
// // // // //         border: Border.all(color: Colors.white24, width: 1),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _flagWidget() {
// // // // //     try {
// // // // //       return SizedBox(
// // // // //         height: 16,
// // // // //         width: 22,
// // // // //         child: Flag.fromCode(
// // // // //           widget.host.flagCode,
// // // // //           fit: BoxFit.cover,
// // // // //         ),
// // // // //       );
// // // // //     } catch (_) {
// // // // //       return const Icon(
// // // // //         Icons.language,
// // // // //         color: Colors.white,
// // // // //         size: 16,
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   Widget _backgroundImage() {
// // // // //     final url = widget.host.profilePhotoUrl;
// // // // //     if (url == null || url.isEmpty) {
// // // // //       return Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       );
// // // // //     }
// // // // //     return Image.network(
// // // // //       url,
// // // // //       fit: BoxFit.cover,
// // // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // // //   Widget _followButton() {
// // // // //     return Material(
// // // // //       color: Colors.transparent,
// // // // //       child: InkWell(
// // // // //         onTap: () {
// // // // //           HapticFeedback.lightImpact();
// // // // //           _toggleFollow();
// // // // //         },
// // // // //         borderRadius: BorderRadius.circular(100),
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(4),
// // // // //           child: AnimatedSwitcher(
// // // // //             duration: const Duration(milliseconds: 200),
// // // // //             transitionBuilder: (child, animation) =>
// // // // //                 ScaleTransition(scale: animation, child: child),
// // // // //             child: FaIcon(
// // // // //               _isFollowed
// // // // //                   ? FontAwesomeIcons.solidHeart
// // // // //                   : FontAwesomeIcons.heart,
// // // // //               key: ValueKey(_isFollowed),
// // // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // // //               size: 23,
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // // //   Widget _bottomOverlay(AppColors c) {
// // // // //     return Positioned(
// // // // //       left: 0,
// // // // //       right: 0,
// // // // //       bottom: 0,
// // // // //       child: LayoutBuilder(
// // // // //         builder: (context, constraints) {
// // // // //           // Responsive font: scales 13–18 based on card width so it never
// // // // //           // overflows on high-DPI or narrow screens.
// // // // //           final cardWidth = constraints.maxWidth;
// // // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // // //             13.0,
// // // // //             18.0,
// // // // //           );

// // // // //           return Container(
// // // // //             padding: const EdgeInsets.symmetric(
// // // // //               vertical: 10,
// // // // //               horizontal: 12,
// // // // //             ),
// // // // //             decoration: const BoxDecoration(
// // // // //               gradient: LinearGradient(
// // // // //                 begin: Alignment.bottomCenter,
// // // // //                 end: Alignment.topCenter,
// // // // //                 colors: [
// // // // //                   Color(0xCC000000), // 80% black at bottom
// // // // //                   Color(0x00000000), // transparent at top
// // // // //                 ],
// // // // //                 stops: [0.0, 1.0],
// // // // //               ),
// // // // //             ),
// // // // //             child: Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: Column(
// // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                     children: [
// // // // //                       // Name row
// // // // //                       Row(
// // // // //                         children: [
// // // // //                           _statusDot(),
// // // // //                           const SizedBox(width: 4),
// // // // //                           Expanded(
// // // // //                             child: Text(
// // // // //                               widget.host.displayName,
// // // // //                               maxLines: 1,
// // // // //                               overflow: TextOverflow.ellipsis,
// // // // //                               style: GoogleFonts.lato(
// // // // //                                 color: Colors.white,
// // // // //                                 fontWeight: FontWeight.bold,
// // // // //                                 fontSize: nameFontSize,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                       const SizedBox(height: 4),
// // // // //                       // Chips row — FittedBox prevents overflow on any density
// // // // //                       FittedBox(
// // // // //                         fit: BoxFit.scaleDown,
// // // // //                         alignment: Alignment.centerLeft,
// // // // //                         child: Row(
// // // // //                           crossAxisAlignment:
// // // // //                               CrossAxisAlignment.center,
// // // // //                           children: [
// // // // //                             _flagWidget(),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _ageChip(_age),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _levelChip(
// // // // //                               'Lv ${widget.host.level}',
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 8),
// // // // //                 // Video call button
// // // // //                 Material(
// // // // //                   color: c.pink,
// // // // //                   shape: const CircleBorder(),
// // // // //                   clipBehavior: Clip.hardEdge,
// // // // //                   child: InkWell(
// // // // //                     onTap: _onCallTap,
// // // // //                     child: const Padding(
// // // // //                       padding: EdgeInsets.all(10),
// // // // //                       child: FaIcon(
// // // // //                         FontAwesomeIcons.video,
// // // // //                         color: Colors.white,
// // // // //                         size: 25,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final c = AppColors.of(context);
// // // // //     final isDark =
// // // // //         Theme.of(context).brightness == Brightness.dark;

// // // // //     return ScaleTransition(
// // // // //       scale: _pressScale,
// // // // //       child: Container(
// // // // //         decoration: BoxDecoration(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           border: isDark
// // // // //               ? Border.all(
// // // // //                   color: c.pink.withValues(alpha: 0.55),
// // // // //                   width: 1.5,
// // // // //                 )
// // // // //               : null,
// // // // //         ),
// // // // //         child: ClipRRect(
// // // // //           borderRadius: BorderRadius.circular(10.5),
// // // // //           child: GestureDetector(
// // // // //             behavior: HitTestBehavior.opaque,
// // // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // // //             onTap: _onCardTap,
// // // // //             onDoubleTap: _toggleFollow,
// // // // //             child: Stack(
// // // // //               fit: StackFit.expand,
// // // // //               children: [
// // // // //                 // ── Photo background — Hero source ───────────────────────
// // // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // // //                 Hero(
// // // // //                   tag: 'host_photo_${widget.host.userId}',
// // // // //                   flightShuttleBuilder:
// // // // //                       (
// // // // //                         flightContext,
// // // // //                         animation,
// // // // //                         flightDirection,
// // // // //                         fromHeroContext,
// // // // //                         toHeroContext,
// // // // //                       ) {
// // // // //                         // Fade between the two hero states during flight
// // // // //                         return FadeTransition(
// // // // //                           opacity: animation,
// // // // //                           child: toHeroContext.widget,
// // // // //                         );
// // // // //                       },
// // // // //                   child: _backgroundImage(),
// // // // //                 ),

// // // // //                 // ── Follow / heart button ────────────────────────────────
// // // // //                 Positioned(
// // // // //                   top: 8,
// // // // //                   right: 8,
// // // // //                   child: _followButton(),
// // // // //                 ),

// // // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // // //                 _bottomOverlay(c),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // ✅ WIRED TO BACKEND:
// // // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // // //   - Busy host → CallApiService.joinQueue()
// // // // //   - Follow heart → SocialService.follow()/unfollow()
// // // // //   - Reads wallet balance from walletBalanceProvider
// // // // //
// // // // // Animations (unchanged):
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/services/call_api_service.dart';
// // // // import 'package:cheerchat/services/social_service.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends ConsumerStatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends ConsumerState<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   bool _isStartingCall = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() {
// // // //     HapticFeedback.lightImpact();
// // // //     final wasFollowed = _isFollowed;
// // // //     setState(() => _isFollowed = !_isFollowed);

// // // //     // Fire API call — revert on failure
// // // //     final social = ref.read(socialServiceProvider);
// // // //     final future = _isFollowed
// // // //         ? social.follow(widget.host.userId)
// // // //         : social.unfollow(widget.host.userId);

// // // //     future.then((ok) {
// // // //       if (!ok && mounted) {
// // // //         setState(() => _isFollowed = wasFollowed);
// // // //       }
// // // //     });
// // // //   }

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _onCallTap() async {
// // // //     HapticFeedback.mediumImpact();

// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         await _startCallFlow();
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // // //   Future<void> _startCallFlow() async {
// // // //     if (_isStartingCall) return; // prevent double-tap
// // // //     setState(() => _isStartingCall = true);

// // // //     try {
// // // //       // 1. Check local coin balance first (quick fail)
// // // //       final coins = ref.read(coinBalanceProvider);
// // // //       if (coins < widget.host.priceCoins) {
// // // //         if (mounted) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // // //             isError: true,
// // // //           );
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 2. Call the backend to start the call session
// // // //       final callApi = ref.read(callApiServiceProvider);
// // // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // // //       if (!mounted) return;

// // // //       if (!res.ok) {
// // // //         // Handle specific errors
// // // //         final error = res.error ?? 'Could not start call';
// // // //         if (res.statusCode == 409) {
// // // //           // Host became busy between grid load and tap
// // // //           _autoQueue();
// // // //         } else if (res.statusCode == 400 &&
// // // //             error.contains('Insufficient')) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // // //             isError: true,
// // // //           );
// // // //         } else {
// // // //           _showSnackBar(error, isError: true);
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 3. Extract server response
// // // //       final sessionId = res.data['session_id'] as String;
// // // //       final channelName = res.data['channel_name'] as String;
// // // //       final callerToken = res.data['caller_token'] as String;
// // // //       final callerUid = res.data['caller_uid'] as int;
// // // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // // //       // 4. Push OngoingCallScreen with REAL server values
// // // //       if (mounted) {
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // // //               initialCoins: coins,
// // // //               sessionId: sessionId,
// // // //               channelId: channelName,
// // // //               token: callerToken,
// // // //               localUid: callerUid,
// // // //               isAlreadyFollowing: _isFollowed,
// // // //             ),
// // // //           ),
// // // //         );

// // // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // // //         ref.read(walletBalanceProvider.notifier).refresh();
// // // //       }
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // // //       }
// // // //     } finally {
// // // //       if (mounted) setState(() => _isStartingCall = false);
// // // //     }
// // // //   }

// // // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // // //   void _autoQueue() {
// // // //     final callApi = ref.read(callApiServiceProvider);
// // // //     callApi.joinQueue(widget.host.userId);

// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showSnackBar(String message, {bool isError = false}) {
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: _toggleFollow,
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000),
// // // //                   Color(0x00000000),
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip('Lv ${widget.host.level}'),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button — shows spinner when starting call
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _isStartingCall ? null : _onCallTap,
// // // //                     child: Padding(
// // // //                       padding: const EdgeInsets.all(10),
// // // //                       child: _isStartingCall
// // // //                           ? const SizedBox(
// // // //                               width: 25,
// // // //                               height: 25,
// // // //                               child: CircularProgressIndicator(
// // // //                                 strokeWidth: 2.5,
// // // //                                 color: Colors.white,
// // // //                               ),
// // // //                             )
// // // //                           : const FaIcon(
// // // //                               FontAwesomeIcons.video,
// // // //                               color: Colors.white,
// // // //                               size: 25,
// // // //                             ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder: (
// // // //                     flightContext,
// // // //                     animation,
// // // //                     flightDirection,
// // // //                     fromHeroContext,
// // // //                     toHeroContext,
// // // //                   ) {
// // // //                     return FadeTransition(
// // // //                       opacity: animation,
// // // //                       child: toHeroContext.widget,
// // // //                     );
// // // //                   },
// // // //                   child: _backgroundImage(),
// // // //                 ),
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     final wasFollowed = _isFollowed;
// // //     setState(() => _isFollowed = !_isFollowed);

// // //     // Fire API call — revert on failure
// // //     final social = ref.read(socialServiceProvider);
// // //     final future = _isFollowed
// // //         ? social.follow(widget.host.userId)
// // //         : social.unfollow(widget.host.userId);

// // //     future.then((ok) {
// // //       if (!ok && mounted) {
// // //         setState(() => _isFollowed = wasFollowed);
// // //       }
// // //     });
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final walletState = ref.read(walletBalanceProvider);
// // //       final coins = walletState.asData?.value?.coinBalance;

// // //       // Only do local check if wallet is loaded — otherwise let server validate
// // //       if (coins != null && coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(
// // //         hostId: widget.host.userId,
// // //       );

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(
// // //                 priceCoins: pricePerMinute,
// // //               ),
// // //               initialCoins: coins ?? 0,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: _isFollowed,
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar(
// // //           'Connection error. Please try again.',
// // //           isError: true,
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(
// // //           message,
// // //           style: const TextStyle(color: Colors.white),
// // //         ),
// // //         backgroundColor: isError
// // //             ? Colors.red.shade700
// // //             : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // //             13.0,
// // //             18.0,
// // //           );

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [Color(0xCC000000), Color(0x00000000)],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment:
// // //                               CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip(
// // //                               'Lv ${widget.host.level}',
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder:
// // //                       (
// // //                         flightContext,
// // //                         animation,
// // //                         flightDirection,
// // //                         fromHeroContext,
// // //                         toHeroContext,
// // //                       ) {
// // //                         return FadeTransition(
// // //                           opacity: animation,
// // //                           child: toHeroContext.widget,
// // //                         );
// // //                       },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // Animations in this file:
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // //
// // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends StatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   State<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends State<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // //   // Uses two separate controllers so press-in and release can have different
// // // //   // curves and durations (snappy down, springy up).
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() =>
// // // //       setState(() => _isFollowed = !_isFollowed);

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _onCallTap() {
// // // //     HapticFeedback.mediumImpact();
// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host,
// // // //               initialCoins: 1000,
// // // //               testMode: true,
// // // //               isAlreadyFollowing: false,
// // // //             ),
// // // //           ),
// // // //         );
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   void _autoQueue() {
// // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: () {
// // // //           HapticFeedback.lightImpact();
// // // //           _toggleFollow();
// // // //         },
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           // Responsive font: scales 13–18 based on card width so it never
// // // //           // overflows on high-DPI or narrow screens.
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // //             13.0,
// // // //             18.0,
// // // //           );

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000), // 80% black at bottom
// // // //                   Color(0x00000000), // transparent at top
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       // Name row
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       // Chips row — FittedBox prevents overflow on any density
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment:
// // // //                               CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip(
// // // //                               'Lv ${widget.host.level}',
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _onCallTap,
// // // //                     child: const Padding(
// // // //                       padding: EdgeInsets.all(10),
// // // //                       child: FaIcon(
// // // //                         FontAwesomeIcons.video,
// // // //                         color: Colors.white,
// // // //                         size: 25,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 // ── Photo background — Hero source ───────────────────────
// // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder:
// // // //                       (
// // // //                         flightContext,
// // // //                         animation,
// // // //                         flightDirection,
// // // //                         fromHeroContext,
// // // //                         toHeroContext,
// // // //                       ) {
// // // //                         // Fade between the two hero states during flight
// // // //                         return FadeTransition(
// // // //                           opacity: animation,
// // // //                           child: toHeroContext.widget,
// // // //                         );
// // // //                       },
// // // //                   child: _backgroundImage(),
// // // //                 ),

// // // //                 // ── Follow / heart button ────────────────────────────────
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),

// // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     final wasFollowed = _isFollowed;
// // //     setState(() => _isFollowed = !_isFollowed);

// // //     // Fire API call — revert on failure
// // //     final social = ref.read(socialServiceProvider);
// // //     final future = _isFollowed
// // //         ? social.follow(widget.host.userId)
// // //         : social.unfollow(widget.host.userId);

// // //     future.then((ok) {
// // //       if (!ok && mounted) {
// // //         setState(() => _isFollowed = wasFollowed);
// // //       }
// // //     });
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final coins = ref.read(coinBalanceProvider);
// // //       if (coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // //               initialCoins: coins,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: _isFollowed,
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000),
// // //                   Color(0x00000000),
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip('Lv ${widget.host.level}'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder: (
// // //                     flightContext,
// // //                     animation,
// // //                     flightDirection,
// // //                     fromHeroContext,
// // //                     toHeroContext,
// // //                   ) {
// // //                     return FadeTransition(
// // //                       opacity: animation,
// // //                       child: toHeroContext.widget,
// // //                     );
// // //                   },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/providers/follow_provider.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     ref.read(followStateProvider(widget.host.userId).notifier).toggle();
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final walletState = ref.read(walletBalanceProvider);
// //       final coins = walletState.asData?.value?.coinBalance;

// //       // Only do local check if wallet is loaded — otherwise let server validate
// //       if (coins != null && coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(
// //         hostId: widget.host.userId,
// //       );

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(
// //                 priceCoins: pricePerMinute,
// //               ),
// //               initialCoins: coins ?? 0,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: ref.read(followStateProvider(widget.host.userId)),
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar(
// //           'Connection error. Please try again.',
// //           isError: true,
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         backgroundColor: isError
// //             ? Colors.red.shade700
// //             : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //   Widget _followButton() {
// //     final isFollowed = ref.watch(followStateProvider(widget.host.userId));
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(isFollowed),
// //               color: isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(
// //             13.0,
// //             18.0,
// //           );

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [Color(0xCC000000), Color(0x00000000)],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip(
// //                               'Lv ${widget.host.level}',
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder:
// //                       (
// //                         flightContext,
// //                         animation,
// //                         flightDirection,
// //                         fromHeroContext,
// //                         toHeroContext,
// //                       ) {
// //                         return FadeTransition(
// //                           opacity: animation,
// //                           child: toHeroContext.widget,
// //                         );
// //                       },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // Animations in this file:
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // //
// // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // hardcoded — they need contrast over an image regardless of theme.
// // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends StatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   State<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends State<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // //   // Uses two separate controllers so press-in and release can have different
// // //   // curves and durations (snappy down, springy up).
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() =>
// // //       setState(() => _isFollowed = !_isFollowed);

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   void _onCallTap() {
// // //     HapticFeedback.mediumImpact();
// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host,
// // //               initialCoins: 1000,
// // //               testMode: true,
// // //               isAlreadyFollowing: false,
// // //             ),
// // //           ),
// // //         );
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   void _autoQueue() {
// // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────
// // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: () {
// // //           HapticFeedback.lightImpact();
// // //           _toggleFollow();
// // //         },
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           // Responsive font: scales 13–18 based on card width so it never
// // //           // overflows on high-DPI or narrow screens.
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // //             13.0,
// // //             18.0,
// // //           );

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000), // 80% black at bottom
// // //                   Color(0x00000000), // transparent at top
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       // Name row
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       // Chips row — FittedBox prevents overflow on any density
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment:
// // //                               CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip(
// // //                               'Lv ${widget.host.level}',
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _onCallTap,
// // //                     child: const Padding(
// // //                       padding: EdgeInsets.all(10),
// // //                       child: FaIcon(
// // //                         FontAwesomeIcons.video,
// // //                         color: Colors.white,
// // //                         size: 25,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 // ── Photo background — Hero source ───────────────────────
// // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder:
// // //                       (
// // //                         flightContext,
// // //                         animation,
// // //                         flightDirection,
// // //                         fromHeroContext,
// // //                         toHeroContext,
// // //                       ) {
// // //                         // Fade between the two hero states during flight
// // //                         return FadeTransition(
// // //                           opacity: animation,
// // //                           child: toHeroContext.widget,
// // //                         );
// // //                       },
// // //                   child: _backgroundImage(),
// // //                 ),

// // //                 // ── Follow / heart button ────────────────────────────────
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),

// // //                 // ── Bottom overlay with name + chips + call button ───────
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/services/social_service.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isFollowed = false;
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     final wasFollowed = _isFollowed;
// //     setState(() => _isFollowed = !_isFollowed);

// //     // Fire API call — revert on failure
// //     final social = ref.read(socialServiceProvider);
// //     final future = _isFollowed
// //         ? social.follow(widget.host.userId)
// //         : social.unfollow(widget.host.userId);

// //     future.then((ok) {
// //       if (!ok && mounted) {
// //         setState(() => _isFollowed = wasFollowed);
// //       }
// //     });
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final coins = ref.read(coinBalanceProvider);
// //       if (coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(hostId: widget.host.userId);

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// //               initialCoins: coins,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: _isFollowed,
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar('Connection error. Please try again.', isError: true);
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message, style: const TextStyle(color: Colors.white)),
// //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               _isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(_isFollowed),
// //               color: _isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [
// //                   Color(0xCC000000),
// //                   Color(0x00000000),
// //                 ],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment: CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip('Lv ${widget.host.level}'),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark = Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder: (
// //                     flightContext,
// //                     animation,
// //                     flightDirection,
// //                     fromHeroContext,
// //                     toHeroContext,
// //                   ) {
// //                     return FadeTransition(
// //                       opacity: animation,
// //                       child: toHeroContext.widget,
// //                     );
// //                   },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/widgets/cards/host_card.dart
// //
// // Host card used in HostsGridViewScreen.
// //
// // ✅ WIRED TO BACKEND:
// //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// //   - Busy host → CallApiService.joinQueue()
// //   - Follow heart → SocialService.follow()/unfollow()
// //   - Reads wallet balance from walletBalanceProvider
// //
// // Animations (unchanged):
// //   1. Card press — scales down to 0.95 on tap, springs back on release
// //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// //   3. Status dot — AnimatedContainer color transition (300 ms)
// //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// //                        — AppTransitions.scaleUp   → OngoingCallScreen
// //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// import 'dart:math';

// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/providers/wallet_provider.dart';
// import 'package:cheerchat/screens/outgoing_call_screen.dart';
// import 'package:cheerchat/screens/profile_details_screen.dart';
// import 'package:cheerchat/services/call_api_service.dart';
// import 'package:cheerchat/providers/follow_provider.dart';
// import 'package:cheerchat/theme/app_colors.dart';
// import 'package:cheerchat/utils/app_transitions.dart';
// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// Widget _ageChip(int age) => Container(
//   padding: const EdgeInsets.all(3.5),
//   decoration: const BoxDecoration(
//     shape: BoxShape.circle,
//     gradient: LinearGradient(
//       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
//     ),
//   ),
//   child: Text(
//     '$age',
//     style: const TextStyle(
//       fontSize: 8,
//       fontWeight: FontWeight.bold,
//       color: Colors.white,
//     ),
//   ),
// );

// Widget _levelChip(String level) => Container(
//   padding: const EdgeInsets.symmetric(
//     horizontal: 6,
//     vertical: 3,
//   ),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(8),
//     gradient: const LinearGradient(
//       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
//     ),
//   ),
//   child: Text(
//     level,
//     style: GoogleFonts.lato(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 8,
//     ),
//   ),
// );

// // ─────────────────────────────────────────────────────────────────────────────

// class HostCard extends ConsumerStatefulWidget {
//   const HostCard({required this.host, super.key});
//   final HostModel host;

//   @override
//   ConsumerState<HostCard> createState() => _HostCardState();
// }

// class _HostCardState extends ConsumerState<HostCard>
//     with TickerProviderStateMixin {
//   bool _isStartingCall = false;
//   late int _age;

//   // ── Press-bounce animation ─────────────────────────────────────────────────
//   late final AnimationController _pressCtrl;
//   late final Animation<double> _pressScale;

//   @override
//   void initState() {
//     super.initState();
//     _age = widget.host.age ?? (18 + Random().nextInt(23));

//     _pressCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 110),
//       reverseDuration: const Duration(milliseconds: 220),
//     );
//     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
//       CurvedAnimation(
//         parent: _pressCtrl,
//         curve: Curves.easeInOut,
//         reverseCurve: Curves.elasticOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pressCtrl.dispose();
//     super.dispose();
//   }

//   // ── Tap handlers ───────────────────────────────────────────────────────────

//   void _toggleFollow() {
//     HapticFeedback.lightImpact();
//     // ref.read(followStateProvider(widget.host.userId).notifier).toggle();
//     ref
//         .read(followNotifierProvider.notifier)
//         .toggle(widget.host.userId);
//   }

//   void _onCardTap() {
//     Navigator.of(context, rootNavigator: true).push(
//       AppTransitions.heroFade(
//         ProfileDetailsScreen(host: widget.host),
//       ),
//     );
//   }

//   Future<void> _onCallTap() async {
//     HapticFeedback.mediumImpact();

//     switch (widget.host.status) {
//       case HostStatus.online:
//         await _startCallFlow();
//         break;
//       case HostStatus.busy:
//         _autoQueue();
//         break;
//       case HostStatus.offline:
//         break;
//     }
//   }

//   // ── Start call — the main wiring ─────────────────────────────────────────

//   Future<void> _startCallFlow() async {
//     if (_isStartingCall) return; // prevent double-tap
//     setState(() => _isStartingCall = true);

//     try {
//       // 1. Check local coin balance first (quick fail)
//       final walletState = ref.read(walletBalanceProvider);
//       final coins = walletState.asData?.value?.coinBalance;

//       // Only do local check if wallet is loaded — otherwise let server validate
//       if (coins != null && coins < widget.host.priceCoins) {
//         if (mounted) {
//           _showSnackBar(
//             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
//             isError: true,
//           );
//         }
//         return;
//       }

//       // 2. Call the backend to start the call session
//       final callApi = ref.read(callApiServiceProvider);
//       final res = await callApi.startCall(
//         hostId: widget.host.userId,
//       );

//       if (!mounted) return;

//       if (!res.ok) {
//         // Handle specific errors
//         final error = res.error ?? 'Could not start call';
//         if (res.statusCode == 409) {
//           // Host became busy between grid load and tap
//           _autoQueue();
//         } else if (res.statusCode == 400 &&
//             error.contains('Insufficient')) {
//           _showSnackBar(
//             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
//             isError: true,
//           );
//         } else {
//           _showSnackBar(error, isError: true);
//         }
//         return;
//       }

//       // 3. Extract server response
//       final sessionId = res.data['session_id'] as String;
//       final channelName = res.data['channel_name'] as String;
//       final callerToken = res.data['caller_token'] as String;
//       final callerUid = res.data['caller_uid'] as int;
//       final pricePerMinute = res.data['price_per_minute'] as int;

//       // 4. Push OutgoingCallScreen — waits for host to accept
//       if (mounted) {
//         Navigator.of(context, rootNavigator: true).push(
//           AppTransitions.scaleUp(
//             OutgoingCallScreen(
//               host: widget.host.copyWith(
//                 priceCoins: pricePerMinute,
//               ),
//               initialCoins: coins ?? 0,
//               sessionId: sessionId,
//               channelId: channelName,
//               token: callerToken,
//               callerUid: callerUid,
//               isAlreadyFollowing: ref.read(
//                 followStateProvider(widget.host.userId),
//               ),
//             ),
//           ),
//         );

//         // 5. Refresh wallet after navigating (call screen will also refresh on end)
//         ref.read(walletBalanceProvider.notifier).refresh();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar(
//           'Connection error. Please try again.',
//           isError: true,
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isStartingCall = false);
//     }
//   }

//   // ── Auto-queue for busy host ─────────────────────────────────────────────

//   void _autoQueue() {
//     final callApi = ref.read(callApiServiceProvider);
//     callApi.joinQueue(widget.host.userId);

//     final c = AppColors.of(context);
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//       SnackBar(
//         duration: const Duration(milliseconds: 1500),
//         content: Row(
//           children: [
//             const Icon(
//               Icons.notifications_active_outlined,
//               color: Colors.white,
//               size: 18,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: c.card,
//         behavior: SnackBarBehavior.floating,
//         // duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: c.border),
//         ),
//       ),
//     );
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: isError
//             ? Colors.red.shade700
//             : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(milliseconds: 1500),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   // ── Sub-widgets ────────────────────────────────────────────────────────────

//   Widget _statusDot() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(
//         color: getStatusColor(widget.host.status),
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white24, width: 1),
//       ),
//     );
//   }

//   Widget _flagWidget() {
//     try {
//       return SizedBox(
//         height: 16,
//         width: 22,
//         child: Flag.fromCode(
//           widget.host.flagCode,
//           fit: BoxFit.cover,
//         ),
//       );
//     } catch (_) {
//       return const Icon(
//         Icons.language,
//         color: Colors.white,
//         size: 16,
//       );
//     }
//   }

//   Widget _backgroundImage() {
//     final url = widget.host.profilePhotoUrl;
//     if (url == null || url.isEmpty) {
//       return Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       );
//     }
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   // ── Follow button ──────────────────────────────────────────────────────────

//   Widget _followButton() {
//     final isFollowed = ref.watch(
//       followStateProvider(widget.host.userId),
//     );
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleFollow,
//         borderRadius: BorderRadius.circular(100),
//         child: Padding(
//           padding: const EdgeInsets.all(4),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             transitionBuilder: (child, animation) =>
//                 ScaleTransition(scale: animation, child: child),
//             child: FaIcon(
//               isFollowed
//                   ? FontAwesomeIcons.solidHeart
//                   : FontAwesomeIcons.heart,
//               key: ValueKey(isFollowed),
//               color: isFollowed ? Colors.red : Colors.white,
//               size: 23,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Bottom overlay ─────────────────────────────────────────────────────────

//   Widget _bottomOverlay(AppColors c) {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final cardWidth = constraints.maxWidth;
//           final nameFontSize = (cardWidth * 0.145).clamp(
//             13.0,
//             18.0,
//           );

//           return Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 12,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [Color(0xCC000000), Color(0x00000000)],
//                 stops: [0.0, 1.0],
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           _statusDot(),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               widget.host.displayName,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.lato(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: nameFontSize,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                           children: [
//                             _flagWidget(),
//                             const SizedBox(width: 8),
//                             _ageChip(_age),
//                             const SizedBox(width: 8),
//                             _levelChip(
//                               'Lv ${widget.host.level}',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Video call button — shows spinner when starting call
//                 Material(
//                   color: c.pink,
//                   shape: const CircleBorder(),
//                   clipBehavior: Clip.hardEdge,
//                   child: InkWell(
//                     onTap: _isStartingCall ? null : _onCallTap,
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: _isStartingCall
//                           ? const SizedBox(
//                               width: 25,
//                               height: 25,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.5,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const FaIcon(
//                               FontAwesomeIcons.video,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;

//     return ScaleTransition(
//       scale: _pressScale,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: isDark
//               ? Border.all(
//                   color: c.pink.withValues(alpha: 0.55),
//                   width: 1.5,
//                 )
//               : null,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.5),
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTapDown: (_) => _pressCtrl.forward(),
//             onTapUp: (_) => _pressCtrl.reverse(),
//             onTapCancel: () => _pressCtrl.reverse(),
//             onTap: _onCardTap,
//             onDoubleTap: _toggleFollow,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Hero(
//                   tag: 'host_photo_${widget.host.userId}',
//                   flightShuttleBuilder:
//                       (
//                         flightContext,
//                         animation,
//                         flightDirection,
//                         fromHeroContext,
//                         toHeroContext,
//                       ) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: toHeroContext.widget,
//                         );
//                       },
//                   child: _backgroundImage(),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: _followButton(),
//                 ),
//                 _bottomOverlay(c),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // // // // // lib/widgets/cards/host_card.dart
// // // // // //
// // // // // // Host card used in HostsGridViewScreen.
// // // // // //
// // // // // // Animations in this file:
// // // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // // //
// // // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // // import 'dart:math';

// // // // // import 'package:cheerchat/models/host_model.dart';
// // // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // // import 'package:flag/flag_widget.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';

// // // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // // Widget _ageChip(int age) => Container(
// // // // //   padding: const EdgeInsets.all(3.5),
// // // // //   decoration: const BoxDecoration(
// // // // //     shape: BoxShape.circle,
// // // // //     gradient: LinearGradient(
// // // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     '$age',
// // // // //     style: const TextStyle(
// // // // //       fontSize: 8,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       color: Colors.white,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // Widget _levelChip(String level) => Container(
// // // // //   padding: const EdgeInsets.symmetric(
// // // // //     horizontal: 6,
// // // // //     vertical: 3,
// // // // //   ),
// // // // //   decoration: BoxDecoration(
// // // // //     borderRadius: BorderRadius.circular(8),
// // // // //     gradient: const LinearGradient(
// // // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // // //     ),
// // // // //   ),
// // // // //   child: Text(
// // // // //     level,
// // // // //     style: GoogleFonts.lato(
// // // // //       color: Colors.white,
// // // // //       fontWeight: FontWeight.bold,
// // // // //       fontSize: 8,
// // // // //     ),
// // // // //   ),
// // // // // );

// // // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // // class HostCard extends StatefulWidget {
// // // // //   const HostCard({required this.host, super.key});
// // // // //   final HostModel host;

// // // // //   @override
// // // // //   State<HostCard> createState() => _HostCardState();
// // // // // }

// // // // // class _HostCardState extends State<HostCard>
// // // // //     with TickerProviderStateMixin {
// // // // //   bool _isFollowed = false;
// // // // //   late int _age;

// // // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // // //   // Uses two separate controllers so press-in and release can have different
// // // // //   // curves and durations (snappy down, springy up).
// // // // //   late final AnimationController _pressCtrl;
// // // // //   late final Animation<double> _pressScale;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // // //     _pressCtrl = AnimationController(
// // // // //       vsync: this,
// // // // //       duration: const Duration(milliseconds: 110),
// // // // //       reverseDuration: const Duration(milliseconds: 220),
// // // // //     );
// // // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // // //       CurvedAnimation(
// // // // //         parent: _pressCtrl,
// // // // //         curve: Curves.easeInOut,
// // // // //         reverseCurve: Curves.elasticOut,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _pressCtrl.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // // //   void _toggleFollow() =>
// // // // //       setState(() => _isFollowed = !_isFollowed);

// // // // //   void _onCardTap() {
// // // // //     Navigator.of(context, rootNavigator: true).push(
// // // // //       AppTransitions.heroFade(
// // // // //         ProfileDetailsScreen(host: widget.host),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _onCallTap() {
// // // // //     HapticFeedback.mediumImpact();
// // // // //     switch (widget.host.status) {
// // // // //       case HostStatus.online:
// // // // //         Navigator.of(context, rootNavigator: true).push(
// // // // //           AppTransitions.scaleUp(
// // // // //             OngoingCallScreen(
// // // // //               host: widget.host,
// // // // //               initialCoins: 1000,
// // // // //               testMode: true,
// // // // //               isAlreadyFollowing: false,
// // // // //             ),
// // // // //           ),
// // // // //         );
// // // // //         break;
// // // // //       case HostStatus.busy:
// // // // //         _autoQueue();
// // // // //         break;
// // // // //       case HostStatus.offline:
// // // // //         break;
// // // // //     }
// // // // //   }

// // // // //   void _autoQueue() {
// // // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // // //     final c = AppColors.of(context);
// // // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Row(
// // // // //           children: [
// // // // //             const Icon(
// // // // //               Icons.notifications_active_outlined,
// // // // //               color: Colors.white,
// // // // //               size: 18,
// // // // //             ),
// // // // //             const SizedBox(width: 10),
// // // // //             Expanded(
// // // // //               child: Text(
// // // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // // //                 style: const TextStyle(color: Colors.white),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         backgroundColor: c.card,
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         duration: const Duration(seconds: 3),
// // // // //         shape: RoundedRectangleBorder(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           side: BorderSide(color: c.border),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // // //   Widget _statusDot() {
// // // // //     return AnimatedContainer(
// // // // //       duration: const Duration(milliseconds: 300),
// // // // //       width: 10,
// // // // //       height: 10,
// // // // //       decoration: BoxDecoration(
// // // // //         color: getStatusColor(widget.host.status),
// // // // //         shape: BoxShape.circle,
// // // // //         border: Border.all(color: Colors.white24, width: 1),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _flagWidget() {
// // // // //     try {
// // // // //       return SizedBox(
// // // // //         height: 16,
// // // // //         width: 22,
// // // // //         child: Flag.fromCode(
// // // // //           widget.host.flagCode,
// // // // //           fit: BoxFit.cover,
// // // // //         ),
// // // // //       );
// // // // //     } catch (_) {
// // // // //       return const Icon(
// // // // //         Icons.language,
// // // // //         color: Colors.white,
// // // // //         size: 16,
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   Widget _backgroundImage() {
// // // // //     final url = widget.host.profilePhotoUrl;
// // // // //     if (url == null || url.isEmpty) {
// // // // //       return Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       );
// // // // //     }
// // // // //     return Image.network(
// // // // //       url,
// // // // //       fit: BoxFit.cover,
// // // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // // //         'assets/default_profile/default_profile_photo.jpg',
// // // // //         fit: BoxFit.cover,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // // //   Widget _followButton() {
// // // // //     return Material(
// // // // //       color: Colors.transparent,
// // // // //       child: InkWell(
// // // // //         onTap: () {
// // // // //           HapticFeedback.lightImpact();
// // // // //           _toggleFollow();
// // // // //         },
// // // // //         borderRadius: BorderRadius.circular(100),
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(4),
// // // // //           child: AnimatedSwitcher(
// // // // //             duration: const Duration(milliseconds: 200),
// // // // //             transitionBuilder: (child, animation) =>
// // // // //                 ScaleTransition(scale: animation, child: child),
// // // // //             child: FaIcon(
// // // // //               _isFollowed
// // // // //                   ? FontAwesomeIcons.solidHeart
// // // // //                   : FontAwesomeIcons.heart,
// // // // //               key: ValueKey(_isFollowed),
// // // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // // //               size: 23,
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // // //   Widget _bottomOverlay(AppColors c) {
// // // // //     return Positioned(
// // // // //       left: 0,
// // // // //       right: 0,
// // // // //       bottom: 0,
// // // // //       child: LayoutBuilder(
// // // // //         builder: (context, constraints) {
// // // // //           // Responsive font: scales 13–18 based on card width so it never
// // // // //           // overflows on high-DPI or narrow screens.
// // // // //           final cardWidth = constraints.maxWidth;
// // // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // // //             13.0,
// // // // //             18.0,
// // // // //           );

// // // // //           return Container(
// // // // //             padding: const EdgeInsets.symmetric(
// // // // //               vertical: 10,
// // // // //               horizontal: 12,
// // // // //             ),
// // // // //             decoration: const BoxDecoration(
// // // // //               gradient: LinearGradient(
// // // // //                 begin: Alignment.bottomCenter,
// // // // //                 end: Alignment.topCenter,
// // // // //                 colors: [
// // // // //                   Color(0xCC000000), // 80% black at bottom
// // // // //                   Color(0x00000000), // transparent at top
// // // // //                 ],
// // // // //                 stops: [0.0, 1.0],
// // // // //               ),
// // // // //             ),
// // // // //             child: Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: Column(
// // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                     children: [
// // // // //                       // Name row
// // // // //                       Row(
// // // // //                         children: [
// // // // //                           _statusDot(),
// // // // //                           const SizedBox(width: 4),
// // // // //                           Expanded(
// // // // //                             child: Text(
// // // // //                               widget.host.displayName,
// // // // //                               maxLines: 1,
// // // // //                               overflow: TextOverflow.ellipsis,
// // // // //                               style: GoogleFonts.lato(
// // // // //                                 color: Colors.white,
// // // // //                                 fontWeight: FontWeight.bold,
// // // // //                                 fontSize: nameFontSize,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                       const SizedBox(height: 4),
// // // // //                       // Chips row — FittedBox prevents overflow on any density
// // // // //                       FittedBox(
// // // // //                         fit: BoxFit.scaleDown,
// // // // //                         alignment: Alignment.centerLeft,
// // // // //                         child: Row(
// // // // //                           crossAxisAlignment:
// // // // //                               CrossAxisAlignment.center,
// // // // //                           children: [
// // // // //                             _flagWidget(),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _ageChip(_age),
// // // // //                             const SizedBox(width: 8),
// // // // //                             _levelChip(
// // // // //                               'Lv ${widget.host.level}',
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 8),
// // // // //                 // Video call button
// // // // //                 Material(
// // // // //                   color: c.pink,
// // // // //                   shape: const CircleBorder(),
// // // // //                   clipBehavior: Clip.hardEdge,
// // // // //                   child: InkWell(
// // // // //                     onTap: _onCallTap,
// // // // //                     child: const Padding(
// // // // //                       padding: EdgeInsets.all(10),
// // // // //                       child: FaIcon(
// // // // //                         FontAwesomeIcons.video,
// // // // //                         color: Colors.white,
// // // // //                         size: 25,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final c = AppColors.of(context);
// // // // //     final isDark =
// // // // //         Theme.of(context).brightness == Brightness.dark;

// // // // //     return ScaleTransition(
// // // // //       scale: _pressScale,
// // // // //       child: Container(
// // // // //         decoration: BoxDecoration(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           border: isDark
// // // // //               ? Border.all(
// // // // //                   color: c.pink.withValues(alpha: 0.55),
// // // // //                   width: 1.5,
// // // // //                 )
// // // // //               : null,
// // // // //         ),
// // // // //         child: ClipRRect(
// // // // //           borderRadius: BorderRadius.circular(10.5),
// // // // //           child: GestureDetector(
// // // // //             behavior: HitTestBehavior.opaque,
// // // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // // //             onTap: _onCardTap,
// // // // //             onDoubleTap: _toggleFollow,
// // // // //             child: Stack(
// // // // //               fit: StackFit.expand,
// // // // //               children: [
// // // // //                 // ── Photo background — Hero source ───────────────────────
// // // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // // //                 Hero(
// // // // //                   tag: 'host_photo_${widget.host.userId}',
// // // // //                   flightShuttleBuilder:
// // // // //                       (
// // // // //                         flightContext,
// // // // //                         animation,
// // // // //                         flightDirection,
// // // // //                         fromHeroContext,
// // // // //                         toHeroContext,
// // // // //                       ) {
// // // // //                         // Fade between the two hero states during flight
// // // // //                         return FadeTransition(
// // // // //                           opacity: animation,
// // // // //                           child: toHeroContext.widget,
// // // // //                         );
// // // // //                       },
// // // // //                   child: _backgroundImage(),
// // // // //                 ),

// // // // //                 // ── Follow / heart button ────────────────────────────────
// // // // //                 Positioned(
// // // // //                   top: 8,
// // // // //                   right: 8,
// // // // //                   child: _followButton(),
// // // // //                 ),

// // // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // // //                 _bottomOverlay(c),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // ✅ WIRED TO BACKEND:
// // // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // // //   - Busy host → CallApiService.joinQueue()
// // // // //   - Follow heart → SocialService.follow()/unfollow()
// // // // //   - Reads wallet balance from walletBalanceProvider
// // // // //
// // // // // Animations (unchanged):
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/services/call_api_service.dart';
// // // // import 'package:cheerchat/services/social_service.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends ConsumerStatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends ConsumerState<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   bool _isStartingCall = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() {
// // // //     HapticFeedback.lightImpact();
// // // //     final wasFollowed = _isFollowed;
// // // //     setState(() => _isFollowed = !_isFollowed);

// // // //     // Fire API call — revert on failure
// // // //     final social = ref.read(socialServiceProvider);
// // // //     final future = _isFollowed
// // // //         ? social.follow(widget.host.userId)
// // // //         : social.unfollow(widget.host.userId);

// // // //     future.then((ok) {
// // // //       if (!ok && mounted) {
// // // //         setState(() => _isFollowed = wasFollowed);
// // // //       }
// // // //     });
// // // //   }

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Future<void> _onCallTap() async {
// // // //     HapticFeedback.mediumImpact();

// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         await _startCallFlow();
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // // //   Future<void> _startCallFlow() async {
// // // //     if (_isStartingCall) return; // prevent double-tap
// // // //     setState(() => _isStartingCall = true);

// // // //     try {
// // // //       // 1. Check local coin balance first (quick fail)
// // // //       final coins = ref.read(coinBalanceProvider);
// // // //       if (coins < widget.host.priceCoins) {
// // // //         if (mounted) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // // //             isError: true,
// // // //           );
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 2. Call the backend to start the call session
// // // //       final callApi = ref.read(callApiServiceProvider);
// // // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // // //       if (!mounted) return;

// // // //       if (!res.ok) {
// // // //         // Handle specific errors
// // // //         final error = res.error ?? 'Could not start call';
// // // //         if (res.statusCode == 409) {
// // // //           // Host became busy between grid load and tap
// // // //           _autoQueue();
// // // //         } else if (res.statusCode == 400 &&
// // // //             error.contains('Insufficient')) {
// // // //           _showSnackBar(
// // // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // // //             isError: true,
// // // //           );
// // // //         } else {
// // // //           _showSnackBar(error, isError: true);
// // // //         }
// // // //         return;
// // // //       }

// // // //       // 3. Extract server response
// // // //       final sessionId = res.data['session_id'] as String;
// // // //       final channelName = res.data['channel_name'] as String;
// // // //       final callerToken = res.data['caller_token'] as String;
// // // //       final callerUid = res.data['caller_uid'] as int;
// // // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // // //       // 4. Push OngoingCallScreen with REAL server values
// // // //       if (mounted) {
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // // //               initialCoins: coins,
// // // //               sessionId: sessionId,
// // // //               channelId: channelName,
// // // //               token: callerToken,
// // // //               localUid: callerUid,
// // // //               isAlreadyFollowing: _isFollowed,
// // // //             ),
// // // //           ),
// // // //         );

// // // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // // //         ref.read(walletBalanceProvider.notifier).refresh();
// // // //       }
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // // //       }
// // // //     } finally {
// // // //       if (mounted) setState(() => _isStartingCall = false);
// // // //     }
// // // //   }

// // // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // // //   void _autoQueue() {
// // // //     final callApi = ref.read(callApiServiceProvider);
// // // //     callApi.joinQueue(widget.host.userId);

// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showSnackBar(String message, {bool isError = false}) {
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: _toggleFollow,
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000),
// // // //                   Color(0x00000000),
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip('Lv ${widget.host.level}'),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button — shows spinner when starting call
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _isStartingCall ? null : _onCallTap,
// // // //                     child: Padding(
// // // //                       padding: const EdgeInsets.all(10),
// // // //                       child: _isStartingCall
// // // //                           ? const SizedBox(
// // // //                               width: 25,
// // // //                               height: 25,
// // // //                               child: CircularProgressIndicator(
// // // //                                 strokeWidth: 2.5,
// // // //                                 color: Colors.white,
// // // //                               ),
// // // //                             )
// // // //                           : const FaIcon(
// // // //                               FontAwesomeIcons.video,
// // // //                               color: Colors.white,
// // // //                               size: 25,
// // // //                             ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder: (
// // // //                     flightContext,
// // // //                     animation,
// // // //                     flightDirection,
// // // //                     fromHeroContext,
// // // //                     toHeroContext,
// // // //                   ) {
// // // //                     return FadeTransition(
// // // //                       opacity: animation,
// // // //                       child: toHeroContext.widget,
// // // //                     );
// // // //                   },
// // // //                   child: _backgroundImage(),
// // // //                 ),
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     final wasFollowed = _isFollowed;
// // //     setState(() => _isFollowed = !_isFollowed);

// // //     // Fire API call — revert on failure
// // //     final social = ref.read(socialServiceProvider);
// // //     final future = _isFollowed
// // //         ? social.follow(widget.host.userId)
// // //         : social.unfollow(widget.host.userId);

// // //     future.then((ok) {
// // //       if (!ok && mounted) {
// // //         setState(() => _isFollowed = wasFollowed);
// // //       }
// // //     });
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final walletState = ref.read(walletBalanceProvider);
// // //       final coins = walletState.asData?.value?.coinBalance;

// // //       // Only do local check if wallet is loaded — otherwise let server validate
// // //       if (coins != null && coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(
// // //         hostId: widget.host.userId,
// // //       );

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(
// // //                 priceCoins: pricePerMinute,
// // //               ),
// // //               initialCoins: coins ?? 0,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: _isFollowed,
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar(
// // //           'Connection error. Please try again.',
// // //           isError: true,
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(
// // //           message,
// // //           style: const TextStyle(color: Colors.white),
// // //         ),
// // //         backgroundColor: isError
// // //             ? Colors.red.shade700
// // //             : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // //             13.0,
// // //             18.0,
// // //           );

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [Color(0xCC000000), Color(0x00000000)],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment:
// // //                               CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip(
// // //                               'Lv ${widget.host.level}',
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder:
// // //                       (
// // //                         flightContext,
// // //                         animation,
// // //                         flightDirection,
// // //                         fromHeroContext,
// // //                         toHeroContext,
// // //                       ) {
// // //                         return FadeTransition(
// // //                           opacity: animation,
// // //                           child: toHeroContext.widget,
// // //                         );
// // //                       },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // Animations in this file:
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // //
// // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends StatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   State<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends State<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // //   // Uses two separate controllers so press-in and release can have different
// // // //   // curves and durations (snappy down, springy up).
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() =>
// // // //       setState(() => _isFollowed = !_isFollowed);

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _onCallTap() {
// // // //     HapticFeedback.mediumImpact();
// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host,
// // // //               initialCoins: 1000,
// // // //               testMode: true,
// // // //               isAlreadyFollowing: false,
// // // //             ),
// // // //           ),
// // // //         );
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   void _autoQueue() {
// // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: () {
// // // //           HapticFeedback.lightImpact();
// // // //           _toggleFollow();
// // // //         },
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           // Responsive font: scales 13–18 based on card width so it never
// // // //           // overflows on high-DPI or narrow screens.
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // //             13.0,
// // // //             18.0,
// // // //           );

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000), // 80% black at bottom
// // // //                   Color(0x00000000), // transparent at top
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       // Name row
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       // Chips row — FittedBox prevents overflow on any density
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment:
// // // //                               CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip(
// // // //                               'Lv ${widget.host.level}',
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _onCallTap,
// // // //                     child: const Padding(
// // // //                       padding: EdgeInsets.all(10),
// // // //                       child: FaIcon(
// // // //                         FontAwesomeIcons.video,
// // // //                         color: Colors.white,
// // // //                         size: 25,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 // ── Photo background — Hero source ───────────────────────
// // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder:
// // // //                       (
// // // //                         flightContext,
// // // //                         animation,
// // // //                         flightDirection,
// // // //                         fromHeroContext,
// // // //                         toHeroContext,
// // // //                       ) {
// // // //                         // Fade between the two hero states during flight
// // // //                         return FadeTransition(
// // // //                           opacity: animation,
// // // //                           child: toHeroContext.widget,
// // // //                         );
// // // //                       },
// // // //                   child: _backgroundImage(),
// // // //                 ),

// // // //                 // ── Follow / heart button ────────────────────────────────
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),

// // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     final wasFollowed = _isFollowed;
// // //     setState(() => _isFollowed = !_isFollowed);

// // //     // Fire API call — revert on failure
// // //     final social = ref.read(socialServiceProvider);
// // //     final future = _isFollowed
// // //         ? social.follow(widget.host.userId)
// // //         : social.unfollow(widget.host.userId);

// // //     future.then((ok) {
// // //       if (!ok && mounted) {
// // //         setState(() => _isFollowed = wasFollowed);
// // //       }
// // //     });
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final coins = ref.read(coinBalanceProvider);
// // //       if (coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // //               initialCoins: coins,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: _isFollowed,
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000),
// // //                   Color(0x00000000),
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip('Lv ${widget.host.level}'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder: (
// // //                     flightContext,
// // //                     animation,
// // //                     flightDirection,
// // //                     fromHeroContext,
// // //                     toHeroContext,
// // //                   ) {
// // //                     return FadeTransition(
// // //                       opacity: animation,
// // //                       child: toHeroContext.widget,
// // //                     );
// // //                   },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/providers/follow_provider.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     ref.read(followStateProvider(widget.host.userId).notifier).toggle();
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final walletState = ref.read(walletBalanceProvider);
// //       final coins = walletState.asData?.value?.coinBalance;

// //       // Only do local check if wallet is loaded — otherwise let server validate
// //       if (coins != null && coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(
// //         hostId: widget.host.userId,
// //       );

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(
// //                 priceCoins: pricePerMinute,
// //               ),
// //               initialCoins: coins ?? 0,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: ref.read(followStateProvider(widget.host.userId)),
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar(
// //           'Connection error. Please try again.',
// //           isError: true,
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         backgroundColor: isError
// //             ? Colors.red.shade700
// //             : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //   Widget _followButton() {
// //     final isFollowed = ref.watch(followStateProvider(widget.host.userId));
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(isFollowed),
// //               color: isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(
// //             13.0,
// //             18.0,
// //           );

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [Color(0xCC000000), Color(0x00000000)],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip(
// //                               'Lv ${widget.host.level}',
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder:
// //                       (
// //                         flightContext,
// //                         animation,
// //                         flightDirection,
// //                         fromHeroContext,
// //                         toHeroContext,
// //                       ) {
// //                         return FadeTransition(
// //                           opacity: animation,
// //                           child: toHeroContext.widget,
// //                         );
// //                       },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // Animations in this file:
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // //
// // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // hardcoded — they need contrast over an image regardless of theme.
// // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends StatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   State<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends State<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // //   // Uses two separate controllers so press-in and release can have different
// // //   // curves and durations (snappy down, springy up).
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() =>
// // //       setState(() => _isFollowed = !_isFollowed);

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   void _onCallTap() {
// // //     HapticFeedback.mediumImpact();
// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host,
// // //               initialCoins: 1000,
// // //               testMode: true,
// // //               isAlreadyFollowing: false,
// // //             ),
// // //           ),
// // //         );
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   void _autoQueue() {
// // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────
// // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: () {
// // //           HapticFeedback.lightImpact();
// // //           _toggleFollow();
// // //         },
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           // Responsive font: scales 13–18 based on card width so it never
// // //           // overflows on high-DPI or narrow screens.
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // //             13.0,
// // //             18.0,
// // //           );

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000), // 80% black at bottom
// // //                   Color(0x00000000), // transparent at top
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       // Name row
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       // Chips row — FittedBox prevents overflow on any density
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment:
// // //                               CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip(
// // //                               'Lv ${widget.host.level}',
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _onCallTap,
// // //                     child: const Padding(
// // //                       padding: EdgeInsets.all(10),
// // //                       child: FaIcon(
// // //                         FontAwesomeIcons.video,
// // //                         color: Colors.white,
// // //                         size: 25,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 // ── Photo background — Hero source ───────────────────────
// // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder:
// // //                       (
// // //                         flightContext,
// // //                         animation,
// // //                         flightDirection,
// // //                         fromHeroContext,
// // //                         toHeroContext,
// // //                       ) {
// // //                         // Fade between the two hero states during flight
// // //                         return FadeTransition(
// // //                           opacity: animation,
// // //                           child: toHeroContext.widget,
// // //                         );
// // //                       },
// // //                   child: _backgroundImage(),
// // //                 ),

// // //                 // ── Follow / heart button ────────────────────────────────
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),

// // //                 // ── Bottom overlay with name + chips + call button ───────
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/services/social_service.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isFollowed = false;
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     final wasFollowed = _isFollowed;
// //     setState(() => _isFollowed = !_isFollowed);

// //     // Fire API call — revert on failure
// //     final social = ref.read(socialServiceProvider);
// //     final future = _isFollowed
// //         ? social.follow(widget.host.userId)
// //         : social.unfollow(widget.host.userId);

// //     future.then((ok) {
// //       if (!ok && mounted) {
// //         setState(() => _isFollowed = wasFollowed);
// //       }
// //     });
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final coins = ref.read(coinBalanceProvider);
// //       if (coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(hostId: widget.host.userId);

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// //               initialCoins: coins,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: _isFollowed,
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar('Connection error. Please try again.', isError: true);
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message, style: const TextStyle(color: Colors.white)),
// //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               _isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(_isFollowed),
// //               color: _isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [
// //                   Color(0xCC000000),
// //                   Color(0x00000000),
// //                 ],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment: CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip('Lv ${widget.host.level}'),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark = Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder: (
// //                     flightContext,
// //                     animation,
// //                     flightDirection,
// //                     fromHeroContext,
// //                     toHeroContext,
// //                   ) {
// //                     return FadeTransition(
// //                       opacity: animation,
// //                       child: toHeroContext.widget,
// //                     );
// //                   },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/widgets/cards/host_card.dart
// //
// // Host card used in HostsGridViewScreen.
// //
// // ✅ WIRED TO BACKEND:
// //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// //   - Busy host → CallApiService.joinQueue()
// //   - Follow heart → SocialService.follow()/unfollow()
// //   - Reads wallet balance from walletBalanceProvider
// //
// // Animations (unchanged):
// //   1. Card press — scales down to 0.95 on tap, springs back on release
// //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// //   3. Status dot — AnimatedContainer color transition (300 ms)
// //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// //                        — AppTransitions.scaleUp   → OngoingCallScreen
// //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// import 'dart:math';

// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/providers/wallet_provider.dart';
// import 'package:cheerchat/screens/ongoing_call_screen.dart';
// import 'package:cheerchat/screens/profile_details_screen.dart';
// import 'package:cheerchat/services/call_api_service.dart';
// import 'package:cheerchat/providers/follow_provider.dart';
// import 'package:cheerchat/theme/app_colors.dart';
// import 'package:cheerchat/utils/app_transitions.dart';
// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// Widget _ageChip(int age) => Container(
//   padding: const EdgeInsets.all(3.5),
//   decoration: const BoxDecoration(
//     shape: BoxShape.circle,
//     gradient: LinearGradient(
//       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
//     ),
//   ),
//   child: Text(
//     '$age',
//     style: const TextStyle(
//       fontSize: 8,
//       fontWeight: FontWeight.bold,
//       color: Colors.white,
//     ),
//   ),
// );

// Widget _levelChip(String level) => Container(
//   padding: const EdgeInsets.symmetric(
//     horizontal: 6,
//     vertical: 3,
//   ),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(8),
//     gradient: const LinearGradient(
//       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
//     ),
//   ),
//   child: Text(
//     level,
//     style: GoogleFonts.lato(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 8,
//     ),
//   ),
// );

// // ─────────────────────────────────────────────────────────────────────────────

// class HostCard extends ConsumerStatefulWidget {
//   const HostCard({required this.host, super.key});
//   final HostModel host;

//   @override
//   ConsumerState<HostCard> createState() => _HostCardState();
// }

// class _HostCardState extends ConsumerState<HostCard>
//     with TickerProviderStateMixin {
//   bool _isStartingCall = false;
//   late int _age;

//   // ── Press-bounce animation ─────────────────────────────────────────────────
//   late final AnimationController _pressCtrl;
//   late final Animation<double> _pressScale;

//   @override
//   void initState() {
//     super.initState();
//     _age = widget.host.age ?? (18 + Random().nextInt(23));

//     _pressCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 110),
//       reverseDuration: const Duration(milliseconds: 220),
//     );
//     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
//       CurvedAnimation(
//         parent: _pressCtrl,
//         curve: Curves.easeInOut,
//         reverseCurve: Curves.elasticOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pressCtrl.dispose();
//     super.dispose();
//   }

//   // ── Tap handlers ───────────────────────────────────────────────────────────

//   void _toggleFollow() {
//     HapticFeedback.lightImpact();
//     // ref.read(followStateProvider(widget.host.userId).notifier).toggle();
//     ref
//         .read(followNotifierProvider.notifier)
//         .toggle(widget.host.userId);
//   }

//   void _onCardTap() {
//     Navigator.of(context, rootNavigator: true).push(
//       AppTransitions.heroFade(
//         ProfileDetailsScreen(host: widget.host),
//       ),
//     );
//   }

//   Future<void> _onCallTap() async {
//     HapticFeedback.mediumImpact();

//     switch (widget.host.status) {
//       case HostStatus.online:
//         await _startCallFlow();
//         break;
//       case HostStatus.busy:
//         _autoQueue();
//         break;
//       case HostStatus.offline:
//         break;
//     }
//   }

//   // ── Start call — the main wiring ─────────────────────────────────────────

//   Future<void> _startCallFlow() async {
//     if (_isStartingCall) return; // prevent double-tap
//     setState(() => _isStartingCall = true);

//     try {
//       // 1. Check local coin balance first (quick fail)
//       final walletState = ref.read(walletBalanceProvider);
//       final coins = walletState.asData?.value?.coinBalance;

//       // Only do local check if wallet is loaded — otherwise let server validate
//       if (coins != null && coins < widget.host.priceCoins) {
//         if (mounted) {
//           _showSnackBar(
//             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
//             isError: true,
//           );
//         }
//         return;
//       }

//       // 2. Call the backend to start the call session
//       final callApi = ref.read(callApiServiceProvider);
//       final res = await callApi.startCall(
//         hostId: widget.host.userId,
//       );

//       if (!mounted) return;

//       if (!res.ok) {
//         // Handle specific errors
//         final error = res.error ?? 'Could not start call';
//         if (res.statusCode == 409) {
//           // Host became busy between grid load and tap
//           _autoQueue();
//         } else if (res.statusCode == 400 &&
//             error.contains('Insufficient')) {
//           _showSnackBar(
//             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
//             isError: true,
//           );
//         } else {
//           _showSnackBar(error, isError: true);
//         }
//         return;
//       }

//       // 3. Extract server response
//       final sessionId = res.data['session_id'] as String;
//       final channelName = res.data['channel_name'] as String;
//       final callerToken = res.data['caller_token'] as String;
//       final callerUid = res.data['caller_uid'] as int;
//       final pricePerMinute = res.data['price_per_minute'] as int;

//       // 4. Push OngoingCallScreen with REAL server values
//       if (mounted) {
//         Navigator.of(context, rootNavigator: true).push(
//           AppTransitions.scaleUp(
//             OngoingCallScreen(
//               host: widget.host.copyWith(
//                 priceCoins: pricePerMinute,
//               ),
//               initialCoins: coins ?? 0,
//               sessionId: sessionId,
//               channelId: channelName,
//               token: callerToken,
//               localUid: callerUid,
//               isAlreadyFollowing: ref.read(followStateProvider(widget.host.userId)),
//             ),
//           ),
//         );

//         // 5. Refresh wallet after navigating (call screen will also refresh on end)
//         ref.read(walletBalanceProvider.notifier).refresh();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar(
//           'Connection error. Please try again.',
//           isError: true,
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isStartingCall = false);
//     }
//   }

//   // ── Auto-queue for busy host ─────────────────────────────────────────────

//   void _autoQueue() {
//     final callApi = ref.read(callApiServiceProvider);
//     callApi.joinQueue(widget.host.userId);

//     final c = AppColors.of(context);
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.notifications_active_outlined,
//               color: Colors.white,
//               size: 18,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: c.card,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: c.border),
//         ),
//       ),
//     );
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: isError
//             ? Colors.red.shade700
//             : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   // ── Sub-widgets ────────────────────────────────────────────────────────────

//   Widget _statusDot() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(
//         color: getStatusColor(widget.host.status),
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white24, width: 1),
//       ),
//     );
//   }

//   Widget _flagWidget() {
//     try {
//       return SizedBox(
//         height: 16,
//         width: 22,
//         child: Flag.fromCode(
//           widget.host.flagCode,
//           fit: BoxFit.cover,
//         ),
//       );
//     } catch (_) {
//       return const Icon(
//         Icons.language,
//         color: Colors.white,
//         size: 16,
//       );
//     }
//   }

//   Widget _backgroundImage() {
//     final url = widget.host.profilePhotoUrl;
//     if (url == null || url.isEmpty) {
//       return Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       );
//     }
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   // ── Follow button ──────────────────────────────────────────────────────────

//   Widget _followButton() {
//     final isFollowed = ref.watch(followStateProvider(widget.host.userId));
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleFollow,
//         borderRadius: BorderRadius.circular(100),
//         child: Padding(
//           padding: const EdgeInsets.all(4),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             transitionBuilder: (child, animation) =>
//                 ScaleTransition(scale: animation, child: child),
//             child: FaIcon(
//               isFollowed
//                   ? FontAwesomeIcons.solidHeart
//                   : FontAwesomeIcons.heart,
//               key: ValueKey(isFollowed),
//               color: isFollowed ? Colors.red : Colors.white,
//               size: 23,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Bottom overlay ─────────────────────────────────────────────────────────

//   Widget _bottomOverlay(AppColors c) {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final cardWidth = constraints.maxWidth;
//           final nameFontSize = (cardWidth * 0.145).clamp(
//             13.0,
//             18.0,
//           );

//           return Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 12,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [Color(0xCC000000), Color(0x00000000)],
//                 stops: [0.0, 1.0],
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           _statusDot(),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               widget.host.displayName,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.lato(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: nameFontSize,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                           children: [
//                             _flagWidget(),
//                             const SizedBox(width: 8),
//                             _ageChip(_age),
//                             const SizedBox(width: 8),
//                             _levelChip(
//                               'Lv ${widget.host.level}',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Video call button — shows spinner when starting call
//                 Material(
//                   color: c.pink,
//                   shape: const CircleBorder(),
//                   clipBehavior: Clip.hardEdge,
//                   child: InkWell(
//                     onTap: _isStartingCall ? null : _onCallTap,
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: _isStartingCall
//                           ? const SizedBox(
//                               width: 25,
//                               height: 25,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.5,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const FaIcon(
//                               FontAwesomeIcons.video,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;

//     return ScaleTransition(
//       scale: _pressScale,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: isDark
//               ? Border.all(
//                   color: c.pink.withValues(alpha: 0.55),
//                   width: 1.5,
//                 )
//               : null,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.5),
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTapDown: (_) => _pressCtrl.forward(),
//             onTapUp: (_) => _pressCtrl.reverse(),
//             onTapCancel: () => _pressCtrl.reverse(),
//             onTap: _onCardTap,
//             onDoubleTap: _toggleFollow,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Hero(
//                   tag: 'host_photo_${widget.host.userId}',
//                   flightShuttleBuilder:
//                       (
//                         flightContext,
//                         animation,
//                         flightDirection,
//                         fromHeroContext,
//                         toHeroContext,
//                       ) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: toHeroContext.widget,
//                         );
//                       },
//                   child: _backgroundImage(),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: _followButton(),
//                 ),
//                 _bottomOverlay(c),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // // // // lib/widgets/cards/host_card.dart
// // // // //
// // // // // Host card used in HostsGridViewScreen.
// // // // //
// // // // // Animations in this file:
// // // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // // //
// // // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // // hardcoded — they need contrast over an image regardless of theme.
// // // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // // import 'dart:math';

// // // // import 'package:cheerchat/models/host_model.dart';
// // // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:cheerchat/utils/app_transitions.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';

// // // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // // Widget _ageChip(int age) => Container(
// // // //   padding: const EdgeInsets.all(3.5),
// // // //   decoration: const BoxDecoration(
// // // //     shape: BoxShape.circle,
// // // //     gradient: LinearGradient(
// // // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     '$age',
// // // //     style: const TextStyle(
// // // //       fontSize: 8,
// // // //       fontWeight: FontWeight.bold,
// // // //       color: Colors.white,
// // // //     ),
// // // //   ),
// // // // );

// // // // Widget _levelChip(String level) => Container(
// // // //   padding: const EdgeInsets.symmetric(
// // // //     horizontal: 6,
// // // //     vertical: 3,
// // // //   ),
// // // //   decoration: BoxDecoration(
// // // //     borderRadius: BorderRadius.circular(8),
// // // //     gradient: const LinearGradient(
// // // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // // //     ),
// // // //   ),
// // // //   child: Text(
// // // //     level,
// // // //     style: GoogleFonts.lato(
// // // //       color: Colors.white,
// // // //       fontWeight: FontWeight.bold,
// // // //       fontSize: 8,
// // // //     ),
// // // //   ),
// // // // );

// // // // // ─────────────────────────────────────────────────────────────────────────────

// // // // class HostCard extends StatefulWidget {
// // // //   const HostCard({required this.host, super.key});
// // // //   final HostModel host;

// // // //   @override
// // // //   State<HostCard> createState() => _HostCardState();
// // // // }

// // // // class _HostCardState extends State<HostCard>
// // // //     with TickerProviderStateMixin {
// // // //   bool _isFollowed = false;
// // // //   late int _age;

// // // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // // //   // Uses two separate controllers so press-in and release can have different
// // // //   // curves and durations (snappy down, springy up).
// // // //   late final AnimationController _pressCtrl;
// // // //   late final Animation<double> _pressScale;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // // //     _pressCtrl = AnimationController(
// // // //       vsync: this,
// // // //       duration: const Duration(milliseconds: 110),
// // // //       reverseDuration: const Duration(milliseconds: 220),
// // // //     );
// // // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // // //       CurvedAnimation(
// // // //         parent: _pressCtrl,
// // // //         curve: Curves.easeInOut,
// // // //         reverseCurve: Curves.elasticOut,
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pressCtrl.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // // //   void _toggleFollow() =>
// // // //       setState(() => _isFollowed = !_isFollowed);

// // // //   void _onCardTap() {
// // // //     Navigator.of(context, rootNavigator: true).push(
// // // //       AppTransitions.heroFade(
// // // //         ProfileDetailsScreen(host: widget.host),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _onCallTap() {
// // // //     HapticFeedback.mediumImpact();
// // // //     switch (widget.host.status) {
// // // //       case HostStatus.online:
// // // //         Navigator.of(context, rootNavigator: true).push(
// // // //           AppTransitions.scaleUp(
// // // //             OngoingCallScreen(
// // // //               host: widget.host,
// // // //               initialCoins: 1000,
// // // //               testMode: true,
// // // //               isAlreadyFollowing: false,
// // // //             ),
// // // //           ),
// // // //         );
// // // //         break;
// // // //       case HostStatus.busy:
// // // //         _autoQueue();
// // // //         break;
// // // //       case HostStatus.offline:
// // // //         break;
// // // //     }
// // // //   }

// // // //   void _autoQueue() {
// // // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Row(
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.notifications_active_outlined,
// // // //               color: Colors.white,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // // //                 style: const TextStyle(color: Colors.white),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         backgroundColor: c.card,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         duration: const Duration(seconds: 3),
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           side: BorderSide(color: c.border),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // // //   Widget _statusDot() {
// // // //     return AnimatedContainer(
// // // //       duration: const Duration(milliseconds: 300),
// // // //       width: 10,
// // // //       height: 10,
// // // //       decoration: BoxDecoration(
// // // //         color: getStatusColor(widget.host.status),
// // // //         shape: BoxShape.circle,
// // // //         border: Border.all(color: Colors.white24, width: 1),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _flagWidget() {
// // // //     try {
// // // //       return SizedBox(
// // // //         height: 16,
// // // //         width: 22,
// // // //         child: Flag.fromCode(
// // // //           widget.host.flagCode,
// // // //           fit: BoxFit.cover,
// // // //         ),
// // // //       );
// // // //     } catch (_) {
// // // //       return const Icon(
// // // //         Icons.language,
// // // //         color: Colors.white,
// // // //         size: 16,
// // // //       );
// // // //     }
// // // //   }

// // // //   Widget _backgroundImage() {
// // // //     final url = widget.host.profilePhotoUrl;
// // // //     if (url == null || url.isEmpty) {
// // // //       return Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       );
// // // //     }
// // // //     return Image.network(
// // // //       url,
// // // //       fit: BoxFit.cover,
// // // //       errorBuilder: (_, __, ___) => Image.asset(
// // // //         'assets/default_profile/default_profile_photo.jpg',
// // // //         fit: BoxFit.cover,
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow button ──────────────────────────────────────────────────────────
// // // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // // //   Widget _followButton() {
// // // //     return Material(
// // // //       color: Colors.transparent,
// // // //       child: InkWell(
// // // //         onTap: () {
// // // //           HapticFeedback.lightImpact();
// // // //           _toggleFollow();
// // // //         },
// // // //         borderRadius: BorderRadius.circular(100),
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(4),
// // // //           child: AnimatedSwitcher(
// // // //             duration: const Duration(milliseconds: 200),
// // // //             transitionBuilder: (child, animation) =>
// // // //                 ScaleTransition(scale: animation, child: child),
// // // //             child: FaIcon(
// // // //               _isFollowed
// // // //                   ? FontAwesomeIcons.solidHeart
// // // //                   : FontAwesomeIcons.heart,
// // // //               key: ValueKey(_isFollowed),
// // // //               color: _isFollowed ? Colors.red : Colors.white,
// // // //               size: 23,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // // //   Widget _bottomOverlay(AppColors c) {
// // // //     return Positioned(
// // // //       left: 0,
// // // //       right: 0,
// // // //       bottom: 0,
// // // //       child: LayoutBuilder(
// // // //         builder: (context, constraints) {
// // // //           // Responsive font: scales 13–18 based on card width so it never
// // // //           // overflows on high-DPI or narrow screens.
// // // //           final cardWidth = constraints.maxWidth;
// // // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // // //             13.0,
// // // //             18.0,
// // // //           );

// // // //           return Container(
// // // //             padding: const EdgeInsets.symmetric(
// // // //               vertical: 10,
// // // //               horizontal: 12,
// // // //             ),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.bottomCenter,
// // // //                 end: Alignment.topCenter,
// // // //                 colors: [
// // // //                   Color(0xCC000000), // 80% black at bottom
// // // //                   Color(0x00000000), // transparent at top
// // // //                 ],
// // // //                 stops: [0.0, 1.0],
// // // //               ),
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       // Name row
// // // //                       Row(
// // // //                         children: [
// // // //                           _statusDot(),
// // // //                           const SizedBox(width: 4),
// // // //                           Expanded(
// // // //                             child: Text(
// // // //                               widget.host.displayName,
// // // //                               maxLines: 1,
// // // //                               overflow: TextOverflow.ellipsis,
// // // //                               style: GoogleFonts.lato(
// // // //                                 color: Colors.white,
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: nameFontSize,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       // Chips row — FittedBox prevents overflow on any density
// // // //                       FittedBox(
// // // //                         fit: BoxFit.scaleDown,
// // // //                         alignment: Alignment.centerLeft,
// // // //                         child: Row(
// // // //                           crossAxisAlignment:
// // // //                               CrossAxisAlignment.center,
// // // //                           children: [
// // // //                             _flagWidget(),
// // // //                             const SizedBox(width: 8),
// // // //                             _ageChip(_age),
// // // //                             const SizedBox(width: 8),
// // // //                             _levelChip(
// // // //                               'Lv ${widget.host.level}',
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 // Video call button
// // // //                 Material(
// // // //                   color: c.pink,
// // // //                   shape: const CircleBorder(),
// // // //                   clipBehavior: Clip.hardEdge,
// // // //                   child: InkWell(
// // // //                     onTap: _onCallTap,
// // // //                     child: const Padding(
// // // //                       padding: EdgeInsets.all(10),
// // // //                       child: FaIcon(
// // // //                         FontAwesomeIcons.video,
// // // //                         color: Colors.white,
// // // //                         size: 25,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Build ──────────────────────────────────────────────────────────────────

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     return ScaleTransition(
// // // //       scale: _pressScale,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: isDark
// // // //               ? Border.all(
// // // //                   color: c.pink.withValues(alpha: 0.55),
// // // //                   width: 1.5,
// // // //                 )
// // // //               : null,
// // // //         ),
// // // //         child: ClipRRect(
// // // //           borderRadius: BorderRadius.circular(10.5),
// // // //           child: GestureDetector(
// // // //             behavior: HitTestBehavior.opaque,
// // // //             onTapDown: (_) => _pressCtrl.forward(),
// // // //             onTapUp: (_) => _pressCtrl.reverse(),
// // // //             onTapCancel: () => _pressCtrl.reverse(),
// // // //             onTap: _onCardTap,
// // // //             onDoubleTap: _toggleFollow,
// // // //             child: Stack(
// // // //               fit: StackFit.expand,
// // // //               children: [
// // // //                 // ── Photo background — Hero source ───────────────────────
// // // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // // //                 Hero(
// // // //                   tag: 'host_photo_${widget.host.userId}',
// // // //                   flightShuttleBuilder:
// // // //                       (
// // // //                         flightContext,
// // // //                         animation,
// // // //                         flightDirection,
// // // //                         fromHeroContext,
// // // //                         toHeroContext,
// // // //                       ) {
// // // //                         // Fade between the two hero states during flight
// // // //                         return FadeTransition(
// // // //                           opacity: animation,
// // // //                           child: toHeroContext.widget,
// // // //                         );
// // // //                       },
// // // //                   child: _backgroundImage(),
// // // //                 ),

// // // //                 // ── Follow / heart button ────────────────────────────────
// // // //                 Positioned(
// // // //                   top: 8,
// // // //                   right: 8,
// // // //                   child: _followButton(),
// // // //                 ),

// // // //                 // ── Bottom overlay with name + chips + call button ───────
// // // //                 _bottomOverlay(c),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // ✅ WIRED TO BACKEND:
// // // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // // //   - Busy host → CallApiService.joinQueue()
// // // //   - Follow heart → SocialService.follow()/unfollow()
// // // //   - Reads wallet balance from walletBalanceProvider
// // // //
// // // // Animations (unchanged):
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/services/call_api_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends ConsumerStatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   ConsumerState<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends ConsumerState<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   bool _isStartingCall = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() {
// // //     HapticFeedback.lightImpact();
// // //     final wasFollowed = _isFollowed;
// // //     setState(() => _isFollowed = !_isFollowed);

// // //     // Fire API call — revert on failure
// // //     final social = ref.read(socialServiceProvider);
// // //     final future = _isFollowed
// // //         ? social.follow(widget.host.userId)
// // //         : social.unfollow(widget.host.userId);

// // //     future.then((ok) {
// // //       if (!ok && mounted) {
// // //         setState(() => _isFollowed = wasFollowed);
// // //       }
// // //     });
// // //   }

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   Future<void> _onCallTap() async {
// // //     HapticFeedback.mediumImpact();

// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         await _startCallFlow();
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   // ── Start call — the main wiring ─────────────────────────────────────────

// // //   Future<void> _startCallFlow() async {
// // //     if (_isStartingCall) return; // prevent double-tap
// // //     setState(() => _isStartingCall = true);

// // //     try {
// // //       // 1. Check local coin balance first (quick fail)
// // //       final coins = ref.read(coinBalanceProvider);
// // //       if (coins < widget.host.priceCoins) {
// // //         if (mounted) {
// // //           _showSnackBar(
// // //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// // //             isError: true,
// // //           );
// // //         }
// // //         return;
// // //       }

// // //       // 2. Call the backend to start the call session
// // //       final callApi = ref.read(callApiServiceProvider);
// // //       final res = await callApi.startCall(hostId: widget.host.userId);

// // //       if (!mounted) return;

// // //       if (!res.ok) {
// // //         // Handle specific errors
// // //         final error = res.error ?? 'Could not start call';
// // //         if (res.statusCode == 409) {
// // //           // Host became busy between grid load and tap
// // //           _autoQueue();
// // //         } else if (res.statusCode == 400 &&
// // //             error.contains('Insufficient')) {
// // //           _showSnackBar(
// // //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// // //             isError: true,
// // //           );
// // //         } else {
// // //           _showSnackBar(error, isError: true);
// // //         }
// // //         return;
// // //       }

// // //       // 3. Extract server response
// // //       final sessionId = res.data['session_id'] as String;
// // //       final channelName = res.data['channel_name'] as String;
// // //       final callerToken = res.data['caller_token'] as String;
// // //       final callerUid = res.data['caller_uid'] as int;
// // //       final pricePerMinute = res.data['price_per_minute'] as int;

// // //       // 4. Push OngoingCallScreen with REAL server values
// // //       if (mounted) {
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// // //               initialCoins: coins,
// // //               sessionId: sessionId,
// // //               channelId: channelName,
// // //               token: callerToken,
// // //               localUid: callerUid,
// // //               isAlreadyFollowing: _isFollowed,
// // //             ),
// // //           ),
// // //         );

// // //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// // //         ref.read(walletBalanceProvider.notifier).refresh();
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         _showSnackBar('Connection error. Please try again.', isError: true);
// // //       }
// // //     } finally {
// // //       if (mounted) setState(() => _isStartingCall = false);
// // //     }
// // //   }

// // //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// // //   void _autoQueue() {
// // //     final callApi = ref.read(callApiServiceProvider);
// // //     callApi.joinQueue(widget.host.userId);

// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _showSnackBar(String message, {bool isError = false}) {
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message, style: const TextStyle(color: Colors.white)),
// // //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: _toggleFollow,
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000),
// // //                   Color(0x00000000),
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment: CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip('Lv ${widget.host.level}'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button — shows spinner when starting call
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _isStartingCall ? null : _onCallTap,
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(10),
// // //                       child: _isStartingCall
// // //                           ? const SizedBox(
// // //                               width: 25,
// // //                               height: 25,
// // //                               child: CircularProgressIndicator(
// // //                                 strokeWidth: 2.5,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             )
// // //                           : const FaIcon(
// // //                               FontAwesomeIcons.video,
// // //                               color: Colors.white,
// // //                               size: 25,
// // //                             ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark = Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder: (
// // //                     flightContext,
// // //                     animation,
// // //                     flightDirection,
// // //                     fromHeroContext,
// // //                     toHeroContext,
// // //                   ) {
// // //                     return FadeTransition(
// // //                       opacity: animation,
// // //                       child: toHeroContext.widget,
// // //                     );
// // //                   },
// // //                   child: _backgroundImage(),
// // //                 ),
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/services/social_service.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isFollowed = false;
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     final wasFollowed = _isFollowed;
// //     setState(() => _isFollowed = !_isFollowed);

// //     // Fire API call — revert on failure
// //     final social = ref.read(socialServiceProvider);
// //     final future = _isFollowed
// //         ? social.follow(widget.host.userId)
// //         : social.unfollow(widget.host.userId);

// //     future.then((ok) {
// //       if (!ok && mounted) {
// //         setState(() => _isFollowed = wasFollowed);
// //       }
// //     });
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final walletState = ref.read(walletBalanceProvider);
// //       final coins = walletState.asData?.value?.coinBalance;

// //       // Only do local check if wallet is loaded — otherwise let server validate
// //       if (coins != null && coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(
// //         hostId: widget.host.userId,
// //       );

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(
// //                 priceCoins: pricePerMinute,
// //               ),
// //               initialCoins: coins ?? 0,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: _isFollowed,
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar(
// //           'Connection error. Please try again.',
// //           isError: true,
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         backgroundColor: isError
// //             ? Colors.red.shade700
// //             : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               _isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(_isFollowed),
// //               color: _isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(
// //             13.0,
// //             18.0,
// //           );

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [Color(0xCC000000), Color(0x00000000)],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip(
// //                               'Lv ${widget.host.level}',
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder:
// //                       (
// //                         flightContext,
// //                         animation,
// //                         flightDirection,
// //                         fromHeroContext,
// //                         toHeroContext,
// //                       ) {
// //                         return FadeTransition(
// //                           opacity: animation,
// //                           child: toHeroContext.widget,
// //                         );
// //                       },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // // lib/widgets/cards/host_card.dart
// // // //
// // // // Host card used in HostsGridViewScreen.
// // // //
// // // // Animations in this file:
// // // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // // //
// // // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // // hardcoded — they need contrast over an image regardless of theme.
// // // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // // import 'dart:math';

// // // import 'package:cheerchat/models/host_model.dart';
// // // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // // import 'package:cheerchat/screens/profile_details_screen.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:cheerchat/utils/app_transitions.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';

// // // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // // Widget _ageChip(int age) => Container(
// // //   padding: const EdgeInsets.all(3.5),
// // //   decoration: const BoxDecoration(
// // //     shape: BoxShape.circle,
// // //     gradient: LinearGradient(
// // //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     '$age',
// // //     style: const TextStyle(
// // //       fontSize: 8,
// // //       fontWeight: FontWeight.bold,
// // //       color: Colors.white,
// // //     ),
// // //   ),
// // // );

// // // Widget _levelChip(String level) => Container(
// // //   padding: const EdgeInsets.symmetric(
// // //     horizontal: 6,
// // //     vertical: 3,
// // //   ),
// // //   decoration: BoxDecoration(
// // //     borderRadius: BorderRadius.circular(8),
// // //     gradient: const LinearGradient(
// // //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// // //     ),
// // //   ),
// // //   child: Text(
// // //     level,
// // //     style: GoogleFonts.lato(
// // //       color: Colors.white,
// // //       fontWeight: FontWeight.bold,
// // //       fontSize: 8,
// // //     ),
// // //   ),
// // // );

// // // // ─────────────────────────────────────────────────────────────────────────────

// // // class HostCard extends StatefulWidget {
// // //   const HostCard({required this.host, super.key});
// // //   final HostModel host;

// // //   @override
// // //   State<HostCard> createState() => _HostCardState();
// // // }

// // // class _HostCardState extends State<HostCard>
// // //     with TickerProviderStateMixin {
// // //   bool _isFollowed = false;
// // //   late int _age;

// // //   // ── Press-bounce animation ─────────────────────────────────────────────────
// // //   // Scales the card to 0.95 on finger-down, springs back on release.
// // //   // Uses two separate controllers so press-in and release can have different
// // //   // curves and durations (snappy down, springy up).
// // //   late final AnimationController _pressCtrl;
// // //   late final Animation<double> _pressScale;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// // //     _pressCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 110),
// // //       reverseDuration: const Duration(milliseconds: 220),
// // //     );
// // //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// // //       CurvedAnimation(
// // //         parent: _pressCtrl,
// // //         curve: Curves.easeInOut,
// // //         reverseCurve: Curves.elasticOut,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pressCtrl.dispose();
// // //     super.dispose();
// // //   }

// // //   // ── Tap handlers ───────────────────────────────────────────────────────────

// // //   void _toggleFollow() =>
// // //       setState(() => _isFollowed = !_isFollowed);

// // //   void _onCardTap() {
// // //     Navigator.of(context, rootNavigator: true).push(
// // //       AppTransitions.heroFade(
// // //         ProfileDetailsScreen(host: widget.host),
// // //       ),
// // //     );
// // //   }

// // //   void _onCallTap() {
// // //     HapticFeedback.mediumImpact();
// // //     switch (widget.host.status) {
// // //       case HostStatus.online:
// // //         Navigator.of(context, rootNavigator: true).push(
// // //           AppTransitions.scaleUp(
// // //             OngoingCallScreen(
// // //               host: widget.host,
// // //               initialCoins: 1000,
// // //               testMode: true,
// // //               isAlreadyFollowing: false,
// // //             ),
// // //           ),
// // //         );
// // //         break;
// // //       case HostStatus.busy:
// // //         _autoQueue();
// // //         break;
// // //       case HostStatus.offline:
// // //         break;
// // //     }
// // //   }

// // //   void _autoQueue() {
// // //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Row(
// // //           children: [
// // //             const Icon(
// // //               Icons.notifications_active_outlined,
// // //               color: Colors.white,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 10),
// // //             Expanded(
// // //               child: Text(
// // //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// // //                 style: const TextStyle(color: Colors.white),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         backgroundColor: c.card,
// // //         behavior: SnackBarBehavior.floating,
// // //         duration: const Duration(seconds: 3),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           side: BorderSide(color: c.border),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// // //   Widget _statusDot() {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: 10,
// // //       height: 10,
// // //       decoration: BoxDecoration(
// // //         color: getStatusColor(widget.host.status),
// // //         shape: BoxShape.circle,
// // //         border: Border.all(color: Colors.white24, width: 1),
// // //       ),
// // //     );
// // //   }

// // //   Widget _flagWidget() {
// // //     try {
// // //       return SizedBox(
// // //         height: 16,
// // //         width: 22,
// // //         child: Flag.fromCode(
// // //           widget.host.flagCode,
// // //           fit: BoxFit.cover,
// // //         ),
// // //       );
// // //     } catch (_) {
// // //       return const Icon(
// // //         Icons.language,
// // //         color: Colors.white,
// // //         size: 16,
// // //       );
// // //     }
// // //   }

// // //   Widget _backgroundImage() {
// // //     final url = widget.host.profilePhotoUrl;
// // //     if (url == null || url.isEmpty) {
// // //       return Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       );
// // //     }
// // //     return Image.network(
// // //       url,
// // //       fit: BoxFit.cover,
// // //       errorBuilder: (_, __, ___) => Image.asset(
// // //         'assets/default_profile/default_profile_photo.jpg',
// // //         fit: BoxFit.cover,
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow button ──────────────────────────────────────────────────────────
// // //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// // //   Widget _followButton() {
// // //     return Material(
// // //       color: Colors.transparent,
// // //       child: InkWell(
// // //         onTap: () {
// // //           HapticFeedback.lightImpact();
// // //           _toggleFollow();
// // //         },
// // //         borderRadius: BorderRadius.circular(100),
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(4),
// // //           child: AnimatedSwitcher(
// // //             duration: const Duration(milliseconds: 200),
// // //             transitionBuilder: (child, animation) =>
// // //                 ScaleTransition(scale: animation, child: child),
// // //             child: FaIcon(
// // //               _isFollowed
// // //                   ? FontAwesomeIcons.solidHeart
// // //                   : FontAwesomeIcons.heart,
// // //               key: ValueKey(_isFollowed),
// // //               color: _isFollowed ? Colors.red : Colors.white,
// // //               size: 23,
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// // //   Widget _bottomOverlay(AppColors c) {
// // //     return Positioned(
// // //       left: 0,
// // //       right: 0,
// // //       bottom: 0,
// // //       child: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           // Responsive font: scales 13–18 based on card width so it never
// // //           // overflows on high-DPI or narrow screens.
// // //           final cardWidth = constraints.maxWidth;
// // //           final nameFontSize = (cardWidth * 0.145).clamp(
// // //             13.0,
// // //             18.0,
// // //           );

// // //           return Container(
// // //             padding: const EdgeInsets.symmetric(
// // //               vertical: 10,
// // //               horizontal: 12,
// // //             ),
// // //             decoration: const BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 begin: Alignment.bottomCenter,
// // //                 end: Alignment.topCenter,
// // //                 colors: [
// // //                   Color(0xCC000000), // 80% black at bottom
// // //                   Color(0x00000000), // transparent at top
// // //                 ],
// // //                 stops: [0.0, 1.0],
// // //               ),
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       // Name row
// // //                       Row(
// // //                         children: [
// // //                           _statusDot(),
// // //                           const SizedBox(width: 4),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.host.displayName,
// // //                               maxLines: 1,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: GoogleFonts.lato(
// // //                                 color: Colors.white,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 fontSize: nameFontSize,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       // Chips row — FittedBox prevents overflow on any density
// // //                       FittedBox(
// // //                         fit: BoxFit.scaleDown,
// // //                         alignment: Alignment.centerLeft,
// // //                         child: Row(
// // //                           crossAxisAlignment:
// // //                               CrossAxisAlignment.center,
// // //                           children: [
// // //                             _flagWidget(),
// // //                             const SizedBox(width: 8),
// // //                             _ageChip(_age),
// // //                             const SizedBox(width: 8),
// // //                             _levelChip(
// // //                               'Lv ${widget.host.level}',
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 // Video call button
// // //                 Material(
// // //                   color: c.pink,
// // //                   shape: const CircleBorder(),
// // //                   clipBehavior: Clip.hardEdge,
// // //                   child: InkWell(
// // //                     onTap: _onCallTap,
// // //                     child: const Padding(
// // //                       padding: EdgeInsets.all(10),
// // //                       child: FaIcon(
// // //                         FontAwesomeIcons.video,
// // //                         color: Colors.white,
// // //                         size: 25,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ── Build ──────────────────────────────────────────────────────────────────

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return ScaleTransition(
// // //       scale: _pressScale,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: isDark
// // //               ? Border.all(
// // //                   color: c.pink.withValues(alpha: 0.55),
// // //                   width: 1.5,
// // //                 )
// // //               : null,
// // //         ),
// // //         child: ClipRRect(
// // //           borderRadius: BorderRadius.circular(10.5),
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.opaque,
// // //             onTapDown: (_) => _pressCtrl.forward(),
// // //             onTapUp: (_) => _pressCtrl.reverse(),
// // //             onTapCancel: () => _pressCtrl.reverse(),
// // //             onTap: _onCardTap,
// // //             onDoubleTap: _toggleFollow,
// // //             child: Stack(
// // //               fit: StackFit.expand,
// // //               children: [
// // //                 // ── Photo background — Hero source ───────────────────────
// // //                 // tag matches the Hero destination in ProfileDetailsScreen:
// // //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// // //                 Hero(
// // //                   tag: 'host_photo_${widget.host.userId}',
// // //                   flightShuttleBuilder:
// // //                       (
// // //                         flightContext,
// // //                         animation,
// // //                         flightDirection,
// // //                         fromHeroContext,
// // //                         toHeroContext,
// // //                       ) {
// // //                         // Fade between the two hero states during flight
// // //                         return FadeTransition(
// // //                           opacity: animation,
// // //                           child: toHeroContext.widget,
// // //                         );
// // //                       },
// // //                   child: _backgroundImage(),
// // //                 ),

// // //                 // ── Follow / heart button ────────────────────────────────
// // //                 Positioned(
// // //                   top: 8,
// // //                   right: 8,
// // //                   child: _followButton(),
// // //                 ),

// // //                 // ── Bottom overlay with name + chips + call button ───────
// // //                 _bottomOverlay(c),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // ✅ WIRED TO BACKEND:
// // //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// // //   - Busy host → CallApiService.joinQueue()
// // //   - Follow heart → SocialService.follow()/unfollow()
// // //   - Reads wallet balance from walletBalanceProvider
// // //
// // // Animations (unchanged):
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/services/call_api_service.dart';
// // import 'package:cheerchat/services/social_service.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends ConsumerStatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   ConsumerState<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends ConsumerState<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isFollowed = false;
// //   bool _isStartingCall = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() {
// //     HapticFeedback.lightImpact();
// //     final wasFollowed = _isFollowed;
// //     setState(() => _isFollowed = !_isFollowed);

// //     // Fire API call — revert on failure
// //     final social = ref.read(socialServiceProvider);
// //     final future = _isFollowed
// //         ? social.follow(widget.host.userId)
// //         : social.unfollow(widget.host.userId);

// //     future.then((ok) {
// //       if (!ok && mounted) {
// //         setState(() => _isFollowed = wasFollowed);
// //       }
// //     });
// //   }

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   Future<void> _onCallTap() async {
// //     HapticFeedback.mediumImpact();

// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         await _startCallFlow();
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   // ── Start call — the main wiring ─────────────────────────────────────────

// //   Future<void> _startCallFlow() async {
// //     if (_isStartingCall) return; // prevent double-tap
// //     setState(() => _isStartingCall = true);

// //     try {
// //       // 1. Check local coin balance first (quick fail)
// //       final coins = ref.read(coinBalanceProvider);
// //       if (coins < widget.host.priceCoins) {
// //         if (mounted) {
// //           _showSnackBar(
// //             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
// //             isError: true,
// //           );
// //         }
// //         return;
// //       }

// //       // 2. Call the backend to start the call session
// //       final callApi = ref.read(callApiServiceProvider);
// //       final res = await callApi.startCall(hostId: widget.host.userId);

// //       if (!mounted) return;

// //       if (!res.ok) {
// //         // Handle specific errors
// //         final error = res.error ?? 'Could not start call';
// //         if (res.statusCode == 409) {
// //           // Host became busy between grid load and tap
// //           _autoQueue();
// //         } else if (res.statusCode == 400 &&
// //             error.contains('Insufficient')) {
// //           _showSnackBar(
// //             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
// //             isError: true,
// //           );
// //         } else {
// //           _showSnackBar(error, isError: true);
// //         }
// //         return;
// //       }

// //       // 3. Extract server response
// //       final sessionId = res.data['session_id'] as String;
// //       final channelName = res.data['channel_name'] as String;
// //       final callerToken = res.data['caller_token'] as String;
// //       final callerUid = res.data['caller_uid'] as int;
// //       final pricePerMinute = res.data['price_per_minute'] as int;

// //       // 4. Push OngoingCallScreen with REAL server values
// //       if (mounted) {
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host.copyWith(priceCoins: pricePerMinute),
// //               initialCoins: coins,
// //               sessionId: sessionId,
// //               channelId: channelName,
// //               token: callerToken,
// //               localUid: callerUid,
// //               isAlreadyFollowing: _isFollowed,
// //             ),
// //           ),
// //         );

// //         // 5. Refresh wallet after navigating (call screen will also refresh on end)
// //         ref.read(walletBalanceProvider.notifier).refresh();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar('Connection error. Please try again.', isError: true);
// //       }
// //     } finally {
// //       if (mounted) setState(() => _isStartingCall = false);
// //     }
// //   }

// //   // ── Auto-queue for busy host ─────────────────────────────────────────────

// //   void _autoQueue() {
// //     final callApi = ref.read(callApiServiceProvider);
// //     callApi.joinQueue(widget.host.userId);

// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message, style: const TextStyle(color: Colors.white)),
// //         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────

// //   Widget _followButton() {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: _toggleFollow,
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               _isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(_isFollowed),
// //               color: _isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [
// //                   Color(0xCC000000),
// //                   Color(0x00000000),
// //                 ],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment: CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip('Lv ${widget.host.level}'),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button — shows spinner when starting call
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _isStartingCall ? null : _onCallTap,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(10),
// //                       child: _isStartingCall
// //                           ? const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2.5,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const FaIcon(
// //                               FontAwesomeIcons.video,
// //                               color: Colors.white,
// //                               size: 25,
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark = Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder: (
// //                     flightContext,
// //                     animation,
// //                     flightDirection,
// //                     fromHeroContext,
// //                     toHeroContext,
// //                   ) {
// //                     return FadeTransition(
// //                       opacity: animation,
// //                       child: toHeroContext.widget,
// //                     );
// //                   },
// //                   child: _backgroundImage(),
// //                 ),
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/widgets/cards/host_card.dart
// //
// // Host card used in HostsGridViewScreen.
// //
// // ✅ WIRED TO BACKEND:
// //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// //   - Busy host → CallApiService.joinQueue()
// //   - Follow heart → SocialService.follow()/unfollow()
// //   - Reads wallet balance from walletBalanceProvider
// //
// // Animations (unchanged):
// //   1. Card press — scales down to 0.95 on tap, springs back on release
// //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// //   3. Status dot — AnimatedContainer color transition (300 ms)
// //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// //                        — AppTransitions.scaleUp   → OngoingCallScreen
// //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// import 'dart:math';

// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/providers/wallet_provider.dart';
// import 'package:cheerchat/screens/ongoing_call_screen.dart';
// import 'package:cheerchat/screens/profile_details_screen.dart';
// import 'package:cheerchat/services/call_api_service.dart';
// import 'package:cheerchat/providers/follow_provider.dart';
// import 'package:cheerchat/theme/app_colors.dart';
// import 'package:cheerchat/utils/app_transitions.dart';
// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// Widget _ageChip(int age) => Container(
//   padding: const EdgeInsets.all(3.5),
//   decoration: const BoxDecoration(
//     shape: BoxShape.circle,
//     gradient: LinearGradient(
//       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
//     ),
//   ),
//   child: Text(
//     '$age',
//     style: const TextStyle(
//       fontSize: 8,
//       fontWeight: FontWeight.bold,
//       color: Colors.white,
//     ),
//   ),
// );

// Widget _levelChip(String level) => Container(
//   padding: const EdgeInsets.symmetric(
//     horizontal: 6,
//     vertical: 3,
//   ),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(8),
//     gradient: const LinearGradient(
//       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
//     ),
//   ),
//   child: Text(
//     level,
//     style: GoogleFonts.lato(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 8,
//     ),
//   ),
// );

// // ─────────────────────────────────────────────────────────────────────────────

// class HostCard extends ConsumerStatefulWidget {
//   const HostCard({required this.host, super.key});
//   final HostModel host;

//   @override
//   ConsumerState<HostCard> createState() => _HostCardState();
// }

// class _HostCardState extends ConsumerState<HostCard>
//     with TickerProviderStateMixin {
//   bool _isStartingCall = false;
//   late int _age;

//   // ── Press-bounce animation ─────────────────────────────────────────────────
//   late final AnimationController _pressCtrl;
//   late final Animation<double> _pressScale;

//   @override
//   void initState() {
//     super.initState();
//     _age = widget.host.age ?? (18 + Random().nextInt(23));

//     _pressCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 110),
//       reverseDuration: const Duration(milliseconds: 220),
//     );
//     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
//       CurvedAnimation(
//         parent: _pressCtrl,
//         curve: Curves.easeInOut,
//         reverseCurve: Curves.elasticOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pressCtrl.dispose();
//     super.dispose();
//   }

//   // ── Tap handlers ───────────────────────────────────────────────────────────

//   void _toggleFollow() {
//     HapticFeedback.lightImpact();
//     ref.read(followStateProvider(widget.host.userId).notifier).toggle();
//   }

//   void _onCardTap() {
//     Navigator.of(context, rootNavigator: true).push(
//       AppTransitions.heroFade(
//         ProfileDetailsScreen(host: widget.host),
//       ),
//     );
//   }

//   Future<void> _onCallTap() async {
//     HapticFeedback.mediumImpact();

//     switch (widget.host.status) {
//       case HostStatus.online:
//         await _startCallFlow();
//         break;
//       case HostStatus.busy:
//         _autoQueue();
//         break;
//       case HostStatus.offline:
//         break;
//     }
//   }

//   // ── Start call — the main wiring ─────────────────────────────────────────

//   Future<void> _startCallFlow() async {
//     if (_isStartingCall) return; // prevent double-tap
//     setState(() => _isStartingCall = true);

//     try {
//       // 1. Check local coin balance first (quick fail)
//       final walletState = ref.read(walletBalanceProvider);
//       final coins = walletState.asData?.value?.coinBalance;

//       // Only do local check if wallet is loaded — otherwise let server validate
//       if (coins != null && coins < widget.host.priceCoins) {
//         if (mounted) {
//           _showSnackBar(
//             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
//             isError: true,
//           );
//         }
//         return;
//       }

//       // 2. Call the backend to start the call session
//       final callApi = ref.read(callApiServiceProvider);
//       final res = await callApi.startCall(
//         hostId: widget.host.userId,
//       );

//       if (!mounted) return;

//       if (!res.ok) {
//         // Handle specific errors
//         final error = res.error ?? 'Could not start call';
//         if (res.statusCode == 409) {
//           // Host became busy between grid load and tap
//           _autoQueue();
//         } else if (res.statusCode == 400 &&
//             error.contains('Insufficient')) {
//           _showSnackBar(
//             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
//             isError: true,
//           );
//         } else {
//           _showSnackBar(error, isError: true);
//         }
//         return;
//       }

//       // 3. Extract server response
//       final sessionId = res.data['session_id'] as String;
//       final channelName = res.data['channel_name'] as String;
//       final callerToken = res.data['caller_token'] as String;
//       final callerUid = res.data['caller_uid'] as int;
//       final pricePerMinute = res.data['price_per_minute'] as int;

//       // 4. Push OngoingCallScreen with REAL server values
//       if (mounted) {
//         Navigator.of(context, rootNavigator: true).push(
//           AppTransitions.scaleUp(
//             OngoingCallScreen(
//               host: widget.host.copyWith(
//                 priceCoins: pricePerMinute,
//               ),
//               initialCoins: coins ?? 0,
//               sessionId: sessionId,
//               channelId: channelName,
//               token: callerToken,
//               localUid: callerUid,
//               isAlreadyFollowing: ref.read(followStateProvider(widget.host.userId)),
//             ),
//           ),
//         );

//         // 5. Refresh wallet after navigating (call screen will also refresh on end)
//         ref.read(walletBalanceProvider.notifier).refresh();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar(
//           'Connection error. Please try again.',
//           isError: true,
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isStartingCall = false);
//     }
//   }

//   // ── Auto-queue for busy host ─────────────────────────────────────────────

//   void _autoQueue() {
//     final callApi = ref.read(callApiServiceProvider);
//     callApi.joinQueue(widget.host.userId);

//     final c = AppColors.of(context);
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.notifications_active_outlined,
//               color: Colors.white,
//               size: 18,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: c.card,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: c.border),
//         ),
//       ),
//     );
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: isError
//             ? Colors.red.shade700
//             : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   // ── Sub-widgets ────────────────────────────────────────────────────────────

//   Widget _statusDot() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(
//         color: getStatusColor(widget.host.status),
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white24, width: 1),
//       ),
//     );
//   }

//   Widget _flagWidget() {
//     try {
//       return SizedBox(
//         height: 16,
//         width: 22,
//         child: Flag.fromCode(
//           widget.host.flagCode,
//           fit: BoxFit.cover,
//         ),
//       );
//     } catch (_) {
//       return const Icon(
//         Icons.language,
//         color: Colors.white,
//         size: 16,
//       );
//     }
//   }

//   Widget _backgroundImage() {
//     final url = widget.host.profilePhotoUrl;
//     if (url == null || url.isEmpty) {
//       return Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       );
//     }
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   // ── Follow button ──────────────────────────────────────────────────────────

//   Widget _followButton() {
//   Widget _followButton() {
//     final isFollowed = ref.watch(followStateProvider(widget.host.userId));
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleFollow,
//         borderRadius: BorderRadius.circular(100),
//         child: Padding(
//           padding: const EdgeInsets.all(4),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             transitionBuilder: (child, animation) =>
//                 ScaleTransition(scale: animation, child: child),
//             child: FaIcon(
//               isFollowed
//                   ? FontAwesomeIcons.solidHeart
//                   : FontAwesomeIcons.heart,
//               key: ValueKey(isFollowed),
//               color: isFollowed ? Colors.red : Colors.white,
//               size: 23,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Bottom overlay ─────────────────────────────────────────────────────────

//   Widget _bottomOverlay(AppColors c) {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final cardWidth = constraints.maxWidth;
//           final nameFontSize = (cardWidth * 0.145).clamp(
//             13.0,
//             18.0,
//           );

//           return Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 12,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [Color(0xCC000000), Color(0x00000000)],
//                 stops: [0.0, 1.0],
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           _statusDot(),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               widget.host.displayName,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.lato(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: nameFontSize,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                           children: [
//                             _flagWidget(),
//                             const SizedBox(width: 8),
//                             _ageChip(_age),
//                             const SizedBox(width: 8),
//                             _levelChip(
//                               'Lv ${widget.host.level}',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Video call button — shows spinner when starting call
//                 Material(
//                   color: c.pink,
//                   shape: const CircleBorder(),
//                   clipBehavior: Clip.hardEdge,
//                   child: InkWell(
//                     onTap: _isStartingCall ? null : _onCallTap,
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: _isStartingCall
//                           ? const SizedBox(
//                               width: 25,
//                               height: 25,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.5,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const FaIcon(
//                               FontAwesomeIcons.video,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;

//     return ScaleTransition(
//       scale: _pressScale,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: isDark
//               ? Border.all(
//                   color: c.pink.withValues(alpha: 0.55),
//                   width: 1.5,
//                 )
//               : null,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.5),
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTapDown: (_) => _pressCtrl.forward(),
//             onTapUp: (_) => _pressCtrl.reverse(),
//             onTapCancel: () => _pressCtrl.reverse(),
//             onTap: _onCardTap,
//             onDoubleTap: _toggleFollow,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Hero(
//                   tag: 'host_photo_${widget.host.userId}',
//                   flightShuttleBuilder:
//                       (
//                         flightContext,
//                         animation,
//                         flightDirection,
//                         fromHeroContext,
//                         toHeroContext,
//                       ) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: toHeroContext.widget,
//                         );
//                       },
//                   child: _backgroundImage(),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: _followButton(),
//                 ),
//                 _bottomOverlay(c),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // // lib/widgets/cards/host_card.dart
// // //
// // // Host card used in HostsGridViewScreen.
// // //
// // // Animations in this file:
// // //   1. Card press — scales down to 0.95 on tap, springs back on release
// // //      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
// // //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// // //   3. Status dot — AnimatedContainer color transition (300 ms)
// // //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// // //                        — AppTransitions.scaleUp   → OngoingCallScreen
// // //   5. Hero — photo background morphs into the header of ProfileDetailsScreen
// // //
// // // Colors on photo overlay (white text, dark scrim) are intentionally
// // // hardcoded — they need contrast over an image regardless of theme.
// // // Brand colors (pink button, snackbar) use AppColors.of(context).

// // import 'dart:math';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/screens/ongoing_call_screen.dart';
// // import 'package:cheerchat/screens/profile_details_screen.dart';
// // import 'package:cheerchat/theme/app_colors.dart';
// // import 'package:cheerchat/utils/app_transitions.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// // Widget _ageChip(int age) => Container(
// //   padding: const EdgeInsets.all(3.5),
// //   decoration: const BoxDecoration(
// //     shape: BoxShape.circle,
// //     gradient: LinearGradient(
// //       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
// //     ),
// //   ),
// //   child: Text(
// //     '$age',
// //     style: const TextStyle(
// //       fontSize: 8,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.white,
// //     ),
// //   ),
// // );

// // Widget _levelChip(String level) => Container(
// //   padding: const EdgeInsets.symmetric(
// //     horizontal: 6,
// //     vertical: 3,
// //   ),
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(8),
// //     gradient: const LinearGradient(
// //       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
// //     ),
// //   ),
// //   child: Text(
// //     level,
// //     style: GoogleFonts.lato(
// //       color: Colors.white,
// //       fontWeight: FontWeight.bold,
// //       fontSize: 8,
// //     ),
// //   ),
// // );

// // // ─────────────────────────────────────────────────────────────────────────────

// // class HostCard extends StatefulWidget {
// //   const HostCard({required this.host, super.key});
// //   final HostModel host;

// //   @override
// //   State<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends State<HostCard>
// //     with TickerProviderStateMixin {
// //   bool _isFollowed = false;
// //   late int _age;

// //   // ── Press-bounce animation ─────────────────────────────────────────────────
// //   // Scales the card to 0.95 on finger-down, springs back on release.
// //   // Uses two separate controllers so press-in and release can have different
// //   // curves and durations (snappy down, springy up).
// //   late final AnimationController _pressCtrl;
// //   late final Animation<double> _pressScale;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _age = widget.host.age ?? (18 + Random().nextInt(23));

// //     _pressCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 110),
// //       reverseDuration: const Duration(milliseconds: 220),
// //     );
// //     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
// //       CurvedAnimation(
// //         parent: _pressCtrl,
// //         curve: Curves.easeInOut,
// //         reverseCurve: Curves.elasticOut,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _pressCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ── Tap handlers ───────────────────────────────────────────────────────────

// //   void _toggleFollow() =>
// //       setState(() => _isFollowed = !_isFollowed);

// //   void _onCardTap() {
// //     Navigator.of(context, rootNavigator: true).push(
// //       AppTransitions.heroFade(
// //         ProfileDetailsScreen(host: widget.host),
// //       ),
// //     );
// //   }

// //   void _onCallTap() {
// //     HapticFeedback.mediumImpact();
// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         Navigator.of(context, rootNavigator: true).push(
// //           AppTransitions.scaleUp(
// //             OngoingCallScreen(
// //               host: widget.host,
// //               initialCoins: 1000,
// //               testMode: true,
// //               isAlreadyFollowing: false,
// //             ),
// //           ),
// //         );
// //         break;
// //       case HostStatus.busy:
// //         _autoQueue();
// //         break;
// //       case HostStatus.offline:
// //         break;
// //     }
// //   }

// //   void _autoQueue() {
// //     // TODO: POST /api/call-queue { host_id: widget.host.userId }
// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(
// //               Icons.notifications_active_outlined,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ],
// //         ),
// //         backgroundColor: c.card,
// //         behavior: SnackBarBehavior.floating,
// //         duration: const Duration(seconds: 3),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           side: BorderSide(color: c.border),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sub-widgets ────────────────────────────────────────────────────────────

// //   Widget _statusDot() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: 10,
// //       height: 10,
// //       decoration: BoxDecoration(
// //         color: getStatusColor(widget.host.status),
// //         shape: BoxShape.circle,
// //         border: Border.all(color: Colors.white24, width: 1),
// //       ),
// //     );
// //   }

// //   Widget _flagWidget() {
// //     try {
// //       return SizedBox(
// //         height: 16,
// //         width: 22,
// //         child: Flag.fromCode(
// //           widget.host.flagCode,
// //           fit: BoxFit.cover,
// //         ),
// //       );
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white,
// //         size: 16,
// //       );
// //     }
// //   }

// //   Widget _backgroundImage() {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url == null || url.isEmpty) {
// //       return Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       );
// //     }
// //     return Image.network(
// //       url,
// //       fit: BoxFit.cover,
// //       errorBuilder: (_, __, ___) => Image.asset(
// //         'assets/default_profile/default_profile_photo.jpg',
// //         fit: BoxFit.cover,
// //       ),
// //     );
// //   }

// //   // ── Follow button ──────────────────────────────────────────────────────────
// //   // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

// //   Widget _followButton() {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: () {
// //           HapticFeedback.lightImpact();
// //           _toggleFollow();
// //         },
// //         borderRadius: BorderRadius.circular(100),
// //         child: Padding(
// //           padding: const EdgeInsets.all(4),
// //           child: AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 200),
// //             transitionBuilder: (child, animation) =>
// //                 ScaleTransition(scale: animation, child: child),
// //             child: FaIcon(
// //               _isFollowed
// //                   ? FontAwesomeIcons.solidHeart
// //                   : FontAwesomeIcons.heart,
// //               key: ValueKey(_isFollowed),
// //               color: _isFollowed ? Colors.red : Colors.white,
// //               size: 23,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Bottom overlay ─────────────────────────────────────────────────────────

// //   Widget _bottomOverlay(AppColors c) {
// //     return Positioned(
// //       left: 0,
// //       right: 0,
// //       bottom: 0,
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           // Responsive font: scales 13–18 based on card width so it never
// //           // overflows on high-DPI or narrow screens.
// //           final cardWidth = constraints.maxWidth;
// //           final nameFontSize = (cardWidth * 0.145).clamp(
// //             13.0,
// //             18.0,
// //           );

// //           return Container(
// //             padding: const EdgeInsets.symmetric(
// //               vertical: 10,
// //               horizontal: 12,
// //             ),
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.bottomCenter,
// //                 end: Alignment.topCenter,
// //                 colors: [
// //                   Color(0xCC000000), // 80% black at bottom
// //                   Color(0x00000000), // transparent at top
// //                 ],
// //                 stops: [0.0, 1.0],
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Name row
// //                       Row(
// //                         children: [
// //                           _statusDot(),
// //                           const SizedBox(width: 4),
// //                           Expanded(
// //                             child: Text(
// //                               widget.host.displayName,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: GoogleFonts.lato(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: nameFontSize,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       // Chips row — FittedBox prevents overflow on any density
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         alignment: Alignment.centerLeft,
// //                         child: Row(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.center,
// //                           children: [
// //                             _flagWidget(),
// //                             const SizedBox(width: 8),
// //                             _ageChip(_age),
// //                             const SizedBox(width: 8),
// //                             _levelChip(
// //                               'Lv ${widget.host.level}',
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 // Video call button
// //                 Material(
// //                   color: c.pink,
// //                   shape: const CircleBorder(),
// //                   clipBehavior: Clip.hardEdge,
// //                   child: InkWell(
// //                     onTap: _onCallTap,
// //                     child: const Padding(
// //                       padding: EdgeInsets.all(10),
// //                       child: FaIcon(
// //                         FontAwesomeIcons.video,
// //                         color: Colors.white,
// //                         size: 25,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── Build ──────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return ScaleTransition(
// //       scale: _pressScale,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: isDark
// //               ? Border.all(
// //                   color: c.pink.withValues(alpha: 0.55),
// //                   width: 1.5,
// //                 )
// //               : null,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(10.5),
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.opaque,
// //             onTapDown: (_) => _pressCtrl.forward(),
// //             onTapUp: (_) => _pressCtrl.reverse(),
// //             onTapCancel: () => _pressCtrl.reverse(),
// //             onTap: _onCardTap,
// //             onDoubleTap: _toggleFollow,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 // ── Photo background — Hero source ───────────────────────
// //                 // tag matches the Hero destination in ProfileDetailsScreen:
// //                 //   Hero(tag: 'host_photo_${host.userId}', ...)
// //                 Hero(
// //                   tag: 'host_photo_${widget.host.userId}',
// //                   flightShuttleBuilder:
// //                       (
// //                         flightContext,
// //                         animation,
// //                         flightDirection,
// //                         fromHeroContext,
// //                         toHeroContext,
// //                       ) {
// //                         // Fade between the two hero states during flight
// //                         return FadeTransition(
// //                           opacity: animation,
// //                           child: toHeroContext.widget,
// //                         );
// //                       },
// //                   child: _backgroundImage(),
// //                 ),

// //                 // ── Follow / heart button ────────────────────────────────
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: _followButton(),
// //                 ),

// //                 // ── Bottom overlay with name + chips + call button ───────
// //                 _bottomOverlay(c),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/widgets/cards/host_card.dart
// //
// // Host card used in HostsGridViewScreen.
// //
// // ✅ WIRED TO BACKEND:
// //   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
// //   - Busy host → CallApiService.joinQueue()
// //   - Follow heart → SocialService.follow()/unfollow()
// //   - Reads wallet balance from walletBalanceProvider
// //
// // Animations (unchanged):
// //   1. Card press — scales down to 0.95 on tap, springs back on release
// //   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
// //   3. Status dot — AnimatedContainer color transition (300 ms)
// //   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
// //                        — AppTransitions.scaleUp   → OngoingCallScreen
// //   5. Hero — photo background morphs into the header of ProfileDetailsScreen

// import 'dart:math';

// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/providers/wallet_provider.dart';
// import 'package:cheerchat/screens/ongoing_call_screen.dart';
// import 'package:cheerchat/screens/profile_details_screen.dart';
// import 'package:cheerchat/services/call_api_service.dart';
// import 'package:cheerchat/services/social_service.dart';
// import 'package:cheerchat/theme/app_colors.dart';
// import 'package:cheerchat/utils/app_transitions.dart';
// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// // ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

// Widget _ageChip(int age) => Container(
//   padding: const EdgeInsets.all(3.5),
//   decoration: const BoxDecoration(
//     shape: BoxShape.circle,
//     gradient: LinearGradient(
//       colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
//     ),
//   ),
//   child: Text(
//     '$age',
//     style: const TextStyle(
//       fontSize: 8,
//       fontWeight: FontWeight.bold,
//       color: Colors.white,
//     ),
//   ),
// );

// Widget _levelChip(String level) => Container(
//   padding: const EdgeInsets.symmetric(
//     horizontal: 6,
//     vertical: 3,
//   ),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(8),
//     gradient: const LinearGradient(
//       colors: [Color(0xFFF66868), Color(0xFFDF3535)],
//     ),
//   ),
//   child: Text(
//     level,
//     style: GoogleFonts.lato(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 8,
//     ),
//   ),
// );

// // ─────────────────────────────────────────────────────────────────────────────

// class HostCard extends ConsumerStatefulWidget {
//   const HostCard({required this.host, super.key});
//   final HostModel host;

//   @override
//   ConsumerState<HostCard> createState() => _HostCardState();
// }

// class _HostCardState extends ConsumerState<HostCard>
//     with TickerProviderStateMixin {
//   bool _isFollowed = false;
//   bool _isStartingCall = false;
//   late int _age;

//   // ── Press-bounce animation ─────────────────────────────────────────────────
//   late final AnimationController _pressCtrl;
//   late final Animation<double> _pressScale;

//   @override
//   void initState() {
//     super.initState();
//     _age = widget.host.age ?? (18 + Random().nextInt(23));

//     _pressCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 110),
//       reverseDuration: const Duration(milliseconds: 220),
//     );
//     _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
//       CurvedAnimation(
//         parent: _pressCtrl,
//         curve: Curves.easeInOut,
//         reverseCurve: Curves.elasticOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pressCtrl.dispose();
//     super.dispose();
//   }

//   // ── Tap handlers ───────────────────────────────────────────────────────────

//   void _toggleFollow() {
//     HapticFeedback.lightImpact();
//     final wasFollowed = _isFollowed;
//     setState(() => _isFollowed = !_isFollowed);

//     // Fire API call — revert on failure
//     final social = ref.read(socialServiceProvider);
//     final future = _isFollowed
//         ? social.follow(widget.host.userId)
//         : social.unfollow(widget.host.userId);

//     future.then((ok) {
//       if (!ok && mounted) {
//         setState(() => _isFollowed = wasFollowed);
//       }
//     });
//   }

//   void _onCardTap() {
//     Navigator.of(context, rootNavigator: true).push(
//       AppTransitions.heroFade(
//         ProfileDetailsScreen(host: widget.host),
//       ),
//     );
//   }

//   Future<void> _onCallTap() async {
//     HapticFeedback.mediumImpact();

//     switch (widget.host.status) {
//       case HostStatus.online:
//         await _startCallFlow();
//         break;
//       case HostStatus.busy:
//         _autoQueue();
//         break;
//       case HostStatus.offline:
//         break;
//     }
//   }

//   // ── Start call — the main wiring ─────────────────────────────────────────

//   Future<void> _startCallFlow() async {
//     if (_isStartingCall) return; // prevent double-tap
//     setState(() => _isStartingCall = true);

//     try {
//       // 1. Check local coin balance first (quick fail)
//       final coins = ref.read(coinBalanceProvider);
//       if (coins < widget.host.priceCoins) {
//         if (mounted) {
//           _showSnackBar(
//             'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
//             isError: true,
//           );
//         }
//         return;
//       }

//       // 2. Call the backend to start the call session
//       final callApi = ref.read(callApiServiceProvider);
//       final res = await callApi.startCall(hostId: widget.host.userId);

//       if (!mounted) return;

//       if (!res.ok) {
//         // Handle specific errors
//         final error = res.error ?? 'Could not start call';
//         if (res.statusCode == 409) {
//           // Host became busy between grid load and tap
//           _autoQueue();
//         } else if (res.statusCode == 400 &&
//             error.contains('Insufficient')) {
//           _showSnackBar(
//             'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
//             isError: true,
//           );
//         } else {
//           _showSnackBar(error, isError: true);
//         }
//         return;
//       }

//       // 3. Extract server response
//       final sessionId = res.data['session_id'] as String;
//       final channelName = res.data['channel_name'] as String;
//       final callerToken = res.data['caller_token'] as String;
//       final callerUid = res.data['caller_uid'] as int;
//       final pricePerMinute = res.data['price_per_minute'] as int;

//       // 4. Push OngoingCallScreen with REAL server values
//       if (mounted) {
//         Navigator.of(context, rootNavigator: true).push(
//           AppTransitions.scaleUp(
//             OngoingCallScreen(
//               host: widget.host.copyWith(priceCoins: pricePerMinute),
//               initialCoins: coins,
//               sessionId: sessionId,
//               channelId: channelName,
//               token: callerToken,
//               localUid: callerUid,
//               isAlreadyFollowing: _isFollowed,
//             ),
//           ),
//         );

//         // 5. Refresh wallet after navigating (call screen will also refresh on end)
//         ref.read(walletBalanceProvider.notifier).refresh();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Connection error. Please try again.', isError: true);
//       }
//     } finally {
//       if (mounted) setState(() => _isStartingCall = false);
//     }
//   }

//   // ── Auto-queue for busy host ─────────────────────────────────────────────

//   void _autoQueue() {
//     final callApi = ref.read(callApiServiceProvider);
//     callApi.joinQueue(widget.host.userId);

//     final c = AppColors.of(context);
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.notifications_active_outlined,
//               color: Colors.white,
//               size: 18,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "${widget.host.displayName} is busy! We'll notify you when she's free.",
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: c.card,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: c.border),
//         ),
//       ),
//     );
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   // ── Sub-widgets ────────────────────────────────────────────────────────────

//   Widget _statusDot() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(
//         color: getStatusColor(widget.host.status),
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white24, width: 1),
//       ),
//     );
//   }

//   Widget _flagWidget() {
//     try {
//       return SizedBox(
//         height: 16,
//         width: 22,
//         child: Flag.fromCode(
//           widget.host.flagCode,
//           fit: BoxFit.cover,
//         ),
//       );
//     } catch (_) {
//       return const Icon(
//         Icons.language,
//         color: Colors.white,
//         size: 16,
//       );
//     }
//   }

//   Widget _backgroundImage() {
//     final url = widget.host.profilePhotoUrl;
//     if (url == null || url.isEmpty) {
//       return Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       );
//     }
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => Image.asset(
//         'assets/default_profile/default_profile_photo.jpg',
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   // ── Follow button ──────────────────────────────────────────────────────────

//   Widget _followButton() {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleFollow,
//         borderRadius: BorderRadius.circular(100),
//         child: Padding(
//           padding: const EdgeInsets.all(4),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             transitionBuilder: (child, animation) =>
//                 ScaleTransition(scale: animation, child: child),
//             child: FaIcon(
//               _isFollowed
//                   ? FontAwesomeIcons.solidHeart
//                   : FontAwesomeIcons.heart,
//               key: ValueKey(_isFollowed),
//               color: _isFollowed ? Colors.red : Colors.white,
//               size: 23,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Bottom overlay ─────────────────────────────────────────────────────────

//   Widget _bottomOverlay(AppColors c) {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final cardWidth = constraints.maxWidth;
//           final nameFontSize = (cardWidth * 0.145).clamp(13.0, 18.0);

//           return Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 12,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [
//                   Color(0xCC000000),
//                   Color(0x00000000),
//                 ],
//                 stops: [0.0, 1.0],
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           _statusDot(),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               widget.host.displayName,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: GoogleFonts.lato(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: nameFontSize,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             _flagWidget(),
//                             const SizedBox(width: 8),
//                             _ageChip(_age),
//                             const SizedBox(width: 8),
//                             _levelChip('Lv ${widget.host.level}'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Video call button — shows spinner when starting call
//                 Material(
//                   color: c.pink,
//                   shape: const CircleBorder(),
//                   clipBehavior: Clip.hardEdge,
//                   child: InkWell(
//                     onTap: _isStartingCall ? null : _onCallTap,
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: _isStartingCall
//                           ? const SizedBox(
//                               width: 25,
//                               height: 25,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.5,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const FaIcon(
//                               FontAwesomeIcons.video,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return ScaleTransition(
//       scale: _pressScale,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: isDark
//               ? Border.all(
//                   color: c.pink.withValues(alpha: 0.55),
//                   width: 1.5,
//                 )
//               : null,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.5),
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTapDown: (_) => _pressCtrl.forward(),
//             onTapUp: (_) => _pressCtrl.reverse(),
//             onTapCancel: () => _pressCtrl.reverse(),
//             onTap: _onCardTap,
//             onDoubleTap: _toggleFollow,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Hero(
//                   tag: 'host_photo_${widget.host.userId}',
//                   flightShuttleBuilder: (
//                     flightContext,
//                     animation,
//                     flightDirection,
//                     fromHeroContext,
//                     toHeroContext,
//                   ) {
//                     return FadeTransition(
//                       opacity: animation,
//                       child: toHeroContext.widget,
//                     );
//                   },
//                   child: _backgroundImage(),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: _followButton(),
//                 ),
//                 _bottomOverlay(c),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/widgets/cards/host_card.dart
//
// Host card used in HostsGridViewScreen.
//
// ✅ WIRED TO BACKEND:
//   - Video button → CallApiService.startCall() → OngoingCallScreen with real Agora token
//   - Busy host → CallApiService.joinQueue()
//   - Follow heart → SocialService.follow()/unfollow()
//   - Reads wallet balance from walletBalanceProvider
//
// Animations (unchanged):
//   1. Card press — scales down to 0.95 on tap, springs back on release
//   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
//   3. Status dot — AnimatedContainer color transition (300 ms)
//   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
//                        — AppTransitions.scaleUp   → OngoingCallScreen
//   5. Hero — photo background morphs into the header of ProfileDetailsScreen

import 'dart:math';

import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/providers/wallet_provider.dart';
import 'package:cheerchat/screens/outgoing_call_screen.dart';
import 'package:cheerchat/screens/profile_details_screen.dart';
import 'package:cheerchat/services/call_api_service.dart';
import 'package:cheerchat/providers/follow_provider.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:cheerchat/utils/app_transitions.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Top-level chip helpers (no theme needed — always on photo bg) ─────────────

Widget _ageChip(int age) => Container(
  padding: const EdgeInsets.all(3.5),
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [Color(0xFFF79CBA), Color(0xFFF87DA8)],
    ),
  ),
  child: Text(
    '$age',
    style: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);

Widget _levelChip(String level) => Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 3,
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    gradient: const LinearGradient(
      colors: [Color(0xFFF66868), Color(0xFFDF3535)],
    ),
  ),
  child: Text(
    level,
    style: GoogleFonts.lato(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 8,
    ),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────

class HostCard extends ConsumerStatefulWidget {
  const HostCard({required this.host, super.key});
  final HostModel host;

  @override
  ConsumerState<HostCard> createState() => _HostCardState();
}

class _HostCardState extends ConsumerState<HostCard>
    with TickerProviderStateMixin {
  bool _isStartingCall = false;
  late int _age;

  // ── Press-bounce animation ─────────────────────────────────────────────────
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _age = widget.host.age ?? (18 + Random().nextInt(23));

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.955).animate(
      CurvedAnimation(
        parent: _pressCtrl,
        curve: Curves.easeInOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Tap handlers ───────────────────────────────────────────────────────────

  void _toggleFollow() {
    HapticFeedback.lightImpact();
    // ref.read(followStateProvider(widget.host.userId).notifier).toggle();
    ref
        .read(followNotifierProvider.notifier)
        .toggle(widget.host.userId);
  }

  void _onCardTap() {
    Navigator.of(context, rootNavigator: true).push(
      AppTransitions.heroFade(
        ProfileDetailsScreen(host: widget.host),
      ),
    );
  }

  Future<void> _onCallTap() async {
    HapticFeedback.mediumImpact();

    switch (widget.host.status) {
      case HostStatus.online:
        await _startCallFlow();
        break;
      case HostStatus.busy:
        _autoQueue();
        break;
      case HostStatus.offline:
        break;
    }
  }

  // ── Start call — the main wiring ─────────────────────────────────────────

  Future<void> _startCallFlow() async {
    if (_isStartingCall) return; // prevent double-tap
    setState(() => _isStartingCall = true);

    try {
      // 1. Check local coin balance first (quick fail)
      final walletState = ref.read(walletBalanceProvider);
      final coins = walletState.asData?.value?.coinBalance;

      // Only do local check if wallet is loaded — otherwise let server validate
      if (coins != null && coins < widget.host.priceCoins) {
        if (mounted) {
          _showSnackBar(
            'Not enough coins! You need ${widget.host.priceCoins} coins/min.',
            isError: true,
          );
        }
        return;
      }

      // 2. Call the backend to start the call session
      final callApi = ref.read(callApiServiceProvider);
      final res = await callApi.startCall(
        hostId: widget.host.userId,
      );

      if (!mounted) return;

      if (!res.ok) {
        // Handle specific errors
        final error = res.error ?? 'Could not start call';
        if (res.statusCode == 409) {
          // Host became busy between grid load and tap
          _autoQueue();
        } else if (res.statusCode == 400 &&
            error.contains('Insufficient')) {
          _showSnackBar(
            'Not enough coins! Need ${res.data['required'] ?? widget.host.priceCoins}/min.',
            isError: true,
          );
        } else {
          _showSnackBar(error, isError: true);
        }
        return;
      }

      // 3. Extract server response
      final sessionId = res.data['session_id'] as String;
      final channelName = res.data['channel_name'] as String;
      final callerToken = res.data['caller_token'] as String;
      final callerUid = res.data['caller_uid'] as int;
      final pricePerMinute = res.data['price_per_minute'] as int;

      // 4. Push OutgoingCallScreen — waits for host to accept
      if (mounted) {
        Navigator.of(context, rootNavigator: true).push(
          AppTransitions.scaleUp(
            OutgoingCallScreen(
              host: widget.host.copyWith(
                priceCoins: pricePerMinute,
              ),
              initialCoins: coins ?? 0,
              sessionId: sessionId,
              channelId: channelName,
              token: callerToken,
              callerUid: callerUid,
              isAlreadyFollowing: ref.read(
                followStateProvider(widget.host.userId),
              ),
            ),
          ),
        );

        // 5. Refresh wallet after navigating (call screen will also refresh on end)
        ref.read(walletBalanceProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Connection error. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingCall = false);
    }
  }

  // ── Auto-queue for busy host ─────────────────────────────────────────────

  void _autoQueue() {
    final callApi = ref.read(callApiServiceProvider);
    callApi.joinQueue(widget.host.userId);

    final c = AppColors.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${widget.host.displayName} is busy! We'll notify you when she's free.",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: c.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c.border),
          ),
        ),
      );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _statusDot() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: getStatusColor(widget.host.status),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }

  Widget _flagWidget() {
    try {
      return SizedBox(
        height: 16,
        width: 22,
        child: Flag.fromCode(
          widget.host.flagCode,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return const Icon(
        Icons.language,
        color: Colors.white,
        size: 16,
      );
    }
  }

  Widget _backgroundImage() {
    final url = widget.host.profilePhotoUrl;
    if (url == null || url.isEmpty) {
      return Image.asset(
        'assets/default_profile/default_profile_photo.jpg',
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/default_profile/default_profile_photo.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  // ── Follow button ──────────────────────────────────────────────────────────

  Widget _followButton() {
    final isFollowed = ref.watch(
      followStateProvider(widget.host.userId),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleFollow,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: FaIcon(
              isFollowed
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              key: ValueKey(isFollowed),
              color: isFollowed ? Colors.red : Colors.white,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom overlay ─────────────────────────────────────────────────────────

  Widget _bottomOverlay(AppColors c) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final nameFontSize = (cardWidth * 0.145).clamp(
            13.0,
            18.0,
          );

          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC000000), Color(0x00000000)],
                stops: [0.0, 1.0],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statusDot(),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.host.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: nameFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            _flagWidget(),
                            const SizedBox(width: 8),
                            _ageChip(_age),
                            const SizedBox(width: 8),
                            _levelChip(
                              'Lv ${widget.host.level}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Video call button — shows spinner when starting call
                Material(
                  color: c.pink,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: _isStartingCall ? null : _onCallTap,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _isStartingCall
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const FaIcon(
                              FontAwesomeIcons.video,
                              color: Colors.white,
                              size: 25,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _pressScale,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(
                  color: c.pink.withValues(alpha: 0.55),
                  width: 1.5,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _pressCtrl.forward(),
            onTapUp: (_) => _pressCtrl.reverse(),
            onTapCancel: () => _pressCtrl.reverse(),
            onTap: _onCardTap,
            onDoubleTap: _toggleFollow,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'host_photo_${widget.host.userId}',
                  flightShuttleBuilder:
                      (
                        flightContext,
                        animation,
                        flightDirection,
                        fromHeroContext,
                        toHeroContext,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: toHeroContext.widget,
                        );
                      },
                  child: _backgroundImage(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _followButton(),
                ),
                _bottomOverlay(c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

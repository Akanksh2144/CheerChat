// // // lib/screens/profile_details_screen.dart
// // //
// // // Host profile page — opened from HostCard tap (card body) or
// // // the small profile icon on the card corner.
// // //
// // // Receives a HostModel. All data that isn't in HostModel yet
// // // (followers, call count, gifts) is stubbed with dummy values
// // // clearly marked TODO — swap with real API data when Node.js is ready.

// // import 'dart:math';

// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// // // ---------------------------------------------------------------------------
// // // Screen
// // // ---------------------------------------------------------------------------
// // class ProfileDetailsScreen extends StatefulWidget {
// //   const ProfileDetailsScreen({super.key, required this.host});

// //   final HostModel host;

// //   @override
// //   State<ProfileDetailsScreen> createState() =>
// //       _ProfileDetailsScreenState();
// // }

// // class _ProfileDetailsScreenState
// //     extends State<ProfileDetailsScreen>
// //     with SingleTickerProviderStateMixin {
// //   int _currentPhotoIndex = 0;
// //   late final PageController _pageController;
// //   late final AnimationController _entranceController;
// //   late final Animation<double> _fadeAnim;
// //   late final Animation<Offset> _slideAnim;

// //   // Stub stats — replace with real data from API
// //   // TODO: load from GET /api/hosts/:userId/stats
// //   late final int _followerCount;
// //   late final int _followingCount;
// //   late final int _giftCount;
// //   late final int _age;

// //   // For now a host may have only one photo; PageView is already wired
// //   // so adding photos later requires zero UI changes.
// //   List<String> get _photos {
// //     final url = widget.host.profilePhotoUrl;
// //     if (url != null && url.isNotEmpty) return [url];
// //     return [];
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageController = PageController();
// //     _entranceController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 420),
// //     );
// //     _fadeAnim = CurvedAnimation(
// //       parent: _entranceController,
// //       curve: Curves.easeOut,
// //     );
// //     _slideAnim =
// //         Tween<Offset>(
// //           begin: const Offset(0, 0.06),
// //           end: Offset.zero,
// //         ).animate(
// //           CurvedAnimation(
// //             parent: _entranceController,
// //             curve: Curves.easeOut,
// //           ),
// //         );

// //     // Stub data
// //     final rng = Random();
// //     _followerCount = widget.host.age != null
// //         ? 200 + rng.nextInt(4800)
// //         : 100 + rng.nextInt(9900);
// //     _followingCount = 10 + rng.nextInt(290);
// //     _giftCount = 5 + rng.nextInt(295);
// //     _age = widget.host.age ?? (18 + rng.nextInt(23));

// //     _entranceController.forward();
// //   }

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     _entranceController.dispose();
// //     super.dispose();
// //   }

// //   // -------------------------------------------------------------------------
// //   // Actions
// //   // -------------------------------------------------------------------------
// //   void _openChat() {
// //     HapticFeedback.lightImpact();
// //     // TODO: pushScreenWithoutNavBar(context, ChatScreen(host: widget.host));
// //     debugPrint('Open chat with ${widget.host.displayName}');
// //   }

// //   void _onCallTap() {
// //     HapticFeedback.mediumImpact();
// //     switch (widget.host.status) {
// //       case HostStatus.online:
// //         // TODO: push call screen
// //         debugPrint('Calling ${widget.host.displayName}');
// //         break;
// //       case HostStatus.busy:
// //         _showBusyDialog();
// //         break;
// //       case HostStatus.offline:
// //         _showOfflineSnack();
// //         break;
// //     }
// //   }

// //   void _showBusyDialog() {
// //     showDialog<void>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(20),
// //         ),
// //         contentPadding: const EdgeInsets.fromLTRB(
// //           24,
// //           24,
// //           24,
// //           12,
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             CircleAvatar(
// //               radius: 30,
// //               backgroundColor: Colors.pink.shade50,
// //               child: const FaIcon(
// //                 FontAwesomeIcons.video,
// //                 color: Colors.pink,
// //                 size: 24,
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               '${widget.host.displayName} is busy',
// //               style: GoogleFonts.lato(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'She is on a call right now.\nJoin the queue and we\'ll notify you when she\'s free.',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: Colors.grey.shade600,
// //                 height: 1.5,
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(ctx).pop(),
// //             child: const Text('Cancel'),
// //           ),
// //           FilledButton.icon(
// //             style: FilledButton.styleFrom(
// //               backgroundColor: Colors.pink,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //             onPressed: () {
// //               Navigator.of(ctx).pop();
// //               _joinQueue();
// //             },
// //             icon: const Icon(
// //               Icons.notifications_outlined,
// //               size: 16,
// //             ),
// //             label: const Text('Notify Me'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _joinQueue() {
// //     // TODO: POST /api/call-queue  { host_id: widget.host.userId }
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           "You'll be notified when ${widget.host.displayName} is free!",
// //         ),
// //         backgroundColor: Colors.orange,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   void _showOfflineSnack() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           '${widget.host.displayName} is offline right now.',
// //         ),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // -------------------------------------------------------------------------
// //   // Build
// //   // -------------------------------------------------------------------------
// //   @override
// //   Widget build(BuildContext context) {
// //     final host = widget.host;
// //     final bottomPad = MediaQuery.of(context).padding.bottom;

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       extendBodyBehindAppBar: true,
// //       body: Stack(
// //         children: [
// //           // ── Scrollable content ───────────────────────────────────────────
// //           CustomScrollView(
// //             slivers: [
// //               // Photo hero
// //               SliverToBoxAdapter(child: _buildPhotoHero(host)),

// //               // Info card
// //               SliverToBoxAdapter(
// //                 child: FadeTransition(
// //                   opacity: _fadeAnim,
// //                   child: SlideTransition(
// //                     position: _slideAnim,
// //                     child: _buildInfoCard(host),
// //                   ),
// //                 ),
// //               ),

// //               // Bottom padding for sticky bar
// //               SliverToBoxAdapter(
// //                 child: SizedBox(height: 100 + bottomPad),
// //               ),
// //             ],
// //           ),

// //           // ── Back button ──────────────────────────────────────────────────
// //           Positioned(
// //             top: MediaQuery.of(context).padding.top + 8,
// //             left: 12,
// //             child: _circleButton(
// //               icon: Icons.arrow_back_ios_new_rounded,
// //               onTap: () => Navigator.of(context).pop(),
// //             ),
// //           ),

// //           // ── 3-dot menu (report / share) ──────────────────────────────────
// //           Positioned(
// //             top: MediaQuery.of(context).padding.top + 8,
// //             right: 12,
// //             child: _circleButton(
// //               icon: Icons.more_vert_rounded,
// //               onTap: _showMoreMenu,
// //             ),
// //           ),

// //           // ── Sticky bottom action bar ─────────────────────────────────────
// //           Positioned(
// //             left: 0,
// //             right: 0,
// //             bottom: 0,
// //             child: _buildBottomBar(host, bottomPad),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Photo hero ─────────────────────────────────────────────────────────────
// //   Widget _buildPhotoHero(HostModel host) {
// //     final photos = _photos;
// //     const heroHeight = 420.0;

// //     return SizedBox(
// //       height: heroHeight,
// //       child: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           // PageView of photos (or default placeholder)
// //           photos.isEmpty
// //               ? _defaultPhoto()
// //               : PageView.builder(
// //                   controller: _pageController,
// //                   itemCount: photos.length,
// //                   onPageChanged: (i) =>
// //                       setState(() => _currentPhotoIndex = i),
// //                   itemBuilder: (_, i) => GestureDetector(
// //                     onTap: () => _openFullScreenPhoto(photos, i),
// //                     child: Image.network(
// //                       photos[i],
// //                       fit: BoxFit.cover,
// //                       errorBuilder: (_, __, ___) =>
// //                           _defaultPhoto(),
// //                     ),
// //                   ),
// //                 ),

// //           // Bottom gradient
// //           Positioned(
// //             left: 0,
// //             right: 0,
// //             bottom: 0,
// //             child: Container(
// //               height: 160,
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.bottomCenter,
// //                   end: Alignment.topCenter,
// //                   colors: [
// //                     Colors.black.withValues(alpha: 0.70),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // Level label badge — top-right corner of photo
// //           Positioned(
// //             top: MediaQuery.of(context).padding.top + 56,
// //             right: 16,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: 10,
// //                 vertical: 5,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: Colors.pink.withValues(alpha: 0.88),
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Text(
// //                 host.levelLabel,
// //                 style: GoogleFonts.lato(
// //                   color: Colors.white,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // Name + meta over the photo
// //           Positioned(
// //             left: 16,
// //             right: 16,
// //             bottom: 20,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // Name row with status dot + verified badge
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     _statusDot(host.status),
// //                     const SizedBox(width: 7),
// //                     Flexible(
// //                       child: Text(
// //                         host.displayName,
// //                         style: GoogleFonts.lato(
// //                           color: Colors.white,
// //                           fontSize: 26,
// //                           fontWeight: FontWeight.bold,
// //                           shadows: const [
// //                             Shadow(
// //                               blurRadius: 8,
// //                               color: Colors.black54,
// //                             ),
// //                           ],
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     // Verified badge
// //                     Container(
// //                       padding: const EdgeInsets.all(3),
// //                       decoration: const BoxDecoration(
// //                         color: Colors.blue,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child: const Icon(
// //                         Icons.check,
// //                         color: Colors.white,
// //                         size: 11,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 7),
// //                 // Flag • Age • Level number  ——  counter pushed to far right
// //                 Row(
// //                   children: [
// //                     SizedBox(
// //                       height: 14,
// //                       width: 20,
// //                       child: _safeFlagWidget(host),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     _pillChip(
// //                       '$_age yrs',
// //                       Colors.white.withValues(alpha: 0.22),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     _pillChip(
// //                       'Lv.${host.level}',
// //                       Colors.white.withValues(alpha: 0.22),
// //                     ),
// //                     const Spacer(),
// //                     // Numeric photo counter — rightmost of this row
// //                     Text(
// //                       '${_currentPhotoIndex + 1} / ${_photos.isEmpty ? 1 : _photos.length}',
// //                       style: GoogleFonts.lato(
// //                         color: Colors.white,
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w600,
// //                         shadows: const [
// //                           Shadow(
// //                             blurRadius: 6,
// //                             color: Colors.black87,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Info card ──────────────────────────────────────────────────────────────
// //   Widget _buildInfoCard(HostModel host) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(
// //         horizontal: 20,
// //         vertical: 20,
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Stats row
// //           _buildStatsRow(),

// //           const SizedBox(height: 24),
// //           const Divider(height: 1),
// //           const SizedBox(height: 20),

// //           // Bio
// //           if (host.bio != null && host.bio!.isNotEmpty) ...[
// //             _sectionLabel('About'),
// //             const SizedBox(height: 8),
// //             Text(
// //               host.bio!,
// //               style: TextStyle(
// //                 fontSize: 15,
// //                 color: Colors.grey.shade700,
// //                 height: 1.55,
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //           ],

// //           // Language
// //           _sectionLabel('Speaks'),
// //           const SizedBox(height: 10),
// //           Wrap(
// //             spacing: 8,
// //             runSpacing: 8,
// //             children: [
// //               _languageChip(host.language),
// //               // TODO: add more languages when API returns list
// //             ],
// //           ),

// //           const SizedBox(height: 24),
// //           const Divider(height: 1),
// //           const SizedBox(height: 20),

// //           // Gifts Received
// //           _buildGiftsSection(),
// //         ],
// //       ),
// //     );
// //   }

// //   // Stats row
// //   Widget _buildStatsRow() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceAround,
// //       children: [
// //         _statItem(_formatCount(_followerCount), 'Followers'),
// //         _vertDivider(),
// //         _statItem(_formatCount(_followingCount), 'Following'),
// //         _vertDivider(),
// //         _statItem(_formatCount(_giftCount), 'Gifts'),
// //       ],
// //     );
// //   }

// //   Widget _statItem(String value, String label) {
// //     return Column(
// //       children: [
// //         Text(
// //           value,
// //           style: GoogleFonts.lato(
// //             fontSize: 22,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         const SizedBox(height: 2),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 12,
// //             color: Colors.grey.shade500,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _vertDivider() => Container(
// //     width: 1,
// //     height: 36,
// //     color: Colors.grey.shade200,
// //   );

// //   // Gifts Received section
// //   // TODO: load real gift data from GET /api/hosts/:userId/gifts
// //   Widget _buildGiftsSection() {
// //     // Stub gift catalog — 6 popular gifts with emoji + stub counts
// //     final gifts = [
// //       _GiftItem(
// //         emoji: '🌹',
// //         name: 'Rose',
// //         count: 12 + Random().nextInt(88),
// //       ),
// //       _GiftItem(
// //         emoji: '💎',
// //         name: 'Diamond',
// //         count: 3 + Random().nextInt(27),
// //       ),
// //       _GiftItem(
// //         emoji: '🎂',
// //         name: 'Cake',
// //         count: 5 + Random().nextInt(45),
// //       ),
// //       _GiftItem(
// //         emoji: '🚀',
// //         name: 'Rocket',
// //         count: 1 + Random().nextInt(19),
// //       ),
// //       _GiftItem(
// //         emoji: '👑',
// //         name: 'Crown',
// //         count: 2 + Random().nextInt(18),
// //       ),
// //       _GiftItem(
// //         emoji: '🎁',
// //         name: 'Box',
// //         count: 8 + Random().nextInt(72),
// //       ),
// //     ];

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         _sectionLabel('Gifts Received'),
// //         const SizedBox(height: 4),
// //         GridView.builder(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           itemCount: gifts.length,
// //           gridDelegate:
// //               const SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 3,
// //                 mainAxisSpacing: 10,
// //                 crossAxisSpacing: 10,
// //                 childAspectRatio: 1.15,
// //               ),
// //           itemBuilder: (_, i) {
// //             final g = gifts[i];
// //             return Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.grey.shade50,
// //                 borderRadius: BorderRadius.circular(14),
// //                 border: Border.all(color: Colors.grey.shade200),
// //               ),
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Text(
// //                     g.emoji,
// //                     style: const TextStyle(fontSize: 28),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     g.name,
// //                     style: TextStyle(
// //                       fontSize: 11,
// //                       color: Colors.grey.shade600,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 2),
// //                   Text(
// //                     '×${g.count}',
// //                     style: GoogleFonts.lato(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.pink,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Sticky bottom bar ──────────────────────────────────────────────────────
// //   Widget _buildBottomBar(HostModel host, double bottomPad) {
// //     final isOffline = host.status == HostStatus.offline;
// //     final isBusy = host.status == HostStatus.busy;

// //     // Call button label + color
// //     final callLabel = isBusy
// //         ? 'Join Queue'
// //         : isOffline
// //         ? 'Offline'
// //         : 'Video Call';
// //     final callColor = isBusy
// //         ? Colors.orange
// //         : isOffline
// //         ? Colors.grey.shade400
// //         : Colors.pink;
// //     final callIcon = isBusy
// //         ? FontAwesomeIcons.clock
// //         : isOffline
// //         ? FontAwesomeIcons.ban
// //         : FontAwesomeIcons.video;

// //     return Container(
// //       padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPad),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha: 0.08),
// //             blurRadius: 20,
// //             offset: const Offset(0, -4),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           // Message button
// //           _iconBarButton(
// //             icon: FontAwesomeIcons.commentDots,
// //             color: Colors.pink,
// //             bgColor: Colors.pink.withValues(alpha: 0.10),
// //             onTap: _openChat,
// //           ),

// //           const SizedBox(width: 14),

// //           // Big call / queue button
// //           Expanded(
// //             child: Material(
// //               color: callColor,
// //               borderRadius: BorderRadius.circular(14),
// //               child: InkWell(
// //                 onTap: _onCallTap,
// //                 borderRadius: BorderRadius.circular(14),
// //                 child: Padding(
// //                   padding: const EdgeInsets.symmetric(
// //                     vertical: 14,
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       FaIcon(
// //                         callIcon,
// //                         color: Colors.white,
// //                         size: 16,
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Text(
// //                         callLabel,
// //                         style: GoogleFonts.lato(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Helpers ────────────────────────────────────────────────────────────────
// //   Widget _circleButton({
// //     required IconData icon,
// //     required VoidCallback onTap,
// //   }) {
// //     return Material(
// //       color: Colors.black.withValues(alpha: 0.35),
// //       shape: const CircleBorder(),
// //       child: InkWell(
// //         onTap: onTap,
// //         customBorder: const CircleBorder(),
// //         child: Padding(
// //           padding: const EdgeInsets.all(10),
// //           child: Icon(icon, color: Colors.white, size: 18),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _iconBarButton({
// //     required IconData icon,
// //     required Color color,
// //     required Color bgColor,
// //     required VoidCallback onTap,
// //   }) {
// //     return Material(
// //       color: bgColor,
// //       borderRadius: BorderRadius.circular(12),
// //       child: InkWell(
// //         onTap: onTap,
// //         borderRadius: BorderRadius.circular(12),
// //         child: Padding(
// //           padding: const EdgeInsets.all(14),
// //           child: FaIcon(icon, color: color, size: 18),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _statusDot(HostStatus status) => Container(
// //     width: 10,
// //     height: 10,
// //     decoration: BoxDecoration(
// //       color: getStatusColor(status),
// //       shape: BoxShape.circle,
// //       border: Border.all(color: Colors.white38, width: 1),
// //     ),
// //   );

// //   Widget _safeFlagWidget(HostModel host) {
// //     try {
// //       return Flag.fromCode(host.flagCode, fit: BoxFit.cover);
// //     } catch (_) {
// //       return const Icon(
// //         Icons.language,
// //         color: Colors.white70,
// //         size: 14,
// //       );
// //     }
// //   }

// //   Widget _pillChip(
// //     String label,
// //     Color bg, {
// //     Color textColor = Colors.white,
// //   }) => Container(
// //     padding: const EdgeInsets.symmetric(
// //       horizontal: 8,
// //       vertical: 3,
// //     ),
// //     decoration: BoxDecoration(
// //       color: bg,
// //       borderRadius: BorderRadius.circular(20),
// //     ),
// //     child: Text(
// //       label,
// //       style: TextStyle(
// //         color: textColor,
// //         fontSize: 11,
// //         fontWeight: FontWeight.w600,
// //       ),
// //     ),
// //   );

// //   Widget _languageChip(String language) => Container(
// //     padding: const EdgeInsets.symmetric(
// //       horizontal: 14,
// //       vertical: 8,
// //     ),
// //     decoration: BoxDecoration(
// //       color: Colors.grey.shade100,
// //       borderRadius: BorderRadius.circular(20),
// //       border: Border.all(color: Colors.grey.shade300),
// //     ),
// //     child: Row(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Icon(
// //           Icons.translate_rounded,
// //           size: 14,
// //           color: Colors.grey.shade600,
// //         ),
// //         const SizedBox(width: 6),
// //         Text(
// //           language,
// //           style: TextStyle(
// //             fontSize: 13,
// //             color: Colors.grey.shade800,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );

// //   Widget _sectionLabel(String text) => Text(
// //     text,
// //     style: GoogleFonts.lato(
// //       fontSize: 17,
// //       fontWeight: FontWeight.bold,
// //       color: Colors.black87,
// //     ),
// //   );

// //   // Full-screen photo viewer — swipable, pinch-to-zoom, tap to dismiss
// //   void _openFullScreenPhoto(
// //     List<String> photos,
// //     int startIndex,
// //   ) {
// //     Navigator.of(context).push(
// //       PageRouteBuilder<void>(
// //         opaque: false,
// //         barrierColor: Colors.black,
// //         pageBuilder: (ctx, animation, _) {
// //           return FadeTransition(
// //             opacity: animation,
// //             child: _FullScreenPhotoViewer(
// //               photos: photos,
// //               initialIndex: startIndex,
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _defaultPhoto() => Container(
// //     color: Colors.grey.shade200,
// //     child: Center(
// //       child: Icon(
// //         Icons.person,
// //         size: 80,
// //         color: Colors.grey.shade400,
// //       ),
// //     ),
// //   );

// //   String _formatCount(int n) {
// //     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
// //     return n.toString();
// //   }

// //   void _showMoreMenu() {
// //     showModalBottomSheet<void>(
// //       context: context,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(
// //           top: Radius.circular(20),
// //         ),
// //       ),
// //       builder: (_) => SafeArea(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const SizedBox(height: 8),
// //             Container(
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: Colors.grey.shade300,
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             ListTile(
// //               leading: const Icon(Icons.share_outlined),
// //               title: const Text('Share Profile'),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 // TODO: Share host profile link
// //               },
// //             ),
// //             ListTile(
// //               leading: const Icon(
// //                 Icons.flag_outlined,
// //                 color: Colors.red,
// //               ),
// //               title: const Text(
// //                 'Report',
// //                 style: TextStyle(color: Colors.red),
// //               ),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 _showReportDialog();
// //               },
// //             ),
// //             const SizedBox(height: 8),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void _showReportDialog() {
// //     showDialog<void>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: const Text('Report Host'),
// //         content: const Text(
// //           'Are you sure you want to report this host? Our team will review their profile.',
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(ctx).pop(),
// //             child: const Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.of(ctx).pop();
// //               // TODO: POST /api/reports  { reported_user_id: widget.host.userId }
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(
// //                   content: Text('Report submitted. Thank you.'),
// //                   behavior: SnackBarBehavior.floating,
// //                 ),
// //               );
// //             },
// //             child: const Text(
// //               'Report',
// //               style: TextStyle(color: Colors.red),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ---------------------------------------------------------------------------
// // // Internal data class for stub gift display
// // // ---------------------------------------------------------------------------
// // class _GiftItem {
// //   const _GiftItem({
// //     required this.emoji,
// //     required this.name,
// //     required this.count,
// //   });

// //   final String emoji;
// //   final String name;
// //   final int count;
// // }

// // // ---------------------------------------------------------------------------
// // // Full-screen photo viewer
// // // Swipable PageView + pinch-to-zoom via InteractiveViewer.
// // // Tap anywhere or press back to dismiss.
// // // ---------------------------------------------------------------------------
// // class _FullScreenPhotoViewer extends StatefulWidget {
// //   const _FullScreenPhotoViewer({
// //     required this.photos,
// //     required this.initialIndex,
// //   });

// //   final List<String> photos;
// //   final int initialIndex;

// //   @override
// //   State<_FullScreenPhotoViewer> createState() =>
// //       _FullScreenPhotoViewerState();
// // }

// // class _FullScreenPhotoViewerState
// //     extends State<_FullScreenPhotoViewer> {
// //   late final PageController _ctrl;
// //   late int _current;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _current = widget.initialIndex;
// //     _ctrl = PageController(initialPage: widget.initialIndex);
// //   }

// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Stack(
// //         children: [
// //           // Swipable + zoomable photos
// //           PageView.builder(
// //             controller: _ctrl,
// //             itemCount: widget.photos.length,
// //             onPageChanged: (i) => setState(() => _current = i),
// //             itemBuilder: (_, i) => InteractiveViewer(
// //               minScale: 0.8,
// //               maxScale: 4.0,
// //               child: Center(
// //                 child: Image.network(
// //                   widget.photos[i],
// //                   fit: BoxFit.contain,
// //                   errorBuilder: (_, __, ___) => const Icon(
// //                     Icons.broken_image,
// //                     color: Colors.white38,
// //                     size: 60,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // Close button
// //           Positioned(
// //             top: MediaQuery.of(context).padding.top + 8,
// //             left: 12,
// //             child: Material(
// //               color: Colors.black45,
// //               shape: const CircleBorder(),
// //               child: InkWell(
// //                 customBorder: const CircleBorder(),
// //                 onTap: () => Navigator.of(context).pop(),
// //                 child: const Padding(
// //                   padding: EdgeInsets.all(10),
// //                   child: Icon(
// //                     Icons.close,
// //                     color: Colors.white,
// //                     size: 20,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // Photo count indicator  e.g. "2 / 5"
// //           if (widget.photos.length > 1)
// //             Positioned(
// //               top: MediaQuery.of(context).padding.top + 16,
// //               left: 0,
// //               right: 0,
// //               child: Center(
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 12,
// //                     vertical: 5,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.black54,
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     '${_current + 1} / ${widget.photos.length}',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // lib/screens/profile_details_screen.dart
// //
// // Host profile page — opened from HostCard tap (card body) or
// // the small profile icon on the card corner.
// //
// // Receives a HostModel. All data that isn't in HostModel yet
// // (followers, call count, gifts) is stubbed with dummy values
// // clearly marked TODO — swap with real API data when Node.js is ready.

// import 'dart:math';

// import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:cheerchat/models/host_model.dart';
// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// // ---------------------------------------------------------------------------
// // Screen
// // ---------------------------------------------------------------------------
// class ProfileDetailsScreen extends StatefulWidget {
//   const ProfileDetailsScreen({super.key, required this.host});

//   final HostModel host;

//   @override
//   State<ProfileDetailsScreen> createState() =>
//       _ProfileDetailsScreenState();
// }

// class _ProfileDetailsScreenState
//     extends State<ProfileDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   bool _isFollowed = false;
//   bool _isNotifySet = false;
//   int _currentPhotoIndex = 0;
//   late final PageController _pageController;
//   late final AnimationController _entranceController;
//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset> _slideAnim;

//   // Stub stats — replace with real data from API
//   // TODO: load from GET /api/hosts/:userId/stats
//   late final int _followerCount;
//   late final int _followingCount;
//   // late final int _giftCount;
//   late final int _age;

//   // For now a host may have only one photo; PageView is already wired
//   // so adding photos later requires zero UI changes.
//   List<String> get _photos {
//     final url = widget.host.profilePhotoUrl;
//     if (url != null && url.isNotEmpty) return [url];
//     return [];
//   }

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _entranceController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 420),
//     );
//     _fadeAnim = CurvedAnimation(
//       parent: _entranceController,
//       curve: Curves.easeOut,
//     );
//     _slideAnim =
//         Tween<Offset>(
//           begin: const Offset(0, 0.06),
//           end: Offset.zero,
//         ).animate(
//           CurvedAnimation(
//             parent: _entranceController,
//             curve: Curves.easeOut,
//           ),
//         );

//     // Stub data
//     final rng = Random();
//     _followerCount = widget.host.age != null
//         ? 200 + rng.nextInt(4800)
//         : 100 + rng.nextInt(9900);
//     _followingCount = 10 + rng.nextInt(290);
//     // _giftCount = 5 + rng.nextInt(295);
//     _age = widget.host.age ?? (18 + rng.nextInt(23));

//     _entranceController.forward();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _entranceController.dispose();
//     super.dispose();
//   }

//   // -------------------------------------------------------------------------
//   // Actions
//   // -------------------------------------------------------------------------
//   void _toggleFollow() {
//     HapticFeedback.lightImpact();
//     setState(() => _isFollowed = !_isFollowed);
//     // TODO: POST /api/follows  { host_id: widget.host.userId }
//   }

//   void _toggleNotify() {
//     HapticFeedback.lightImpact();
//     final wasSet = _isNotifySet;
//     setState(() => _isNotifySet = !_isNotifySet);
//     // TODO: POST /api/notify-online  { host_id: widget.host.userId, enabled: !wasSet }
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           wasSet
//               ? 'Notification cancelled.'
//               : "We'll notify you when ${widget.host.displayName} comes online!",
//         ),
//         backgroundColor: wasSet
//             ? Colors.grey.shade700
//             : Colors.orange,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   void _openChat() {
//     HapticFeedback.lightImpact();
//     // TODO: pushScreenWithoutNavBar(context, ChatScreen(host: widget.host));
//     debugPrint('Open chat with ${widget.host.displayName}');
//   }

//   void _onCallTap() {
//     HapticFeedback.mediumImpact();
//     switch (widget.host.status) {
//       case HostStatus.online:
//         // TODO: push call screen
//         debugPrint('Calling ${widget.host.displayName}');
//         break;
//       case HostStatus.busy:
//         _showBusyDialog();
//         break;
//       case HostStatus.offline:
//         _toggleNotify();
//         break;
//     }
//   }

//   void _showBusyDialog() {
//     showDialog<void>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         contentPadding: const EdgeInsets.fromLTRB(
//           24,
//           24,
//           24,
//           12,
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.pink.shade50,
//               child: const FaIcon(
//                 FontAwesomeIcons.video,
//                 color: Colors.pink,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               '${widget.host.displayName} is busy',
//               style: GoogleFonts.lato(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'She is on a call right now.\nJoin the queue and we\'ll notify you when she\'s free.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           FilledButton.icon(
//             style: FilledButton.styleFrom(
//               backgroundColor: Colors.pink,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               _joinQueue();
//             },
//             icon: const Icon(
//               Icons.notifications_outlined,
//               size: 16,
//             ),
//             label: const Text('Notify Me'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _joinQueue() {
//     // TODO: POST /api/call-queue  { host_id: widget.host.userId }
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           "You'll be notified when ${widget.host.displayName} is free!",
//         ),
//         backgroundColor: Colors.orange,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   // -------------------------------------------------------------------------
//   // Build
//   // -------------------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     final host = widget.host;
//     final bottomPad = MediaQuery.of(context).padding.bottom;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           // ── Scrollable content ───────────────────────────────────────────
//           CustomScrollView(
//             slivers: [
//               // Photo hero
//               SliverToBoxAdapter(child: _buildPhotoHero(host)),

//               // Info card
//               SliverToBoxAdapter(
//                 child: FadeTransition(
//                   opacity: _fadeAnim,
//                   child: SlideTransition(
//                     position: _slideAnim,
//                     child: _buildInfoCard(host),
//                   ),
//                 ),
//               ),

//               // Bottom padding for sticky bar
//               SliverToBoxAdapter(
//                 child: SizedBox(height: 100 + bottomPad),
//               ),
//             ],
//           ),

//           // ── Back button ──────────────────────────────────────────────────
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             left: 12,
//             child: _circleButton(
//               icon: Icons.arrow_back_ios_new_rounded,
//               onTap: () => Navigator.of(context).pop(),
//             ),
//           ),

//           // ── 3-dot menu (report / share) ──────────────────────────────────
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             right: 12,
//             child: _circleButton(
//               icon: Icons.more_vert_rounded,
//               onTap: _showMoreMenu,
//             ),
//           ),

//           // ── Sticky bottom action bar ─────────────────────────────────────
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: _buildBottomBar(host, bottomPad),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Photo hero ─────────────────────────────────────────────────────────────
//   Widget _buildPhotoHero(HostModel host) {
//     final photos = _photos;
//     const heroHeight = 420.0;

//     return SizedBox(
//       height: heroHeight,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // PageView of photos (or default placeholder)
//           photos.isEmpty
//               ? _defaultPhoto()
//               : PageView.builder(
//                   controller: _pageController,
//                   itemCount: photos.length,
//                   onPageChanged: (i) =>
//                       setState(() => _currentPhotoIndex = i),
//                   itemBuilder: (_, i) => GestureDetector(
//                     onTap: () => _openFullScreenPhoto(photos, i),
//                     child: Image.network(
//                       photos[i],
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                           _defaultPhoto(),
//                     ),
//                   ),
//                 ),

//           // Bottom gradient
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               height: 160,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     Colors.black.withValues(alpha: 0.70),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Level label badge — top-right corner of photo
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 56,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 10,
//                 vertical: 5,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.pink.withValues(alpha: 0.88),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 host.levelLabel,
//                 style: GoogleFonts.lato(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           // Name + meta over the photo
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: 20,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Name row with status dot + verified badge
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     _statusDot(host.status),
//                     const SizedBox(width: 7),
//                     Flexible(
//                       child: Text(
//                         host.displayName,
//                         style: GoogleFonts.lato(
//                           color: Colors.white,
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           shadows: const [
//                             Shadow(
//                               blurRadius: 8,
//                               color: Colors.black54,
//                             ),
//                           ],
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     // Verified badge
//                     Container(
//                       padding: const EdgeInsets.all(3),
//                       decoration: const BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         color: Colors.white,
//                         size: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 7),
//                 // Flag • Age • Level number  ——  counter pushed to far right
//                 Row(
//                   children: [
//                     SizedBox(
//                       height: 14,
//                       width: 20,
//                       child: _safeFlagWidget(host),
//                     ),
//                     const SizedBox(width: 8),
//                     _pillChip(
//                       '$_age yrs',
//                       Colors.white.withValues(alpha: 0.22),
//                     ),
//                     const SizedBox(width: 6),
//                     _pillChip(
//                       'Lv.${host.level}',
//                       Colors.white.withValues(alpha: 0.22),
//                     ),
//                     const Spacer(),
//                     // Numeric photo counter — rightmost of this row
//                     Text(
//                       '${_currentPhotoIndex + 1} / ${_photos.isEmpty ? 1 : _photos.length}',
//                       style: GoogleFonts.lato(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         shadows: const [
//                           Shadow(
//                             blurRadius: 6,
//                             color: Colors.black87,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Info card ──────────────────────────────────────────────────────────────
//   Widget _buildInfoCard(HostModel host) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 20,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Stats row
//           _buildStatsRow(),

//           const SizedBox(height: 24),
//           const Divider(height: 1),
//           const SizedBox(height: 20),

//           // Bio
//           if (host.bio != null && host.bio!.isNotEmpty) ...[
//             _sectionLabel('About'),
//             const SizedBox(height: 8),
//             Text(
//               host.bio!,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey.shade700,
//                 height: 1.55,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],

//           // Language
//           _sectionLabel('Speaks'),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _languageChip(host.language),
//               // TODO: add more languages when API returns list
//             ],
//           ),

//           const SizedBox(height: 24),
//           const Divider(height: 1),
//           const SizedBox(height: 20),

//           // Gifts Received
//           _buildGiftsSection(),
//         ],
//       ),
//     );
//   }

//   Widget _vertDivider() => Container(
//     width: 1,
//     height: 36,
//     color: Colors.grey.shade200,
//   );

//   // Stats row
//   Widget _buildStatsRow() {
//     return SizedBox(
//       height:
//           56, // Increased slightly to comfortably fit the extra spacing
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Expanded(
//             child: _statItem(
//               _formatCount(_followerCount),
//               'Followers',
//             ),
//           ),
//           _vertDivider(),
//           Expanded(
//             child: _statItem(
//               _formatCount(_followingCount),
//               'Following',
//             ),
//           ),
//           _vertDivider(),
//           Expanded(child: _followStatButton()),
//         ],
//       ),
//     );
//   }

//   Widget _statItem(String value, String label) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Text(
//           value,
//           style: GoogleFonts.lato(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//             height: 1.0,
//           ),
//         ),
//         const SizedBox(
//           height: 8,
//         ), // 👈 Increased vertical gap here
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade500,
//             height: 1.0,
//           ),
//         ),
//       ],
//     );
//   }

//   // Follow button styled like a stat cell
//   Widget _followStatButton() {
//     return GestureDetector(
//       onTap: _toggleFollow,
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Icon(
//               _isFollowed
//                   ? Icons.favorite
//                   : Icons.favorite_border,
//               color: _isFollowed
//                   ? Colors.pink
//                   : Colors.grey.shade700,
//               size: 24,
//             ),
//             const SizedBox(
//               height: 8,
//             ), // 👈 MUST match the gap in _statItem exactly!
//             Text(
//               _isFollowed ? 'Following' : 'Follow',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: _isFollowed
//                     ? Colors.pink
//                     : Colors.grey.shade500,
//                 height: 1.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Gifts Received section
//   // TODO: load real gift data from GET /api/hosts/:userId/gifts
//   Widget _buildGiftsSection() {
//     // Stub gift catalog — 6 popular gifts with emoji + stub counts
//     final gifts = [
//       _GiftItem(
//         emoji: '🌹',
//         name: 'Rose',
//         count: 12 + Random().nextInt(88),
//       ),
//       _GiftItem(
//         emoji: '💎',
//         name: 'Diamond',
//         count: 3 + Random().nextInt(27),
//       ),
//       _GiftItem(
//         emoji: '🎂',
//         name: 'Cake',
//         count: 5 + Random().nextInt(45),
//       ),
//       _GiftItem(
//         emoji: '🚀',
//         name: 'Rocket',
//         count: 1 + Random().nextInt(19),
//       ),
//       _GiftItem(
//         emoji: '👑',
//         name: 'Crown',
//         count: 2 + Random().nextInt(18),
//       ),
//       _GiftItem(
//         emoji: '🎁',
//         name: 'Box',
//         count: 8 + Random().nextInt(72),
//       ),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Gifts Received'),
//         // const SizedBox(height: 12),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: gifts.length,
//           padding: EdgeInsetsGeometry.only(top: 20),
//           gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 10,
//                 crossAxisSpacing: 10,
//                 childAspectRatio: 1.15,
//               ),
//           itemBuilder: (_, i) {
//             final g = gifts[i];
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     g.emoji,
//                     style: const TextStyle(fontSize: 28),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     g.name,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     '×${g.count}',
//                     style: GoogleFonts.lato(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.pink,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // ── Sticky bottom bar ──────────────────────────────────────────────────────
//   Widget _buildBottomBar(HostModel host, double bottomPad) {
//     final isOffline = host.status == HostStatus.offline;
//     final isBusy = host.status == HostStatus.busy;

//     return Container(
//       padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPad),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 20,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Message button
//           _iconBarButton(
//             icon: FontAwesomeIcons.commentDots,
//             color: Colors.pink,
//             bgColor: Colors.pink.withValues(alpha: 0.10),
//             onTap: _openChat,
//           ),

//           const SizedBox(width: 14),

//           // Big action button — changes per status
//           Expanded(
//             child: isOffline
//                 ? _notifyButton(host, bottomPad)
//                 : _callButton(host, isBusy),
//           ),
//         ],
//       ),
//     );
//   }

//   // Online / Busy call button with rate shown
//   Widget _callButton(HostModel host, bool isBusy) {
//     final color = isBusy ? Colors.orange : Colors.pink;
//     final icon = isBusy
//         ? FontAwesomeIcons.clock
//         : FontAwesomeIcons.video;

//     return Material(
//       color: color,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         onTap: _onCallTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 13),
//           child: isBusy
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     FaIcon(icon, color: Colors.white, size: 15),
//                     const SizedBox(width: 9),
//                     Text(
//                       'Join Queue',
//                       style: GoogleFonts.lato(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 )
//               // Online: show icon + rate on one line
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     FaIcon(icon, color: Colors.white, size: 15),
//                     const SizedBox(width: 9),
//                     Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Video Call',
//                           style: GoogleFonts.lato(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15,
//                             height: 1.1,
//                           ),
//                         ),
//                         Text(
//                           '${host.priceCoins} coins / min',
//                           style: TextStyle(
//                             color: Colors.white.withValues(
//                               alpha: 0.85,
//                             ),
//                             fontSize: 11,
//                             height: 1.2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   // Offline: notify-when-online bell button
//   Widget _notifyButton(HostModel host, double bottomPad) {
//     return Material(
//       color: _isNotifySet
//           ? Colors.grey.shade200
//           : Colors.grey.shade800,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         onTap: _toggleNotify,
//         borderRadius: BorderRadius.circular(14),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 13),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 _isNotifySet
//                     ? Icons.notifications_active
//                     : Icons.notifications_outlined,
//                 color: _isNotifySet
//                     ? Colors.orange
//                     : Colors.white,
//                 size: 20,
//               ),
//               const SizedBox(width: 9),
//               Text(
//                 _isNotifySet
//                     ? 'Notify Me (Set)'
//                     : 'Notify When Online',
//                 style: GoogleFonts.lato(
//                   color: _isNotifySet
//                       ? Colors.grey.shade700
//                       : Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Helpers ────────────────────────────────────────────────────────────────
//   Widget _circleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.black.withValues(alpha: 0.35),
//       shape: const CircleBorder(),
//       child: InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Icon(icon, color: Colors.white, size: 18),
//         ),
//       ),
//     );
//   }

//   Widget _iconBarButton({
//     required IconData icon,
//     required Color color,
//     required Color bgColor,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: bgColor,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: FaIcon(icon, color: color, size: 18),
//         ),
//       ),
//     );
//   }

//   Widget _statusDot(HostStatus status) => Container(
//     width: 10,
//     height: 10,
//     decoration: BoxDecoration(
//       color: getStatusColor(status),
//       shape: BoxShape.circle,
//       border: Border.all(color: Colors.white38, width: 1),
//     ),
//   );

//   Widget _safeFlagWidget(HostModel host) {
//     try {
//       return Flag.fromCode(host.flagCode, fit: BoxFit.cover);
//     } catch (_) {
//       return const Icon(
//         Icons.language,
//         color: Colors.white70,
//         size: 14,
//       );
//     }
//   }

//   Widget _pillChip(
//     String label,
//     Color bg, {
//     Color textColor = Colors.white,
//   }) => Container(
//     padding: const EdgeInsets.symmetric(
//       horizontal: 8,
//       vertical: 3,
//     ),
//     decoration: BoxDecoration(
//       color: bg,
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Text(
//       label,
//       style: TextStyle(
//         color: textColor,
//         fontSize: 11,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//   );

//   Widget _languageChip(String language) => Container(
//     padding: const EdgeInsets.symmetric(
//       horizontal: 14,
//       vertical: 8,
//     ),
//     decoration: BoxDecoration(
//       color: Colors.grey.shade100,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: Colors.grey.shade300),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           Icons.translate_rounded,
//           size: 14,
//           color: Colors.grey.shade600,
//         ),
//         const SizedBox(width: 6),
//         Text(
//           language,
//           style: TextStyle(
//             fontSize: 13,
//             color: Colors.grey.shade800,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );

//   Widget _sectionLabel(String text) => Text(
//     text,
//     style: GoogleFonts.lato(
//       fontSize: 17,
//       fontWeight: FontWeight.bold,
//       color: Colors.black87,
//     ),
//   );

//   // Full-screen photo viewer — swipable, pinch-to-zoom, tap to dismiss
//   void _openFullScreenPhoto(
//     List<String> photos,
//     int startIndex,
//   ) {
//     Navigator.of(context).push(
//       PageRouteBuilder<void>(
//         opaque: false,
//         barrierColor: Colors.black,
//         pageBuilder: (ctx, animation, _) {
//           return FadeTransition(
//             opacity: animation,
//             child: _FullScreenPhotoViewer(
//               photos: photos,
//               initialIndex: startIndex,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _defaultPhoto() => Container(
//     color: Colors.grey.shade200,
//     child: Center(
//       child: Icon(
//         Icons.person,
//         size: 80,
//         color: Colors.grey.shade400,
//       ),
//     ),
//   );

//   String _formatCount(int n) {
//     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
//     return n.toString();
//   }

//   void _showMoreMenu() {

//     showAdaptiveActionSheet(
//       bottomSheetColor: Colors.white,
//       // barrierColor: Colors.red,
//       context: context,
//       androidBorderRadius:
//           20, // Keeps the rounded corners on Android
//       actions: <BottomSheetAction>[
//         BottomSheetAction(
//           title: const Text('Share Profile'),
//           leading: const Icon(Icons.share_outlined),
//           onPressed: (BuildContext context) {
//             Navigator.pop(context);
//             // TODO: Share host profile link
//           },
//         ),
//         BottomSheetAction(
//           title: const Text('Block'),
//           leading: const Icon(Icons.block_outlined),
//           onPressed: (BuildContext context) {
//             Navigator.pop(context);
//             // TODO: Block host logic
//           },
//         ),
//         BottomSheetAction(
//           title: const Text(
//             'Report',
//             style: TextStyle(color: Colors.red),
//           ),
//           leading: const Icon(
//             Icons.flag_outlined,
//             color: Colors.red,
//           ),
//           onPressed: (BuildContext context) {
//             Navigator.pop(context);
//             _showReportDialog();
//           },
//         ),
//       ],
//       // The cancel button is highly recommended for iOS native behavior
//       cancelAction: CancelAction(
//         title: const Text(
//           'Cancel',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showReportDialog() {

//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.warning,
//       animType: AnimType.rightSlide,
//       customHeader: const Icon(
//         Icons.flag_outlined,
//         color: Colors.red,
//         size: 40,
//       ),
//       title: 'Block User?',
//       dialogBackgroundColor: Colors.white,
//       // desc: 'Dialog description here.............',
//       btnCancelOnPress: () {},
//       btnOkOnPress: () {},
//     ).show();
//   }
// }

// // ---------------------------------------------------------------------------
// // Internal data class for stub gift display
// // ---------------------------------------------------------------------------
// class _GiftItem {
//   const _GiftItem({
//     required this.emoji,
//     required this.name,
//     required this.count,
//   });

//   final String emoji;
//   final String name;
//   final int count;
// }

// // ---------------------------------------------------------------------------
// // Full-screen photo viewer
// // Swipable PageView + pinch-to-zoom via InteractiveViewer.
// // Tap anywhere or press back to dismiss.
// // ---------------------------------------------------------------------------
// class _FullScreenPhotoViewer extends StatefulWidget {
//   const _FullScreenPhotoViewer({
//     required this.photos,
//     required this.initialIndex,
//   });

//   final List<String> photos;
//   final int initialIndex;

//   @override
//   State<_FullScreenPhotoViewer> createState() =>
//       _FullScreenPhotoViewerState();
// }

// class _FullScreenPhotoViewerState
//     extends State<_FullScreenPhotoViewer> {
//   late final PageController _ctrl;
//   late int _current;

//   @override
//   void initState() {
//     super.initState();
//     _current = widget.initialIndex;
//     _ctrl = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Swipable + zoomable photos
//           PageView.builder(
//             controller: _ctrl,
//             itemCount: widget.photos.length,
//             onPageChanged: (i) => setState(() => _current = i),
//             itemBuilder: (_, i) => InteractiveViewer(
//               minScale: 0.8,
//               maxScale: 4.0,
//               child: Center(
//                 child: Image.network(
//                   widget.photos[i],
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) => const Icon(
//                     Icons.broken_image,
//                     color: Colors.white38,
//                     size: 60,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Close button
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             left: 12,
//             child: Material(
//               color: Colors.black45,
//               shape: const CircleBorder(),
//               child: InkWell(
//                 customBorder: const CircleBorder(),
//                 onTap: () => Navigator.of(context).pop(),
//                 child: const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Photo count indicator  e.g. "2 / 5"
//           if (widget.photos.length > 1)
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 16,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${_current + 1} / ${widget.photos.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key, required this.host});

  final HostModel host;

  @override
  State<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState
    extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isFollowed = false;
  bool _isNotifySet = false;
  int _currentPhotoIndex = 0;
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Stub stats — replace with real data from API
  // TODO: load from GET /api/hosts/:userId/stats
  late final int _followerCount;
  late final int _followingCount;
  // late final int _giftCount;
  late final int _age;

  // For now a host may have only one photo; PageView is already wired
  // so adding photos later requires zero UI changes.
  List<String> get _photos {
    final url = widget.host.profilePhotoUrl;
    if (url != null && url.isNotEmpty) return [url];
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim =
        Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOut,
          ),
        );

    // Stub data
    final rng = Random();
    _followerCount = widget.host.age != null
        ? 200 + rng.nextInt(4800)
        : 100 + rng.nextInt(9900);
    _followingCount = 10 + rng.nextInt(290);
    // _giftCount = 5 + rng.nextInt(295);
    _age = widget.host.age ?? (18 + rng.nextInt(23));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------
  void _toggleFollow() {
    HapticFeedback.lightImpact();
    setState(() => _isFollowed = !_isFollowed);
    // TODO: POST /api/follows  { host_id: widget.host.userId }
  }

  void _toggleNotify() {
    HapticFeedback.lightImpact();
    final wasSet = _isNotifySet;
    setState(() => _isNotifySet = !_isNotifySet);
    // TODO: POST /api/notify-online  { host_id: widget.host.userId, enabled: !wasSet }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSet
              ? 'Notification cancelled.'
              : "We'll notify you when ${widget.host.displayName} comes online!",
        ),
        backgroundColor: wasSet
            ? Colors.grey.shade700
            : Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _openChat() {
    HapticFeedback.lightImpact();
    // TODO: pushScreenWithoutNavBar(context, ChatScreen(host: widget.host));
    debugPrint('Open chat with ${widget.host.displayName}');
  }

  // ── CHANGED: busy now shows a snackbar instead of a dialog ───────────────
  void _onCallTap() {
    HapticFeedback.mediumImpact();
    switch (widget.host.status) {
      case HostStatus.online:
        // TODO: push call screen
        debugPrint('Calling ${widget.host.displayName}');
        break;
      case HostStatus.busy:
        _showBusySnackbar();
        break;
      case HostStatus.offline:
        _toggleNotify();
        break;
    }
  }

  void _showBusySnackbar() {
    // Auto-queue in background — TODO: POST /api/call-queue { host_id }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.host.displayName} is on a call right now. '
          "We'll notify you when she's available!",
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final host = widget.host;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable content ───────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // Photo hero
              SliverToBoxAdapter(child: _buildPhotoHero(host)),

              // Info card
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildInfoCard(host),
                  ),
                ),
              ),

              // Bottom padding for sticky bar
              SliverToBoxAdapter(
                child: SizedBox(height: 100 + bottomPad),
              ),
            ],
          ),

          // ── Back button ──────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _circleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

          // ── 3-dot menu (report / share) ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _circleButton(
              icon: Icons.more_vert_rounded,
              onTap: _showMoreMenu,
            ),
          ),

          // ── Sticky bottom action bar ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(host, bottomPad),
          ),
        ],
      ),
    );
  }

  // ── Photo hero ─────────────────────────────────────────────────────────────
  Widget _buildPhotoHero(HostModel host) {
    final photos = _photos;
    const heroHeight = 420.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView of photos (or default placeholder)
          photos.isEmpty
              ? _defaultPhoto()
              : PageView.builder(
                  controller: _pageController,
                  itemCount: photos.length,
                  onPageChanged: (i) =>
                      setState(() => _currentPhotoIndex = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openFullScreenPhoto(photos, i),
                    child: Image.network(
                      photos[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _defaultPhoto(),
                    ),
                  ),
                ),

          // Bottom gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Level label badge — top-right corner of photo
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                host.levelLabel,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Name + meta over the photo
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name row with status dot + verified badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _statusDot(host.status),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        host.displayName,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Verified badge
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // Flag • Age • Level number  ——  counter pushed to far right
                Row(
                  children: [
                    SizedBox(
                      height: 14,
                      width: 20,
                      child: _safeFlagWidget(host),
                    ),
                    const SizedBox(width: 8),
                    _pillChip(
                      '$_age yrs',
                      Colors.white.withValues(alpha: 0.22),
                    ),
                    const SizedBox(width: 6),
                    _pillChip(
                      'Lv.${host.level}',
                      Colors.white.withValues(alpha: 0.22),
                    ),
                    const Spacer(),
                    // Numeric photo counter — rightmost of this row
                    Text(
                      '${_currentPhotoIndex + 1} / ${_photos.isEmpty ? 1 : _photos.length}',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard(HostModel host) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          _buildStatsRow(),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Bio
          if (host.bio != null && host.bio!.isNotEmpty) ...[
            _sectionLabel('About'),
            const SizedBox(height: 8),
            Text(
              host.bio!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Language
          _sectionLabel('Speaks'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _languageChip(host.language),
              // TODO: add more languages when API returns list
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Gifts Received
          _buildGiftsSection(),
        ],
      ),
    );
  }

  Widget _vertDivider() => Container(
    width: 1,
    height: 36,
    color: Colors.grey.shade200,
  );

  // Stats row
  Widget _buildStatsRow() {
    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _statItem(
              _formatCount(_followerCount),
              'Followers',
            ),
          ),
          _vertDivider(),
          Expanded(
            child: _statItem(
              _formatCount(_followingCount),
              'Following',
            ),
          ),
          _vertDivider(),
          Expanded(child: _followStatButton()),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // Follow button styled like a stat cell
  Widget _followStatButton() {
    return GestureDetector(
      onTap: _toggleFollow,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              _isFollowed
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _isFollowed
                  ? Colors.pink
                  : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              _isFollowed ? 'Following' : 'Follow',
              style: TextStyle(
                fontSize: 12,
                color: _isFollowed
                    ? Colors.pink
                    : Colors.grey.shade500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gifts Received section
  // TODO: load real gift data from GET /api/hosts/:userId/gifts
  Widget _buildGiftsSection() {
    final gifts = [
      _GiftItem(
        emoji: '🌹',
        name: 'Rose',
        count: 12 + Random().nextInt(88),
      ),
      _GiftItem(
        emoji: '💎',
        name: 'Diamond',
        count: 3 + Random().nextInt(27),
      ),
      _GiftItem(
        emoji: '🎂',
        name: 'Cake',
        count: 5 + Random().nextInt(45),
      ),
      _GiftItem(
        emoji: '🚀',
        name: 'Rocket',
        count: 1 + Random().nextInt(19),
      ),
      _GiftItem(
        emoji: '👑',
        name: 'Crown',
        count: 2 + Random().nextInt(18),
      ),
      _GiftItem(
        emoji: '🎁',
        name: 'Box',
        count: 8 + Random().nextInt(72),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Gifts Received'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gifts.length,
          padding: EdgeInsetsGeometry.only(top: 20),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
          itemBuilder: (_, i) {
            final g = gifts[i];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    g.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    g.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '×${g.count}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Sticky bottom bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar(HostModel host, double bottomPad) {
    final isOffline = host.status == HostStatus.offline;
    final isBusy = host.status == HostStatus.busy;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message button
          _iconBarButton(
            icon: FontAwesomeIcons.commentDots,
            color: Colors.pink,
            bgColor: Colors.pink.withValues(alpha: 0.10),
            onTap: _openChat,
          ),

          const SizedBox(width: 14),

          // Big action button — changes per status
          Expanded(
            child: isOffline
                ? _notifyButton(host, bottomPad)
                : _callButton(host, isBusy),
          ),
        ],
      ),
    );
  }

  // ── CHANGED: identical pink button for both online and busy ───────────────
  Widget _callButton(HostModel host, bool isBusy) {
    return Material(
      color: Colors.pink,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _onCallTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.video,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Video Call',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '${host.priceCoins} coins / min',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.85,
                      ),
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Offline: notify-when-online bell button
  Widget _notifyButton(HostModel host, double bottomPad) {
    return Material(
      color: _isNotifySet
          ? Colors.grey.shade200
          : Colors.grey.shade800,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _toggleNotify,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isNotifySet
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
                color: _isNotifySet
                    ? Colors.orange
                    : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 9),
              Text(
                _isNotifySet
                    ? 'Notify Me (Set)'
                    : 'Notify When Online',
                style: GoogleFonts.lato(
                  color: _isNotifySet
                      ? Colors.grey.shade700
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _iconBarButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FaIcon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _statusDot(HostStatus status) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: getStatusColor(status),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white38, width: 1),
    ),
  );

  Widget _safeFlagWidget(HostModel host) {
    try {
      return Flag.fromCode(host.flagCode, fit: BoxFit.cover);
    } catch (_) {
      return const Icon(
        Icons.language,
        color: Colors.white70,
        size: 14,
      );
    }
  }

  Widget _pillChip(
    String label,
    Color bg, {
    Color textColor = Colors.white,
  }) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _languageChip(String language) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.translate_rounded,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Text(
          language,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.lato(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  void _openFullScreenPhoto(
    List<String> photos,
    int startIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (ctx, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenPhotoViewer(
              photos: photos,
              initialIndex: startIndex,
            ),
          );
        },
      ),
    );
  }

  Widget _defaultPhoto() => Container(
    color: Colors.grey.shade200,
    child: Center(
      child: Icon(
        Icons.person,
        size: 80,
        color: Colors.grey.shade400,
      ),
    ),
  );

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  void _showMoreMenu() {
    showAdaptiveActionSheet(
      bottomSheetColor: Colors.white,
      context: context,
      androidBorderRadius: 20,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('Share Profile'),
          leading: const Icon(Icons.share_outlined),
          onPressed: (BuildContext context) {
            Navigator.pop(context);
            // TODO: Share host profile link
          },
        ),
        BottomSheetAction(
          title: const Text('Block'),
          leading: const Icon(Icons.block_outlined),
          onPressed: (BuildContext context) {
            Navigator.pop(context);
            // TODO: Block host logic

            _showBlockDialog();
          },
        ),
        BottomSheetAction(
          title: const Text(
            'Report',
            style: TextStyle(color: Colors.red),
          ),
          leading: const Icon(
            Icons.flag_outlined,
            color: Colors.red,
          ),
          onPressed: (BuildContext context) {
            Navigator.pop(context);
            _showReportDialog();
          },
        ),
      ],
      cancelAction: CancelAction(
        title: const Text(
          'Cancel',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  void _showBlockDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      customHeader: const Icon(
        Icons.block_outlined,
        color: Colors.red,
        size: 40,
      ),
      title: 'Block ${widget.host.displayName}?',
      dialogBackgroundColor: Colors.white,
      btnCancelOnPress: () {
        // Navigator.pop(context);
      },
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }

  void _showReportDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      customHeader: const Icon(
        Icons.flag_outlined,
        color: Colors.red,
        size: 40,
      ),
      title: 'Report ${widget.host.displayName}?',
      dialogBackgroundColor: Colors.white,
      btnCancelOnPress: () {
        // Navigator.pop(context);
      },
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }
}

// ---------------------------------------------------------------------------
// Internal data class for stub gift display
// ---------------------------------------------------------------------------
class _GiftItem {
  const _GiftItem({
    required this.emoji,
    required this.name,
    required this.count,
  });

  final String emoji;
  final String name;
  final int count;
}

// ---------------------------------------------------------------------------
// Full-screen photo viewer
// ---------------------------------------------------------------------------
class _FullScreenPhotoViewer extends StatefulWidget {
  const _FullScreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  final List<String> photos;
  final int initialIndex;

  @override
  State<_FullScreenPhotoViewer> createState() =>
      _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState
    extends State<_FullScreenPhotoViewer> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  widget.photos[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white38,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          if (widget.photos.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_current + 1} / ${widget.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

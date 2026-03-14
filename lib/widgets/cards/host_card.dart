
// lib/widgets/cards/host_card.dart
//
// Host card used in HostsGridViewScreen.
//
// Animations in this file:
//   1. Card press — scales down to 0.95 on tap, springs back on release
//      (AnimationController + CurvedAnimation, 120 ms / 200 ms)
//   2. Follow heart — AnimatedSwitcher ScaleTransition (200 ms)
//   3. Status dot — AnimatedContainer color transition (300 ms)
//   4. Route transitions — AppTransitions.heroFade  → ProfileDetailsScreen
//                        — AppTransitions.scaleUp   → OngoingCallScreen
//   5. Hero — photo background morphs into the header of ProfileDetailsScreen
//
// Colors on photo overlay (white text, dark scrim) are intentionally
// hardcoded — they need contrast over an image regardless of theme.
// Brand colors (pink button, snackbar) use AppColors.of(context).

import 'dart:math';

import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/screens/ongoing_call_screen.dart';
import 'package:cheerchat/screens/profile_details_screen.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:cheerchat/utils/app_transitions.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HostCard extends StatefulWidget {
  const HostCard({required this.host, super.key});
  final HostModel host;

  @override
  State<HostCard> createState() => _HostCardState();
}

class _HostCardState extends State<HostCard>
    with TickerProviderStateMixin {
  bool _isFollowed = false;
  late int _age;

  // ── Press-bounce animation ─────────────────────────────────────────────────
  // Scales the card to 0.95 on finger-down, springs back on release.
  // Uses two separate controllers so press-in and release can have different
  // curves and durations (snappy down, springy up).
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

  void _toggleFollow() =>
      setState(() => _isFollowed = !_isFollowed);

  void _onCardTap() {
    Navigator.of(context, rootNavigator: true).push(
      AppTransitions.heroFade(
        ProfileDetailsScreen(host: widget.host),
      ),
    );
  }

  void _onCallTap() {
    HapticFeedback.mediumImpact();
    switch (widget.host.status) {
      case HostStatus.online:
        Navigator.of(context, rootNavigator: true).push(
          AppTransitions.scaleUp(
            OngoingCallScreen(
              host: widget.host,
              initialCoins: 1000,
              testMode: true,
              isAlreadyFollowing: false,
            ),
          ),
        );
        break;
      case HostStatus.busy:
        _autoQueue();
        break;
      case HostStatus.offline:
        break;
    }
  }

  void _autoQueue() {
    // TODO: POST /api/call-queue { host_id: widget.host.userId }
    final c = AppColors.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
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
  // AnimatedSwitcher + ScaleTransition gives the heart a satisfying pop.

  Widget _followButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _toggleFollow();
        },
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: FaIcon(
              _isFollowed
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              key: ValueKey(_isFollowed),
              color: _isFollowed ? Colors.red : Colors.white,
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
          // Responsive font: scales 13–18 based on card width so it never
          // overflows on high-DPI or narrow screens.
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
                colors: [
                  Color(0xCC000000), // 80% black at bottom
                  Color(0x00000000), // transparent at top
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row
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
                      // Chips row — FittedBox prevents overflow on any density
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
                // Video call button
                Material(
                  color: c.pink,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: _onCallTap,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: FaIcon(
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
                // ── Photo background — Hero source ───────────────────────
                // tag matches the Hero destination in ProfileDetailsScreen:
                //   Hero(tag: 'host_photo_${host.userId}', ...)
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
                        // Fade between the two hero states during flight
                        return FadeTransition(
                          opacity: animation,
                          child: toHeroContext.widget,
                        );
                      },
                  child: _backgroundImage(),
                ),

                // ── Follow / heart button ────────────────────────────────
                Positioned(
                  top: 8,
                  right: 8,
                  child: _followButton(),
                ),

                // ── Bottom overlay with name + chips + call button ───────
                _bottomOverlay(c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

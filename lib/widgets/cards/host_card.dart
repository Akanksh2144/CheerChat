// lib/widgets/cards/host_card.dart
//
// Host card used in HostsGridViewScreen.
// Colors on the photo overlay (white text, dark scrim) are intentionally
// hardcoded — they need contrast over an image regardless of app theme.
// Brand colors (pink video button, snackbar) use AppColors.of(context).

import 'dart:math';

import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/screens/ongoing_call_screen.dart';
import 'package:cheerchat/screens/profile_details_screen.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Top-level helpers (no theme needed — always on photo bg) ─────────────────

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

class _HostCardState extends State<HostCard> {
  bool _isFollowed = false;
  late int _age;

  @override
  void initState() {
    super.initState();
    _age = widget.host.age ?? (18 + Random().nextInt(23));
  }

  void _toggleFollow() =>
      setState(() => _isFollowed = !_isFollowed);

  void _onCallTap() {
    HapticFeedback.mediumImpact();
    switch (widget.host.status) {
      case HostStatus.online:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => OngoingCallScreen(
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

  // Status dot — small circle with a colored fill
  Widget _statusDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: getStatusColor(widget.host.status),
        shape: BoxShape.circle,
        // Transparent border — visible on any bg
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }

  // Flag — falls back to globe icon on error
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

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: c.pink.withOpacity(0.55),
                width: 1.5,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) =>
                    ProfileDetailsScreen(host: widget.host),
              ),
            );
          },
          onDoubleTap: _toggleFollow,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo background
              _backgroundImage(),

              // Follow / heart button
              Positioned(
                top: 8,
                right: 8,
                child: Material(
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
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                        child: FaIcon(
                          _isFollowed
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          key: ValueKey(_isFollowed),
                          color: _isFollowed
                              ? Colors.red
                              : Colors.white,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom overlay — always dark scrim over photo
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive font: scale between 13–18 based on
                    // available card width so it never overflows on
                    // high-DPI or narrow screens.
                    final cardWidth = constraints.maxWidth;
                    final nameFontSize = (cardWidth * 0.145)
                        .clamp(13.0, 18.0);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      color: Colors.black.withOpacity(0.45),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Name row — always ellipsis-safe
                                Row(
                                  children: [
                                    _statusDot(),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.host.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow
                                            .ellipsis,
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: nameFontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Chips row — FittedBox scales down
                                // only when natural size exceeds
                                // available width (any screen density)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment:
                                      Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
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
                          // Video call button — always pink (brand color)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

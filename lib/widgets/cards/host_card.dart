import 'dart:math';

import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:judotalk/data/country_data.dart';
import 'package:judotalk/data/hosts_data.dart';
import 'package:judotalk/screens_notcompleted/profile_details_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

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

class HostCard extends StatefulWidget {
  const HostCard({required this.host, super.key});

  final HostData host;

  @override
  State<HostCard> createState() => _HostCardState();
}

class _HostCardState extends State<HostCard> {
  bool isFollowed = false;
  HostStatus status = HostStatus.online; // default
  int age = 18; // default

  @override
  void initState() {
    super.initState();
    final random = Random();
    status = HostStatus
        .values[random.nextInt(HostStatus.values.length)];
    age = 18 + random.nextInt(23); // 18–40
  }

  void _toggleFavorite() {
    setState(() {
      isFollowed = !isFollowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // splashFactory: NoSplash.splashFactory,
        // highlightColor: Colors.transparent,
        onTap: () async {
          // let pop animation + pointer system settle
          await Future.delayed(const Duration(milliseconds: 60));
          if (!context.mounted) return;

          pushScreenWithoutNavBar(
            context,
            ProfileDetailsScreen(host: widget.host),
          );
        },

        onDoubleTap: _toggleFavorite,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.host.images!.isEmpty
                ? Image.asset(
                    'assets/default_profile/default_profile_photo.jpg',
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    widget.host.images![0],
                    fit: BoxFit.cover,
                  ),

            /// Heart icon
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _toggleFavorite();
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: FaIcon(
                        isFollowed
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        key: ValueKey(isFollowed),
                        color: isFollowed
                            ? Colors.red
                            : Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Bottom overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                color: Colors.black.withValues(alpha: 0.45),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              statusCircle(status),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.host.name,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                // decoration: BoxDecoration(
                                //   shape: BoxShape.circle,
                                // ),
                                // clipBehavior: Clip.hardEdge,
                                height: 16,
                                width: 22,
                                child: Flag.fromCode(
                                  widget.host.country.flagCode,
                                  fit: BoxFit.cover,
                                ),
                                // child: Text(
                                //   EmojiConverter.fromAlpha2CountryCode(
                                //     widget
                                //         .host
                                //         .country
                                //         .countryCode,
                                //   ),
                                //   style: TextStyle(fontSize: 20),
                                // ),
                              ),
                              const SizedBox(width: 10),
                              _ageChip(age),
                              const SizedBox(width: 10),
                              _levelChip(widget.host.level),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Video button
                    Material(
                      color: Colors.pink,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {},
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // import 'dart:math';

// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:some_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:cheerchat/data/country_data.dart';
// // import 'package:cheerchat/data/hosts_data.dart';
// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/screens_notcompleted/profile_details_screen.dart';
// // import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

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

// // class HostCard extends StatefulWidget {
// //   const HostCard({required this.host, super.key});

// //   final HostModel host;

// //   @override
// //   State<HostCard> createState() => _HostCardState();
// // }

// // class _HostCardState extends State<HostCard> {
// //   bool isFollowed = false;
// //   HostStatus status = HostStatus.online; // default
// //   int age = 18; // default

// //   @override
// //   void initState() {
// //     super.initState();
// //     final random = Random();
// //     status = HostStatus
// //         .values[random.nextInt(HostStatus.values.length)];
// //     age = 18 + random.nextInt(23); // 18–40
// //   }

// //   void _toggleFavorite() {
// //     setState(() {
// //       isFollowed = !isFollowed;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return ClipRRect(
// //       borderRadius: BorderRadius.circular(12),
// //       child: GestureDetector(
// //         behavior: HitTestBehavior.opaque,
// //         // splashFactory: NoSplash.splashFactory,
// //         // highlightColor: Colors.transparent,
// //         onTap: () async {
// //           // let pop animation + pointer system settle
// //           await Future.delayed(const Duration(milliseconds: 60));
// //           if (!context.mounted) return;

// //           // pushScreenWithoutNavBar(
// //           //   context,
// //           //   ProfileDetailsScreen(host: widget.host),
// //           // );
// //         },

// //         onDoubleTap: _toggleFavorite,
// //         child: Stack(
// //           fit: StackFit.expand,
// //           children: [
// //             widget.host.profilePhotoUrl!.isEmpty
// //                 ? Image.asset(
// //                     'assets/default_profile/default_profile_photo.jpg',
// //                     fit: BoxFit.cover,
// //                   )
// //                 : Image.network(
// //                     widget.host.profilePhotoUrl![0],
// //                     fit: BoxFit.cover,
// //                   ),

// //             /// Heart icon
// //             Positioned(
// //               top: 8,
// //               right: 8,
// //               child: Material(
// //                 color: Colors.transparent,
// //                 child: InkWell(
// //                   onTap: () {
// //                     HapticFeedback.lightImpact();
// //                     _toggleFavorite();
// //                   },
// //                   borderRadius: BorderRadius.circular(100),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(4),
// //                     child: AnimatedSwitcher(
// //                       duration: const Duration(
// //                         milliseconds: 200,
// //                       ),
// //                       transitionBuilder: (child, animation) {
// //                         return ScaleTransition(
// //                           scale: animation,
// //                           child: child,
// //                         );
// //                       },
// //                       child: FaIcon(
// //                         isFollowed
// //                             ? FontAwesomeIcons.solidHeart
// //                             : FontAwesomeIcons.heart,
// //                         key: ValueKey(isFollowed),
// //                         color: isFollowed
// //                             ? Colors.red
// //                             : Colors.white,
// //                         size: 23,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),

// //             /// Bottom overlay
// //             Positioned(
// //               left: 0,
// //               right: 0,
// //               bottom: 0,
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   vertical: 10,
// //                   horizontal: 12,
// //                 ),
// //                 color: Colors.black.withValues(alpha: 0.45),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment:
// //                             CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               // statusCircle(status),
// //                               const SizedBox(width: 4),
// //                               Expanded(
// //                                 child: Text(
// //                                   widget.host.displayName,
// //                                   maxLines: 1,
// //                                   overflow:
// //                                       TextOverflow.ellipsis,
// //                                   softWrap: false,
// //                                   style: GoogleFonts.lato(
// //                                     color: Colors.white,
// //                                     fontWeight: FontWeight.bold,
// //                                     fontSize: 18,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 4),
// //                           Row(
// //                             mainAxisAlignment:
// //                                 MainAxisAlignment.start,
// //                             crossAxisAlignment:
// //                                 CrossAxisAlignment.center,
// //                             children: [
// //                               SizedBox(
// //                                 // decoration: BoxDecoration(
// //                                 //   shape: BoxShape.circle,
// //                                 // ),
// //                                 // clipBehavior: Clip.hardEdge,
// //                                 height: 16,
// //                                 width: 22,
// //                                 child: Flag.fromCode(
// //                                   widget.host.flagCode,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                                 // child: Text(
// //                                 //   EmojiConverter.fromAlpha2CountryCode(
// //                                 //     widget
// //                                 //         .host
// //                                 //         .country
// //                                 //         .countryCode,
// //                                 //   ),
// //                                 //   style: TextStyle(fontSize: 20),
// //                                 // ),
// //                               ),
// //                               const SizedBox(width: 10),
// //                               _ageChip(age),
// //                               const SizedBox(width: 10),
// //                               _levelChip(
// //                                 'Lv${widget.host.level}',
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     /// Video button
// //                     Material(
// //                       color: Colors.pink,
// //                       shape: const CircleBorder(),
// //                       clipBehavior: Clip.hardEdge,
// //                       child: InkWell(
// //                         onTap: () {},
// //                         child: const Padding(
// //                           padding: EdgeInsets.all(10),
// //                           child: FaIcon(
// //                             FontAwesomeIcons.video,
// //                             color: Colors.white,
// //                             size: 25,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // lib/widgets/cards/host_card.dart

// import 'dart:math';

// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cheerchat/models/host_model.dart';
// // import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// // Status dot
// Widget statusCircle(HostStatus status) {
//   return Container(
//     width: 10,
//     height: 10,
//     decoration: BoxDecoration(
//       color: getStatusColor(status),
//       shape: BoxShape.circle,
//       border: Border.all(color: Colors.black26, width: 1),
//     ),
//   );
// }

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

// class HostCard extends StatefulWidget {
//   const HostCard({required this.host, super.key});

//   final HostModel host;

//   @override
//   State<HostCard> createState() => _HostCardState();
// }

// class _HostCardState extends State<HostCard> {
//   bool isFollowed = false;
//   int age = 18;

//   @override
//   void initState() {
//     super.initState();
//     age = widget.host.age ?? (18 + Random().nextInt(23));
//   }

//   void _toggleFavorite() {
//     setState(() => isFollowed = !isFollowed);
//   }

//   void _onCallTap() {
//     HapticFeedback.mediumImpact();
//     switch (widget.host.status) {
//       case HostStatus.online:
//         // TODO: pushScreenWithoutNavBar(context, CallInitScreen(host: widget.host));
//         break;
//       case HostStatus.busy:
//         _showBusyDialog();
//         break;
//       case HostStatus.offline:
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
//         title: Text('${widget.host.displayName} is busy'),
//         content: const Text(
//           'She is currently on a call.\nJoin the queue and we\'ll notify you when she\'s free.',
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
//               // TODO: POST /api/call-queue { host_id: widget.host.userId }
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     "You'll be notified when ${widget.host.displayName} is free!",
//                   ),
//                   backgroundColor: Colors.pink,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               );
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

//   // Safe flag widget — falls back to a plain globe icon if the flag
//   // package throws for any reason (e.g. unknown FlagsCode).
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

//   // Safe background image — never uses ! operator
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

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () async {
//           await Future.delayed(const Duration(milliseconds: 60));
//           if (!context.mounted) return;
//           // TODO: pushScreenWithoutNavBar(context, HostProfileScreen(host: widget.host));
//         },
//         onDoubleTap: _toggleFavorite,
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             _backgroundImage(),

//             /// Heart icon
//             Positioned(
//               top: 8,
//               right: 8,
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () {
//                     HapticFeedback.lightImpact();
//                     _toggleFavorite();
//                   },
//                   borderRadius: BorderRadius.circular(100),
//                   child: Padding(
//                     padding: const EdgeInsets.all(4),
//                     child: AnimatedSwitcher(
//                       duration: const Duration(
//                         milliseconds: 200,
//                       ),
//                       transitionBuilder: (child, animation) =>
//                           ScaleTransition(
//                             scale: animation,
//                             child: child,
//                           ),
//                       child: FaIcon(
//                         isFollowed
//                             ? FontAwesomeIcons.solidHeart
//                             : FontAwesomeIcons.heart,
//                         key: ValueKey(isFollowed),
//                         color: isFollowed
//                             ? Colors.red
//                             : Colors.white,
//                         size: 23,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             /// Bottom overlay
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 12,
//                 ),
//                 color: Colors.black.withValues(alpha: 0.45),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               statusCircle(widget.host.status),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   widget.host.displayName,
//                                   maxLines: 1,
//                                   overflow:
//                                       TextOverflow.ellipsis,
//                                   softWrap: false,
//                                   style: GoogleFonts.lato(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment:
//                                 MainAxisAlignment.start,
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.center,
//                             children: [
//                               _flagWidget(),
//                               const SizedBox(width: 10),
//                               _ageChip(age),
//                               const SizedBox(width: 10),
//                               _levelChip(
//                                 'Lv ${widget.host.level}',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     /// Video button
//                     Material(
//                       color:
//                           widget.host.status == HostStatus.busy
//                           ? Colors.orange
//                           : Colors.pink,
//                       shape: const CircleBorder(),
//                       clipBehavior: Clip.hardEdge,
//                       child: InkWell(
//                         onTap: _onCallTap,
//                         child: Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: FaIcon(
//                             widget.host.status == HostStatus.busy
//                                 ? FontAwesomeIcons.clock
//                                 : FontAwesomeIcons.video,
//                             color: Colors.white,
//                             size: 25,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';

import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/screens/profile_details_screen.dart';
import 'package:cheerchat/screens_notcompleted/ongoing_call_screen.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Status dot
Widget statusCircle(HostStatus status) {
  return Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: getStatusColor(status),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black26, width: 1),
    ),
  );
}

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

  final HostModel host;

  @override
  State<HostCard> createState() => _HostCardState();
}

class _HostCardState extends State<HostCard> {
  bool isFollowed = false;
  int age = 18;

  @override
  void initState() {
    super.initState();
    age = widget.host.age ?? (18 + Random().nextInt(23));
  }

  void _toggleFavorite() {
    setState(() => isFollowed = !isFollowed);
  }

  void _onCallTap() {
    HapticFeedback.mediumImpact();
    switch (widget.host.status) {
      case HostStatus.online:
        pushScreenWithoutNavBar(context, OngoingCallScreen(
          
              host: widget.host, // any host from hosts_data.dart
              initialCoins: 1000,
              testMode: true, // ← this is all you need
              isAlreadyFollowing: false,
            ),);
        
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
    // Server will send an FCM push when host transitions to online.
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
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(
          255,
          157,
          154,
          152,
        ),
        behavior: SnackBarBehavior.floating,

        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Safe flag widget — falls back to a plain globe icon if the flag
  // package throws for any reason (e.g. unknown FlagsCode).
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

  // Safe background image — never uses ! operator
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 60));
          if (!context.mounted) return;
          // TODO: pushScreenWithoutNavBar(context, HostProfileScreen(host: widget.host));
          pushScreenWithoutNavBar(
            context,
            ProfileDetailsScreen(host: widget.host),
          );
        },
        onDoubleTap: _toggleFavorite,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _backgroundImage(),

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
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
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
                              statusCircle(widget.host.status),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.host.displayName,
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
                              _flagWidget(),
                              const SizedBox(width: 10),
                              _ageChip(age),
                              const SizedBox(width: 10),
                              _levelChip(
                                'Lv ${widget.host.level}',
                              ),
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
                        onTap: _onCallTap,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
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

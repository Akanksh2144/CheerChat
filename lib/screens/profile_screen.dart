// // // // // lib/screens/profile_screen.dart
// // // // //
// // // // // User's own profile — settings, wallet, host earnings, preferences.
// // // // // Fully adaptive to all screen sizes.

// // // // import 'package:cached_network_image/cached_network_image.dart';
// // // // import 'package:cheerchat/models/app_user.dart';
// // // // import 'package:cheerchat/providers/auth_provider.dart';
// // // // import 'package:cheerchat/providers/theme_provider.dart';
// // // // import 'package:cheerchat/providers/user_provider.dart';
// // // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // // import 'package:cheerchat/services/api_service.dart';
// // // // import 'package:cheerchat/services/auth_service.dart';
// // // // import 'package:cheerchat/services/social_service.dart';
// // // // import 'package:cheerchat/theme/app_colors.dart';
// // // // import 'package:flag/flag_widget.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:google_fonts/google_fonts.dart';
// // // // import 'package:image_picker/image_picker.dart';

// // // // class ProfileScreen extends ConsumerStatefulWidget {
// // // //   const ProfileScreen({super.key});

// // // //   @override
// // // //   ConsumerState<ProfileScreen> createState() =>
// // // //       _ProfileScreenState();
// // // // }

// // // // class _ProfileScreenState extends ConsumerState<ProfileScreen> {
// // // //   bool _isUploadingPhoto = false;
// // // //   int _followerCount = 0;
// // // //   int _followingCount = 0;
// // // //   List<Map<String, dynamic>> _blockedUsers = [];

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadSocialStats();
// // // //   }

// // // //   Future<void> _loadSocialStats() async {
// // // //     try {
// // // //       final social = ref.read(socialServiceProvider);
// // // //       final followers = await social.getFollowers();
// // // //       final following = await social.getFollowing();
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           _followerCount = followers.length;
// // // //           _followingCount = following.length;
// // // //         });
// // // //       }
// // // //     } catch (_) {}
// // // //   }

// // // //   // ── Helpers ───────────────────────────────────────────────────────────────

// // // //   void _snack(String msg, {bool isError = false}) {
// // // //     if (!mounted) return;
// // // //     final c = AppColors.of(context);
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text(msg),
// // // //         backgroundColor: isError ? Colors.redAccent : c.pink,
// // // //         behavior: SnackBarBehavior.floating,
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(10),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _todo(String feature) => _snack('$feature coming soon!');

// // // //   // ── Photo picker ──────────────────────────────────────────────────────────

// // // //   Future<void> _pickPhoto() async {
// // // //     final picker = ImagePicker();
// // // //     final XFile? picked = await picker.pickImage(
// // // //       source: ImageSource.gallery,
// // // //       imageQuality: 85,
// // // //       maxWidth: 800,
// // // //     );
// // // //     if (picked == null || !mounted) return;
// // // //     setState(() => _isUploadingPhoto = true);
// // // //     try {
// // // //       // TODO: Upload to Firebase Storage → PUT /api/me { profile_photo_url }
// // // //       _snack('Photo upload coming soon!');
// // // //     } finally {
// // // //       if (mounted) setState(() => _isUploadingPhoto = false);
// // // //     }
// // // //   }

// // // //   // ── Edit name ─────────────────────────────────────────────────────────────

// // // //   void _editName(String current) {
// // // //     final c = AppColors.of(context);
// // // //     final ctrl = TextEditingController(text: current);
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         backgroundColor: c.card,
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //         ),
// // // //         title: Text(
// // // //           'Edit Name',
// // // //           style: GoogleFonts.poppins(
// // // //             color: c.textPrimary,
// // // //             fontWeight: FontWeight.w600,
// // // //           ),
// // // //         ),
// // // //         content: TextField(
// // // //           controller: ctrl,
// // // //           autofocus: true,
// // // //           maxLength: 24,
// // // //           style: TextStyle(color: c.textPrimary),
// // // //           cursorColor: c.pink,
// // // //           decoration: InputDecoration(
// // // //             hintText: 'Display name',
// // // //             hintStyle: TextStyle(color: c.textSecondary),
// // // //             counterStyle: TextStyle(color: c.textSecondary),
// // // //             enabledBorder: OutlineInputBorder(
// // // //               borderRadius: BorderRadius.circular(10),
// // // //               borderSide: BorderSide(color: c.border),
// // // //             ),
// // // //             focusedBorder: OutlineInputBorder(
// // // //               borderRadius: BorderRadius.circular(10),
// // // //               borderSide: BorderSide(color: c.pink),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(ctx),
// // // //             child: Text(
// // // //               'Cancel',
// // // //               style: TextStyle(color: c.textSecondary),
// // // //             ),
// // // //           ),
// // // //           TextButton(
// // // //             onPressed: () async {
// // // //               final newName = ctrl.text.trim();
// // // //               if (newName.isEmpty) return;
// // // //               Navigator.pop(ctx);
// // // //               final api = ref.read(apiServiceProvider);
// // // //               final res = await api.put(
// // // //                 '/api/me',
// // // //                 body: {'display_name': newName},
// // // //               );
// // // //               if (res.ok) {
// // // //                 ref.read(currentUserProvider.notifier).refresh();
// // // //                 _snack('Name updated!');
// // // //               } else {
// // // //                 _snack(
// // // //                   res.error ?? 'Could not update name',
// // // //                   isError: true,
// // // //                 );
// // // //               }
// // // //             },
// // // //             child: Text(
// // // //               'Save',
// // // //               style: TextStyle(
// // // //                 color: c.pink,
// // // //                 fontWeight: FontWeight.w700,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Logout ────────────────────────────────────────────────────────────────

// // // //   void _confirmLogout() {
// // // //     final c = AppColors.of(context);
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         backgroundColor: c.card,
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //         ),
// // // //         title: Text(
// // // //           'Log Out?',
// // // //           style: GoogleFonts.poppins(
// // // //             color: c.textPrimary,
// // // //             fontWeight: FontWeight.w600,
// // // //           ),
// // // //         ),
// // // //         content: Text(
// // // //           'You will need to sign in again.',
// // // //           style: TextStyle(color: c.textSecondary),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(ctx),
// // // //             child: Text(
// // // //               'Cancel',
// // // //               style: TextStyle(color: c.textSecondary),
// // // //             ),
// // // //           ),
// // // //           TextButton(
// // // //             onPressed: () async {
// // // //               final logoutNotifier = ref.read(
// // // //                 isLoggingOutProvider.notifier,
// // // //               );
// // // //               final userNotifier = ref.read(
// // // //                 currentUserProvider.notifier,
// // // //               );
// // // //               final authSvc = ref.read(authServiceProvider);
// // // //               Navigator.pop(ctx);
// // // //               logoutNotifier.start();
// // // //               userNotifier.clear();
// // // //               await authSvc.signOut();
// // // //             },
// // // //             child: const Text(
// // // //               'Log Out',
// // // //               style: TextStyle(
// // // //                 color: Colors.redAccent,
// // // //                 fontWeight: FontWeight.w700,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Delete account ────────────────────────────────────────────────────────

// // // //   void _confirmDeleteAccount() {
// // // //     final c = AppColors.of(context);
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         backgroundColor: c.card,
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //         ),
// // // //         title: Text(
// // // //           'Delete Account?',
// // // //           style: GoogleFonts.poppins(
// // // //             color: Colors.redAccent,
// // // //             fontWeight: FontWeight.w600,
// // // //           ),
// // // //         ),
// // // //         content: Text(
// // // //           'This is permanent. All your data, coins, and history will be erased and cannot be recovered.',
// // // //           style: TextStyle(color: c.textSecondary),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(ctx),
// // // //             child: Text(
// // // //               'Cancel',
// // // //               style: TextStyle(color: c.textSecondary),
// // // //             ),
// // // //           ),
// // // //           TextButton(
// // // //             onPressed: () {
// // // //               Navigator.pop(ctx);
// // // //               _snack('Delete account coming soon.');
// // // //             },
// // // //             child: const Text(
// // // //               'Delete',
// // // //               style: TextStyle(
// // // //                 color: Colors.redAccent,
// // // //                 fontWeight: FontWeight.w700,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Clear cache dialog ────────────────────────────────────────────────────

// // // //   void _showClearCacheDialog() {
// // // //     final c = AppColors.of(context);
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         backgroundColor: c.card,
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //         ),
// // // //         title: Text(
// // // //           'Clear Cache?',
// // // //           style: GoogleFonts.poppins(
// // // //             color: c.textPrimary,
// // // //             fontWeight: FontWeight.w600,
// // // //           ),
// // // //         ),
// // // //         content: Text(
// // // //           'Cached images and data will be removed. The app may load slower temporarily.',
// // // //           style: TextStyle(color: c.textSecondary),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(ctx),
// // // //             child: Text(
// // // //               'Cancel',
// // // //               style: TextStyle(color: c.textSecondary),
// // // //             ),
// // // //           ),
// // // //           TextButton(
// // // //             onPressed: () {
// // // //               Navigator.pop(ctx);
// // // //               CachedNetworkImage.evictFromCache('');
// // // //               _snack('Cache cleared');
// // // //             },
// // // //             child: Text(
// // // //               'Clear',
// // // //               style: TextStyle(
// // // //                 color: c.pink,
// // // //                 fontWeight: FontWeight.w700,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Help sheet ────────────────────────────────────────────────────────────

// // // //   void _showHelpSheet({required bool isHost}) {
// // // //     final c = AppColors.of(context);
// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: c.surface,
// // // //       shape: const RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.vertical(
// // // //           top: Radius.circular(20),
// // // //         ),
// // // //       ),
// // // //       isScrollControlled: true,
// // // //       builder: (ctx) => ConstrainedBox(
// // // //         constraints: BoxConstraints(
// // // //           maxHeight: MediaQuery.of(ctx).size.height * 0.7,
// // // //         ),
// // // //         child: Padding(
// // // //           padding: EdgeInsets.fromLTRB(
// // // //             20,
// // // //             16,
// // // //             20,
// // // //             MediaQuery.of(ctx).padding.bottom + 20,
// // // //           ),
// // // //           child: SingleChildScrollView(
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Center(
// // // //                   child: Container(
// // // //                     width: 36,
// // // //                     height: 4,
// // // //                     decoration: BoxDecoration(
// // // //                       color: c.border,
// // // //                       borderRadius: BorderRadius.circular(2),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 16),
// // // //                 Text(
// // // //                   'Help & Support',
// // // //                   style: GoogleFonts.poppins(
// // // //                     color: c.textPrimary,
// // // //                     fontSize: 17,
// // // //                     fontWeight: FontWeight.w700,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Text(
// // // //                   'How can we help you?',
// // // //                   style: TextStyle(
// // // //                     color: c.textSecondary,
// // // //                     fontSize: 13,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 20),
// // // //                 _sheetTile(
// // // //                   icon: Icons.chat_bubble_outline,
// // // //                   label: 'Contact Support',
// // // //                   onTap: () {
// // // //                     Navigator.pop(ctx);
// // // //                     _todo('Customer support');
// // // //                   },
// // // //                 ),
// // // //                 _sheetTile(
// // // //                   icon: Icons.quiz_outlined,
// // // //                   label: 'FAQ',
// // // //                   onTap: () {
// // // //                     Navigator.pop(ctx);
// // // //                     _todo('FAQ');
// // // //                   },
// // // //                 ),
// // // //                 if (isHost) ...[
// // // //                   Padding(
// // // //                     padding: const EdgeInsets.symmetric(
// // // //                       vertical: 10,
// // // //                     ),
// // // //                     child: Divider(color: c.divider),
// // // //                   ),
// // // //                   Text(
// // // //                     'For Hosts',
// // // //                     style: GoogleFonts.poppins(
// // // //                       color: c.pink,
// // // //                       fontSize: 12,
// // // //                       fontWeight: FontWeight.w600,
// // // //                       letterSpacing: 1.1,
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 8),
// // // //                   _sheetTile(
// // // //                     icon: Icons.lightbulb_outline,
// // // //                     label: 'Request a Feature',
// // // //                     onTap: () {
// // // //                       Navigator.pop(ctx);
// // // //                       _todo('Feature request');
// // // //                     },
// // // //                   ),
// // // //                   _sheetTile(
// // // //                     icon: Icons.feedback_outlined,
// // // //                     label: 'Share Feedback',
// // // //                     onTap: () {
// // // //                       Navigator.pop(ctx);
// // // //                       _todo('Feedback form');
// // // //                     },
// // // //                   ),
// // // //                   _sheetTile(
// // // //                     icon: Icons.campaign_outlined,
// // // //                     label: 'Host Community',
// // // //                     onTap: () {
// // // //                       Navigator.pop(ctx);
// // // //                       _todo('Host forum');
// // // //                     },
// // // //                   ),
// // // //                 ],
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Follow list sheet ─────────────────────────────────────────────────────

// // // //   void _showFollowList(String type) async {
// // // //     final c = AppColors.of(context);
// // // //     final social = ref.read(socialServiceProvider);
// // // //     final list = type == 'Followers'
// // // //         ? await social.getFollowers()
// // // //         : await social.getFollowing();

// // // //     if (!mounted) return;

// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: c.surface,
// // // //       isScrollControlled: true,
// // // //       shape: const RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.vertical(
// // // //           top: Radius.circular(20),
// // // //         ),
// // // //       ),
// // // //       builder: (ctx) => ConstrainedBox(
// // // //         constraints: BoxConstraints(
// // // //           maxHeight: MediaQuery.of(ctx).size.height * 0.6,
// // // //         ),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             const SizedBox(height: 12),
// // // //             Container(
// // // //               width: 36,
// // // //               height: 4,
// // // //               decoration: BoxDecoration(
// // // //                 color: c.border,
// // // //                 borderRadius: BorderRadius.circular(2),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //             Text(
// // // //               type,
// // // //               style: GoogleFonts.poppins(
// // // //                 color: c.textPrimary,
// // // //                 fontSize: 17,
// // // //                 fontWeight: FontWeight.w700,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //             if (list.isEmpty)
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(40),
// // // //                 child: Text(
// // // //                   'No $type yet',
// // // //                   style: TextStyle(color: c.textSecondary),
// // // //                 ),
// // // //               )
// // // //             else
// // // //               Flexible(
// // // //                 child: ListView.builder(
// // // //                   shrinkWrap: true,
// // // //                   itemCount: list.length,
// // // //                   padding: const EdgeInsets.symmetric(
// // // //                     horizontal: 16,
// // // //                   ),
// // // //                   itemBuilder: (_, i) {
// // // //                     final user = list[i];
// // // //                     return ListTile(
// // // //                       leading: CircleAvatar(
// // // //                         backgroundColor: c.pink.withOpacity(0.1),
// // // //                         backgroundImage:
// // // //                             user['profile_photo_url'] != null
// // // //                             ? NetworkImage(
// // // //                                 user['profile_photo_url'],
// // // //                               )
// // // //                             : null,
// // // //                         child: user['profile_photo_url'] == null
// // // //                             ? Icon(
// // // //                                 Icons.person,
// // // //                                 color: c.pink,
// // // //                                 size: 20,
// // // //                               )
// // // //                             : null,
// // // //                       ),
// // // //                       title: Text(
// // // //                         user['display_name'] ?? 'User',
// // // //                         style: TextStyle(
// // // //                           color: c.textPrimary,
// // // //                           fontWeight: FontWeight.w500,
// // // //                         ),
// // // //                       ),
// // // //                       subtitle: Text(
// // // //                         'ID: ${user['public_id'] ?? ''}',
// // // //                         style: TextStyle(
// // // //                           color: c.textSecondary,
// // // //                           fontSize: 11,
// // // //                         ),
// // // //                       ),
// // // //                     );
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //             SizedBox(
// // // //               height: MediaQuery.of(ctx).padding.bottom + 16,
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Blocked users sheet ───────────────────────────────────────────────────

// // // //   void _showBlockedUsers() async {
// // // //     final c = AppColors.of(context);
// // // //     final social = ref.read(socialServiceProvider);
// // // //     _blockedUsers = await social.getBlocked();

// // // //     if (!mounted) return;

// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: c.surface,
// // // //       isScrollControlled: true,
// // // //       shape: const RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.vertical(
// // // //           top: Radius.circular(20),
// // // //         ),
// // // //       ),
// // // //       builder: (ctx) => StatefulBuilder(
// // // //         builder: (ctx, setSheet) => ConstrainedBox(
// // // //           constraints: BoxConstraints(
// // // //             maxHeight: MediaQuery.of(ctx).size.height * 0.6,
// // // //           ),
// // // //           child: Column(
// // // //             mainAxisSize: MainAxisSize.min,
// // // //             children: [
// // // //               const SizedBox(height: 12),
// // // //               Container(
// // // //                 width: 36,
// // // //                 height: 4,
// // // //                 decoration: BoxDecoration(
// // // //                   color: c.border,
// // // //                   borderRadius: BorderRadius.circular(2),
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 16),
// // // //               Text(
// // // //                 'Blocked Users',
// // // //                 style: GoogleFonts.poppins(
// // // //                   color: c.textPrimary,
// // // //                   fontSize: 17,
// // // //                   fontWeight: FontWeight.w700,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 12),
// // // //               if (_blockedUsers.isEmpty)
// // // //                 Padding(
// // // //                   padding: const EdgeInsets.all(40),
// // // //                   child: Text(
// // // //                     'No blocked users',
// // // //                     style: TextStyle(color: c.textSecondary),
// // // //                   ),
// // // //                 )
// // // //               else
// // // //                 Flexible(
// // // //                   child: ListView.builder(
// // // //                     shrinkWrap: true,
// // // //                     itemCount: _blockedUsers.length,
// // // //                     padding: const EdgeInsets.symmetric(
// // // //                       horizontal: 16,
// // // //                     ),
// // // //                     itemBuilder: (_, i) {
// // // //                       final user = _blockedUsers[i];
// // // //                       return ListTile(
// // // //                         leading: CircleAvatar(
// // // //                           backgroundColor: c.pink.withOpacity(
// // // //                             0.1,
// // // //                           ),
// // // //                           backgroundImage:
// // // //                               user['profile_photo_url'] != null
// // // //                               ? NetworkImage(
// // // //                                   user['profile_photo_url'],
// // // //                                 )
// // // //                               : null,
// // // //                           child:
// // // //                               user['profile_photo_url'] == null
// // // //                               ? Icon(
// // // //                                   Icons.person,
// // // //                                   color: c.textSecondary,
// // // //                                   size: 20,
// // // //                                 )
// // // //                               : null,
// // // //                         ),
// // // //                         title: Text(
// // // //                           user['display_name'] ?? 'User',
// // // //                           style: TextStyle(
// // // //                             color: c.textPrimary,
// // // //                             fontWeight: FontWeight.w500,
// // // //                           ),
// // // //                         ),
// // // //                         trailing: TextButton(
// // // //                           onPressed: () async {
// // // //                             final ok = await social.unblock(
// // // //                               user['blocked_id'] ?? '',
// // // //                             );
// // // //                             if (ok) {
// // // //                               setSheet(
// // // //                                 () => _blockedUsers.removeAt(i),
// // // //                               );
// // // //                               _snack('Unblocked');
// // // //                             }
// // // //                           },
// // // //                           child: Text(
// // // //                             'Unblock',
// // // //                             style: TextStyle(
// // // //                               color: c.pink,
// // // //                               fontSize: 12,
// // // //                               fontWeight: FontWeight.w600,
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                       );
// // // //                     },
// // // //                   ),
// // // //                 ),
// // // //               SizedBox(
// // // //                 height: MediaQuery.of(ctx).padding.bottom + 16,
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Transaction history sheet ─────────────────────────────────────────────

// // // //   void _showTransactionHistory() async {
// // // //     final c = AppColors.of(context);
// // // //     final api = ref.read(apiServiceProvider);
// // // //     final res = await api.get(
// // // //       '/api/wallet/ledger',
// // // //       query: {'limit': '50'},
// // // //     );
// // // //     final List<Map<String, dynamic>> ledger = res.ok
// // // //         ? (res.data['ledger'] as List)
// // // //               .cast<Map<String, dynamic>>()
// // // //         : [];

// // // //     if (!mounted) return;

// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: c.surface,
// // // //       isScrollControlled: true,
// // // //       shape: const RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.vertical(
// // // //           top: Radius.circular(20),
// // // //         ),
// // // //       ),
// // // //       builder: (ctx) => ConstrainedBox(
// // // //         constraints: BoxConstraints(
// // // //           maxHeight: MediaQuery.of(ctx).size.height * 0.75,
// // // //         ),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             const SizedBox(height: 12),
// // // //             Container(
// // // //               width: 36,
// // // //               height: 4,
// // // //               decoration: BoxDecoration(
// // // //                 color: c.border,
// // // //                 borderRadius: BorderRadius.circular(2),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //             Text(
// // // //               'Transaction History',
// // // //               style: GoogleFonts.poppins(
// // // //                 color: c.textPrimary,
// // // //                 fontSize: 17,
// // // //                 fontWeight: FontWeight.w700,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //             if (ledger.isEmpty)
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(40),
// // // //                 child: Text(
// // // //                   'No transactions yet',
// // // //                   style: TextStyle(color: c.textSecondary),
// // // //                 ),
// // // //               )
// // // //             else
// // // //               Flexible(
// // // //                 child: ListView.builder(
// // // //                   shrinkWrap: true,
// // // //                   itemCount: ledger.length,
// // // //                   padding: const EdgeInsets.symmetric(
// // // //                     horizontal: 16,
// // // //                   ),
// // // //                   itemBuilder: (_, i) {
// // // //                     final txn = ledger[i];
// // // //                     final amount =
// // // //                         (txn['amount'] as num?)?.toInt() ?? 0;
// // // //                     final type = txn['type'] as String? ?? '';
// // // //                     final isPositive = amount > 0;
// // // //                     final date = DateTime.tryParse(
// // // //                       txn['created_at'] ?? '',
// // // //                     );
// // // //                     final dateStr = date != null
// // // //                         ? '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
// // // //                         : '';

// // // //                     IconData icon;
// // // //                     Color iconColor;
// // // //                     switch (type) {
// // // //                       case 'recharge':
// // // //                         icon = Icons.add_circle_outline;
// // // //                         iconColor = Colors.green;
// // // //                         break;
// // // //                       case 'call_spent':
// // // //                         icon = Icons.videocam_outlined;
// // // //                         iconColor = Colors.orange;
// // // //                         break;
// // // //                       case 'gift_sent':
// // // //                         icon = Icons.card_giftcard;
// // // //                         iconColor = Colors.pink;
// // // //                         break;
// // // //                       case 'gift_received':
// // // //                         icon = Icons.card_giftcard;
// // // //                         iconColor = Colors.green;
// // // //                         break;
// // // //                       case 'bonus':
// // // //                         icon = Icons.stars_outlined;
// // // //                         iconColor = Colors.amber;
// // // //                         break;
// // // //                       case 'unlock':
// // // //                         icon = Icons.lock_open_outlined;
// // // //                         iconColor = Colors.blue;
// // // //                         break;
// // // //                       default:
// // // //                         icon = Icons.swap_horiz;
// // // //                         iconColor = c.textSecondary;
// // // //                     }

// // // //                     return ListTile(
// // // //                       contentPadding: const EdgeInsets.symmetric(
// // // //                         horizontal: 4,
// // // //                         vertical: 2,
// // // //                       ),
// // // //                       leading: Container(
// // // //                         width: 38,
// // // //                         height: 38,
// // // //                         decoration: BoxDecoration(
// // // //                           color: iconColor.withOpacity(0.1),
// // // //                           borderRadius: BorderRadius.circular(
// // // //                             10,
// // // //                           ),
// // // //                         ),
// // // //                         child: Icon(
// // // //                           icon,
// // // //                           color: iconColor,
// // // //                           size: 18,
// // // //                         ),
// // // //                       ),
// // // //                       title: Text(
// // // //                         type.replaceAll('_', ' ').toUpperCase(),
// // // //                         style: TextStyle(
// // // //                           color: c.textPrimary,
// // // //                           fontWeight: FontWeight.w500,
// // // //                           fontSize: 13,
// // // //                         ),
// // // //                       ),
// // // //                       subtitle: Text(
// // // //                         dateStr,
// // // //                         style: TextStyle(
// // // //                           color: c.textSecondary,
// // // //                           fontSize: 10,
// // // //                         ),
// // // //                       ),
// // // //                       trailing: Text(
// // // //                         '${isPositive ? '+' : ''}$amount',
// // // //                         style: TextStyle(
// // // //                           color: isPositive
// // // //                               ? Colors.green
// // // //                               : Colors.redAccent,
// // // //                           fontWeight: FontWeight.bold,
// // // //                           fontSize: 15,
// // // //                         ),
// // // //                       ),
// // // //                     );
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //             SizedBox(
// // // //               height: MediaQuery.of(ctx).padding.bottom + 16,
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Top Up sheet ──────────────────────────────────────────────────────────

// // // //   void _showTopUpSheet() async {
// // // //     final c = AppColors.of(context);
// // // //     final api = ref.read(apiServiceProvider);
// // // //     final res = await api.get('/api/wallet/packages');
// // // //     final List<Map<String, dynamic>> packages = res.ok
// // // //         ? (res.data['packages'] as List)
// // // //               .cast<Map<String, dynamic>>()
// // // //         : [];

// // // //     if (!mounted) return;

// // // //     final walletState = ref.read(walletBalanceProvider);
// // // //     final currentCoins =
// // // //         walletState.asData?.value?.coinBalance ?? 0;

// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: Colors.transparent,
// // // //       isScrollControlled: true,
// // // //       builder: (ctx) => Container(
// // // //         constraints: BoxConstraints(
// // // //           maxHeight: MediaQuery.of(ctx).size.height * 0.65,
// // // //         ),
// // // //         decoration: BoxDecoration(
// // // //           color: c.surface,
// // // //           borderRadius: const BorderRadius.vertical(
// // // //             top: Radius.circular(24),
// // // //           ),
// // // //         ),
// // // //         padding: EdgeInsets.fromLTRB(
// // // //           20,
// // // //           12,
// // // //           20,
// // // //           MediaQuery.of(ctx).padding.bottom + 20,
// // // //         ),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Container(
// // // //               width: 36,
// // // //               height: 4,
// // // //               decoration: BoxDecoration(
// // // //                 color: c.border,
// // // //                 borderRadius: BorderRadius.circular(2),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //             // Balance display
// // // //             Container(
// // // //               width: double.infinity,
// // // //               padding: const EdgeInsets.symmetric(vertical: 16),
// // // //               decoration: BoxDecoration(
// // // //                 gradient: LinearGradient(
// // // //                   colors: [
// // // //                     c.pink.withOpacity(0.08),
// // // //                     c.gold.withOpacity(0.05),
// // // //                   ],
// // // //                 ),
// // // //                 borderRadius: BorderRadius.circular(14),
// // // //                 border: Border.all(
// // // //                   color: c.pink.withOpacity(0.15),
// // // //                 ),
// // // //               ),
// // // //               child: Column(
// // // //                 children: [
// // // //                   Text(
// // // //                     'Current Balance',
// // // //                     style: TextStyle(
// // // //                       color: c.textSecondary,
// // // //                       fontSize: 12,
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 4),
// // // //                   Text(
// // // //                     '$currentCoins coins',
// // // //                     style: GoogleFonts.poppins(
// // // //                       color: c.gold,
// // // //                       fontSize: 26,
// // // //                       fontWeight: FontWeight.w700,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 16),
// // // //             Align(
// // // //               alignment: Alignment.centerLeft,
// // // //               child: Text(
// // // //                 'Choose a Package',
// // // //                 style: GoogleFonts.poppins(
// // // //                   color: c.textPrimary,
// // // //                   fontSize: 15,
// // // //                   fontWeight: FontWeight.w600,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 10),
// // // //             if (packages.isEmpty)
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(20),
// // // //                 child: Text(
// // // //                   'No packages available',
// // // //                   style: TextStyle(color: c.textSecondary),
// // // //                 ),
// // // //               )
// // // //             else
// // // //               Flexible(
// // // //                 child: ListView.builder(
// // // //                   shrinkWrap: true,
// // // //                   itemCount: packages.length,
// // // //                   itemBuilder: (_, i) {
// // // //                     final pkg = packages[i];
// // // //                     final coins =
// // // //                         (pkg['coins_amount'] as num?)?.toInt() ??
// // // //                         0;
// // // //                     final price =
// // // //                         (pkg['price'] as num?)?.toDouble() ?? 0;
// // // //                     final currency =
// // // //                         pkg['currency'] as String? ?? 'INR';
// // // //                     final name =
// // // //                         pkg['name'] as String? ?? '$coins Coins';
// // // //                     final isBest =
// // // //                         i ==
// // // //                         (packages.length ~/
// // // //                             2); // middle package is "best value"

// // // //                     return Padding(
// // // //                       padding: const EdgeInsets.only(bottom: 8),
// // // //                       child: InkWell(
// // // //                         onTap: () {
// // // //                           Navigator.pop(ctx);
// // // //                           _snack(
// // // //                             'Payment integration coming soon! Package: $name',
// // // //                           );
// // // //                         },
// // // //                         borderRadius: BorderRadius.circular(14),
// // // //                         child: Container(
// // // //                           padding: const EdgeInsets.symmetric(
// // // //                             horizontal: 16,
// // // //                             vertical: 14,
// // // //                           ),
// // // //                           decoration: BoxDecoration(
// // // //                             color: isBest
// // // //                                 ? c.pink.withOpacity(0.06)
// // // //                                 : c.card,
// // // //                             borderRadius: BorderRadius.circular(
// // // //                               14,
// // // //                             ),
// // // //                             border: Border.all(
// // // //                               color: isBest
// // // //                                   ? c.pink.withOpacity(0.3)
// // // //                                   : c.border,
// // // //                             ),
// // // //                           ),
// // // //                           child: Row(
// // // //                             children: [
// // // //                               Container(
// // // //                                 width: 40,
// // // //                                 height: 40,
// // // //                                 decoration: BoxDecoration(
// // // //                                   color: c.gold.withOpacity(
// // // //                                     0.12,
// // // //                                   ),
// // // //                                   borderRadius:
// // // //                                       BorderRadius.circular(10),
// // // //                                 ),
// // // //                                 child: const Center(
// // // //                                   child: Text(
// // // //                                     '💎',
// // // //                                     style: TextStyle(
// // // //                                       fontSize: 18,
// // // //                                     ),
// // // //                                   ),
// // // //                                 ),
// // // //                               ),
// // // //                               const SizedBox(width: 14),
// // // //                               Expanded(
// // // //                                 child: Column(
// // // //                                   crossAxisAlignment:
// // // //                                       CrossAxisAlignment.start,
// // // //                                   children: [
// // // //                                     Text(
// // // //                                       name,
// // // //                                       style: TextStyle(
// // // //                                         color: c.textPrimary,
// // // //                                         fontSize: 14,
// // // //                                         fontWeight:
// // // //                                             FontWeight.w600,
// // // //                                       ),
// // // //                                     ),
// // // //                                     if (isBest)
// // // //                                       Text(
// // // //                                         'Best value',
// // // //                                         style: TextStyle(
// // // //                                           color: c.pink,
// // // //                                           fontSize: 10,
// // // //                                           fontWeight:
// // // //                                               FontWeight.bold,
// // // //                                         ),
// // // //                                       ),
// // // //                                   ],
// // // //                                 ),
// // // //                               ),
// // // //                               Container(
// // // //                                 padding:
// // // //                                     const EdgeInsets.symmetric(
// // // //                                       horizontal: 14,
// // // //                                       vertical: 8,
// // // //                                     ),
// // // //                                 decoration: BoxDecoration(
// // // //                                   gradient: LinearGradient(
// // // //                                     colors: [
// // // //                                       c.pink,
// // // //                                       const Color(0xFFFF6B9D),
// // // //                                     ],
// // // //                                   ),
// // // //                                   borderRadius:
// // // //                                       BorderRadius.circular(20),
// // // //                                 ),
// // // //                                 child: Text(
// // // //                                   '${currency == 'INR' ? '₹' : '\$'}${price.toStringAsFixed(0)}',
// // // //                                   style: const TextStyle(
// // // //                                     color: Colors.white,
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     fontSize: 13,
// // // //                                   ),
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     );
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Legal info dialog ─────────────────────────────────────────────────────

// // // //   void _showLegalPage(String title) {
// // // //     final c = AppColors.of(context);
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         backgroundColor: c.card,
// // // //         shape: RoundedRectangleBorder(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //         ),
// // // //         title: Text(
// // // //           title,
// // // //           style: GoogleFonts.poppins(
// // // //             color: c.textPrimary,
// // // //             fontWeight: FontWeight.w600,
// // // //           ),
// // // //         ),
// // // //         content: Text(
// // // //           'This content will be available when the app launches. For now, you can contact support for any legal inquiries.',
// // // //           style: TextStyle(color: c.textSecondary, fontSize: 13),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(ctx),
// // // //             child: Text(
// // // //               'OK',
// // // //               style: TextStyle(
// // // //                 color: c.pink,
// // // //                 fontWeight: FontWeight.w600,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ═══════════════════════════════════════════════════════════════════════════
// // // //   // BUILD
// // // //   // ═══════════════════════════════════════════════════════════════════════════

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final asyncUser = ref.watch(currentUserProvider);
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     return AnnotatedRegion<SystemUiOverlayStyle>(
// // // //       value: isDark
// // // //           ? SystemUiOverlayStyle.light
// // // //           : SystemUiOverlayStyle.dark,
// // // //       child: Scaffold(
// // // //         backgroundColor: c.bg,
// // // //         body: asyncUser.when(
// // // //           loading: () => Center(
// // // //             child: CircularProgressIndicator(color: c.pink),
// // // //           ),
// // // //           error: (e, _) => Center(
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 const Icon(
// // // //                   Icons.error_outline,
// // // //                   color: Colors.redAccent,
// // // //                   size: 48,
// // // //                 ),
// // // //                 const SizedBox(height: 12),
// // // //                 Text(
// // // //                   'Could not load profile',
// // // //                   style: TextStyle(color: c.textSecondary),
// // // //                 ),
// // // //                 const SizedBox(height: 8),
// // // //                 TextButton(
// // // //                   onPressed: () => ref
// // // //                       .read(currentUserProvider.notifier)
// // // //                       .refresh(),
// // // //                   child: Text(
// // // //                     'Retry',
// // // //                     style: TextStyle(color: c.pink),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           data: (user) => _buildBody(user),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Body ──────────────────────────────────────────────────────────────────

// // // //   Widget _buildBody(AppUser? user) {
// // // //     final coins = user?.coins ?? 0;
// // // //     final level = user?.level ?? 1;
// // // //     final levelLabel = user?.levelLabel ?? 'Newcomer';
// // // //     final publicId = user?.publicId;
// // // //     final countryCode = user?.countryCode ?? 'IN';
// // // //     final language = user?.language ?? '';
// // // //     final photoUrl = user?.profilePhotoUrl;
// // // //     final age = user?.age;
// // // //     final isHost = user?.isHost ?? false;
// // // //     final name = user?.displayName ?? 'Guest';

// // // //     final themeMode = ref.watch(themeModeProvider);
// // // //     final isDark =
// // // //         themeMode == ThemeMode.dark ||
// // // //         (themeMode == ThemeMode.system &&
// // // //             MediaQuery.of(context).platformBrightness ==
// // // //                 Brightness.dark);

// // // //     // Adaptive sizing
// // // //     final mq = MediaQuery.of(context);
// // // //     final sw = mq.size.width;
// // // //     final sh = mq.size.height;
// // // //     final hPad = (sw * 0.04).clamp(12.0, 20.0);

// // // //     return CustomScrollView(
// // // //       physics: const BouncingScrollPhysics(),
// // // //       slivers: [
// // // //         SliverToBoxAdapter(
// // // //           child: _buildHeader(
// // // //             name,
// // // //             photoUrl,
// // // //             level,
// // // //             levelLabel,
// // // //             publicId,
// // // //             countryCode,
// // // //             age,
// // // //             sw,
// // // //             sh,
// // // //           ),
// // // //         ),
// // // //         SliverPadding(
// // // //           padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
// // // //           sliver: SliverList(
// // // //             delegate: SliverChildListDelegate([
// // // //               _buildSocialStats(),
// // // //               const SizedBox(height: 12),
// // // //               _buildCoinsCard(coins),

// // // //               if (isHost) ...[
// // // //                 const SizedBox(height: 12),
// // // //                 _buildHostEarningsCard(),
// // // //               ],

// // // //               const SizedBox(height: 20),
// // // //               _sectionLabel('Discover'),
// // // //               _tileGroup([
// // // //                 if (!isHost)
// // // //                   _tile(
// // // //                     icon: FontAwesomeIcons.star,
// // // //                     iconColor: const Color(0xFFFFCA28),
// // // //                     label: 'Become a Host',
// // // //                     badge: 'Apply',
// // // //                     onTap: () => _todo('Host application'),
// // // //                   ),
// // // //                 _tile(
// // // //                   icon: FontAwesomeIcons.userGroup,
// // // //                   iconColor: const Color(0xFF42A5F5),
// // // //                   label: 'Invite Friends',
// // // //                   subtitle: 'Earn coins per referral',
// // // //                   onTap: () => _todo('Referrals'),
// // // //                 ),
// // // //               ]),

// // // //               const SizedBox(height: 20),
// // // //               _sectionLabel('Preferences'),
// // // //               _tileGroup([
// // // //                 _tile(
// // // //                   icon: isDark
// // // //                       ? Icons.dark_mode_outlined
// // // //                       : Icons.light_mode_outlined,
// // // //                   iconColor: isDark
// // // //                       ? const Color(0xFF7C4DFF)
// // // //                       : const Color(0xFFFFB300),
// // // //                   label: 'Appearance',
// // // //                   subtitle: isDark ? 'Dark mode' : 'Light mode',
// // // //                   trailing: _themeToggle(isDark),
// // // //                   onTap: () => ref
// // // //                       .read(themeModeProvider.notifier)
// // // //                       .toggle(),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.language_outlined,
// // // //                   label: 'App Language',
// // // //                   subtitle: language.isNotEmpty
// // // //                       ? language
// // // //                       : 'English',
// // // //                   onTap: () => _todo('Language picker'),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.notifications_outlined,
// // // //                   label: 'Notification Settings',
// // // //                   onTap: () => _todo('Notification settings'),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.auto_fix_high_outlined,
// // // //                   iconColor: const Color(0xFFCE93D8),
// // // //                   label: 'Camera Beauty',
// // // //                   onTap: () => _todo('Beauty settings'),
// // // //                 ),
// // // //               ]),

// // // //               const SizedBox(height: 20),
// // // //               _sectionLabel('Storage & Updates'),
// // // //               _tileGroup([
// // // //                 _tile(
// // // //                   icon: Icons.cleaning_services_outlined,
// // // //                   label: 'Clear Cache',
// // // //                   onTap: _showClearCacheDialog,
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.system_update_outlined,
// // // //                   iconColor: const Color(0xFF4CAF50),
// // // //                   label: 'Check for Updates',
// // // //                   onTap: () => _todo('Update check'),
// // // //                 ),
// // // //               ]),

// // // //               const SizedBox(height: 20),
// // // //               _sectionLabel('Legal & Info'),
// // // //               _tileGroup([
// // // //                 _tile(
// // // //                   icon: Icons.shield_outlined,
// // // //                   label: 'Privacy Policy',
// // // //                   onTap: () => _showLegalPage('Privacy Policy'),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.description_outlined,
// // // //                   label: 'Terms of Service',
// // // //                   onTap: () =>
// // // //                       _showLegalPage('Terms of Service'),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.info_outline,
// // // //                   label: 'About Us',
// // // //                   onTap: () => _showLegalPage('About Us'),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.star_border_outlined,
// // // //                   iconColor: const Color(0xFFFFCA28),
// // // //                   label: 'Rate Our App',
// // // //                   onTap: () =>
// // // //                       _snack('Play Store rating coming soon!'),
// // // //                 ),
// // // //               ]),

// // // //               const SizedBox(height: 20),
// // // //               _sectionLabel('Support'),
// // // //               _tileGroup([
// // // //                 _tile(
// // // //                   icon: Icons.headset_mic_outlined,
// // // //                   label: 'Help & Support',
// // // //                   subtitle: isHost
// // // //                       ? 'Support · Feature requests · Feedback'
// // // //                       : null,
// // // //                   onTap: () => _showHelpSheet(isHost: isHost),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.bug_report_outlined,
// // // //                   label: 'Report a Bug',
// // // //                   onTap: () => _todo('Bug report'),
// // // //                 ),
// // // //               ]),

// // // //               const SizedBox(height: 20),
// // // //               _sectionLabel('Account'),
// // // //               _tileGroup([
// // // //                 _tile(
// // // //                   icon: Icons.link_outlined,
// // // //                   label: 'Bind Accounts',
// // // //                   subtitle: 'Google · Phone · Apple',
// // // //                   onTap: () => _todo('Bind accounts'),
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.block_outlined,
// // // //                   label: 'Blocked Users',
// // // //                   onTap: _showBlockedUsers,
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: Icons.receipt_long_outlined,
// // // //                   label: 'Transaction History',
// // // //                   onTap: _showTransactionHistory,
// // // //                 ),
// // // //                 _tile(
// // // //                   icon: FontAwesomeIcons.trash,
// // // //                   iconSize: 16,
// // // //                   iconColor: Colors.redAccent,
// // // //                   label: 'Delete Account',
// // // //                   labelColor: Colors.redAccent,
// // // //                   onTap: _confirmDeleteAccount,
// // // //                 ),
// // // //               ]),

// // // //               const SizedBox(height: 20),
// // // //               _logoutButton(),
// // // //               SizedBox(height: mq.padding.bottom + 32),
// // // //             ]),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   // ── Header (adaptive) ─────────────────────────────────────────────────────

// // // //   Widget _buildHeader(
// // // //     String name,
// // // //     String? photoUrl,
// // // //     int level,
// // // //     String levelLabel,
// // // //     int? publicId,
// // // //     String countryCode,
// // // //     int? age,
// // // //     double sw,
// // // //     double sh,
// // // //   ) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;

// // // //     // Proportional sizes
// // // //     final headerH = (sh * 0.28).clamp(200.0, 280.0);
// // // //     final avatarSize = (sw * 0.2).clamp(64.0, 96.0);
// // // //     final cameraBadge = (avatarSize * 0.3).clamp(20.0, 28.0);
// // // //     final titleSize = (sw * 0.055).clamp(18.0, 24.0);
// // // //     final nameSize = (sw * 0.05).clamp(16.0, 22.0);
// // // //     final hPad = (sw * 0.04).clamp(12.0, 20.0);

// // // //     return Stack(
// // // //       children: [
// // // //         Container(
// // // //           height: headerH,
// // // //           decoration: BoxDecoration(
// // // //             gradient: LinearGradient(
// // // //               begin: Alignment.topCenter,
// // // //               end: Alignment.bottomCenter,
// // // //               colors: isDark
// // // //                   ? [
// // // //                       const Color(0xFF2D0A1F),
// // // //                       const Color(0xFF0D0D0D),
// // // //                     ]
// // // //                   : [const Color(0xFFFFE4F0), c.bg],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         // Radial glow — proportional to screen width
// // // //         Positioned(
// // // //           top: -sw * 0.1,
// // // //           left: 0,
// // // //           right: 0,
// // // //           child: Center(
// // // //             child: Container(
// // // //               width: sw * 0.85,
// // // //               height: sw * 0.55,
// // // //               decoration: BoxDecoration(
// // // //                 shape: BoxShape.circle,
// // // //                 gradient: RadialGradient(
// // // //                   colors: [
// // // //                     c.pink.withOpacity(0.10),
// // // //                     Colors.transparent,
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         SafeArea(
// // // //           bottom: false,
// // // //           child: Padding(
// // // //             padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
// // // //             child: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Text(
// // // //                   'Profile',
// // // //                   style: GoogleFonts.poppins(
// // // //                     color: c.textPrimary,
// // // //                     fontSize: titleSize,
// // // //                     fontWeight: FontWeight.w700,
// // // //                   ),
// // // //                 ),
// // // //                 SizedBox(height: sh * 0.018),
// // // //                 Row(
// // // //                   crossAxisAlignment: CrossAxisAlignment.center,
// // // //                   children: [
// // // //                     // Avatar
// // // //                     _avatar(photoUrl, avatarSize, cameraBadge),
// // // //                     SizedBox(width: sw * 0.04),
// // // //                     Expanded(
// // // //                       child: Column(
// // // //                         crossAxisAlignment:
// // // //                             CrossAxisAlignment.start,
// // // //                         children: [
// // // //                           // Name + edit
// // // //                           Row(
// // // //                             children: [
// // // //                               Flexible(
// // // //                                 child: Text(
// // // //                                   name,
// // // //                                   style: GoogleFonts.poppins(
// // // //                                     color: c.textPrimary,
// // // //                                     fontSize: nameSize,
// // // //                                     fontWeight: FontWeight.w700,
// // // //                                   ),
// // // //                                   overflow:
// // // //                                       TextOverflow.ellipsis,
// // // //                                 ),
// // // //                               ),
// // // //                               const SizedBox(width: 6),
// // // //                               GestureDetector(
// // // //                                 onTap: () => _editName(name),
// // // //                                 child: Container(
// // // //                                   padding: const EdgeInsets.all(
// // // //                                     5,
// // // //                                   ),
// // // //                                   decoration: BoxDecoration(
// // // //                                     color: c.pink.withOpacity(
// // // //                                       0.12,
// // // //                                     ),
// // // //                                     shape: BoxShape.circle,
// // // //                                   ),
// // // //                                   child: Icon(
// // // //                                     Icons.edit,
// // // //                                     size: (nameSize * 0.6).clamp(
// // // //                                       11.0,
// // // //                                       15.0,
// // // //                                     ),
// // // //                                     color: c.pink,
// // // //                                   ),
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                           const SizedBox(height: 6),
// // // //                           // Meta pills — Wrap handles overflow automatically
// // // //                           Wrap(
// // // //                             spacing: 6,
// // // //                             runSpacing: 4,
// // // //                             crossAxisAlignment:
// // // //                                 WrapCrossAlignment.center,
// // // //                             children: [
// // // //                               if (age != null)
// // // //                                 _metaPill(
// // // //                                   '$age yrs',
// // // //                                   Icons.cake_outlined,
// // // //                                   const Color(0xFFFF8A65),
// // // //                                 ),
// // // //                               Row(
// // // //                                 mainAxisSize: MainAxisSize.min,
// // // //                                 children: [
// // // //                                   ClipRRect(
// // // //                                     borderRadius:
// // // //                                         BorderRadius.circular(3),
// // // //                                     child: Flag.fromString(
// // // //                                       countryCode,
// // // //                                       width: 22,
// // // //                                       height: 15,
// // // //                                       fit: BoxFit.cover,
// // // //                                     ),
// // // //                                   ),
// // // //                                   const SizedBox(width: 4),
// // // //                                   Text(
// // // //                                     countryCode,
// // // //                                     style: TextStyle(
// // // //                                       color: c.textSecondary,
// // // //                                       fontSize: 11,
// // // //                                     ),
// // // //                                   ),
// // // //                                 ],
// // // //                               ),
// // // //                               _metaPill(
// // // //                                 'Lv.$level $levelLabel',
// // // //                                 Icons.bolt,
// // // //                                 c.pink,
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                           const SizedBox(height: 6),
// // // //                           if (publicId != null)
// // // //                             GestureDetector(
// // // //                               onTap: () {
// // // //                                 Clipboard.setData(
// // // //                                   ClipboardData(
// // // //                                     text: '$publicId',
// // // //                                   ),
// // // //                                 );
// // // //                                 _snack('ID copied!');
// // // //                               },
// // // //                               child: Row(
// // // //                                 mainAxisSize: MainAxisSize.min,
// // // //                                 children: [
// // // //                                   Text(
// // // //                                     'ID: $publicId',
// // // //                                     style: TextStyle(
// // // //                                       color: c.textSecondary,
// // // //                                       fontSize: 11,
// // // //                                     ),
// // // //                                   ),
// // // //                                   const SizedBox(width: 4),
// // // //                                   Icon(
// // // //                                     Icons.copy,
// // // //                                     size: 10,
// // // //                                     color: c.textSecondary,
// // // //                                   ),
// // // //                                 ],
// // // //                               ),
// // // //                             ),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   // ── Avatar (adaptive) ─────────────────────────────────────────────────────

// // // //   Widget _avatar(
// // // //     String? photoUrl,
// // // //     double size,
// // // //     double badgeSize,
// // // //   ) {
// // // //     final c = AppColors.of(context);
// // // //     return GestureDetector(
// // // //       onTap: _pickPhoto,
// // // //       child: Stack(
// // // //         children: [
// // // //           Container(
// // // //             width: size,
// // // //             height: size,
// // // //             decoration: BoxDecoration(
// // // //               shape: BoxShape.circle,
// // // //               border: Border.all(color: c.pink, width: 2.5),
// // // //             ),
// // // //             child: ClipOval(
// // // //               child: _isUploadingPhoto
// // // //                   ? Container(
// // // //                       color: c.surface,
// // // //                       child: Center(
// // // //                         child: CircularProgressIndicator(
// // // //                           color: c.pink,
// // // //                           strokeWidth: 2,
// // // //                         ),
// // // //                       ),
// // // //                     )
// // // //                   : photoUrl != null
// // // //                   ? CachedNetworkImage(
// // // //                       imageUrl: photoUrl,
// // // //                       fit: BoxFit.cover,
// // // //                       placeholder: (_, __) =>
// // // //                           Container(color: c.surface),
// // // //                       errorWidget: (_, __, ___) =>
// // // //                           _avatarFallback(size),
// // // //                     )
// // // //                   : _avatarFallback(size),
// // // //             ),
// // // //           ),
// // // //           Positioned(
// // // //             bottom: 0,
// // // //             right: 0,
// // // //             child: Container(
// // // //               width: badgeSize,
// // // //               height: badgeSize,
// // // //               decoration: BoxDecoration(
// // // //                 color: c.pink,
// // // //                 shape: BoxShape.circle,
// // // //                 border: Border.all(color: c.bg, width: 2),
// // // //               ),
// // // //               child: Icon(
// // // //                 Icons.camera_alt,
// // // //                 size: badgeSize * 0.5,
// // // //                 color: Colors.white,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _avatarFallback(double size) {
// // // //     final c = AppColors.of(context);
// // // //     return Container(
// // // //       color: c.avatarFallback,
// // // //       child: Icon(
// // // //         Icons.person,
// // // //         color: c.avatarIcon,
// // // //         size: size * 0.5,
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _metaPill(String label, IconData icon, Color color) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(
// // // //         horizontal: 7,
// // // //         vertical: 3,
// // // //       ),
// // // //       decoration: BoxDecoration(
// // // //         color: color.withOpacity(0.12),
// // // //         borderRadius: BorderRadius.circular(20),
// // // //         border: Border.all(color: color.withOpacity(0.3)),
// // // //       ),
// // // //       child: Row(
// // // //         mainAxisSize: MainAxisSize.min,
// // // //         children: [
// // // //           Icon(icon, size: 11, color: color),
// // // //           const SizedBox(width: 3),
// // // //           Text(
// // // //             label,
// // // //             style: GoogleFonts.poppins(
// // // //               color: color,
// // // //               fontSize: 10,
// // // //               fontWeight: FontWeight.w600,
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Social stats ──────────────────────────────────────────────────────────

// // // //   Widget _buildSocialStats() {
// // // //     final c = AppColors.of(context);

// // // //     return Material(
// // // //       color: c.surface,
// // // //       borderRadius: BorderRadius.circular(16),
// // // //       clipBehavior: Clip.hardEdge,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           border: Border.all(color: c.divider),
// // // //         ),
// // // //         child: IntrinsicHeight(
// // // //           child: Row(
// // // //             children: [
// // // //               _socialStat(
// // // //                 _followerCount,
// // // //                 'Followers',
// // // //                 onTap: () => _showFollowList('Followers'),
// // // //               ),
// // // //               VerticalDivider(width: 1, color: c.divider),
// // // //               _socialStat(
// // // //                 _followingCount,
// // // //                 'Following',
// // // //                 onTap: () => _showFollowList('Following'),
// // // //               ),
// // // //               VerticalDivider(width: 1, color: c.divider),
// // // //               _socialStat(
// // // //                 0,
// // // //                 'Mutuals',
// // // //                 onTap: () => _snack('Mutuals coming soon!'),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _socialStat(
// // // //     int count,
// // // //     String label, {
// // // //     required VoidCallback onTap,
// // // //   }) {
// // // //     final c = AppColors.of(context);
// // // //     final sw = MediaQuery.of(context).size.width;
// // // //     final fontSize = (sw * 0.045).clamp(14.0, 20.0);

// // // //     return Expanded(
// // // //       child: InkWell(
// // // //         onTap: onTap,
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.symmetric(vertical: 14),
// // // //           child: Column(
// // // //             children: [
// // // //               Text(
// // // //                 _formatCount(count),
// // // //                 style: GoogleFonts.poppins(
// // // //                   color: c.textPrimary,
// // // //                   fontSize: fontSize,
// // // //                   fontWeight: FontWeight.w700,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 2),
// // // //               Text(
// // // //                 label,
// // // //                 style: TextStyle(
// // // //                   color: c.textSecondary,
// // // //                   fontSize: 11,
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   String _formatCount(int n) {
// // // //     if (n >= 1000000)
// // // //       return '${(n / 1000000).toStringAsFixed(1)}M';
// // // //     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
// // // //     return '$n';
// // // //   }

// // // //   // ── Coins card ────────────────────────────────────────────────────────────

// // // //   Widget _buildCoinsCard(int coins) {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;
// // // //     final sw = MediaQuery.of(context).size.width;
// // // //     final iconBox = (sw * 0.12).clamp(38.0, 50.0);
// // // //     final coinFontSize = (sw * 0.05).clamp(16.0, 22.0);

// // // //     return Container(
// // // //       padding: EdgeInsets.all((sw * 0.045).clamp(14.0, 20.0)),
// // // //       decoration: BoxDecoration(
// // // //         borderRadius: BorderRadius.circular(18),
// // // //         gradient: LinearGradient(
// // // //           begin: Alignment.topLeft,
// // // //           end: Alignment.bottomRight,
// // // //           colors: isDark
// // // //               ? [
// // // //                   const Color(0xFF1A0D12),
// // // //                   const Color(0xFF221228),
// // // //                 ]
// // // //               : [
// // // //                   const Color(0xFFFFF0F7),
// // // //                   const Color(0xFFFFE4EF),
// // // //                 ],
// // // //         ),
// // // //         border: Border.all(color: c.pink.withOpacity(0.2)),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: c.pink.withOpacity(0.08),
// // // //             blurRadius: 20,
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: Row(
// // // //         children: [
// // // //           Container(
// // // //             width: iconBox,
// // // //             height: iconBox,
// // // //             decoration: BoxDecoration(
// // // //               color: c.gold.withOpacity(0.15),
// // // //               borderRadius: BorderRadius.circular(13),
// // // //             ),
// // // //             child: Center(
// // // //               child: Text(
// // // //                 '💎',
// // // //                 style: TextStyle(fontSize: iconBox * 0.48),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           SizedBox(width: sw * 0.035),
// // // //           Expanded(
// // // //             child: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Text(
// // // //                   'My Balance',
// // // //                   style: TextStyle(
// // // //                     color: c.textSecondary,
// // // //                     fontSize: 11,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 2),
// // // //                 Text(
// // // //                   '$coins coins',
// // // //                   style: GoogleFonts.poppins(
// // // //                     color: c.gold,
// // // //                     fontSize: coinFontSize,
// // // //                     fontWeight: FontWeight.w700,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           GestureDetector(
// // // //             onTap: _showTopUpSheet,
// // // //             child: Container(
// // // //               padding: EdgeInsets.symmetric(
// // // //                 horizontal: sw * 0.04,
// // // //                 vertical: 9,
// // // //               ),
// // // //               decoration: BoxDecoration(
// // // //                 gradient: LinearGradient(
// // // //                   colors: [c.pink, const Color(0xFFFF6B9D)],
// // // //                 ),
// // // //                 borderRadius: BorderRadius.circular(30),
// // // //                 boxShadow: [
// // // //                   BoxShadow(
// // // //                     color: c.pink.withOpacity(0.35),
// // // //                     blurRadius: 10,
// // // //                     offset: const Offset(0, 4),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //               child: Text(
// // // //                 'Top Up',
// // // //                 style: GoogleFonts.poppins(
// // // //                   color: Colors.white,
// // // //                   fontSize: 13,
// // // //                   fontWeight: FontWeight.w600,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Host earnings card ────────────────────────────────────────────────────

// // // //   Widget _buildHostEarningsCard() {
// // // //     final c = AppColors.of(context);
// // // //     final isDark =
// // // //         Theme.of(context).brightness == Brightness.dark;
// // // //     final sw = MediaQuery.of(context).size.width;
// // // //     final pad = (sw * 0.045).clamp(14.0, 20.0);

// // // //     return Container(
// // // //       padding: EdgeInsets.all(pad),
// // // //       decoration: BoxDecoration(
// // // //         borderRadius: BorderRadius.circular(18),
// // // //         gradient: LinearGradient(
// // // //           begin: Alignment.topLeft,
// // // //           end: Alignment.bottomRight,
// // // //           colors: isDark
// // // //               ? [
// // // //                   const Color(0xFF0D1A0D),
// // // //                   const Color(0xFF122212),
// // // //                 ]
// // // //               : [
// // // //                   const Color(0xFFF0FFF0),
// // // //                   const Color(0xFFE8F5E9),
// // // //                 ],
// // // //         ),
// // // //         border: Border.all(color: c.green.withOpacity(0.25)),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: c.green.withOpacity(0.06),
// // // //             blurRadius: 20,
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Row(
// // // //             children: [
// // // //               Container(
// // // //                 width: 36,
// // // //                 height: 36,
// // // //                 decoration: BoxDecoration(
// // // //                   color: c.green.withOpacity(0.12),
// // // //                   borderRadius: BorderRadius.circular(10),
// // // //                 ),
// // // //                 child: Icon(
// // // //                   Icons.trending_up,
// // // //                   color: c.green,
// // // //                   size: 18,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: Text(
// // // //                   'Host Earnings',
// // // //                   style: GoogleFonts.poppins(
// // // //                     color: c.textPrimary,
// // // //                     fontSize: 15,
// // // //                     fontWeight: FontWeight.w600,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               Text(
// // // //                 'This month',
// // // //                 style: TextStyle(
// // // //                   color: c.textSecondary,
// // // //                   fontSize: 11,
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 14),
// // // //           Row(
// // // //             children: [
// // // //               _earningsStat('₹ 0', 'Available', c),
// // // //               const SizedBox(width: 16),
// // // //               _earningsStat('₹ 0', 'Withdrawn', c),
// // // //               const SizedBox(width: 16),
// // // //               _earningsStat('0', 'Call Mins', c),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 14),
// // // //           Row(
// // // //             children: [
// // // //               Expanded(
// // // //                 child: _outlineButton(
// // // //                   label: 'Bind Bank / UPI',
// // // //                   icon: Icons.account_balance_outlined,
// // // //                   color: c.textSecondary,
// // // //                   onTap: () => _todo('Bind bank account'),
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: _outlineButton(
// // // //                   label: 'Withdraw',
// // // //                   icon: Icons.arrow_circle_down_outlined,
// // // //                   color: c.green,
// // // //                   onTap: () => _todo('Withdraw earnings'),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _earningsStat(String value, String label, AppColors c) {
// // // //     return Expanded(
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Text(
// // // //             value,
// // // //             style: GoogleFonts.poppins(
// // // //               color: c.green,
// // // //               fontSize: 16,
// // // //               fontWeight: FontWeight.w700,
// // // //             ),
// // // //           ),
// // // //           Text(
// // // //             label,
// // // //             style: TextStyle(
// // // //               color: c.textSecondary,
// // // //               fontSize: 10,
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _outlineButton({
// // // //     required String label,
// // // //     required IconData icon,
// // // //     required Color color,
// // // //     required VoidCallback onTap,
// // // //   }) {
// // // //     return GestureDetector(
// // // //       onTap: onTap,
// // // //       child: Container(
// // // //         padding: const EdgeInsets.symmetric(vertical: 9),
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(10),
// // // //           border: Border.all(color: color.withOpacity(0.4)),
// // // //         ),
// // // //         child: Row(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             Icon(icon, size: 14, color: color),
// // // //             const SizedBox(width: 5),
// // // //             Flexible(
// // // //               child: Text(
// // // //                 label,
// // // //                 style: TextStyle(
// // // //                   color: color,
// // // //                   fontSize: 12,
// // // //                   fontWeight: FontWeight.w600,
// // // //                 ),
// // // //                 overflow: TextOverflow.ellipsis,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Sheet tile ────────────────────────────────────────────────────────────

// // // //   Widget _sheetTile({
// // // //     required IconData icon,
// // // //     required String label,
// // // //     required VoidCallback onTap,
// // // //     String? subtitle,
// // // //   }) {
// // // //     final c = AppColors.of(context);
// // // //     return ListTile(
// // // //       contentPadding: EdgeInsets.zero,
// // // //       leading: Container(
// // // //         width: 38,
// // // //         height: 38,
// // // //         decoration: BoxDecoration(
// // // //           color: c.pink.withOpacity(0.10),
// // // //           borderRadius: BorderRadius.circular(10),
// // // //         ),
// // // //         child: Icon(icon, size: 18, color: c.pink),
// // // //       ),
// // // //       title: Text(
// // // //         label,
// // // //         style: TextStyle(
// // // //           color: c.textPrimary,
// // // //           fontWeight: FontWeight.w500,
// // // //           fontSize: 14,
// // // //         ),
// // // //       ),
// // // //       subtitle: subtitle != null
// // // //           ? Text(
// // // //               subtitle,
// // // //               style: TextStyle(
// // // //                 color: c.textSecondary,
// // // //                 fontSize: 11,
// // // //               ),
// // // //             )
// // // //           : null,
// // // //       trailing: Icon(
// // // //         Icons.arrow_forward_ios,
// // // //         size: 12,
// // // //         color: c.textSecondary,
// // // //       ),
// // // //       onTap: onTap,
// // // //     );
// // // //   }

// // // //   // ── Logout ────────────────────────────────────────────────────────────────

// // // //   Widget _logoutButton() {
// // // //     return GestureDetector(
// // // //       onTap: _confirmLogout,
// // // //       child: Container(
// // // //         width: double.infinity,
// // // //         padding: const EdgeInsets.symmetric(vertical: 14),
// // // //         decoration: BoxDecoration(
// // // //           color: Colors.redAccent.withOpacity(0.08),
// // // //           borderRadius: BorderRadius.circular(14),
// // // //           border: Border.all(
// // // //             color: Colors.redAccent.withOpacity(0.25),
// // // //           ),
// // // //         ),
// // // //         child: Row(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             const Icon(
// // // //               Icons.logout,
// // // //               color: Colors.redAccent,
// // // //               size: 18,
// // // //             ),
// // // //             const SizedBox(width: 8),
// // // //             Text(
// // // //               'Log Out',
// // // //               style: GoogleFonts.poppins(
// // // //                 color: Colors.redAccent,
// // // //                 fontWeight: FontWeight.w600,
// // // //                 fontSize: 14,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ── Tile components ───────────────────────────────────────────────────────

// // // //   Widget _sectionLabel(String label) {
// // // //     final c = AppColors.of(context);
// // // //     return Padding(
// // // //       padding: const EdgeInsets.only(bottom: 8, left: 2),
// // // //       child: Text(
// // // //         label.toUpperCase(),
// // // //         style: GoogleFonts.poppins(
// // // //           color: c.textSecondary,
// // // //           fontSize: 11,
// // // //           fontWeight: FontWeight.w600,
// // // //           letterSpacing: 1.2,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _tileGroup(List<Widget?> tiles) {
// // // //     final c = AppColors.of(context);
// // // //     final visible = tiles.whereType<Widget>().toList();
// // // //     if (visible.isEmpty) return const SizedBox.shrink();
// // // //     return Material(
// // // //       color: c.surface,
// // // //       borderRadius: BorderRadius.circular(16),
// // // //       clipBehavior: Clip.hardEdge,
// // // //       child: Container(
// // // //         decoration: BoxDecoration(
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           border: Border.all(color: c.divider),
// // // //         ),
// // // //         child: Column(
// // // //           children: [
// // // //             for (int i = 0; i < visible.length; i++) ...[
// // // //               visible[i],
// // // //               if (i < visible.length - 1)
// // // //                 Divider(height: 1, color: c.divider, indent: 54),
// // // //             ],
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget? _tile({
// // // //     required IconData icon,
// // // //     required String label,
// // // //     required VoidCallback onTap,
// // // //     double iconSize = 19,
// // // //     Color? iconColor,
// // // //     Color? labelColor,
// // // //     String? subtitle,
// // // //     String? badge,
// // // //     Widget? trailing,
// // // //   }) {
// // // //     final c = AppColors.of(context);
// // // //     final effectiveIconColor = iconColor ?? c.textSecondary;
// // // //     final effectiveLabelColor = labelColor ?? c.textPrimary;

// // // //     return ListTile(
// // // //       onTap: onTap,
// // // //       contentPadding: const EdgeInsets.symmetric(
// // // //         horizontal: 14,
// // // //         vertical: 2,
// // // //       ),
// // // //       leading: Container(
// // // //         width: 36,
// // // //         height: 36,
// // // //         decoration: BoxDecoration(
// // // //           color: effectiveIconColor.withOpacity(0.10),
// // // //           borderRadius: BorderRadius.circular(10),
// // // //         ),
// // // //         child: Icon(
// // // //           icon,
// // // //           size: iconSize,
// // // //           color: effectiveIconColor,
// // // //         ),
// // // //       ),
// // // //       title: Text(
// // // //         label,
// // // //         style: TextStyle(
// // // //           color: effectiveLabelColor,
// // // //           fontWeight: FontWeight.w500,
// // // //           fontSize: 14,
// // // //         ),
// // // //       ),
// // // //       subtitle: subtitle != null
// // // //           ? Text(
// // // //               subtitle,
// // // //               style: TextStyle(
// // // //                 color: c.textSecondary,
// // // //                 fontSize: 11,
// // // //               ),
// // // //             )
// // // //           : null,
// // // //       trailing:
// // // //           trailing ??
// // // //           (badge != null
// // // //               ? Container(
// // // //                   padding: const EdgeInsets.symmetric(
// // // //                     horizontal: 8,
// // // //                     vertical: 3,
// // // //                   ),
// // // //                   decoration: BoxDecoration(
// // // //                     color: c.pink.withOpacity(0.15),
// // // //                     borderRadius: BorderRadius.circular(20),
// // // //                   ),
// // // //                   child: Text(
// // // //                     badge,
// // // //                     style: TextStyle(
// // // //                       color: c.pink,
// // // //                       fontSize: 10,
// // // //                       fontWeight: FontWeight.w700,
// // // //                     ),
// // // //                   ),
// // // //                 )
// // // //               : Icon(
// // // //                   Icons.arrow_forward_ios,
// // // //                   size: 13,
// // // //                   color: c.textSecondary.withOpacity(0.5),
// // // //                 )),
// // // //     );
// // // //   }

// // // //   // ── Theme toggle ──────────────────────────────────────────────────────────

// // // //   Widget _themeToggle(bool isDark) {
// // // //     return GestureDetector(
// // // //       onTap: () => ref.read(themeModeProvider.notifier).toggle(),
// // // //       child: AnimatedContainer(
// // // //         duration: const Duration(milliseconds: 250),
// // // //         curve: Curves.easeInOut,
// // // //         width: 52,
// // // //         height: 28,
// // // //         decoration: BoxDecoration(
// // // //           gradient: isDark
// // // //               ? const LinearGradient(
// // // //                   colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
// // // //                 )
// // // //               : const LinearGradient(
// // // //                   colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
// // // //                 ),
// // // //           borderRadius: BorderRadius.circular(14),
// // // //         ),
// // // //         child: AnimatedAlign(
// // // //           duration: const Duration(milliseconds: 250),
// // // //           curve: Curves.easeInOut,
// // // //           alignment: isDark
// // // //               ? Alignment.centerRight
// // // //               : Alignment.centerLeft,
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.symmetric(horizontal: 3),
// // // //             child: Container(
// // // //               width: 22,
// // // //               height: 22,
// // // //               decoration: const BoxDecoration(
// // // //                 color: Colors.white,
// // // //                 shape: BoxShape.circle,
// // // //               ),
// // // //               child: Icon(
// // // //                 isDark ? Icons.dark_mode : Icons.light_mode,
// // // //                 size: 13,
// // // //                 color: isDark
// // // //                     ? const Color(0xFF7C4DFF)
// // // //                     : const Color(0xFFFFB300),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // // lib/screens/profile_screen.dart
// // // //
// // // // User's own profile — settings, wallet, host earnings, preferences.
// // // // Fully adaptive to all screen sizes.

// // // import 'package:cached_network_image/cached_network_image.dart';
// // // import 'package:cheerchat/models/app_user.dart';
// // // import 'package:cheerchat/providers/auth_provider.dart';
// // // import 'package:cheerchat/providers/theme_provider.dart';
// // // import 'package:cheerchat/providers/user_provider.dart';
// // // import 'package:cheerchat/providers/wallet_provider.dart';
// // // import 'package:cheerchat/services/api_service.dart';
// // // import 'package:cheerchat/services/auth_service.dart';
// // // import 'package:cheerchat/services/social_service.dart';
// // // import 'package:cheerchat/theme/app_colors.dart';
// // // import 'package:flag/flag_widget.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:image_picker/image_picker.dart';

// // // class ProfileScreen extends ConsumerStatefulWidget {
// // //   const ProfileScreen({super.key});

// // //   @override
// // //   ConsumerState<ProfileScreen> createState() =>
// // //       _ProfileScreenState();
// // // }

// // // class _ProfileScreenState extends ConsumerState<ProfileScreen> {
// // //   bool _isUploadingPhoto = false;
// // //   int _followerCount = 0;
// // //   int _followingCount = 0;
// // //   List<Map<String, dynamic>> _blockedUsers = [];

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadSocialStats();
// // //   }

// // //   Future<void> _loadSocialStats() async {
// // //     try {
// // //       final social = ref.read(socialServiceProvider);
// // //       final followers = await social.getFollowers();
// // //       final following = await social.getFollowing();
// // //       if (mounted) {
// // //         setState(() {
// // //           _followerCount = followers.length;
// // //           _followingCount = following.length;
// // //         });
// // //       }
// // //     } catch (_) {}
// // //   }

// // //   // ── Helpers ───────────────────────────────────────────────────────────────

// // //   void _snack(String msg, {bool isError = false}) {
// // //     if (!mounted) return;
// // //     final c = AppColors.of(context);
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(msg),
// // //         backgroundColor: isError ? Colors.redAccent : c.pink,
// // //         behavior: SnackBarBehavior.floating,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(10),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   void _todo(String feature) => _snack('$feature coming soon!');

// // //   // ── Photo picker ──────────────────────────────────────────────────────────

// // //   Future<void> _pickPhoto() async {
// // //     final picker = ImagePicker();
// // //     final XFile? picked = await picker.pickImage(
// // //       source: ImageSource.gallery,
// // //       imageQuality: 85,
// // //       maxWidth: 800,
// // //     );
// // //     if (picked == null || !mounted) return;
// // //     setState(() => _isUploadingPhoto = true);
// // //     try {
// // //       // TODO: Upload to Firebase Storage → PUT /api/me { profile_photo_url }
// // //       _snack('Photo upload coming soon!');
// // //     } finally {
// // //       if (mounted) setState(() => _isUploadingPhoto = false);
// // //     }
// // //   }

// // //   // ── Edit name ─────────────────────────────────────────────────────────────

// // //   void _editName(String current) {
// // //     final c = AppColors.of(context);
// // //     final ctrl = TextEditingController(text: current);
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: c.card,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //         ),
// // //         title: Text(
// // //           'Edit Name',
// // //           style: GoogleFonts.poppins(
// // //             color: c.textPrimary,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         content: TextField(
// // //           controller: ctrl,
// // //           autofocus: true,
// // //           maxLength: 24,
// // //           style: TextStyle(color: c.textPrimary),
// // //           cursorColor: c.pink,
// // //           decoration: InputDecoration(
// // //             hintText: 'Display name',
// // //             hintStyle: TextStyle(color: c.textSecondary),
// // //             counterStyle: TextStyle(color: c.textSecondary),
// // //             enabledBorder: OutlineInputBorder(
// // //               borderRadius: BorderRadius.circular(10),
// // //               borderSide: BorderSide(color: c.border),
// // //             ),
// // //             focusedBorder: OutlineInputBorder(
// // //               borderRadius: BorderRadius.circular(10),
// // //               borderSide: BorderSide(color: c.pink),
// // //             ),
// // //           ),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: Text(
// // //               'Cancel',
// // //               style: TextStyle(color: c.textSecondary),
// // //             ),
// // //           ),
// // //           TextButton(
// // //             onPressed: () async {
// // //               final newName = ctrl.text.trim();
// // //               if (newName.isEmpty) return;
// // //               Navigator.pop(ctx);
// // //               final api = ref.read(apiServiceProvider);
// // //               final res = await api.put(
// // //                 '/api/me',
// // //                 body: {'display_name': newName},
// // //               );
// // //               if (res.ok) {
// // //                 ref.read(currentUserProvider.notifier).refresh();
// // //                 _snack('Name updated!');
// // //               } else {
// // //                 _snack(
// // //                   res.error ?? 'Could not update name',
// // //                   isError: true,
// // //                 );
// // //               }
// // //             },
// // //             child: Text(
// // //               'Save',
// // //               style: TextStyle(
// // //                 color: c.pink,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Logout ────────────────────────────────────────────────────────────────

// // //   void _confirmLogout() {
// // //     final c = AppColors.of(context);
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: c.card,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //         ),
// // //         title: Text(
// // //           'Log Out?',
// // //           style: GoogleFonts.poppins(
// // //             color: c.textPrimary,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         content: Text(
// // //           'You will need to sign in again.',
// // //           style: TextStyle(color: c.textSecondary),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: Text(
// // //               'Cancel',
// // //               style: TextStyle(color: c.textSecondary),
// // //             ),
// // //           ),
// // //           TextButton(
// // //             onPressed: () async {
// // //               final logoutNotifier = ref.read(
// // //                 isLoggingOutProvider.notifier,
// // //               );
// // //               final userNotifier = ref.read(
// // //                 currentUserProvider.notifier,
// // //               );
// // //               final authSvc = ref.read(authServiceProvider);
// // //               Navigator.pop(ctx);
// // //               logoutNotifier.start();
// // //               userNotifier.clear();
// // //               await authSvc.signOut();
// // //             },
// // //             child: const Text(
// // //               'Log Out',
// // //               style: TextStyle(
// // //                 color: Colors.redAccent,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Delete account ────────────────────────────────────────────────────────

// // //   void _confirmDeleteAccount() {
// // //     final c = AppColors.of(context);
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: c.card,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //         ),
// // //         title: Text(
// // //           'Delete Account?',
// // //           style: GoogleFonts.poppins(
// // //             color: Colors.redAccent,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         content: Text(
// // //           'This is permanent. All your data, coins, and history will be erased and cannot be recovered.',
// // //           style: TextStyle(color: c.textSecondary),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: Text(
// // //               'Cancel',
// // //               style: TextStyle(color: c.textSecondary),
// // //             ),
// // //           ),
// // //           TextButton(
// // //             onPressed: () {
// // //               Navigator.pop(ctx);
// // //               _snack('Delete account coming soon.');
// // //             },
// // //             child: const Text(
// // //               'Delete',
// // //               style: TextStyle(
// // //                 color: Colors.redAccent,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Clear cache dialog ────────────────────────────────────────────────────

// // //   void _showClearCacheDialog() {
// // //     final c = AppColors.of(context);
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: c.card,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //         ),
// // //         title: Text(
// // //           'Clear Cache?',
// // //           style: GoogleFonts.poppins(
// // //             color: c.textPrimary,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         content: Text(
// // //           'Cached images and data will be removed. The app may load slower temporarily.',
// // //           style: TextStyle(color: c.textSecondary),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: Text(
// // //               'Cancel',
// // //               style: TextStyle(color: c.textSecondary),
// // //             ),
// // //           ),
// // //           TextButton(
// // //             onPressed: () {
// // //               Navigator.pop(ctx);
// // //               CachedNetworkImage.evictFromCache('');
// // //               _snack('Cache cleared');
// // //             },
// // //             child: Text(
// // //               'Clear',
// // //               style: TextStyle(
// // //                 color: c.pink,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Help sheet ────────────────────────────────────────────────────────────

// // //   void _showHelpSheet({required bool isHost}) {
// // //     final c = AppColors.of(context);
// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: c.surface,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(
// // //           top: Radius.circular(20),
// // //         ),
// // //       ),
// // //       isScrollControlled: true,
// // //       builder: (ctx) => ConstrainedBox(
// // //         constraints: BoxConstraints(
// // //           maxHeight: MediaQuery.of(ctx).size.height * 0.7,
// // //         ),
// // //         child: Padding(
// // //           padding: EdgeInsets.fromLTRB(
// // //             20,
// // //             16,
// // //             20,
// // //             MediaQuery.of(ctx).padding.bottom + 20,
// // //           ),
// // //           child: SingleChildScrollView(
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Center(
// // //                   child: Container(
// // //                     width: 36,
// // //                     height: 4,
// // //                     decoration: BoxDecoration(
// // //                       color: c.border,
// // //                       borderRadius: BorderRadius.circular(2),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 16),
// // //                 Text(
// // //                   'Help & Support',
// // //                   style: GoogleFonts.poppins(
// // //                     color: c.textPrimary,
// // //                     fontSize: 17,
// // //                     fontWeight: FontWeight.w700,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 4),
// // //                 Text(
// // //                   'How can we help you?',
// // //                   style: TextStyle(
// // //                     color: c.textSecondary,
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //                 _sheetTile(
// // //                   icon: Icons.chat_bubble_outline,
// // //                   label: 'Contact Support',
// // //                   onTap: () {
// // //                     Navigator.pop(ctx);
// // //                     _todo('Customer support');
// // //                   },
// // //                 ),
// // //                 _sheetTile(
// // //                   icon: Icons.quiz_outlined,
// // //                   label: 'FAQ',
// // //                   onTap: () {
// // //                     Navigator.pop(ctx);
// // //                     _todo('FAQ');
// // //                   },
// // //                 ),
// // //                 if (isHost) ...[
// // //                   Padding(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       vertical: 10,
// // //                     ),
// // //                     child: Divider(color: c.divider),
// // //                   ),
// // //                   Text(
// // //                     'For Hosts',
// // //                     style: GoogleFonts.poppins(
// // //                       color: c.pink,
// // //                       fontSize: 12,
// // //                       fontWeight: FontWeight.w600,
// // //                       letterSpacing: 1.1,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 8),
// // //                   _sheetTile(
// // //                     icon: Icons.lightbulb_outline,
// // //                     label: 'Request a Feature',
// // //                     onTap: () {
// // //                       Navigator.pop(ctx);
// // //                       _todo('Feature request');
// // //                     },
// // //                   ),
// // //                   _sheetTile(
// // //                     icon: Icons.feedback_outlined,
// // //                     label: 'Share Feedback',
// // //                     onTap: () {
// // //                       Navigator.pop(ctx);
// // //                       _todo('Feedback form');
// // //                     },
// // //                   ),
// // //                   _sheetTile(
// // //                     icon: Icons.campaign_outlined,
// // //                     label: 'Host Community',
// // //                     onTap: () {
// // //                       Navigator.pop(ctx);
// // //                       _todo('Host forum');
// // //                     },
// // //                   ),
// // //                 ],
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Follow list sheet ─────────────────────────────────────────────────────

// // //   void _showFollowList(String type) async {
// // //     final c = AppColors.of(context);
// // //     final social = ref.read(socialServiceProvider);
// // //     final list = type == 'Followers'
// // //         ? await social.getFollowers()
// // //         : await social.getFollowing();

// // //     if (!mounted) return;

// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: c.surface,
// // //       isScrollControlled: true,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(
// // //           top: Radius.circular(20),
// // //         ),
// // //       ),
// // //       builder: (ctx) => ConstrainedBox(
// // //         constraints: BoxConstraints(
// // //           maxHeight: MediaQuery.of(ctx).size.height * 0.6,
// // //         ),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             const SizedBox(height: 12),
// // //             Container(
// // //               width: 36,
// // //               height: 4,
// // //               decoration: BoxDecoration(
// // //                 color: c.border,
// // //                 borderRadius: BorderRadius.circular(2),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             Text(
// // //               type,
// // //               style: GoogleFonts.poppins(
// // //                 color: c.textPrimary,
// // //                 fontSize: 17,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 12),
// // //             if (list.isEmpty)
// // //               Padding(
// // //                 padding: const EdgeInsets.all(40),
// // //                 child: Text(
// // //                   'No $type yet',
// // //                   style: TextStyle(color: c.textSecondary),
// // //                 ),
// // //               )
// // //             else
// // //               Flexible(
// // //                 child: ListView.builder(
// // //                   shrinkWrap: true,
// // //                   itemCount: list.length,
// // //                   padding: const EdgeInsets.symmetric(
// // //                     horizontal: 16,
// // //                   ),
// // //                   itemBuilder: (_, i) {
// // //                     final user = list[i];
// // //                     return ListTile(
// // //                       leading: CircleAvatar(
// // //                         backgroundColor: c.pink.withOpacity(0.1),
// // //                         backgroundImage:
// // //                             user['profile_photo_url'] != null
// // //                             ? NetworkImage(
// // //                                 user['profile_photo_url'],
// // //                               )
// // //                             : null,
// // //                         child: user['profile_photo_url'] == null
// // //                             ? Icon(
// // //                                 Icons.person,
// // //                                 color: c.pink,
// // //                                 size: 20,
// // //                               )
// // //                             : null,
// // //                       ),
// // //                       title: Text(
// // //                         user['display_name'] ?? 'User',
// // //                         style: TextStyle(
// // //                           color: c.textPrimary,
// // //                           fontWeight: FontWeight.w500,
// // //                         ),
// // //                       ),
// // //                       subtitle: Text(
// // //                         'ID: ${user['public_id'] ?? ''}',
// // //                         style: TextStyle(
// // //                           color: c.textSecondary,
// // //                           fontSize: 11,
// // //                         ),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             SizedBox(
// // //               height: MediaQuery.of(ctx).padding.bottom + 16,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Blocked users sheet ───────────────────────────────────────────────────

// // //   void _showBlockedUsers() async {
// // //     final c = AppColors.of(context);
// // //     final social = ref.read(socialServiceProvider);
// // //     _blockedUsers = await social.getBlocked();

// // //     if (!mounted) return;

// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: c.surface,
// // //       isScrollControlled: true,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(
// // //           top: Radius.circular(20),
// // //         ),
// // //       ),
// // //       builder: (ctx) => StatefulBuilder(
// // //         builder: (ctx, setSheet) => ConstrainedBox(
// // //           constraints: BoxConstraints(
// // //             maxHeight: MediaQuery.of(ctx).size.height * 0.6,
// // //           ),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               const SizedBox(height: 12),
// // //               Container(
// // //                 width: 36,
// // //                 height: 4,
// // //                 decoration: BoxDecoration(
// // //                   color: c.border,
// // //                   borderRadius: BorderRadius.circular(2),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 16),
// // //               Text(
// // //                 'Blocked Users',
// // //                 style: GoogleFonts.poppins(
// // //                   color: c.textPrimary,
// // //                   fontSize: 17,
// // //                   fontWeight: FontWeight.w700,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 12),
// // //               if (_blockedUsers.isEmpty)
// // //                 Padding(
// // //                   padding: const EdgeInsets.all(40),
// // //                   child: Text(
// // //                     'No blocked users',
// // //                     style: TextStyle(color: c.textSecondary),
// // //                   ),
// // //                 )
// // //               else
// // //                 Flexible(
// // //                   child: ListView.builder(
// // //                     shrinkWrap: true,
// // //                     itemCount: _blockedUsers.length,
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 16,
// // //                     ),
// // //                     itemBuilder: (_, i) {
// // //                       final user = _blockedUsers[i];
// // //                       return ListTile(
// // //                         leading: CircleAvatar(
// // //                           backgroundColor: c.pink.withOpacity(
// // //                             0.1,
// // //                           ),
// // //                           backgroundImage:
// // //                               user['profile_photo_url'] != null
// // //                               ? NetworkImage(
// // //                                   user['profile_photo_url'],
// // //                                 )
// // //                               : null,
// // //                           child:
// // //                               user['profile_photo_url'] == null
// // //                               ? Icon(
// // //                                   Icons.person,
// // //                                   color: c.textSecondary,
// // //                                   size: 20,
// // //                                 )
// // //                               : null,
// // //                         ),
// // //                         title: Text(
// // //                           user['display_name'] ?? 'User',
// // //                           style: TextStyle(
// // //                             color: c.textPrimary,
// // //                             fontWeight: FontWeight.w500,
// // //                           ),
// // //                         ),
// // //                         trailing: TextButton(
// // //                           onPressed: () async {
// // //                             final ok = await social.unblock(
// // //                               user['blocked_id'] ?? '',
// // //                             );
// // //                             if (ok) {
// // //                               setSheet(
// // //                                 () => _blockedUsers.removeAt(i),
// // //                               );
// // //                               _snack('Unblocked');
// // //                             }
// // //                           },
// // //                           child: Text(
// // //                             'Unblock',
// // //                             style: TextStyle(
// // //                               color: c.pink,
// // //                               fontSize: 12,
// // //                               fontWeight: FontWeight.w600,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               SizedBox(
// // //                 height: MediaQuery.of(ctx).padding.bottom + 16,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Transaction history sheet ─────────────────────────────────────────────

// // //   void _showTransactionHistory() async {
// // //     final c = AppColors.of(context);
// // //     final api = ref.read(apiServiceProvider);
// // //     final res = await api.get(
// // //       '/api/wallet/ledger',
// // //       query: {'limit': '50'},
// // //     );
// // //     final List<Map<String, dynamic>> ledger = res.ok
// // //         ? (res.data['ledger'] as List)
// // //               .cast<Map<String, dynamic>>()
// // //         : [];

// // //     if (!mounted) return;

// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: c.surface,
// // //       isScrollControlled: true,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(
// // //           top: Radius.circular(20),
// // //         ),
// // //       ),
// // //       builder: (ctx) => ConstrainedBox(
// // //         constraints: BoxConstraints(
// // //           maxHeight: MediaQuery.of(ctx).size.height * 0.75,
// // //         ),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             const SizedBox(height: 12),
// // //             Container(
// // //               width: 36,
// // //               height: 4,
// // //               decoration: BoxDecoration(
// // //                 color: c.border,
// // //                 borderRadius: BorderRadius.circular(2),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             Text(
// // //               'Transaction History',
// // //               style: GoogleFonts.poppins(
// // //                 color: c.textPrimary,
// // //                 fontSize: 17,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 12),
// // //             if (ledger.isEmpty)
// // //               Padding(
// // //                 padding: const EdgeInsets.all(40),
// // //                 child: Text(
// // //                   'No transactions yet',
// // //                   style: TextStyle(color: c.textSecondary),
// // //                 ),
// // //               )
// // //             else
// // //               Flexible(
// // //                 child: ListView.builder(
// // //                   shrinkWrap: true,
// // //                   itemCount: ledger.length,
// // //                   padding: const EdgeInsets.symmetric(
// // //                     horizontal: 16,
// // //                   ),
// // //                   itemBuilder: (_, i) {
// // //                     final txn = ledger[i];
// // //                     final amount =
// // //                         (txn['amount'] as num?)?.toInt() ?? 0;
// // //                     final type = txn['type'] as String? ?? '';
// // //                     final isPositive = amount > 0;
// // //                     final date = DateTime.tryParse(
// // //                       txn['created_at'] ?? '',
// // //                     );
// // //                     final dateStr = date != null
// // //                         ? '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
// // //                         : '';

// // //                     IconData icon;
// // //                     Color iconColor;
// // //                     switch (type) {
// // //                       case 'recharge':
// // //                         icon = Icons.add_circle_outline;
// // //                         iconColor = Colors.green;
// // //                         break;
// // //                       case 'call_spent':
// // //                         icon = Icons.videocam_outlined;
// // //                         iconColor = Colors.orange;
// // //                         break;
// // //                       case 'gift_sent':
// // //                         icon = Icons.card_giftcard;
// // //                         iconColor = Colors.pink;
// // //                         break;
// // //                       case 'gift_received':
// // //                         icon = Icons.card_giftcard;
// // //                         iconColor = Colors.green;
// // //                         break;
// // //                       case 'bonus':
// // //                         icon = Icons.stars_outlined;
// // //                         iconColor = Colors.amber;
// // //                         break;
// // //                       case 'unlock':
// // //                         icon = Icons.lock_open_outlined;
// // //                         iconColor = Colors.blue;
// // //                         break;
// // //                       default:
// // //                         icon = Icons.swap_horiz;
// // //                         iconColor = c.textSecondary;
// // //                     }

// // //                     return ListTile(
// // //                       contentPadding: const EdgeInsets.symmetric(
// // //                         horizontal: 4,
// // //                         vertical: 2,
// // //                       ),
// // //                       leading: Container(
// // //                         width: 38,
// // //                         height: 38,
// // //                         decoration: BoxDecoration(
// // //                           color: iconColor.withOpacity(0.1),
// // //                           borderRadius: BorderRadius.circular(
// // //                             10,
// // //                           ),
// // //                         ),
// // //                         child: Icon(
// // //                           icon,
// // //                           color: iconColor,
// // //                           size: 18,
// // //                         ),
// // //                       ),
// // //                       title: Text(
// // //                         type.replaceAll('_', ' ').toUpperCase(),
// // //                         style: TextStyle(
// // //                           color: c.textPrimary,
// // //                           fontWeight: FontWeight.w500,
// // //                           fontSize: 13,
// // //                         ),
// // //                       ),
// // //                       subtitle: Text(
// // //                         dateStr,
// // //                         style: TextStyle(
// // //                           color: c.textSecondary,
// // //                           fontSize: 10,
// // //                         ),
// // //                       ),
// // //                       trailing: Text(
// // //                         '${isPositive ? '+' : ''}$amount',
// // //                         style: TextStyle(
// // //                           color: isPositive
// // //                               ? Colors.green
// // //                               : Colors.redAccent,
// // //                           fontWeight: FontWeight.bold,
// // //                           fontSize: 15,
// // //                         ),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //             SizedBox(
// // //               height: MediaQuery.of(ctx).padding.bottom + 16,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Top Up sheet ──────────────────────────────────────────────────────────

// // //   void _showTopUpSheet() async {
// // //     final c = AppColors.of(context);
// // //     final api = ref.read(apiServiceProvider);
// // //     final res = await api.get('/api/wallet/packages');
// // //     final List<Map<String, dynamic>> packages = res.ok
// // //         ? (res.data['packages'] as List)
// // //               .cast<Map<String, dynamic>>()
// // //         : [];

// // //     if (!mounted) return;

// // //     final walletState = ref.read(walletBalanceProvider);
// // //     final currentCoins =
// // //         walletState.asData?.value?.coinBalance ?? 0;

// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: Colors.transparent,
// // //       isScrollControlled: true,
// // //       builder: (ctx) => Container(
// // //         constraints: BoxConstraints(
// // //           maxHeight: MediaQuery.of(ctx).size.height * 0.65,
// // //         ),
// // //         decoration: BoxDecoration(
// // //           color: c.surface,
// // //           borderRadius: const BorderRadius.vertical(
// // //             top: Radius.circular(24),
// // //           ),
// // //         ),
// // //         padding: EdgeInsets.fromLTRB(
// // //           20,
// // //           12,
// // //           20,
// // //           MediaQuery.of(ctx).padding.bottom + 20,
// // //         ),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Container(
// // //               width: 36,
// // //               height: 4,
// // //               decoration: BoxDecoration(
// // //                 color: c.border,
// // //                 borderRadius: BorderRadius.circular(2),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             // Balance display
// // //             Container(
// // //               width: double.infinity,
// // //               padding: const EdgeInsets.symmetric(vertical: 16),
// // //               decoration: BoxDecoration(
// // //                 gradient: LinearGradient(
// // //                   colors: [
// // //                     c.pink.withOpacity(0.08),
// // //                     c.gold.withOpacity(0.05),
// // //                   ],
// // //                 ),
// // //                 borderRadius: BorderRadius.circular(14),
// // //                 border: Border.all(
// // //                   color: c.pink.withOpacity(0.15),
// // //                 ),
// // //               ),
// // //               child: Column(
// // //                 children: [
// // //                   Text(
// // //                     'Current Balance',
// // //                     style: TextStyle(
// // //                       color: c.textSecondary,
// // //                       fontSize: 12,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 4),
// // //                   Text(
// // //                     '$currentCoins coins',
// // //                     style: GoogleFonts.poppins(
// // //                       color: c.gold,
// // //                       fontSize: 26,
// // //                       fontWeight: FontWeight.w700,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             Align(
// // //               alignment: Alignment.centerLeft,
// // //               child: Text(
// // //                 'Choose a Package',
// // //                 style: GoogleFonts.poppins(
// // //                   color: c.textPrimary,
// // //                   fontSize: 15,
// // //                   fontWeight: FontWeight.w600,
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 10),
// // //             if (packages.isEmpty)
// // //               Padding(
// // //                 padding: const EdgeInsets.all(20),
// // //                 child: Text(
// // //                   'No packages available',
// // //                   style: TextStyle(color: c.textSecondary),
// // //                 ),
// // //               )
// // //             else
// // //               Flexible(
// // //                 child: ListView.builder(
// // //                   shrinkWrap: true,
// // //                   itemCount: packages.length,
// // //                   itemBuilder: (_, i) {
// // //                     final pkg = packages[i];
// // //                     final coins =
// // //                         (pkg['coins_amount'] as num?)?.toInt() ??
// // //                         0;
// // //                     final price =
// // //                         (pkg['price'] as num?)?.toDouble() ?? 0;
// // //                     final currency =
// // //                         pkg['currency'] as String? ?? 'INR';
// // //                     final name =
// // //                         pkg['name'] as String? ?? '$coins Coins';
// // //                     final isBest =
// // //                         i ==
// // //                         (packages.length ~/
// // //                             2); // middle package is "best value"

// // //                     return Padding(
// // //                       padding: const EdgeInsets.only(bottom: 8),
// // //                       child: InkWell(
// // //                         onTap: () {
// // //                           Navigator.pop(ctx);
// // //                           _snack(
// // //                             'Payment integration coming soon! Package: $name',
// // //                           );
// // //                         },
// // //                         borderRadius: BorderRadius.circular(14),
// // //                         child: Container(
// // //                           padding: const EdgeInsets.symmetric(
// // //                             horizontal: 16,
// // //                             vertical: 14,
// // //                           ),
// // //                           decoration: BoxDecoration(
// // //                             color: isBest
// // //                                 ? c.pink.withOpacity(0.06)
// // //                                 : c.card,
// // //                             borderRadius: BorderRadius.circular(
// // //                               14,
// // //                             ),
// // //                             border: Border.all(
// // //                               color: isBest
// // //                                   ? c.pink.withOpacity(0.3)
// // //                                   : c.border,
// // //                             ),
// // //                           ),
// // //                           child: Row(
// // //                             children: [
// // //                               Container(
// // //                                 width: 40,
// // //                                 height: 40,
// // //                                 decoration: BoxDecoration(
// // //                                   color: c.gold.withOpacity(
// // //                                     0.12,
// // //                                   ),
// // //                                   borderRadius:
// // //                                       BorderRadius.circular(10),
// // //                                 ),
// // //                                 child: const Center(
// // //                                   child: Text(
// // //                                     '💎',
// // //                                     style: TextStyle(
// // //                                       fontSize: 18,
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                               const SizedBox(width: 14),
// // //                               Expanded(
// // //                                 child: Column(
// // //                                   crossAxisAlignment:
// // //                                       CrossAxisAlignment.start,
// // //                                   children: [
// // //                                     Text(
// // //                                       name,
// // //                                       style: TextStyle(
// // //                                         color: c.textPrimary,
// // //                                         fontSize: 14,
// // //                                         fontWeight:
// // //                                             FontWeight.w600,
// // //                                       ),
// // //                                     ),
// // //                                     if (isBest)
// // //                                       Text(
// // //                                         'Best value',
// // //                                         style: TextStyle(
// // //                                           color: c.pink,
// // //                                           fontSize: 10,
// // //                                           fontWeight:
// // //                                               FontWeight.bold,
// // //                                         ),
// // //                                       ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                               Container(
// // //                                 padding:
// // //                                     const EdgeInsets.symmetric(
// // //                                       horizontal: 14,
// // //                                       vertical: 8,
// // //                                     ),
// // //                                 decoration: BoxDecoration(
// // //                                   gradient: LinearGradient(
// // //                                     colors: [
// // //                                       c.pink,
// // //                                       const Color(0xFFFF6B9D),
// // //                                     ],
// // //                                   ),
// // //                                   borderRadius:
// // //                                       BorderRadius.circular(20),
// // //                                 ),
// // //                                 child: Text(
// // //                                   '${currency == 'INR' ? '₹' : '\$'}${price.toStringAsFixed(0)}',
// // //                                   style: const TextStyle(
// // //                                     color: Colors.white,
// // //                                     fontWeight: FontWeight.bold,
// // //                                     fontSize: 13,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Legal info dialog ─────────────────────────────────────────────────────

// // //   void _showLegalPage(String title) {
// // //     final c = AppColors.of(context);
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: c.card,
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //         ),
// // //         title: Text(
// // //           title,
// // //           style: GoogleFonts.poppins(
// // //             color: c.textPrimary,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         content: Text(
// // //           'This content will be available when the app launches. For now, you can contact support for any legal inquiries.',
// // //           style: TextStyle(color: c.textSecondary, fontSize: 13),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: Text(
// // //               'OK',
// // //               style: TextStyle(
// // //                 color: c.pink,
// // //                 fontWeight: FontWeight.w600,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ═══════════════════════════════════════════════════════════════════════════
// // //   // BUILD
// // //   // ═══════════════════════════════════════════════════════════════════════════

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final asyncUser = ref.watch(currentUserProvider);
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     return AnnotatedRegion<SystemUiOverlayStyle>(
// // //       value: isDark
// // //           ? SystemUiOverlayStyle.light
// // //           : SystemUiOverlayStyle.dark,
// // //       child: Scaffold(
// // //         backgroundColor: c.bg,
// // //         body: asyncUser.when(
// // //           loading: () => Center(
// // //             child: CircularProgressIndicator(color: c.pink),
// // //           ),
// // //           error: (e, _) => Center(
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 const Icon(
// // //                   Icons.error_outline,
// // //                   color: Colors.redAccent,
// // //                   size: 48,
// // //                 ),
// // //                 const SizedBox(height: 12),
// // //                 Text(
// // //                   'Could not load profile',
// // //                   style: TextStyle(color: c.textSecondary),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 TextButton(
// // //                   onPressed: () => ref
// // //                       .read(currentUserProvider.notifier)
// // //                       .refresh(),
// // //                   child: Text(
// // //                     'Retry',
// // //                     style: TextStyle(color: c.pink),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           data: (user) => _buildBody(user),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Body ──────────────────────────────────────────────────────────────────

// // //   Widget _buildBody(AppUser? user) {
// // //     final coins = user?.coins ?? 0;
// // //     final level = user?.level ?? 1;
// // //     final levelLabel = user?.levelLabel ?? 'Newcomer';
// // //     final publicId = user?.publicId;
// // //     final countryCode = user?.countryCode ?? 'IN';
// // //     final language = user?.language ?? '';
// // //     final photoUrl = user?.profilePhotoUrl;
// // //     final age = user?.age;
// // //     final isHost = user?.isHost ?? false;
// // //     final name = user?.displayName ?? 'Guest';

// // //     final themeMode = ref.watch(themeModeProvider);
// // //     final isDark =
// // //         themeMode == ThemeMode.dark ||
// // //         (themeMode == ThemeMode.system &&
// // //             MediaQuery.of(context).platformBrightness ==
// // //                 Brightness.dark);

// // //     // Adaptive sizing
// // //     final mq = MediaQuery.of(context);
// // //     final sw = mq.size.width;
// // //     final sh = mq.size.height;
// // //     final hPad = (sw * 0.04).clamp(12.0, 20.0);

// // //     return CustomScrollView(
// // //       physics: const BouncingScrollPhysics(),
// // //       slivers: [
// // //         SliverToBoxAdapter(
// // //           child: _buildHeader(
// // //             name,
// // //             photoUrl,
// // //             level,
// // //             levelLabel,
// // //             publicId,
// // //             countryCode,
// // //             age,
// // //             sw,
// // //             sh,
// // //           ),
// // //         ),
// // //         SliverPadding(
// // //           padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
// // //           sliver: SliverList(
// // //             delegate: SliverChildListDelegate([
// // //               _buildSocialStats(),
// // //               const SizedBox(height: 12),
// // //               _buildCoinsCard(coins),

// // //               if (isHost) ...[
// // //                 const SizedBox(height: 12),
// // //                 _buildHostEarningsCard(),
// // //               ],

// // //               const SizedBox(height: 20),
// // //               _sectionLabel('Discover'),
// // //               _tileGroup([
// // //                 if (!isHost)
// // //                   _tile(
// // //                     icon: FontAwesomeIcons.star,
// // //                     iconColor: const Color(0xFFFFCA28),
// // //                     label: 'Become a Host',
// // //                     badge: 'Apply',
// // //                     onTap: () => _todo('Host application'),
// // //                   ),
// // //                 _tile(
// // //                   icon: FontAwesomeIcons.userGroup,
// // //                   iconColor: const Color(0xFF42A5F5),
// // //                   label: 'Invite Friends',
// // //                   subtitle: 'Earn coins per referral',
// // //                   onTap: () => _todo('Referrals'),
// // //                 ),
// // //               ]),

// // //               const SizedBox(height: 20),
// // //               _sectionLabel('Preferences'),
// // //               _tileGroup([
// // //                 _tile(
// // //                   icon: isDark
// // //                       ? Icons.dark_mode_outlined
// // //                       : Icons.light_mode_outlined,
// // //                   iconColor: isDark
// // //                       ? const Color(0xFF7C4DFF)
// // //                       : const Color(0xFFFFB300),
// // //                   label: 'Appearance',
// // //                   subtitle: isDark ? 'Dark mode' : 'Light mode',
// // //                   trailing: _themeToggle(isDark),
// // //                   onTap: () => ref
// // //                       .read(themeModeProvider.notifier)
// // //                       .toggle(),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.language_outlined,
// // //                   label: 'App Language',
// // //                   subtitle: language.isNotEmpty
// // //                       ? language
// // //                       : 'English',
// // //                   onTap: () => _todo('Language picker'),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.notifications_outlined,
// // //                   label: 'Notification Settings',
// // //                   onTap: () => _todo('Notification settings'),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.auto_fix_high_outlined,
// // //                   iconColor: const Color(0xFFCE93D8),
// // //                   label: 'Camera Beauty',
// // //                   onTap: () => _todo('Beauty settings'),
// // //                 ),
// // //               ]),

// // //               const SizedBox(height: 20),
// // //               _sectionLabel('Storage & Updates'),
// // //               _tileGroup([
// // //                 _tile(
// // //                   icon: Icons.cleaning_services_outlined,
// // //                   label: 'Clear Cache',
// // //                   onTap: _showClearCacheDialog,
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.system_update_outlined,
// // //                   iconColor: const Color(0xFF4CAF50),
// // //                   label: 'Check for Updates',
// // //                   onTap: () => _todo('Update check'),
// // //                 ),
// // //               ]),

// // //               const SizedBox(height: 20),
// // //               _sectionLabel('Legal & Info'),
// // //               _tileGroup([
// // //                 _tile(
// // //                   icon: Icons.shield_outlined,
// // //                   label: 'Privacy Policy',
// // //                   onTap: () => _showLegalPage('Privacy Policy'),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.description_outlined,
// // //                   label: 'Terms of Service',
// // //                   onTap: () =>
// // //                       _showLegalPage('Terms of Service'),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.info_outline,
// // //                   label: 'About Us',
// // //                   onTap: () => _showLegalPage('About Us'),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.star_border_outlined,
// // //                   iconColor: const Color(0xFFFFCA28),
// // //                   label: 'Rate Our App',
// // //                   onTap: () =>
// // //                       _snack('Play Store rating coming soon!'),
// // //                 ),
// // //               ]),

// // //               const SizedBox(height: 20),
// // //               _sectionLabel('Support'),
// // //               _tileGroup([
// // //                 _tile(
// // //                   icon: Icons.headset_mic_outlined,
// // //                   label: 'Help & Support',
// // //                   subtitle: isHost
// // //                       ? 'Support · Feature requests · Feedback'
// // //                       : null,
// // //                   onTap: () => _showHelpSheet(isHost: isHost),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.bug_report_outlined,
// // //                   label: 'Report a Bug',
// // //                   onTap: () => _todo('Bug report'),
// // //                 ),
// // //               ]),

// // //               const SizedBox(height: 20),
// // //               _sectionLabel('Account'),
// // //               _tileGroup([
// // //                 _tile(
// // //                   icon: Icons.link_outlined,
// // //                   label: 'Bind Accounts',
// // //                   subtitle: 'Google · Phone · Apple',
// // //                   onTap: () => _todo('Bind accounts'),
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.block_outlined,
// // //                   label: 'Blocked Users',
// // //                   onTap: _showBlockedUsers,
// // //                 ),
// // //                 _tile(
// // //                   icon: Icons.receipt_long_outlined,
// // //                   label: 'Transaction History',
// // //                   onTap: _showTransactionHistory,
// // //                 ),
// // //                 _tile(
// // //                   icon: FontAwesomeIcons.trash,
// // //                   iconSize: 16,
// // //                   iconColor: Colors.redAccent,
// // //                   label: 'Delete Account',
// // //                   labelColor: Colors.redAccent,
// // //                   onTap: _confirmDeleteAccount,
// // //                 ),
// // //               ]),

// // //               const SizedBox(height: 20),
// // //               _logoutButton(),
// // //               SizedBox(height: mq.padding.bottom + 32),
// // //             ]),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ── Header (adaptive) ─────────────────────────────────────────────────────

// // //   Widget _buildHeader(
// // //     String name,
// // //     String? photoUrl,
// // //     int level,
// // //     String levelLabel,
// // //     int? publicId,
// // //     String countryCode,
// // //     int? age,
// // //     double sw,
// // //     double sh,
// // //   ) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;

// // //     // Proportional sizes
// // //     final headerH = (sh * 0.28).clamp(200.0, 280.0);
// // //     final avatarSize = (sw * 0.2).clamp(64.0, 96.0);
// // //     final cameraBadge = (avatarSize * 0.3).clamp(20.0, 28.0);
// // //     final titleSize = (sw * 0.055).clamp(18.0, 24.0);
// // //     final nameSize = (sw * 0.05).clamp(16.0, 22.0);
// // //     final hPad = (sw * 0.04).clamp(12.0, 20.0);

// // //     return Stack(
// // //       children: [
// // //         Container(
// // //           height: headerH,
// // //           decoration: BoxDecoration(
// // //             gradient: LinearGradient(
// // //               begin: Alignment.topCenter,
// // //               end: Alignment.bottomCenter,
// // //               colors: isDark
// // //                   ? [
// // //                       const Color(0xFF2D0A1F),
// // //                       const Color(0xFF0D0D0D),
// // //                     ]
// // //                   : [const Color(0xFFFFE4F0), c.bg],
// // //             ),
// // //           ),
// // //         ),
// // //         // Radial glow — proportional to screen width
// // //         Positioned(
// // //           top: -sw * 0.1,
// // //           left: 0,
// // //           right: 0,
// // //           child: Center(
// // //             child: Container(
// // //               width: sw * 0.85,
// // //               height: sw * 0.55,
// // //               decoration: BoxDecoration(
// // //                 shape: BoxShape.circle,
// // //                 gradient: RadialGradient(
// // //                   colors: [
// // //                     c.pink.withOpacity(0.10),
// // //                     Colors.transparent,
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //         SafeArea(
// // //           bottom: false,
// // //           child: Padding(
// // //             padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   'Profile',
// // //                   style: GoogleFonts.poppins(
// // //                     color: c.textPrimary,
// // //                     fontSize: titleSize,
// // //                     fontWeight: FontWeight.w700,
// // //                   ),
// // //                 ),
// // //                 SizedBox(height: sh * 0.018),
// // //                 Row(
// // //                   crossAxisAlignment: CrossAxisAlignment.center,
// // //                   children: [
// // //                     // Avatar
// // //                     _avatar(photoUrl, avatarSize, cameraBadge),
// // //                     SizedBox(width: sw * 0.04),
// // //                     Expanded(
// // //                       child: Column(
// // //                         crossAxisAlignment:
// // //                             CrossAxisAlignment.start,
// // //                         children: [
// // //                           // Name + edit
// // //                           Row(
// // //                             children: [
// // //                               Flexible(
// // //                                 child: Text(
// // //                                   name,
// // //                                   style: GoogleFonts.poppins(
// // //                                     color: c.textPrimary,
// // //                                     fontSize: nameSize,
// // //                                     fontWeight: FontWeight.w700,
// // //                                   ),
// // //                                   overflow:
// // //                                       TextOverflow.ellipsis,
// // //                                 ),
// // //                               ),
// // //                               const SizedBox(width: 6),
// // //                               GestureDetector(
// // //                                 onTap: () => _editName(name),
// // //                                 child: Container(
// // //                                   padding: const EdgeInsets.all(
// // //                                     5,
// // //                                   ),
// // //                                   decoration: BoxDecoration(
// // //                                     color: c.pink.withOpacity(
// // //                                       0.12,
// // //                                     ),
// // //                                     shape: BoxShape.circle,
// // //                                   ),
// // //                                   child: Icon(
// // //                                     Icons.edit,
// // //                                     size: (nameSize * 0.6).clamp(
// // //                                       11.0,
// // //                                       15.0,
// // //                                     ),
// // //                                     color: c.pink,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           const SizedBox(height: 6),
// // //                           // Meta pills — Wrap handles overflow automatically
// // //                           Wrap(
// // //                             spacing: 6,
// // //                             runSpacing: 4,
// // //                             crossAxisAlignment:
// // //                                 WrapCrossAlignment.center,
// // //                             children: [
// // //                               if (age != null)
// // //                                 _metaPill(
// // //                                   '$age yrs',
// // //                                   Icons.cake_outlined,
// // //                                   const Color(0xFFFF8A65),
// // //                                 ),
// // //                               Row(
// // //                                 mainAxisSize: MainAxisSize.min,
// // //                                 children: [
// // //                                   ClipRRect(
// // //                                     borderRadius:
// // //                                         BorderRadius.circular(3),
// // //                                     child: Flag.fromString(
// // //                                       countryCode,
// // //                                       width: 22,
// // //                                       height: 15,
// // //                                       fit: BoxFit.cover,
// // //                                     ),
// // //                                   ),
// // //                                   const SizedBox(width: 4),
// // //                                   Text(
// // //                                     countryCode,
// // //                                     style: TextStyle(
// // //                                       color: c.textSecondary,
// // //                                       fontSize: 11,
// // //                                     ),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                               _metaPill(
// // //                                 'Lv.$level $levelLabel',
// // //                                 Icons.bolt,
// // //                                 c.pink,
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           const SizedBox(height: 6),
// // //                           if (publicId != null)
// // //                             GestureDetector(
// // //                               onTap: () {
// // //                                 Clipboard.setData(
// // //                                   ClipboardData(
// // //                                     text: '$publicId',
// // //                                   ),
// // //                                 );
// // //                                 _snack('ID copied!');
// // //                               },
// // //                               child: Row(
// // //                                 mainAxisSize: MainAxisSize.min,
// // //                                 children: [
// // //                                   Text(
// // //                                     'ID: $publicId',
// // //                                     style: TextStyle(
// // //                                       color: c.textSecondary,
// // //                                       fontSize: 11,
// // //                                     ),
// // //                                   ),
// // //                                   const SizedBox(width: 4),
// // //                                   Icon(
// // //                                     Icons.copy,
// // //                                     size: 10,
// // //                                     color: c.textSecondary,
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ── Avatar (adaptive) ─────────────────────────────────────────────────────

// // //   Widget _avatar(
// // //     String? photoUrl,
// // //     double size,
// // //     double badgeSize,
// // //   ) {
// // //     final c = AppColors.of(context);
// // //     return GestureDetector(
// // //       onTap: _pickPhoto,
// // //       child: Stack(
// // //         children: [
// // //           Container(
// // //             width: size,
// // //             height: size,
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               border: Border.all(color: c.pink, width: 2.5),
// // //             ),
// // //             child: ClipOval(
// // //               child: _isUploadingPhoto
// // //                   ? Container(
// // //                       color: c.surface,
// // //                       child: Center(
// // //                         child: CircularProgressIndicator(
// // //                           color: c.pink,
// // //                           strokeWidth: 2,
// // //                         ),
// // //                       ),
// // //                     )
// // //                   : photoUrl != null
// // //                   ? CachedNetworkImage(
// // //                       imageUrl: photoUrl,
// // //                       fit: BoxFit.cover,
// // //                       placeholder: (_, __) =>
// // //                           Container(color: c.surface),
// // //                       errorWidget: (_, __, ___) =>
// // //                           _avatarFallback(size),
// // //                     )
// // //                   : _avatarFallback(size),
// // //             ),
// // //           ),
// // //           Positioned(
// // //             bottom: 0,
// // //             right: 0,
// // //             child: Container(
// // //               width: badgeSize,
// // //               height: badgeSize,
// // //               decoration: BoxDecoration(
// // //                 color: c.pink,
// // //                 shape: BoxShape.circle,
// // //                 border: Border.all(color: c.bg, width: 2),
// // //               ),
// // //               child: Icon(
// // //                 Icons.camera_alt,
// // //                 size: badgeSize * 0.5,
// // //                 color: Colors.white,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _avatarFallback(double size) {
// // //     final c = AppColors.of(context);
// // //     return Container(
// // //       color: c.avatarFallback,
// // //       child: Icon(
// // //         Icons.person,
// // //         color: c.avatarIcon,
// // //         size: size * 0.5,
// // //       ),
// // //     );
// // //   }

// // //   Widget _metaPill(String label, IconData icon, Color color) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(
// // //         horizontal: 7,
// // //         vertical: 3,
// // //       ),
// // //       decoration: BoxDecoration(
// // //         color: color.withOpacity(0.12),
// // //         borderRadius: BorderRadius.circular(20),
// // //         border: Border.all(color: color.withOpacity(0.3)),
// // //       ),
// // //       child: Row(
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           Icon(icon, size: 11, color: color),
// // //           const SizedBox(width: 3),
// // //           Text(
// // //             label,
// // //             style: GoogleFonts.poppins(
// // //               color: color,
// // //               fontSize: 10,
// // //               fontWeight: FontWeight.w600,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Social stats ──────────────────────────────────────────────────────────

// // //   Widget _buildSocialStats() {
// // //     final c = AppColors.of(context);

// // //     return Material(
// // //       color: c.surface,
// // //       borderRadius: BorderRadius.circular(16),
// // //       clipBehavior: Clip.hardEdge,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(16),
// // //           border: Border.all(color: c.divider),
// // //         ),
// // //         child: IntrinsicHeight(
// // //           child: Row(
// // //             children: [
// // //               _socialStat(
// // //                 _followerCount,
// // //                 'Followers',
// // //                 onTap: () => _showFollowList('Followers'),
// // //               ),
// // //               VerticalDivider(width: 1, color: c.divider),
// // //               _socialStat(
// // //                 _followingCount,
// // //                 'Following',
// // //                 onTap: () => _showFollowList('Following'),
// // //               ),
// // //               VerticalDivider(width: 1, color: c.divider),
// // //               _socialStat(
// // //                 0,
// // //                 'Mutuals',
// // //                 onTap: () => _snack('Mutuals coming soon!'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _socialStat(
// // //     int count,
// // //     String label, {
// // //     required VoidCallback onTap,
// // //   }) {
// // //     final c = AppColors.of(context);
// // //     final sw = MediaQuery.of(context).size.width;
// // //     final fontSize = (sw * 0.045).clamp(14.0, 20.0);

// // //     return Expanded(
// // //       child: InkWell(
// // //         onTap: onTap,
// // //         child: Padding(
// // //           padding: const EdgeInsets.symmetric(vertical: 14),
// // //           child: Column(
// // //             children: [
// // //               Text(
// // //                 _formatCount(count),
// // //                 style: GoogleFonts.poppins(
// // //                   color: c.textPrimary,
// // //                   fontSize: fontSize,
// // //                   fontWeight: FontWeight.w700,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 2),
// // //               Text(
// // //                 label,
// // //                 style: TextStyle(
// // //                   color: c.textSecondary,
// // //                   fontSize: 11,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   String _formatCount(int n) {
// // //     if (n >= 1000000)
// // //       return '${(n / 1000000).toStringAsFixed(1)}M';
// // //     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
// // //     return '$n';
// // //   }

// // //   // ── Coins card ────────────────────────────────────────────────────────────

// // //   Widget _buildCoinsCard(int coins) {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;
// // //     final sw = MediaQuery.of(context).size.width;
// // //     final iconBox = (sw * 0.12).clamp(38.0, 50.0);
// // //     final coinFontSize = (sw * 0.05).clamp(16.0, 22.0);

// // //     return Container(
// // //       padding: EdgeInsets.all((sw * 0.045).clamp(14.0, 20.0)),
// // //       decoration: BoxDecoration(
// // //         borderRadius: BorderRadius.circular(18),
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topLeft,
// // //           end: Alignment.bottomRight,
// // //           colors: isDark
// // //               ? [
// // //                   const Color(0xFF1A0D12),
// // //                   const Color(0xFF221228),
// // //                 ]
// // //               : [
// // //                   const Color(0xFFFFF0F7),
// // //                   const Color(0xFFFFE4EF),
// // //                 ],
// // //         ),
// // //         border: Border.all(color: c.pink.withOpacity(0.2)),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: c.pink.withOpacity(0.08),
// // //             blurRadius: 20,
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Container(
// // //             width: iconBox,
// // //             height: iconBox,
// // //             decoration: BoxDecoration(
// // //               color: c.gold.withOpacity(0.15),
// // //               borderRadius: BorderRadius.circular(13),
// // //             ),
// // //             child: Center(
// // //               child: Text(
// // //                 '💎',
// // //                 style: TextStyle(fontSize: iconBox * 0.48),
// // //               ),
// // //             ),
// // //           ),
// // //           SizedBox(width: sw * 0.035),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   'My Balance',
// // //                   style: TextStyle(
// // //                     color: c.textSecondary,
// // //                     fontSize: 11,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 2),
// // //                 Text(
// // //                   '$coins coins',
// // //                   style: GoogleFonts.poppins(
// // //                     color: c.gold,
// // //                     fontSize: coinFontSize,
// // //                     fontWeight: FontWeight.w700,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           GestureDetector(
// // //             onTap: _showTopUpSheet,
// // //             child: Container(
// // //               padding: EdgeInsets.symmetric(
// // //                 horizontal: sw * 0.04,
// // //                 vertical: 9,
// // //               ),
// // //               decoration: BoxDecoration(
// // //                 gradient: LinearGradient(
// // //                   colors: [c.pink, const Color(0xFFFF6B9D)],
// // //                 ),
// // //                 borderRadius: BorderRadius.circular(30),
// // //                 boxShadow: [
// // //                   BoxShadow(
// // //                     color: c.pink.withOpacity(0.35),
// // //                     blurRadius: 10,
// // //                     offset: const Offset(0, 4),
// // //                   ),
// // //                 ],
// // //               ),
// // //               child: Text(
// // //                 'Top Up',
// // //                 style: GoogleFonts.poppins(
// // //                   color: Colors.white,
// // //                   fontSize: 13,
// // //                   fontWeight: FontWeight.w600,
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Host earnings card ────────────────────────────────────────────────────

// // //   Widget _buildHostEarningsCard() {
// // //     final c = AppColors.of(context);
// // //     final isDark =
// // //         Theme.of(context).brightness == Brightness.dark;
// // //     final sw = MediaQuery.of(context).size.width;
// // //     final pad = (sw * 0.045).clamp(14.0, 20.0);

// // //     return Container(
// // //       padding: EdgeInsets.all(pad),
// // //       decoration: BoxDecoration(
// // //         borderRadius: BorderRadius.circular(18),
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topLeft,
// // //           end: Alignment.bottomRight,
// // //           colors: isDark
// // //               ? [
// // //                   const Color(0xFF0D1A0D),
// // //                   const Color(0xFF122212),
// // //                 ]
// // //               : [
// // //                   const Color(0xFFF0FFF0),
// // //                   const Color(0xFFE8F5E9),
// // //                 ],
// // //         ),
// // //         border: Border.all(color: c.green.withOpacity(0.25)),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: c.green.withOpacity(0.06),
// // //             blurRadius: 20,
// // //           ),
// // //         ],
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Row(
// // //             children: [
// // //               Container(
// // //                 width: 36,
// // //                 height: 36,
// // //                 decoration: BoxDecoration(
// // //                   color: c.green.withOpacity(0.12),
// // //                   borderRadius: BorderRadius.circular(10),
// // //                 ),
// // //                 child: Icon(
// // //                   Icons.trending_up,
// // //                   color: c.green,
// // //                   size: 18,
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 10),
// // //               Expanded(
// // //                 child: Text(
// // //                   'Host Earnings',
// // //                   style: GoogleFonts.poppins(
// // //                     color: c.textPrimary,
// // //                     fontSize: 15,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               ),
// // //               Text(
// // //                 'This month',
// // //                 style: TextStyle(
// // //                   color: c.textSecondary,
// // //                   fontSize: 11,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 14),
// // //           Row(
// // //             children: [
// // //               _earningsStat('₹ 0', 'Available', c),
// // //               const SizedBox(width: 16),
// // //               _earningsStat('₹ 0', 'Withdrawn', c),
// // //               const SizedBox(width: 16),
// // //               _earningsStat('0', 'Call Mins', c),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 14),
// // //           Row(
// // //             children: [
// // //               Expanded(
// // //                 child: _outlineButton(
// // //                   label: 'Bind Bank / UPI',
// // //                   icon: Icons.account_balance_outlined,
// // //                   color: c.textSecondary,
// // //                   onTap: () => _todo('Bind bank account'),
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 10),
// // //               Expanded(
// // //                 child: _outlineButton(
// // //                   label: 'Withdraw',
// // //                   icon: Icons.arrow_circle_down_outlined,
// // //                   color: c.green,
// // //                   onTap: () => _todo('Withdraw earnings'),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _earningsStat(String value, String label, AppColors c) {
// // //     return Expanded(
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Text(
// // //             value,
// // //             style: GoogleFonts.poppins(
// // //               color: c.green,
// // //               fontSize: 16,
// // //               fontWeight: FontWeight.w700,
// // //             ),
// // //           ),
// // //           Text(
// // //             label,
// // //             style: TextStyle(
// // //               color: c.textSecondary,
// // //               fontSize: 10,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _outlineButton({
// // //     required String label,
// // //     required IconData icon,
// // //     required Color color,
// // //     required VoidCallback onTap,
// // //   }) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: Container(
// // //         padding: const EdgeInsets.symmetric(vertical: 9),
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(10),
// // //           border: Border.all(color: color.withOpacity(0.4)),
// // //         ),
// // //         child: Row(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Icon(icon, size: 14, color: color),
// // //             const SizedBox(width: 5),
// // //             Flexible(
// // //               child: Text(
// // //                 label,
// // //                 style: TextStyle(
// // //                   color: color,
// // //                   fontSize: 12,
// // //                   fontWeight: FontWeight.w600,
// // //                 ),
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Sheet tile ────────────────────────────────────────────────────────────

// // //   Widget _sheetTile({
// // //     required IconData icon,
// // //     required String label,
// // //     required VoidCallback onTap,
// // //     String? subtitle,
// // //   }) {
// // //     final c = AppColors.of(context);
// // //     return ListTile(
// // //       contentPadding: EdgeInsets.zero,
// // //       leading: Container(
// // //         width: 38,
// // //         height: 38,
// // //         decoration: BoxDecoration(
// // //           color: c.pink.withOpacity(0.10),
// // //           borderRadius: BorderRadius.circular(10),
// // //         ),
// // //         child: Icon(icon, size: 18, color: c.pink),
// // //       ),
// // //       title: Text(
// // //         label,
// // //         style: TextStyle(
// // //           color: c.textPrimary,
// // //           fontWeight: FontWeight.w500,
// // //           fontSize: 14,
// // //         ),
// // //       ),
// // //       subtitle: subtitle != null
// // //           ? Text(
// // //               subtitle,
// // //               style: TextStyle(
// // //                 color: c.textSecondary,
// // //                 fontSize: 11,
// // //               ),
// // //             )
// // //           : null,
// // //       trailing: Icon(
// // //         Icons.arrow_forward_ios,
// // //         size: 12,
// // //         color: c.textSecondary,
// // //       ),
// // //       onTap: onTap,
// // //     );
// // //   }

// // //   // ── Logout ────────────────────────────────────────────────────────────────

// // //   Widget _logoutButton() {
// // //     return GestureDetector(
// // //       onTap: _confirmLogout,
// // //       child: Container(
// // //         width: double.infinity,
// // //         padding: const EdgeInsets.symmetric(vertical: 14),
// // //         decoration: BoxDecoration(
// // //           color: Colors.redAccent.withOpacity(0.08),
// // //           borderRadius: BorderRadius.circular(14),
// // //           border: Border.all(
// // //             color: Colors.redAccent.withOpacity(0.25),
// // //           ),
// // //         ),
// // //         child: Row(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             const Icon(
// // //               Icons.logout,
// // //               color: Colors.redAccent,
// // //               size: 18,
// // //             ),
// // //             const SizedBox(width: 8),
// // //             Text(
// // //               'Log Out',
// // //               style: GoogleFonts.poppins(
// // //                 color: Colors.redAccent,
// // //                 fontWeight: FontWeight.w600,
// // //                 fontSize: 14,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Tile components ───────────────────────────────────────────────────────

// // //   Widget _sectionLabel(String label) {
// // //     final c = AppColors.of(context);
// // //     return Padding(
// // //       padding: const EdgeInsets.only(bottom: 8, left: 2),
// // //       child: Text(
// // //         label.toUpperCase(),
// // //         style: GoogleFonts.poppins(
// // //           color: c.textSecondary,
// // //           fontSize: 11,
// // //           fontWeight: FontWeight.w600,
// // //           letterSpacing: 1.2,
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _tileGroup(List<Widget?> tiles) {
// // //     final c = AppColors.of(context);
// // //     final visible = tiles.whereType<Widget>().toList();
// // //     if (visible.isEmpty) return const SizedBox.shrink();
// // //     return Material(
// // //       color: c.surface,
// // //       borderRadius: BorderRadius.circular(16),
// // //       clipBehavior: Clip.hardEdge,
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(16),
// // //           border: Border.all(color: c.divider),
// // //         ),
// // //         child: Column(
// // //           children: [
// // //             for (int i = 0; i < visible.length; i++) ...[
// // //               visible[i],
// // //               if (i < visible.length - 1)
// // //                 Divider(height: 1, color: c.divider, indent: 54),
// // //             ],
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget? _tile({
// // //     required IconData icon,
// // //     required String label,
// // //     required VoidCallback onTap,
// // //     double iconSize = 19,
// // //     Color? iconColor,
// // //     Color? labelColor,
// // //     String? subtitle,
// // //     String? badge,
// // //     Widget? trailing,
// // //   }) {
// // //     final c = AppColors.of(context);
// // //     final effectiveIconColor = iconColor ?? c.textSecondary;
// // //     final effectiveLabelColor = labelColor ?? c.textPrimary;

// // //     return ListTile(
// // //       onTap: onTap,
// // //       contentPadding: const EdgeInsets.symmetric(
// // //         horizontal: 14,
// // //         vertical: 2,
// // //       ),
// // //       leading: Container(
// // //         width: 36,
// // //         height: 36,
// // //         decoration: BoxDecoration(
// // //           color: effectiveIconColor.withOpacity(0.10),
// // //           borderRadius: BorderRadius.circular(10),
// // //         ),
// // //         child: Icon(
// // //           icon,
// // //           size: iconSize,
// // //           color: effectiveIconColor,
// // //         ),
// // //       ),
// // //       title: Text(
// // //         label,
// // //         style: TextStyle(
// // //           color: effectiveLabelColor,
// // //           fontWeight: FontWeight.w500,
// // //           fontSize: 14,
// // //         ),
// // //       ),
// // //       subtitle: subtitle != null
// // //           ? Text(
// // //               subtitle,
// // //               style: TextStyle(
// // //                 color: c.textSecondary,
// // //                 fontSize: 11,
// // //               ),
// // //             )
// // //           : null,
// // //       trailing:
// // //           trailing ??
// // //           (badge != null
// // //               ? Container(
// // //                   padding: const EdgeInsets.symmetric(
// // //                     horizontal: 8,
// // //                     vertical: 3,
// // //                   ),
// // //                   decoration: BoxDecoration(
// // //                     color: c.pink.withOpacity(0.15),
// // //                     borderRadius: BorderRadius.circular(20),
// // //                   ),
// // //                   child: Text(
// // //                     badge,
// // //                     style: TextStyle(
// // //                       color: c.pink,
// // //                       fontSize: 10,
// // //                       fontWeight: FontWeight.w700,
// // //                     ),
// // //                   ),
// // //                 )
// // //               : Icon(
// // //                   Icons.arrow_forward_ios,
// // //                   size: 13,
// // //                   color: c.textSecondary.withOpacity(0.5),
// // //                 )),
// // //     );
// // //   }

// // //   // ── Theme toggle ──────────────────────────────────────────────────────────

// // //   Widget _themeToggle(bool isDark) {
// // //     return GestureDetector(
// // //       onTap: () => ref.read(themeModeProvider.notifier).toggle(),
// // //       child: AnimatedContainer(
// // //         duration: const Duration(milliseconds: 250),
// // //         curve: Curves.easeInOut,
// // //         width: 52,
// // //         height: 28,
// // //         decoration: BoxDecoration(
// // //           gradient: isDark
// // //               ? const LinearGradient(
// // //                   colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
// // //                 )
// // //               : const LinearGradient(
// // //                   colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
// // //                 ),
// // //           borderRadius: BorderRadius.circular(14),
// // //         ),
// // //         child: AnimatedAlign(
// // //           duration: const Duration(milliseconds: 250),
// // //           curve: Curves.easeInOut,
// // //           alignment: isDark
// // //               ? Alignment.centerRight
// // //               : Alignment.centerLeft,
// // //           child: Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 3),
// // //             child: Container(
// // //               width: 22,
// // //               height: 22,
// // //               decoration: const BoxDecoration(
// // //                 color: Colors.white,
// // //                 shape: BoxShape.circle,
// // //               ),
// // //               child: Icon(
// // //                 isDark ? Icons.dark_mode : Icons.light_mode,
// // //                 size: 13,
// // //                 color: isDark
// // //                     ? const Color(0xFF7C4DFF)
// // //                     : const Color(0xFFFFB300),
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // // lib/screens/profile_screen.dart
// // //
// // // User's own profile — settings, wallet, host earnings, preferences.
// // // Fully adaptive to all screen sizes.

// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flag/flag_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // import 'package:cheerchat/services/api_service.dart';
// // import 'package:cheerchat/services/auth_service.dart';
// // import 'package:cheerchat/services/social_service.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_picker/image_picker.dart';

// // import 'package:cheerchat/models/app_user.dart';
// // import 'package:cheerchat/providers/theme_provider.dart';
// // import 'package:cheerchat/providers/auth_provider.dart';
// // import 'package:cheerchat/providers/user_provider.dart';
// // import 'package:cheerchat/providers/wallet_provider.dart';
// // import 'package:cheerchat/theme/app_colors.dart';

// // class ProfileScreen extends ConsumerStatefulWidget {
// //   const ProfileScreen({super.key});

// //   @override
// //   ConsumerState<ProfileScreen> createState() =>
// //       _ProfileScreenState();
// // }

// // class _ProfileScreenState extends ConsumerState<ProfileScreen> {
// //   bool _isUploadingPhoto = false;
// //   int _followerCount = 0;
// //   int _followingCount = 0;
// //   List<Map<String, dynamic>> _blockedUsers = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSocialStats();
// //   }

// //   Future<void> _loadSocialStats() async {
// //     try {
// //       final social = ref.read(socialServiceProvider);
// //       final followers = await social.getFollowers();
// //       final following = await social.getFollowing();
// //       if (mounted) {
// //         setState(() {
// //           _followerCount = followers.length;
// //           _followingCount = following.length;
// //         });
// //       }
// //     } catch (_) {}
// //   }

// //   // ── Helpers ───────────────────────────────────────────────────────────────

// //   void _snack(String msg, {bool isError = false}) {
// //     if (!mounted) return;
// //     final c = AppColors.of(context);
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(msg),
// //         backgroundColor: isError ? Colors.redAccent : c.pink,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //       ),
// //     );
// //   }

// //   void _todo(String feature) => _snack('$feature coming soon!');

// //   // ── Photo picker ──────────────────────────────────────────────────────────

// //   Future<void> _pickPhoto() async {
// //     final picker = ImagePicker();
// //     final XFile? picked = await picker.pickImage(
// //       source: ImageSource.gallery,
// //       imageQuality: 85,
// //       maxWidth: 800,
// //     );
// //     if (picked == null || !mounted) return;
// //     setState(() => _isUploadingPhoto = true);
// //     try {
// //       // TODO: Upload to Firebase Storage → PUT /api/me { profile_photo_url }
// //       _snack('Photo upload coming soon!');
// //     } finally {
// //       if (mounted) setState(() => _isUploadingPhoto = false);
// //     }
// //   }

// //   // ── Edit name ─────────────────────────────────────────────────────────────

// //   void _editName(String current) {
// //     final c = AppColors.of(context);
// //     final ctrl = TextEditingController(text: current);
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         backgroundColor: c.card,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: Text(
// //           'Edit Name',
// //           style: GoogleFonts.poppins(
// //             color: c.textPrimary,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         content: TextField(
// //           controller: ctrl,
// //           autofocus: true,
// //           maxLength: 24,
// //           style: TextStyle(color: c.textPrimary),
// //           cursorColor: c.pink,
// //           decoration: InputDecoration(
// //             hintText: 'Display name',
// //             hintStyle: TextStyle(color: c.textSecondary),
// //             counterStyle: TextStyle(color: c.textSecondary),
// //             enabledBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //               borderSide: BorderSide(color: c.border),
// //             ),
// //             focusedBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //               borderSide: BorderSide(color: c.pink),
// //             ),
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: Text(
// //               'Cancel',
// //               style: TextStyle(color: c.textSecondary),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () async {
// //               final newName = ctrl.text.trim();
// //               if (newName.isEmpty) return;
// //               Navigator.pop(ctx);
// //               final api = ref.read(apiServiceProvider);
// //               final res = await api.put(
// //                 '/api/me',
// //                 body: {'display_name': newName},
// //               );
// //               if (res.ok) {
// //                 ref.read(currentUserProvider.notifier).refresh();
// //                 _snack('Name updated!');
// //               } else {
// //                 _snack(
// //                   res.error ?? 'Could not update name',
// //                   isError: true,
// //                 );
// //               }
// //             },
// //             child: Text(
// //               'Save',
// //               style: TextStyle(
// //                 color: c.pink,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Logout ────────────────────────────────────────────────────────────────

// //   void _confirmLogout() {
// //     final c = AppColors.of(context);
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         backgroundColor: c.card,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: Text(
// //           'Log Out?',
// //           style: GoogleFonts.poppins(
// //             color: c.textPrimary,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         content: Text(
// //           'You will need to sign in again.',
// //           style: TextStyle(color: c.textSecondary),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: Text(
// //               'Cancel',
// //               style: TextStyle(color: c.textSecondary),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () async {
// //               final logoutNotifier = ref.read(
// //                 isLoggingOutProvider.notifier,
// //               );
// //               final userNotifier = ref.read(
// //                 currentUserProvider.notifier,
// //               );
// //               final authSvc = ref.read(authServiceProvider);
// //               Navigator.pop(ctx);
// //               logoutNotifier.start();
// //               userNotifier.clear();
// //               await authSvc.signOut();
// //             },
// //             child: const Text(
// //               'Log Out',
// //               style: TextStyle(
// //                 color: Colors.redAccent,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Delete account ────────────────────────────────────────────────────────

// //   void _confirmDeleteAccount() {
// //     final c = AppColors.of(context);
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         backgroundColor: c.card,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: Text(
// //           'Delete Account?',
// //           style: GoogleFonts.poppins(
// //             color: Colors.redAccent,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         content: Text(
// //           'This is permanent. All your data, coins, and history will be erased and cannot be recovered.',
// //           style: TextStyle(color: c.textSecondary),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: Text(
// //               'Cancel',
// //               style: TextStyle(color: c.textSecondary),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(ctx);
// //               _snack('Delete account coming soon.');
// //             },
// //             child: const Text(
// //               'Delete',
// //               style: TextStyle(
// //                 color: Colors.redAccent,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Clear cache dialog ────────────────────────────────────────────────────

// //   void _showClearCacheDialog() {
// //     final c = AppColors.of(context);
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         backgroundColor: c.card,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: Text(
// //           'Clear Cache?',
// //           style: GoogleFonts.poppins(
// //             color: c.textPrimary,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         content: Text(
// //           'Cached images and data will be removed. The app may load slower temporarily.',
// //           style: TextStyle(color: c.textSecondary),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: Text(
// //               'Cancel',
// //               style: TextStyle(color: c.textSecondary),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(ctx);
// //               CachedNetworkImage.evictFromCache('');
// //               _snack('Cache cleared');
// //             },
// //             child: Text(
// //               'Clear',
// //               style: TextStyle(
// //                 color: c.pink,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Help sheet ────────────────────────────────────────────────────────────

// //   void _showHelpSheet({required bool isHost}) {
// //     final c = AppColors.of(context);
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: c.surface,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(
// //           top: Radius.circular(20),
// //         ),
// //       ),
// //       isScrollControlled: true,
// //       builder: (ctx) => ConstrainedBox(
// //         constraints: BoxConstraints(
// //           maxHeight: MediaQuery.of(ctx).size.height * 0.7,
// //         ),
// //         child: Padding(
// //           padding: EdgeInsets.fromLTRB(
// //             20,
// //             16,
// //             20,
// //             MediaQuery.of(ctx).padding.bottom + 20,
// //           ),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Center(
// //                   child: Container(
// //                     width: 36,
// //                     height: 4,
// //                     decoration: BoxDecoration(
// //                       color: c.border,
// //                       borderRadius: BorderRadius.circular(2),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'Help & Support',
// //                   style: GoogleFonts.poppins(
// //                     color: c.textPrimary,
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   'How can we help you?',
// //                   style: TextStyle(
// //                     color: c.textSecondary,
// //                     fontSize: 13,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 _sheetTile(
// //                   icon: Icons.chat_bubble_outline,
// //                   label: 'Contact Support',
// //                   onTap: () {
// //                     Navigator.pop(ctx);
// //                     _todo('Customer support');
// //                   },
// //                 ),
// //                 _sheetTile(
// //                   icon: Icons.quiz_outlined,
// //                   label: 'FAQ',
// //                   onTap: () {
// //                     Navigator.pop(ctx);
// //                     _todo('FAQ');
// //                   },
// //                 ),
// //                 if (isHost) ...[
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(
// //                       vertical: 10,
// //                     ),
// //                     child: Divider(color: c.divider),
// //                   ),
// //                   Text(
// //                     'For Hosts',
// //                     style: GoogleFonts.poppins(
// //                       color: c.pink,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                       letterSpacing: 1.1,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   _sheetTile(
// //                     icon: Icons.lightbulb_outline,
// //                     label: 'Request a Feature',
// //                     onTap: () {
// //                       Navigator.pop(ctx);
// //                       _todo('Feature request');
// //                     },
// //                   ),
// //                   _sheetTile(
// //                     icon: Icons.feedback_outlined,
// //                     label: 'Share Feedback',
// //                     onTap: () {
// //                       Navigator.pop(ctx);
// //                       _todo('Feedback form');
// //                     },
// //                   ),
// //                   _sheetTile(
// //                     icon: Icons.campaign_outlined,
// //                     label: 'Host Community',
// //                     onTap: () {
// //                       Navigator.pop(ctx);
// //                       _todo('Host forum');
// //                     },
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Navigate to a full-screen list page ────────────────────────────────

// //   void _pushPage(Widget page) {
// //     Navigator.of(
// //       context,
// //     ).push(MaterialPageRoute(builder: (_) => page));
// //   }

// //   // ── Follow list ───────────────────────────────────────────────────────────

// //   void _showFollowList(String type) async {
// //     final social = ref.read(socialServiceProvider);
// //     final list = type == 'Followers'
// //         ? await social.getFollowers()
// //         : await social.getFollowing();
// //     if (!mounted) return;
// //     _pushPage(
// //       _UserListPage(
// //         title: type,
// //         users: list,
// //         emptyIcon: type == 'Followers'
// //             ? Icons.people_outline
// //             : Icons.person_add_outlined,
// //         emptyTitle: 'No $type yet',
// //         emptySubtitle: type == 'Followers'
// //             ? 'When someone follows you, they\'ll appear here'
// //             : 'Hosts you follow will show up here',
// //       ),
// //     );
// //   }

// //   // ── Blocked users ─────────────────────────────────────────────────────────

// //   void _showBlockedUsers() async {
// //     final social = ref.read(socialServiceProvider);
// //     final blocked = await social.getBlocked();
// //     if (!mounted) return;
// //     _pushPage(
// //       _BlockedUsersPage(
// //         blockedUsers: blocked,
// //         onUnblock: (id) => social.unblock(id),
// //       ),
// //     );
// //   }

// //   // ── Transaction history ───────────────────────────────────────────────────

// //   void _showTransactionHistory() async {
// //     final api = ref.read(apiServiceProvider);
// //     final res = await api.get(
// //       '/api/wallet/ledger',
// //       query: {'limit': '100'},
// //     );
// //     final List<Map<String, dynamic>> ledger = res.ok
// //         ? (res.data['ledger'] as List)
// //               .cast<Map<String, dynamic>>()
// //         : [];
// //     if (!mounted) return;
// //     _pushPage(_TransactionHistoryPage(ledger: ledger));
// //   }

// //   // ── Top Up ────────────────────────────────────────────────────────────────

// //   void _showTopUpSheet() async {
// //     final api = ref.read(apiServiceProvider);
// //     final res = await api.get('/api/wallet/packages');
// //     final List<Map<String, dynamic>> packages = res.ok
// //         ? (res.data['packages'] as List)
// //               .cast<Map<String, dynamic>>()
// //         : [];
// //     if (!mounted) return;
// //     final walletState = ref.read(walletBalanceProvider);
// //     final currentCoins =
// //         walletState.asData?.value?.coinBalance ?? 0;
// //     _pushPage(
// //       _TopUpPage(packages: packages, currentCoins: currentCoins),
// //     );
// //   }

// //   // ── Legal ─────────────────────────────────────────────────────────────────

// //   void _showLegalPage(String title) {
// //     _pushPage(_LegalPage(title: title));
// //   }

// //   // ═══════════════════════════════════════════════════════════════════════════
// //   // BUILD
// //   // ═══════════════════════════════════════════════════════════════════════════

// //   @override
// //   Widget build(BuildContext context) {
// //     final asyncUser = ref.watch(currentUserProvider);
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return AnnotatedRegion<SystemUiOverlayStyle>(
// //       value: isDark
// //           ? SystemUiOverlayStyle.light
// //           : SystemUiOverlayStyle.dark,
// //       child: Scaffold(
// //         backgroundColor: c.bg,
// //         body: asyncUser.when(
// //           loading: () => Center(
// //             child: CircularProgressIndicator(color: c.pink),
// //           ),
// //           error: (e, _) => Center(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Icon(
// //                   Icons.error_outline,
// //                   color: Colors.redAccent,
// //                   size: 48,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'Could not load profile',
// //                   style: TextStyle(color: c.textSecondary),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 TextButton(
// //                   onPressed: () => ref
// //                       .read(currentUserProvider.notifier)
// //                       .refresh(),
// //                   child: Text(
// //                     'Retry',
// //                     style: TextStyle(color: c.pink),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           data: (user) => _buildBody(user),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Body ──────────────────────────────────────────────────────────────────

// //   Widget _buildBody(AppUser? user) {
// //     final coins = user?.coins ?? 0;
// //     final level = user?.level ?? 1;
// //     final levelLabel = user?.levelLabel ?? 'Newcomer';
// //     final publicId = user?.publicId;
// //     final countryCode = user?.countryCode ?? 'IN';
// //     final language = user?.language ?? '';
// //     final photoUrl = user?.profilePhotoUrl;
// //     final age = user?.age;
// //     final isHost = user?.isHost ?? false;
// //     final name = user?.displayName ?? 'Guest';

// //     final themeMode = ref.watch(themeModeProvider);
// //     final isDark =
// //         themeMode == ThemeMode.dark ||
// //         (themeMode == ThemeMode.system &&
// //             MediaQuery.of(context).platformBrightness ==
// //                 Brightness.dark);

// //     // Adaptive sizing
// //     final mq = MediaQuery.of(context);
// //     final sw = mq.size.width;
// //     final sh = mq.size.height;
// //     final hPad = (sw * 0.04).clamp(12.0, 20.0);

// //     return CustomScrollView(
// //       physics: const BouncingScrollPhysics(),
// //       slivers: [
// //         SliverToBoxAdapter(
// //           child: _buildHeader(
// //             name,
// //             photoUrl,
// //             level,
// //             levelLabel,
// //             publicId,
// //             countryCode,
// //             age,
// //             sw,
// //             sh,
// //           ),
// //         ),
// //         SliverPadding(
// //           padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
// //           sliver: SliverList(
// //             delegate: SliverChildListDelegate([
// //               _buildSocialStats(),
// //               const SizedBox(height: 12),
// //               _buildCoinsCard(coins),

// //               if (isHost) ...[
// //                 const SizedBox(height: 12),
// //                 _buildHostEarningsCard(),
// //               ],

// //               const SizedBox(height: 20),
// //               _sectionLabel('Discover'),
// //               _tileGroup([
// //                 if (!isHost)
// //                   _tile(
// //                     icon: FontAwesomeIcons.star,
// //                     iconColor: const Color(0xFFFFCA28),
// //                     label: 'Become a Host',
// //                     badge: 'Apply',
// //                     onTap: () => _todo('Host application'),
// //                   ),
// //                 _tile(
// //                   icon: FontAwesomeIcons.userGroup,
// //                   iconColor: const Color(0xFF42A5F5),
// //                   label: 'Invite Friends',
// //                   subtitle: 'Earn coins per referral',
// //                   onTap: () => _todo('Referrals'),
// //                 ),
// //               ]),

// //               const SizedBox(height: 20),
// //               _sectionLabel('Preferences'),
// //               _tileGroup([
// //                 _tile(
// //                   icon: isDark
// //                       ? Icons.dark_mode_outlined
// //                       : Icons.light_mode_outlined,
// //                   iconColor: isDark
// //                       ? const Color(0xFF7C4DFF)
// //                       : const Color(0xFFFFB300),
// //                   label: 'Appearance',
// //                   subtitle: isDark ? 'Dark mode' : 'Light mode',
// //                   trailing: _themeToggle(isDark),
// //                   onTap: () => ref
// //                       .read(themeModeProvider.notifier)
// //                       .toggle(),
// //                 ),
// //                 _tile(
// //                   icon: Icons.language_outlined,
// //                   label: 'App Language',
// //                   subtitle: language.isNotEmpty
// //                       ? language
// //                       : 'English',
// //                   onTap: () => _todo('Language picker'),
// //                 ),
// //                 _tile(
// //                   icon: Icons.notifications_outlined,
// //                   label: 'Notification Settings',
// //                   onTap: () => _todo('Notification settings'),
// //                 ),
// //                 _tile(
// //                   icon: Icons.auto_fix_high_outlined,
// //                   iconColor: const Color(0xFFCE93D8),
// //                   label: 'Camera Beauty',
// //                   onTap: () => _todo('Beauty settings'),
// //                 ),
// //               ]),

// //               const SizedBox(height: 20),
// //               _sectionLabel('Storage & Updates'),
// //               _tileGroup([
// //                 _tile(
// //                   icon: Icons.cleaning_services_outlined,
// //                   label: 'Clear Cache',
// //                   onTap: _showClearCacheDialog,
// //                 ),
// //                 _tile(
// //                   icon: Icons.system_update_outlined,
// //                   iconColor: const Color(0xFF4CAF50),
// //                   label: 'Check for Updates',
// //                   onTap: () => _todo('Update check'),
// //                 ),
// //               ]),

// //               const SizedBox(height: 20),
// //               _sectionLabel('Legal & Info'),
// //               _tileGroup([
// //                 _tile(
// //                   icon: Icons.shield_outlined,
// //                   label: 'Privacy Policy',
// //                   onTap: () => _showLegalPage('Privacy Policy'),
// //                 ),
// //                 _tile(
// //                   icon: Icons.description_outlined,
// //                   label: 'Terms of Service',
// //                   onTap: () =>
// //                       _showLegalPage('Terms of Service'),
// //                 ),
// //                 _tile(
// //                   icon: Icons.info_outline,
// //                   label: 'About Us',
// //                   onTap: () => _showLegalPage('About Us'),
// //                 ),
// //                 _tile(
// //                   icon: Icons.star_border_outlined,
// //                   iconColor: const Color(0xFFFFCA28),
// //                   label: 'Rate Our App',
// //                   onTap: () =>
// //                       _snack('Play Store rating coming soon!'),
// //                 ),
// //               ]),

// //               const SizedBox(height: 20),
// //               _sectionLabel('Support'),
// //               _tileGroup([
// //                 _tile(
// //                   icon: Icons.headset_mic_outlined,
// //                   label: 'Help & Support',
// //                   subtitle: isHost
// //                       ? 'Support · Feature requests · Feedback'
// //                       : null,
// //                   onTap: () => _showHelpSheet(isHost: isHost),
// //                 ),
// //                 _tile(
// //                   icon: Icons.bug_report_outlined,
// //                   label: 'Report a Bug',
// //                   onTap: () => _todo('Bug report'),
// //                 ),
// //               ]),

// //               const SizedBox(height: 20),
// //               _sectionLabel('Account'),
// //               _tileGroup([
// //                 _tile(
// //                   icon: Icons.link_outlined,
// //                   label: 'Bind Accounts',
// //                   subtitle: 'Google · Phone · Apple',
// //                   onTap: () => _todo('Bind accounts'),
// //                 ),
// //                 _tile(
// //                   icon: Icons.block_outlined,
// //                   label: 'Blocked Users',
// //                   onTap: _showBlockedUsers,
// //                 ),
// //                 _tile(
// //                   icon: Icons.receipt_long_outlined,
// //                   label: 'Transaction History',
// //                   onTap: _showTransactionHistory,
// //                 ),
// //                 _tile(
// //                   icon: FontAwesomeIcons.trash,
// //                   iconSize: 16,
// //                   iconColor: Colors.redAccent,
// //                   label: 'Delete Account',
// //                   labelColor: Colors.redAccent,
// //                   onTap: _confirmDeleteAccount,
// //                 ),
// //               ]),

// //               const SizedBox(height: 20),
// //               _logoutButton(),
// //               SizedBox(height: mq.padding.bottom + 32),
// //             ]),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Header (adaptive) ─────────────────────────────────────────────────────

// //   Widget _buildHeader(
// //     String name,
// //     String? photoUrl,
// //     int level,
// //     String levelLabel,
// //     int? publicId,
// //     String countryCode,
// //     int? age,
// //     double sw,
// //     double sh,
// //   ) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     // Proportional sizes
// //     final headerH = (sh * 0.28).clamp(200.0, 280.0);
// //     final avatarSize = (sw * 0.2).clamp(64.0, 96.0);
// //     final cameraBadge = (avatarSize * 0.3).clamp(20.0, 28.0);
// //     final titleSize = (sw * 0.055).clamp(18.0, 24.0);
// //     final nameSize = (sw * 0.05).clamp(16.0, 22.0);
// //     final hPad = (sw * 0.04).clamp(12.0, 20.0);

// //     return Stack(
// //       children: [
// //         Container(
// //           height: headerH,
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               begin: Alignment.topCenter,
// //               end: Alignment.bottomCenter,
// //               colors: isDark
// //                   ? [
// //                       const Color(0xFF2D0A1F),
// //                       const Color(0xFF0D0D0D),
// //                     ]
// //                   : [const Color(0xFFFFE4F0), c.bg],
// //             ),
// //           ),
// //         ),
// //         // Radial glow — proportional to screen width
// //         Positioned(
// //           top: -sw * 0.1,
// //           left: 0,
// //           right: 0,
// //           child: Center(
// //             child: Container(
// //               width: sw * 0.85,
// //               height: sw * 0.55,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 gradient: RadialGradient(
// //                   colors: [
// //                     c.pink.withOpacity(0.10),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //         SafeArea(
// //           bottom: false,
// //           child: Padding(
// //             padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Profile',
// //                   style: GoogleFonts.poppins(
// //                     color: c.textPrimary,
// //                     fontSize: titleSize,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //                 SizedBox(height: sh * 0.018),
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     // Avatar
// //                     _avatar(photoUrl, avatarSize, cameraBadge),
// //                     SizedBox(width: sw * 0.04),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment:
// //                             CrossAxisAlignment.start,
// //                         children: [
// //                           // Name + edit
// //                           Row(
// //                             children: [
// //                               Flexible(
// //                                 child: Text(
// //                                   name,
// //                                   style: GoogleFonts.poppins(
// //                                     color: c.textPrimary,
// //                                     fontSize: nameSize,
// //                                     fontWeight: FontWeight.w700,
// //                                   ),
// //                                   overflow:
// //                                       TextOverflow.ellipsis,
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 6),
// //                               GestureDetector(
// //                                 onTap: () => _editName(name),
// //                                 child: Container(
// //                                   padding: const EdgeInsets.all(
// //                                     5,
// //                                   ),
// //                                   decoration: BoxDecoration(
// //                                     color: c.pink.withOpacity(
// //                                       0.12,
// //                                     ),
// //                                     shape: BoxShape.circle,
// //                                   ),
// //                                   child: Icon(
// //                                     Icons.edit,
// //                                     size: (nameSize * 0.6).clamp(
// //                                       11.0,
// //                                       15.0,
// //                                     ),
// //                                     color: c.pink,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 6),
// //                           // Meta pills — Wrap handles overflow automatically
// //                           Wrap(
// //                             spacing: 6,
// //                             runSpacing: 4,
// //                             crossAxisAlignment:
// //                                 WrapCrossAlignment.center,
// //                             children: [
// //                               if (age != null)
// //                                 _metaPill(
// //                                   '$age yrs',
// //                                   Icons.cake_outlined,
// //                                   const Color(0xFFFF8A65),
// //                                 ),
// //                               Row(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   ClipRRect(
// //                                     borderRadius:
// //                                         BorderRadius.circular(3),
// //                                     child: Flag.fromString(
// //                                       countryCode,
// //                                       width: 22,
// //                                       height: 15,
// //                                       fit: BoxFit.cover,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 4),
// //                                   Text(
// //                                     countryCode,
// //                                     style: TextStyle(
// //                                       color: c.textSecondary,
// //                                       fontSize: 11,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               _metaPill(
// //                                 'Lv.$level $levelLabel',
// //                                 Icons.bolt,
// //                                 c.pink,
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 6),
// //                           if (publicId != null)
// //                             GestureDetector(
// //                               onTap: () {
// //                                 Clipboard.setData(
// //                                   ClipboardData(
// //                                     text: '$publicId',
// //                                   ),
// //                                 );
// //                                 _snack('ID copied!');
// //                               },
// //                               child: Row(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   Text(
// //                                     'ID: $publicId',
// //                                     style: TextStyle(
// //                                       color: c.textSecondary,
// //                                       fontSize: 11,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 4),
// //                                   Icon(
// //                                     Icons.copy,
// //                                     size: 10,
// //                                     color: c.textSecondary,
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Avatar (adaptive) ─────────────────────────────────────────────────────

// //   Widget _avatar(
// //     String? photoUrl,
// //     double size,
// //     double badgeSize,
// //   ) {
// //     final c = AppColors.of(context);
// //     return GestureDetector(
// //       onTap: _pickPhoto,
// //       child: Stack(
// //         children: [
// //           Container(
// //             width: size,
// //             height: size,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               border: Border.all(color: c.pink, width: 2.5),
// //             ),
// //             child: ClipOval(
// //               child: _isUploadingPhoto
// //                   ? Container(
// //                       color: c.surface,
// //                       child: Center(
// //                         child: CircularProgressIndicator(
// //                           color: c.pink,
// //                           strokeWidth: 2,
// //                         ),
// //                       ),
// //                     )
// //                   : photoUrl != null
// //                   ? CachedNetworkImage(
// //                       imageUrl: photoUrl,
// //                       fit: BoxFit.cover,
// //                       placeholder: (_, __) =>
// //                           Container(color: c.surface),
// //                       errorWidget: (_, __, ___) =>
// //                           _avatarFallback(size),
// //                     )
// //                   : _avatarFallback(size),
// //             ),
// //           ),
// //           Positioned(
// //             bottom: 0,
// //             right: 0,
// //             child: Container(
// //               width: badgeSize,
// //               height: badgeSize,
// //               decoration: BoxDecoration(
// //                 color: c.pink,
// //                 shape: BoxShape.circle,
// //                 border: Border.all(color: c.bg, width: 2),
// //               ),
// //               child: Icon(
// //                 Icons.camera_alt,
// //                 size: badgeSize * 0.5,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _avatarFallback(double size) {
// //     final c = AppColors.of(context);
// //     return Container(
// //       color: c.avatarFallback,
// //       child: Icon(
// //         Icons.person,
// //         color: c.avatarIcon,
// //         size: size * 0.5,
// //       ),
// //     );
// //   }

// //   Widget _metaPill(String label, IconData icon, Color color) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(
// //         horizontal: 7,
// //         vertical: 3,
// //       ),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.12),
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 11, color: color),
// //           const SizedBox(width: 3),
// //           Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               color: color,
// //               fontSize: 10,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Social stats ──────────────────────────────────────────────────────────

// //   Widget _buildSocialStats() {
// //     final c = AppColors.of(context);

// //     return Material(
// //       color: c.surface,
// //       borderRadius: BorderRadius.circular(16),
// //       clipBehavior: Clip.hardEdge,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: c.divider),
// //         ),
// //         child: IntrinsicHeight(
// //           child: Row(
// //             children: [
// //               _socialStat(
// //                 _followerCount,
// //                 'Followers',
// //                 onTap: () => _showFollowList('Followers'),
// //               ),
// //               VerticalDivider(width: 1, color: c.divider),
// //               _socialStat(
// //                 _followingCount,
// //                 'Following',
// //                 onTap: () => _showFollowList('Following'),
// //               ),
// //               VerticalDivider(width: 1, color: c.divider),
// //               _socialStat(
// //                 0,
// //                 'Mutuals',
// //                 onTap: () => _snack('Mutuals coming soon!'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _socialStat(
// //     int count,
// //     String label, {
// //     required VoidCallback onTap,
// //   }) {
// //     final c = AppColors.of(context);
// //     final sw = MediaQuery.of(context).size.width;
// //     final fontSize = (sw * 0.045).clamp(14.0, 20.0);

// //     return Expanded(
// //       child: InkWell(
// //         onTap: onTap,
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 14),
// //           child: Column(
// //             children: [
// //               Text(
// //                 _formatCount(count),
// //                 style: GoogleFonts.poppins(
// //                   color: c.textPrimary,
// //                   fontSize: fontSize,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //               const SizedBox(height: 2),
// //               Text(
// //                 label,
// //                 style: TextStyle(
// //                   color: c.textSecondary,
// //                   fontSize: 11,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   String _formatCount(int n) {
// //     if (n >= 1000000)
// //       return '${(n / 1000000).toStringAsFixed(1)}M';
// //     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
// //     return '$n';
// //   }

// //   // ── Coins card ────────────────────────────────────────────────────────────

// //   Widget _buildCoinsCard(int coins) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;
// //     final sw = MediaQuery.of(context).size.width;
// //     final iconBox = (sw * 0.12).clamp(38.0, 50.0);
// //     final coinFontSize = (sw * 0.05).clamp(16.0, 22.0);

// //     return Container(
// //       padding: EdgeInsets.all((sw * 0.045).clamp(14.0, 20.0)),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(18),
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: isDark
// //               ? [
// //                   const Color(0xFF1A0D12),
// //                   const Color(0xFF221228),
// //                 ]
// //               : [
// //                   const Color(0xFFFFF0F7),
// //                   const Color(0xFFFFE4EF),
// //                 ],
// //         ),
// //         border: Border.all(color: c.pink.withOpacity(0.2)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: c.pink.withOpacity(0.08),
// //             blurRadius: 20,
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: iconBox,
// //             height: iconBox,
// //             decoration: BoxDecoration(
// //               color: c.gold.withOpacity(0.15),
// //               borderRadius: BorderRadius.circular(13),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 '💎',
// //                 style: TextStyle(fontSize: iconBox * 0.48),
// //               ),
// //             ),
// //           ),
// //           SizedBox(width: sw * 0.035),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'My Balance',
// //                   style: TextStyle(
// //                     color: c.textSecondary,
// //                     fontSize: 11,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   '$coins coins',
// //                   style: GoogleFonts.poppins(
// //                     color: c.gold,
// //                     fontSize: coinFontSize,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           GestureDetector(
// //             onTap: _showTopUpSheet,
// //             child: Container(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: sw * 0.04,
// //                 vertical: 9,
// //               ),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [c.pink, const Color(0xFFFF6B9D)],
// //                 ),
// //                 borderRadius: BorderRadius.circular(30),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: c.pink.withOpacity(0.35),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ],
// //               ),
// //               child: Text(
// //                 'Top Up',
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.white,
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Host earnings card ────────────────────────────────────────────────────

// //   Widget _buildHostEarningsCard() {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;
// //     final sw = MediaQuery.of(context).size.width;
// //     final pad = (sw * 0.045).clamp(14.0, 20.0);

// //     return Container(
// //       padding: EdgeInsets.all(pad),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(18),
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: isDark
// //               ? [
// //                   const Color(0xFF0D1A0D),
// //                   const Color(0xFF122212),
// //                 ]
// //               : [
// //                   const Color(0xFFF0FFF0),
// //                   const Color(0xFFE8F5E9),
// //                 ],
// //         ),
// //         border: Border.all(color: c.green.withOpacity(0.25)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: c.green.withOpacity(0.06),
// //             blurRadius: 20,
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Container(
// //                 width: 36,
// //                 height: 36,
// //                 decoration: BoxDecoration(
// //                   color: c.green.withOpacity(0.12),
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: Icon(
// //                   Icons.trending_up,
// //                   color: c.green,
// //                   size: 18,
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 child: Text(
// //                   'Host Earnings',
// //                   style: GoogleFonts.poppins(
// //                     color: c.textPrimary,
// //                     fontSize: 15,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //               Text(
// //                 'This month',
// //                 style: TextStyle(
// //                   color: c.textSecondary,
// //                   fontSize: 11,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 14),
// //           Row(
// //             children: [
// //               _earningsStat('₹ 0', 'Available', c),
// //               const SizedBox(width: 16),
// //               _earningsStat('₹ 0', 'Withdrawn', c),
// //               const SizedBox(width: 16),
// //               _earningsStat('0', 'Call Mins', c),
// //             ],
// //           ),
// //           const SizedBox(height: 14),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: _outlineButton(
// //                   label: 'Bind Bank / UPI',
// //                   icon: Icons.account_balance_outlined,
// //                   color: c.textSecondary,
// //                   onTap: () => _todo('Bind bank account'),
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 child: _outlineButton(
// //                   label: 'Withdraw',
// //                   icon: Icons.arrow_circle_down_outlined,
// //                   color: c.green,
// //                   onTap: () => _todo('Withdraw earnings'),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _earningsStat(String value, String label, AppColors c) {
// //     return Expanded(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               color: c.green,
// //               fontSize: 16,
// //               fontWeight: FontWeight.w700,
// //             ),
// //           ),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               color: c.textSecondary,
// //               fontSize: 10,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _outlineButton({
// //     required String label,
// //     required IconData icon,
// //     required Color color,
// //     required VoidCallback onTap,
// //   }) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(vertical: 9),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(color: color.withOpacity(0.4)),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, size: 14, color: color),
// //             const SizedBox(width: 5),
// //             Flexible(
// //               child: Text(
// //                 label,
// //                 style: TextStyle(
// //                   color: color,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Sheet tile ────────────────────────────────────────────────────────────

// //   Widget _sheetTile({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //     String? subtitle,
// //   }) {
// //     final c = AppColors.of(context);
// //     return ListTile(
// //       contentPadding: EdgeInsets.zero,
// //       leading: Container(
// //         width: 38,
// //         height: 38,
// //         decoration: BoxDecoration(
// //           color: c.pink.withOpacity(0.10),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: Icon(icon, size: 18, color: c.pink),
// //       ),
// //       title: Text(
// //         label,
// //         style: TextStyle(
// //           color: c.textPrimary,
// //           fontWeight: FontWeight.w500,
// //           fontSize: 14,
// //         ),
// //       ),
// //       subtitle: subtitle != null
// //           ? Text(
// //               subtitle,
// //               style: TextStyle(
// //                 color: c.textSecondary,
// //                 fontSize: 11,
// //               ),
// //             )
// //           : null,
// //       trailing: Icon(
// //         Icons.arrow_forward_ios,
// //         size: 12,
// //         color: c.textSecondary,
// //       ),
// //       onTap: onTap,
// //     );
// //   }

// //   // ── Logout ────────────────────────────────────────────────────────────────

// //   Widget _logoutButton() {
// //     return GestureDetector(
// //       onTap: _confirmLogout,
// //       child: Container(
// //         width: double.infinity,
// //         padding: const EdgeInsets.symmetric(vertical: 14),
// //         decoration: BoxDecoration(
// //           color: Colors.redAccent.withOpacity(0.08),
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(
// //             color: Colors.redAccent.withOpacity(0.25),
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(
// //               Icons.logout,
// //               color: Colors.redAccent,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 8),
// //             Text(
// //               'Log Out',
// //               style: GoogleFonts.poppins(
// //                 color: Colors.redAccent,
// //                 fontWeight: FontWeight.w600,
// //                 fontSize: 14,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Tile components ───────────────────────────────────────────────────────

// //   Widget _sectionLabel(String label) {
// //     final c = AppColors.of(context);
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8, left: 2),
// //       child: Text(
// //         label.toUpperCase(),
// //         style: GoogleFonts.poppins(
// //           color: c.textSecondary,
// //           fontSize: 11,
// //           fontWeight: FontWeight.w600,
// //           letterSpacing: 1.2,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _tileGroup(List<Widget?> tiles) {
// //     final c = AppColors.of(context);
// //     final visible = tiles.whereType<Widget>().toList();
// //     if (visible.isEmpty) return const SizedBox.shrink();
// //     return Material(
// //       color: c.surface,
// //       borderRadius: BorderRadius.circular(16),
// //       clipBehavior: Clip.hardEdge,
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: c.divider),
// //         ),
// //         child: Column(
// //           children: [
// //             for (int i = 0; i < visible.length; i++) ...[
// //               visible[i],
// //               if (i < visible.length - 1)
// //                 Divider(height: 1, color: c.divider, indent: 54),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget? _tile({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //     double iconSize = 19,
// //     Color? iconColor,
// //     Color? labelColor,
// //     String? subtitle,
// //     String? badge,
// //     Widget? trailing,
// //   }) {
// //     final c = AppColors.of(context);
// //     final effectiveIconColor = iconColor ?? c.textSecondary;
// //     final effectiveLabelColor = labelColor ?? c.textPrimary;

// //     return ListTile(
// //       onTap: onTap,
// //       contentPadding: const EdgeInsets.symmetric(
// //         horizontal: 14,
// //         vertical: 2,
// //       ),
// //       leading: Container(
// //         width: 36,
// //         height: 36,
// //         decoration: BoxDecoration(
// //           color: effectiveIconColor.withOpacity(0.10),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: Icon(
// //           icon,
// //           size: iconSize,
// //           color: effectiveIconColor,
// //         ),
// //       ),
// //       title: Text(
// //         label,
// //         style: TextStyle(
// //           color: effectiveLabelColor,
// //           fontWeight: FontWeight.w500,
// //           fontSize: 14,
// //         ),
// //       ),
// //       subtitle: subtitle != null
// //           ? Text(
// //               subtitle,
// //               style: TextStyle(
// //                 color: c.textSecondary,
// //                 fontSize: 11,
// //               ),
// //             )
// //           : null,
// //       trailing:
// //           trailing ??
// //           (badge != null
// //               ? Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 8,
// //                     vertical: 3,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: c.pink.withOpacity(0.15),
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     badge,
// //                     style: TextStyle(
// //                       color: c.pink,
// //                       fontSize: 10,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 )
// //               : Icon(
// //                   Icons.arrow_forward_ios,
// //                   size: 13,
// //                   color: c.textSecondary.withOpacity(0.5),
// //                 )),
// //     );
// //   }

// //   // ── Theme toggle ──────────────────────────────────────────────────────────

// //   Widget _themeToggle(bool isDark) {
// //     return GestureDetector(
// //       onTap: () => ref.read(themeModeProvider.notifier).toggle(),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 250),
// //         curve: Curves.easeInOut,
// //         width: 52,
// //         height: 28,
// //         decoration: BoxDecoration(
// //           gradient: isDark
// //               ? const LinearGradient(
// //                   colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
// //                 )
// //               : const LinearGradient(
// //                   colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
// //                 ),
// //           borderRadius: BorderRadius.circular(14),
// //         ),
// //         child: AnimatedAlign(
// //           duration: const Duration(milliseconds: 250),
// //           curve: Curves.easeInOut,
// //           alignment: isDark
// //               ? Alignment.centerRight
// //               : Alignment.centerLeft,
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 3),
// //             child: Container(
// //               width: 22,
// //               height: 22,
// //               decoration: const BoxDecoration(
// //                 color: Colors.white,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 isDark ? Icons.dark_mode : Icons.light_mode,
// //                 size: 13,
// //                 color: isDark
// //                     ? const Color(0xFF7C4DFF)
// //                     : const Color(0xFFFFB300),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ── Helper class ────────────────────────────────────────────────────────────

// // class _TxnConfig {
// //   final IconData icon;
// //   final Color color;
// //   final String label;
// //   const _TxnConfig(this.icon, this.color, this.label);
// // }

// // _TxnConfig _txnConfigStatic(String type) {
// //   switch (type) {
// //     case 'recharge':
// //       return _TxnConfig(
// //         Icons.add_circle_outline,
// //         Colors.green,
// //         'Recharge',
// //       );
// //     case 'call_spent':
// //       return _TxnConfig(
// //         Icons.videocam_outlined,
// //         Colors.orange,
// //         'Video Call',
// //       );
// //     case 'call_earned':
// //       return _TxnConfig(
// //         Icons.videocam_outlined,
// //         Colors.green,
// //         'Call Earning',
// //       );
// //     case 'gift_sent':
// //       return _TxnConfig(
// //         Icons.card_giftcard,
// //         Colors.pink,
// //         'Gift Sent',
// //       );
// //     case 'gift_received':
// //       return _TxnConfig(
// //         Icons.card_giftcard,
// //         Colors.green,
// //         'Gift Received',
// //       );
// //     case 'bonus':
// //       return _TxnConfig(
// //         Icons.stars_outlined,
// //         Colors.amber.shade700,
// //         'Bonus',
// //       );
// //     case 'signup_bonus':
// //       return _TxnConfig(
// //         Icons.celebration_outlined,
// //         Colors.amber.shade700,
// //         'Welcome Bonus',
// //       );
// //     case 'daily_bonus':
// //       return _TxnConfig(
// //         Icons.today_outlined,
// //         Colors.blue,
// //         'Daily Bonus',
// //       );
// //     case 'unlock':
// //       return _TxnConfig(
// //         Icons.lock_open_outlined,
// //         Colors.blue,
// //         'Chat Unlock',
// //       );
// //     case 'referral':
// //       return _TxnConfig(
// //         Icons.people_outline,
// //         Colors.teal,
// //         'Referral Reward',
// //       );
// //     default:
// //       return _TxnConfig(
// //         Icons.swap_horiz,
// //         Colors.grey,
// //         type.replaceAll('_', ' '),
// //       );
// //   }
// // }

// // String _monthNameStatic(int m) {
// //   const months = [
// //     '',
// //     'Jan',
// //     'Feb',
// //     'Mar',
// //     'Apr',
// //     'May',
// //     'Jun',
// //     'Jul',
// //     'Aug',
// //     'Sep',
// //     'Oct',
// //     'Nov',
// //     'Dec',
// //   ];
// //   return m >= 1 && m <= 12 ? months[m] : '';
// // }

// // // ═════════════════════════════════════════════════════════════════════════════
// // // FULL-SCREEN SUB-PAGES
// // // ═════════════════════════════════════════════════════════════════════════════

// // /// Reusable empty state widget
// // class _EmptyState extends StatelessWidget {
// //   const _EmptyState({
// //     required this.icon,
// //     required this.title,
// //     this.subtitle,
// //   });
// //   final IconData icon;
// //   final String title;
// //   final String? subtitle;

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 48),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 100,
// //               height: 100,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 gradient: RadialGradient(
// //                   colors: [
// //                     c.pink.withOpacity(isDark ? 0.08 : 0.06),
// //                     c.pink.withOpacity(0.02),
// //                   ],
// //                 ),
// //                 border: Border.all(
// //                   color: c.pink.withOpacity(0.1),
// //                 ),
// //               ),
// //               child: Icon(
// //                 icon,
// //                 size: 42,
// //                 color: c.pink.withOpacity(0.35),
// //               ),
// //             ),
// //             const SizedBox(height: 28),
// //             Text(
// //               title,
// //               style: GoogleFonts.poppins(
// //                 color: c.textPrimary,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             if (subtitle != null) ...[
// //               const SizedBox(height: 10),
// //               Text(
// //                 subtitle!,
// //                 style: TextStyle(
// //                   color: c.textSecondary,
// //                   fontSize: 14,
// //                   height: 1.5,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // /// Reusable AppBar for sub-pages
// // PreferredSizeWidget _subPageAppBar(
// //   BuildContext context,
// //   String title, {
// //   String? countBadge,
// // }) {
// //   final c = AppColors.of(context);
// //   return AppBar(
// //     backgroundColor: c.bg,
// //     elevation: 0,
// //     scrolledUnderElevation: 0.5,
// //     leading: GestureDetector(
// //       onTap: () => Navigator.pop(context),
// //       child: Padding(
// //         padding: const EdgeInsets.all(8),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: c.surface,
// //             shape: BoxShape.circle,
// //             border: Border.all(color: c.divider),
// //           ),
// //           child: Icon(
// //             Icons.arrow_back_ios_new_rounded,
// //             size: 16,
// //             color: c.textPrimary,
// //           ),
// //         ),
// //       ),
// //     ),
// //     title: Row(
// //       children: [
// //         Text(
// //           title,
// //           style: GoogleFonts.poppins(
// //             color: c.textPrimary,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w700,
// //           ),
// //         ),
// //         if (countBadge != null) ...[
// //           const SizedBox(width: 10),
// //           Container(
// //             padding: const EdgeInsets.symmetric(
// //               horizontal: 10,
// //               vertical: 3,
// //             ),
// //             decoration: BoxDecoration(
// //               color: c.pink.withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Text(
// //               countBadge,
// //               style: TextStyle(
// //                 color: c.pink,
// //                 fontSize: 12,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ],
// //     ),
// //     centerTitle: false,
// //   );
// // }

// // /// Reusable user avatar
// // Widget _userAvatar(
// //   String? photoUrl,
// //   AppColors c, {
// //   Color? borderColor,
// //   double size = 50,
// // }) {
// //   final bc = borderColor ?? c.pink;
// //   return Container(
// //     width: size,
// //     height: size,
// //     decoration: BoxDecoration(
// //       shape: BoxShape.circle,
// //       gradient: LinearGradient(
// //         begin: Alignment.topLeft,
// //         end: Alignment.bottomRight,
// //         colors: [bc.withOpacity(0.15), bc.withOpacity(0.05)],
// //       ),
// //       border: Border.all(
// //         color: bc.withOpacity(0.25),
// //         width: 1.5,
// //       ),
// //     ),
// //     child: ClipOval(
// //       child: photoUrl != null
// //           ? Image.network(
// //               photoUrl,
// //               fit: BoxFit.cover,
// //               errorBuilder: (_, __, ___) => Icon(
// //                 Icons.person,
// //                 color: bc.withOpacity(0.4),
// //                 size: size * 0.44,
// //               ),
// //             )
// //           : Icon(
// //               Icons.person,
// //               color: bc.withOpacity(0.4),
// //               size: size * 0.44,
// //             ),
// //     ),
// //   );
// // }

// // // ── User List Page (Followers / Following) ──────────────────────────────────

// // class _UserListPage extends StatelessWidget {
// //   const _UserListPage({
// //     required this.title,
// //     required this.users,
// //     required this.emptyIcon,
// //     required this.emptyTitle,
// //     required this.emptySubtitle,
// //   });
// //   final String title;
// //   final List<Map<String, dynamic>> users;
// //   final IconData emptyIcon;
// //   final String emptyTitle;
// //   final String emptySubtitle;

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     return Scaffold(
// //       backgroundColor: c.bg,
// //       appBar: _subPageAppBar(
// //         context,
// //         title,
// //         countBadge: '${users.length}',
// //       ),
// //       body: users.isEmpty
// //           ? _EmptyState(
// //               icon: emptyIcon,
// //               title: emptyTitle,
// //               subtitle: emptySubtitle,
// //             )
// //           : ListView.separated(
// //               padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
// //               itemCount: users.length,
// //               separatorBuilder: (_, __) => Divider(
// //                 height: 1,
// //                 color: c.divider,
// //                 indent: 66,
// //               ),
// //               itemBuilder: (_, i) {
// //                 final user = users[i];
// //                 final name =
// //                     user['display_name'] as String? ?? 'User';
// //                 final photo =
// //                     user['profile_photo_url'] as String?;
// //                 final pid = user['public_id'];

// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(
// //                     vertical: 12,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       _userAvatar(photo, c),
// //                       const SizedBox(width: 14),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               name,
// //                               style: TextStyle(
// //                                 color: c.textPrimary,
// //                                 fontWeight: FontWeight.w600,
// //                                 fontSize: 15,
// //                               ),
// //                             ),
// //                             if (pid != null) ...[
// //                               const SizedBox(height: 2),
// //                               Text(
// //                                 'ID: $pid',
// //                                 style: TextStyle(
// //                                   color: c.textSecondary,
// //                                   fontSize: 12,
// //                                 ),
// //                               ),
// //                             ],
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }

// // // ── Blocked Users Page ──────────────────────────────────────────────────────

// // class _BlockedUsersPage extends StatefulWidget {
// //   const _BlockedUsersPage({
// //     required this.blockedUsers,
// //     required this.onUnblock,
// //   });
// //   final List<Map<String, dynamic>> blockedUsers;
// //   final Future<bool> Function(String id) onUnblock;

// //   @override
// //   State<_BlockedUsersPage> createState() =>
// //       _BlockedUsersPageState();
// // }

// // class _BlockedUsersPageState extends State<_BlockedUsersPage> {
// //   late List<Map<String, dynamic>> _list;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _list = List.from(widget.blockedUsers);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     return Scaffold(
// //       backgroundColor: c.bg,
// //       appBar: _subPageAppBar(
// //         context,
// //         'Blocked Users',
// //         countBadge: '${_list.length}',
// //       ),
// //       body: _list.isEmpty
// //           ? const _EmptyState(
// //               icon: Icons.shield_outlined,
// //               title: 'No blocked users',
// //               subtitle:
// //                   'Users you block won\'t be able to\ncall or message you',
// //             )
// //           : ListView.separated(
// //               padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
// //               itemCount: _list.length,
// //               separatorBuilder: (_, __) => Divider(
// //                 height: 1,
// //                 color: c.divider,
// //                 indent: 66,
// //               ),
// //               itemBuilder: (_, i) {
// //                 if (i >= _list.length)
// //                   return const SizedBox.shrink();
// //                 final user = _list[i];
// //                 final name =
// //                     user['display_name'] as String? ?? 'User';
// //                 final photo =
// //                     user['profile_photo_url'] as String?;

// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(
// //                     vertical: 10,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       _userAvatar(
// //                         photo,
// //                         c,
// //                         borderColor: Colors.red.shade300,
// //                       ),
// //                       const SizedBox(width: 14),
// //                       Expanded(
// //                         child: Text(
// //                           name,
// //                           style: TextStyle(
// //                             color: c.textPrimary,
// //                             fontWeight: FontWeight.w600,
// //                             fontSize: 15,
// //                           ),
// //                         ),
// //                       ),
// //                       GestureDetector(
// //                         onTap: () async {
// //                           final ok = await widget.onUnblock(
// //                             user['blocked_id'] ?? '',
// //                           );
// //                           if (ok && mounted) {
// //                             setState(() => _list.removeAt(i));
// //                             ScaffoldMessenger.of(
// //                               context,
// //                             ).showSnackBar(
// //                               SnackBar(
// //                                 content: Text('Unblocked $name'),
// //                                 backgroundColor: c.pink,
// //                                 behavior:
// //                                     SnackBarBehavior.floating,
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.circular(10),
// //                                 ),
// //                               ),
// //                             );
// //                           }
// //                         },
// //                         child: Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 18,
// //                             vertical: 9,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               colors: [
// //                                 c.pink,
// //                                 const Color(0xFFFF6B9D),
// //                               ],
// //                             ),
// //                             borderRadius: BorderRadius.circular(
// //                               22,
// //                             ),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: c.pink.withOpacity(0.25),
// //                                 blurRadius: 8,
// //                                 offset: const Offset(0, 2),
// //                               ),
// //                             ],
// //                           ),
// //                           child: const Text(
// //                             'Unblock',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 13,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }

// // // ── Transaction History Page ─────────────────────────────────────────────────

// // class _TransactionHistoryPage extends StatelessWidget {
// //   const _TransactionHistoryPage({required this.ledger});
// //   final List<Map<String, dynamic>> ledger;

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     return Scaffold(
// //       backgroundColor: c.bg,
// //       appBar: _subPageAppBar(
// //         context,
// //         'Transactions',
// //         countBadge: '${ledger.length}',
// //       ),
// //       body: ledger.isEmpty
// //           ? const _EmptyState(
// //               icon: Icons.receipt_long_outlined,
// //               title: 'No transactions yet',
// //               subtitle:
// //                   'Your coin activity — calls, gifts,\nrecharges — will appear here',
// //             )
// //           : ListView.separated(
// //               padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
// //               itemCount: ledger.length,
// //               separatorBuilder: (_, __) => Divider(
// //                 height: 1,
// //                 color: c.divider,
// //                 indent: 66,
// //               ),
// //               itemBuilder: (_, i) {
// //                 final txn = ledger[i];
// //                 final amount =
// //                     (txn['amount'] as num?)?.toInt() ?? 0;
// //                 final type = txn['type'] as String? ?? '';
// //                 final isPositive = amount > 0;
// //                 final date = DateTime.tryParse(
// //                   txn['created_at'] ?? '',
// //                 );
// //                 final dateStr = date != null
// //                     ? '${date.day} ${_monthNameStatic(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
// //                     : '';
// //                 final config = _txnConfigStatic(type);

// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(
// //                     vertical: 10,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Container(
// //                         width: 50,
// //                         height: 50,
// //                         decoration: BoxDecoration(
// //                           color: config.color.withOpacity(0.08),
// //                           borderRadius: BorderRadius.circular(
// //                             15,
// //                           ),
// //                           border: Border.all(
// //                             color: config.color.withOpacity(
// //                               0.15,
// //                             ),
// //                           ),
// //                         ),
// //                         child: Icon(
// //                           config.icon,
// //                           color: config.color,
// //                           size: 22,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 14),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment:
// //                               CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               config.label,
// //                               style: TextStyle(
// //                                 color: c.textPrimary,
// //                                 fontWeight: FontWeight.w600,
// //                                 fontSize: 15,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 3),
// //                             Text(
// //                               dateStr,
// //                               style: TextStyle(
// //                                 color: c.textSecondary,
// //                                 fontSize: 12,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 14,
// //                           vertical: 6,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color:
// //                               (isPositive
// //                                       ? Colors.green
// //                                       : Colors.redAccent)
// //                                   .withOpacity(0.08),
// //                           borderRadius: BorderRadius.circular(
// //                             20,
// //                           ),
// //                           border: Border.all(
// //                             color:
// //                                 (isPositive
// //                                         ? Colors.green
// //                                         : Colors.redAccent)
// //                                     .withOpacity(0.15),
// //                           ),
// //                         ),
// //                         child: Text(
// //                           '${isPositive ? '+' : ''}$amount',
// //                           style: TextStyle(
// //                             color: isPositive
// //                                 ? Colors.green
// //                                 : Colors.redAccent,
// //                             fontWeight: FontWeight.w700,
// //                             fontSize: 15,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }

// // // ── Top Up Page ─────────────────────────────────────────────────────────────

// // class _TopUpPage extends StatelessWidget {
// //   const _TopUpPage({
// //     required this.packages,
// //     required this.currentCoins,
// //   });
// //   final List<Map<String, dynamic>> packages;
// //   final int currentCoins;

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;

// //     return Scaffold(
// //       backgroundColor: c.bg,
// //       appBar: _subPageAppBar(context, 'Top Up'),
// //       body: Column(
// //         children: [
// //           // Hero balance
// //           Padding(
// //             padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
// //             child: Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.symmetric(vertical: 28),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                   colors: isDark
// //                       ? [
// //                           const Color(0xFF2D1B4E),
// //                           const Color(0xFF1A0D30),
// //                         ]
// //                       : [
// //                           const Color(0xFFFFF0F7),
// //                           const Color(0xFFFFE4EF),
// //                         ],
// //                 ),
// //                 borderRadius: BorderRadius.circular(24),
// //                 border: Border.all(
// //                   color: c.pink.withOpacity(0.2),
// //                 ),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: c.pink.withOpacity(0.08),
// //                     blurRadius: 20,
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 children: [
// //                   Container(
// //                     width: 60,
// //                     height: 60,
// //                     decoration: BoxDecoration(
// //                       color: c.gold.withOpacity(0.12),
// //                       shape: BoxShape.circle,
// //                       border: Border.all(
// //                         color: c.gold.withOpacity(0.2),
// //                       ),
// //                     ),
// //                     child: const Center(
// //                       child: Text(
// //                         '💎',
// //                         style: TextStyle(fontSize: 30),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 14),
// //                   Text(
// //                     'Current Balance',
// //                     style: TextStyle(
// //                       color: c.textSecondary,
// //                       fontSize: 12,
// //                       letterSpacing: 0.5,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     '$currentCoins',
// //                     style: GoogleFonts.poppins(
// //                       color: c.gold,
// //                       fontSize: 36,
// //                       fontWeight: FontWeight.w800,
// //                     ),
// //                   ),
// //                   Text(
// //                     'coins',
// //                     style: TextStyle(
// //                       color: c.textSecondary,
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           // Header
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24),
// //             child: Row(
// //               children: [
// //                 Text(
// //                   'Choose a Pack',
// //                   style: GoogleFonts.poppins(
// //                     color: c.textPrimary,
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 10,
// //                     vertical: 4,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.green.withOpacity(0.08),
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(
// //                       color: Colors.green.withOpacity(0.15),
// //                     ),
// //                   ),
// //                   child: const Text(
// //                     '100% Secure',
// //                     style: TextStyle(
// //                       color: Colors.green,
// //                       fontSize: 10,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           // Packages
// //           Expanded(
// //             child: packages.isEmpty
// //                 ? Center(
// //                     child: Text(
// //                       'No packages available',
// //                       style: TextStyle(color: c.textSecondary),
// //                     ),
// //                   )
// //                 : ListView.builder(
// //                     padding: const EdgeInsets.fromLTRB(
// //                       20,
// //                       0,
// //                       20,
// //                       40,
// //                     ),
// //                     itemCount: packages.length,
// //                     itemBuilder: (_, i) {
// //                       final pkg = packages[i];
// //                       final coins =
// //                           (pkg['coins_amount'] as num?)
// //                               ?.toInt() ??
// //                           0;
// //                       final price =
// //                           (pkg['price'] as num?)?.toDouble() ??
// //                           0;
// //                       final currency =
// //                           pkg['currency'] as String? ?? 'INR';
// //                       final name =
// //                           pkg['name'] as String? ??
// //                           '$coins Coins';
// //                       final isBest =
// //                           packages.length > 2 &&
// //                           i == packages.length ~/ 2;

// //                       return Padding(
// //                         padding: const EdgeInsets.only(
// //                           bottom: 12,
// //                         ),
// //                         child: GestureDetector(
// //                           onTap: () {
// //                             ScaffoldMessenger.of(
// //                               context,
// //                             ).showSnackBar(
// //                               SnackBar(
// //                                 content: const Text(
// //                                   'Payment integration coming soon!',
// //                                 ),
// //                                 backgroundColor: c.pink,
// //                                 behavior:
// //                                     SnackBarBehavior.floating,
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius:
// //                                       BorderRadius.circular(10),
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                           child: Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: isBest
// //                                   ? c.pink.withOpacity(0.04)
// //                                   : c.surface,
// //                               borderRadius:
// //                                   BorderRadius.circular(18),
// //                               border: Border.all(
// //                                 color: isBest
// //                                     ? c.pink.withOpacity(0.4)
// //                                     : c.divider,
// //                                 width: isBest ? 1.5 : 1,
// //                               ),
// //                               boxShadow: isBest
// //                                   ? [
// //                                       BoxShadow(
// //                                         color: c.pink
// //                                             .withOpacity(0.08),
// //                                         blurRadius: 16,
// //                                       ),
// //                                     ]
// //                                   : null,
// //                             ),
// //                             child: Row(
// //                               children: [
// //                                 Container(
// //                                   width: 50,
// //                                   height: 50,
// //                                   decoration: BoxDecoration(
// //                                     gradient: LinearGradient(
// //                                       colors: [
// //                                         c.gold.withOpacity(0.15),
// //                                         c.gold.withOpacity(0.05),
// //                                       ],
// //                                     ),
// //                                     borderRadius:
// //                                         BorderRadius.circular(
// //                                           15,
// //                                         ),
// //                                     border: Border.all(
// //                                       color: c.gold.withOpacity(
// //                                         0.2,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   child: const Center(
// //                                     child: Text(
// //                                       '💎',
// //                                       style: TextStyle(
// //                                         fontSize: 22,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 14),
// //                                 Expanded(
// //                                   child: Column(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Row(
// //                                         children: [
// //                                           Text(
// //                                             name,
// //                                             style: TextStyle(
// //                                               color:
// //                                                   c.textPrimary,
// //                                               fontSize: 15,
// //                                               fontWeight:
// //                                                   FontWeight
// //                                                       .w700,
// //                                             ),
// //                                           ),
// //                                           if (isBest) ...[
// //                                             const SizedBox(
// //                                               width: 8,
// //                                             ),
// //                                             Container(
// //                                               padding:
// //                                                   const EdgeInsets.symmetric(
// //                                                     horizontal:
// //                                                         8,
// //                                                     vertical: 2,
// //                                                   ),
// //                                               decoration: BoxDecoration(
// //                                                 gradient: LinearGradient(
// //                                                   colors: [
// //                                                     c.pink,
// //                                                     const Color(
// //                                                       0xFFFF6B9D,
// //                                                     ),
// //                                                   ],
// //                                                 ),
// //                                                 borderRadius:
// //                                                     BorderRadius.circular(
// //                                                       10,
// //                                                     ),
// //                                               ),
// //                                               child: const Text(
// //                                                 'POPULAR',
// //                                                 style: TextStyle(
// //                                                   color: Colors
// //                                                       .white,
// //                                                   fontSize: 8,
// //                                                   fontWeight:
// //                                                       FontWeight
// //                                                           .w800,
// //                                                   letterSpacing:
// //                                                       0.5,
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ],
// //                                       ),
// //                                       const SizedBox(height: 3),
// //                                       Text(
// //                                         '$coins coins',
// //                                         style: TextStyle(
// //                                           color: c.gold,
// //                                           fontSize: 12,
// //                                           fontWeight:
// //                                               FontWeight.w500,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                                 Container(
// //                                   padding:
// //                                       const EdgeInsets.symmetric(
// //                                         horizontal: 20,
// //                                         vertical: 11,
// //                                       ),
// //                                   decoration: BoxDecoration(
// //                                     gradient: LinearGradient(
// //                                       colors: [
// //                                         c.pink,
// //                                         const Color(0xFFFF6B9D),
// //                                       ],
// //                                     ),
// //                                     borderRadius:
// //                                         BorderRadius.circular(
// //                                           24,
// //                                         ),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: c.pink
// //                                             .withOpacity(0.3),
// //                                         blurRadius: 8,
// //                                         offset: const Offset(
// //                                           0,
// //                                           2,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   child: Text(
// //                                     '${currency == 'INR' ? '₹' : '\$'}${price.toStringAsFixed(0)}',
// //                                     style: const TextStyle(
// //                                       color: Colors.white,
// //                                       fontWeight:
// //                                           FontWeight.w700,
// //                                       fontSize: 15,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ── Legal Page ───────────────────────────────────────────────────────────────

// // class _LegalPage extends StatelessWidget {
// //   const _LegalPage({required this.title});
// //   final String title;

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     return Scaffold(
// //       backgroundColor: c.bg,
// //       appBar: _subPageAppBar(context, title),
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 40),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 width: 80,
// //                 height: 80,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: c.pink.withOpacity(0.06),
// //                   border: Border.all(
// //                     color: c.pink.withOpacity(0.12),
// //                   ),
// //                 ),
// //                 child: Icon(
// //                   title.contains('Privacy')
// //                       ? Icons.shield_outlined
// //                       : title.contains('Terms')
// //                       ? Icons.description_outlined
// //                       : Icons.info_outline,
// //                   size: 36,
// //                   color: c.pink.withOpacity(0.4),
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               Text(
// //                 'Coming Soon',
// //                 style: GoogleFonts.poppins(
// //                   color: c.textPrimary,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               Text(
// //                 'This content will be available when the app launches. For now, contact support for any legal inquiries.',
// //                 style: TextStyle(
// //                   color: c.textSecondary,
// //                   fontSize: 14,
// //                   height: 1.5,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // lib/screens/profile_screen.dart
// //
// // User's own profile — settings, wallet, host earnings, preferences.
// // Fully adaptive to all screen sizes.

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flag/flag_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:cheerchat/services/api_service.dart';
// import 'package:cheerchat/services/auth_service.dart';
// import 'package:cheerchat/services/social_service.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:cheerchat/models/app_user.dart';
// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/screens/profile_details_screen.dart';
// import 'package:cheerchat/providers/theme_provider.dart';
// import 'package:cheerchat/providers/auth_provider.dart';
// import 'package:cheerchat/providers/user_provider.dart';
// import 'package:cheerchat/providers/wallet_provider.dart';
// import 'package:cheerchat/theme/app_colors.dart';

// class ProfileScreen extends ConsumerStatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   ConsumerState<ProfileScreen> createState() =>
//       _ProfileScreenState();
// }

// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   bool _isUploadingPhoto = false;
//   int _followerCount = 0;
//   int _followingCount = 0;
//   List<Map<String, dynamic>> _blockedUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSocialStats();
//   }

//   Future<void> _loadSocialStats() async {
//     try {
//       final social = ref.read(socialServiceProvider);
//       final followers = await social.getFollowers();
//       final following = await social.getFollowing();
//       if (mounted) {
//         setState(() {
//           _followerCount = followers.length;
//           _followingCount = following.length;
//         });
//       }
//     } catch (_) {}
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────

//   void _snack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     final c = AppColors.of(context);
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(msg),
//           duration: const Duration(milliseconds: 1500),
//           backgroundColor: isError ? Colors.redAccent : c.pink,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//   }

//   void _todo(String feature) => _snack('$feature coming soon!');

//   // ── Photo picker ──────────────────────────────────────────────────────────

//   Future<void> _pickPhoto() async {
//     final picker = ImagePicker();
//     final XFile? picked = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//       maxWidth: 800,
//     );
//     if (picked == null || !mounted) return;
//     setState(() => _isUploadingPhoto = true);
//     try {
//       // TODO: Upload to Firebase Storage → PUT /api/me { profile_photo_url }
//       _snack('Photo upload coming soon!');
//     } finally {
//       if (mounted) setState(() => _isUploadingPhoto = false);
//     }
//   }

//   // ── Edit name ─────────────────────────────────────────────────────────────

//   void _editName(String current) {
//     final c = AppColors.of(context);
//     final ctrl = TextEditingController(text: current);
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: c.card,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Edit Name',
//           style: GoogleFonts.poppins(
//             color: c.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: TextField(
//           controller: ctrl,
//           autofocus: true,
//           maxLength: 24,
//           style: TextStyle(color: c.textPrimary),
//           cursorColor: c.pink,
//           decoration: InputDecoration(
//             hintText: 'Display name',
//             hintStyle: TextStyle(color: c.textSecondary),
//             counterStyle: TextStyle(color: c.textSecondary),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: c.border),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: c.pink),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: c.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               final newName = ctrl.text.trim();
//               if (newName.isEmpty) return;
//               Navigator.pop(ctx);
//               final api = ref.read(apiServiceProvider);
//               final res = await api.put(
//                 '/api/me',
//                 body: {'display_name': newName},
//               );
//               if (res.ok) {
//                 ref.read(currentUserProvider.notifier).refresh();
//                 _snack('Name updated!');
//               } else {
//                 _snack(
//                   res.error ?? 'Could not update name',
//                   isError: true,
//                 );
//               }
//             },
//             child: Text(
//               'Save',
//               style: TextStyle(
//                 color: c.pink,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Logout ────────────────────────────────────────────────────────────────

//   void _confirmLogout() {
//     final c = AppColors.of(context);
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: c.card,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Log Out?',
//           style: GoogleFonts.poppins(
//             color: c.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'You will need to sign in again.',
//           style: TextStyle(color: c.textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: c.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               final logoutNotifier = ref.read(
//                 isLoggingOutProvider.notifier,
//               );
//               final userNotifier = ref.read(
//                 currentUserProvider.notifier,
//               );
//               final authSvc = ref.read(authServiceProvider);
//               Navigator.pop(ctx);
//               logoutNotifier.start();
//               userNotifier.clear();
//               await authSvc.signOut();
//             },
//             child: const Text(
//               'Log Out',
//               style: TextStyle(
//                 color: Colors.redAccent,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Delete account ────────────────────────────────────────────────────────

//   void _confirmDeleteAccount() {
//     final c = AppColors.of(context);
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: c.card,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Delete Account?',
//           style: GoogleFonts.poppins(
//             color: Colors.redAccent,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'This is permanent. All your data, coins, and history will be erased and cannot be recovered.',
//           style: TextStyle(color: c.textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: c.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               _snack('Delete account coming soon.');
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(
//                 color: Colors.redAccent,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Clear cache dialog ────────────────────────────────────────────────────

//   void _showClearCacheDialog() {
//     final c = AppColors.of(context);
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: c.card,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Clear Cache?',
//           style: GoogleFonts.poppins(
//             color: c.textPrimary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Cached images and data will be removed. The app may load slower temporarily.',
//           style: TextStyle(color: c.textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: c.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               CachedNetworkImage.evictFromCache('');
//               _snack('Cache cleared');
//             },
//             child: Text(
//               'Clear',
//               style: TextStyle(
//                 color: c.pink,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Help sheet ────────────────────────────────────────────────────────────

//   void _showHelpSheet({required bool isHost}) {
//     final c = AppColors.of(context);
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: c.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(20),
//         ),
//       ),
//       isScrollControlled: true,
//       builder: (ctx) => ConstrainedBox(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(ctx).size.height * 0.7,
//         ),
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(
//             20,
//             16,
//             20,
//             MediaQuery.of(ctx).padding.bottom + 20,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 36,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: c.border,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Help & Support',
//                   style: GoogleFonts.poppins(
//                     color: c.textPrimary,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'How can we help you?',
//                   style: TextStyle(
//                     color: c.textSecondary,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _sheetTile(
//                   icon: Icons.chat_bubble_outline,
//                   label: 'Contact Support',
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _todo('Customer support');
//                   },
//                 ),
//                 _sheetTile(
//                   icon: Icons.quiz_outlined,
//                   label: 'FAQ',
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _todo('FAQ');
//                   },
//                 ),
//                 if (isHost) ...[
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                     ),
//                     child: Divider(color: c.divider),
//                   ),
//                   Text(
//                     'For Hosts',
//                     style: GoogleFonts.poppins(
//                       color: c.pink,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 1.1,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _sheetTile(
//                     icon: Icons.lightbulb_outline,
//                     label: 'Request a Feature',
//                     onTap: () {
//                       Navigator.pop(ctx);
//                       _todo('Feature request');
//                     },
//                   ),
//                   _sheetTile(
//                     icon: Icons.feedback_outlined,
//                     label: 'Share Feedback',
//                     onTap: () {
//                       Navigator.pop(ctx);
//                       _todo('Feedback form');
//                     },
//                   ),
//                   _sheetTile(
//                     icon: Icons.campaign_outlined,
//                     label: 'Host Community',
//                     onTap: () {
//                       Navigator.pop(ctx);
//                       _todo('Host forum');
//                     },
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Navigate to a full-screen list page ────────────────────────────────

//   void _pushPage(Widget page) {
//     Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (_) => page));
//   }

//   // ── Follow list ───────────────────────────────────────────────────────────

//   void _showFollowList(String type) async {
//     final social = ref.read(socialServiceProvider);
//     final list = type == 'Followers'
//         ? await social.getFollowers()
//         : await social.getFollowing();
//     if (!mounted) return;
//     _pushPage(
//       _UserListPage(
//         title: type,
//         users: list,
//         emptyIcon: type == 'Followers'
//             ? Icons.people_outline
//             : Icons.person_add_outlined,
//         emptyTitle: 'No $type yet',
//         emptySubtitle: type == 'Followers'
//             ? 'When someone follows you, they\'ll appear here'
//             : 'Hosts you follow will show up here',
//       ),
//     );
//   }

//   // ── Blocked users ─────────────────────────────────────────────────────────

//   void _showBlockedUsers() async {
//     final social = ref.read(socialServiceProvider);
//     final blocked = await social.getBlocked();
//     if (!mounted) return;
//     _pushPage(
//       _BlockedUsersPage(
//         blockedUsers: blocked,
//         onUnblock: (id) => social.unblock(id),
//       ),
//     );
//   }

//   // ── Transaction history ───────────────────────────────────────────────────

//   void _showTransactionHistory() async {
//     final api = ref.read(apiServiceProvider);
//     final res = await api.get(
//       '/api/wallet/ledger',
//       query: {'limit': '100'},
//     );
//     final List<Map<String, dynamic>> ledger = res.ok
//         ? (res.data['ledger'] as List)
//               .cast<Map<String, dynamic>>()
//         : [];
//     if (!mounted) return;
//     _pushPage(_TransactionHistoryPage(ledger: ledger));
//   }

//   // ── Top Up ────────────────────────────────────────────────────────────────

//   void _showTopUpSheet() async {
//     final api = ref.read(apiServiceProvider);
//     final res = await api.get('/api/wallet/packages');
//     final List<Map<String, dynamic>> packages = res.ok
//         ? (res.data['packages'] as List)
//               .cast<Map<String, dynamic>>()
//         : [];
//     if (!mounted) return;
//     final walletState = ref.read(walletBalanceProvider);
//     final currentCoins =
//         walletState.asData?.value?.coinBalance ?? 0;
//     _pushPage(
//       _TopUpPage(packages: packages, currentCoins: currentCoins),
//     );
//   }

//   // ── Legal ─────────────────────────────────────────────────────────────────

//   void _showLegalPage(String title) {
//     _pushPage(_LegalPage(title: title));
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // BUILD
//   // ═══════════════════════════════════════════════════════════════════════════

//   @override
//   Widget build(BuildContext context) {
//     final asyncUser = ref.watch(currentUserProvider);
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: isDark
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: c.bg,
//         body: asyncUser.when(
//           loading: () => Center(
//             child: CircularProgressIndicator(color: c.pink),
//           ),
//           error: (e, _) => Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   color: Colors.redAccent,
//                   size: 48,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Could not load profile',
//                   style: TextStyle(color: c.textSecondary),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: () => ref
//                       .read(currentUserProvider.notifier)
//                       .refresh(),
//                   child: Text(
//                     'Retry',
//                     style: TextStyle(color: c.pink),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           data: (user) => _buildBody(user),
//         ),
//       ),
//     );
//   }

//   // ── Body ──────────────────────────────────────────────────────────────────

//   Widget _buildBody(AppUser? user) {
//     final coins = user?.coins ?? 0;
//     final level = user?.level ?? 1;
//     final levelLabel = user?.levelLabel ?? 'Newcomer';
//     final publicId = user?.publicId;
//     final countryCode = user?.countryCode ?? 'IN';
//     final language = user?.language ?? '';
//     final photoUrl = user?.profilePhotoUrl;
//     final age = user?.age;
//     final isHost = user?.isHost ?? false;
//     final name = user?.displayName ?? 'Guest';

//     final themeMode = ref.watch(themeModeProvider);
//     final isDark =
//         themeMode == ThemeMode.dark ||
//         (themeMode == ThemeMode.system &&
//             MediaQuery.of(context).platformBrightness ==
//                 Brightness.dark);

//     // Adaptive sizing
//     final mq = MediaQuery.of(context);
//     final sw = mq.size.width;
//     final sh = mq.size.height;
//     final hPad = (sw * 0.04).clamp(12.0, 20.0);

//     return RefreshIndicator(
//       color: AppColors.of(context).pink,
//       onRefresh: () async {
//         ref.read(currentUserProvider.notifier).refresh();
//         _loadSocialStats();
//       },
//       child: CustomScrollView(
//         physics: const AlwaysScrollableScrollPhysics(
//           parent: BouncingScrollPhysics(),
//         ),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _buildHeader(
//               name,
//               photoUrl,
//               level,
//               levelLabel,
//               publicId,
//               countryCode,
//               age,
//               sw,
//               sh,
//             ),
//           ),
//           SliverPadding(
//             padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 _buildSocialStats(),
//                 const SizedBox(height: 12),
//                 _buildCoinsCard(coins),

//                 if (isHost) ...[
//                   const SizedBox(height: 12),
//                   _buildHostEarningsCard(),
//                 ],

//                 const SizedBox(height: 20),
//                 _sectionLabel('Discover'),
//                 _tileGroup([
//                   if (!isHost)
//                     _tile(
//                       icon: FontAwesomeIcons.star,
//                       iconColor: const Color(0xFFFFCA28),
//                       label: 'Become a Host',
//                       badge: 'Apply',
//                       onTap: () => _todo('Host application'),
//                     ),
//                   _tile(
//                     icon: FontAwesomeIcons.userGroup,
//                     iconColor: const Color(0xFF42A5F5),
//                     label: 'Invite Friends',
//                     subtitle: 'Earn coins per referral',
//                     onTap: () => _todo('Referrals'),
//                   ),
//                 ]),

//                 const SizedBox(height: 20),
//                 _sectionLabel('Preferences'),
//                 _tileGroup([
//                   _tile(
//                     icon: isDark
//                         ? Icons.dark_mode_outlined
//                         : Icons.light_mode_outlined,
//                     iconColor: isDark
//                         ? const Color(0xFF7C4DFF)
//                         : const Color(0xFFFFB300),
//                     label: 'Appearance',
//                     subtitle: isDark
//                         ? 'Dark mode'
//                         : 'Light mode',
//                     trailing: _themeToggle(isDark),
//                     onTap: () => ref
//                         .read(themeModeProvider.notifier)
//                         .toggle(),
//                   ),
//                   _tile(
//                     icon: Icons.language_outlined,
//                     label: 'App Language',
//                     subtitle: language.isNotEmpty
//                         ? language
//                         : 'English',
//                     onTap: () => _todo('Language picker'),
//                   ),
//                   _tile(
//                     icon: Icons.notifications_outlined,
//                     label: 'Notification Settings',
//                     onTap: () => _todo('Notification settings'),
//                   ),
//                   _tile(
//                     icon: Icons.auto_fix_high_outlined,
//                     iconColor: const Color(0xFFCE93D8),
//                     label: 'Camera Beauty',
//                     onTap: () => _todo('Beauty settings'),
//                   ),
//                 ]),

//                 const SizedBox(height: 20),
//                 _sectionLabel('Storage & Updates'),
//                 _tileGroup([
//                   _tile(
//                     icon: Icons.cleaning_services_outlined,
//                     label: 'Clear Cache',
//                     onTap: _showClearCacheDialog,
//                   ),
//                   _tile(
//                     icon: Icons.system_update_outlined,
//                     iconColor: const Color(0xFF4CAF50),
//                     label: 'Check for Updates',
//                     onTap: () => _todo('Update check'),
//                   ),
//                 ]),

//                 const SizedBox(height: 20),
//                 _sectionLabel('Legal & Info'),
//                 _tileGroup([
//                   _tile(
//                     icon: Icons.shield_outlined,
//                     label: 'Privacy Policy',
//                     onTap: () =>
//                         _showLegalPage('Privacy Policy'),
//                   ),
//                   _tile(
//                     icon: Icons.description_outlined,
//                     label: 'Terms of Service',
//                     onTap: () =>
//                         _showLegalPage('Terms of Service'),
//                   ),
//                   _tile(
//                     icon: Icons.info_outline,
//                     label: 'About Us',
//                     onTap: () => _showLegalPage('About Us'),
//                   ),
//                   _tile(
//                     icon: Icons.star_border_outlined,
//                     iconColor: const Color(0xFFFFCA28),
//                     label: 'Rate Our App',
//                     onTap: () =>
//                         _snack('Play Store rating coming soon!'),
//                   ),
//                 ]),

//                 const SizedBox(height: 20),
//                 _sectionLabel('Support'),
//                 _tileGroup([
//                   _tile(
//                     icon: Icons.headset_mic_outlined,
//                     label: 'Help & Support',
//                     subtitle: isHost
//                         ? 'Support · Feature requests · Feedback'
//                         : null,
//                     onTap: () => _showHelpSheet(isHost: isHost),
//                   ),
//                   _tile(
//                     icon: Icons.bug_report_outlined,
//                     label: 'Report a Bug',
//                     onTap: () => _todo('Bug report'),
//                   ),
//                 ]),

//                 const SizedBox(height: 20),
//                 _sectionLabel('Account'),
//                 _tileGroup([
//                   _tile(
//                     icon: Icons.link_outlined,
//                     label: 'Bind Accounts',
//                     subtitle: 'Google · Phone · Apple',
//                     onTap: () => _todo('Bind accounts'),
//                   ),
//                   _tile(
//                     icon: Icons.block_outlined,
//                     label: 'Blocked Users',
//                     onTap: _showBlockedUsers,
//                   ),
//                   _tile(
//                     icon: Icons.receipt_long_outlined,
//                     label: 'Transaction History',
//                     onTap: _showTransactionHistory,
//                   ),
//                   _tile(
//                     icon: FontAwesomeIcons.trash,
//                     iconSize: 16,
//                     iconColor: Colors.redAccent,
//                     label: 'Delete Account',
//                     labelColor: Colors.redAccent,
//                     onTap: _confirmDeleteAccount,
//                   ),
//                 ]),

//                 const SizedBox(height: 20),
//                 _logoutButton(),
//                 SizedBox(height: mq.padding.bottom + 32),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Header (adaptive) ─────────────────────────────────────────────────────

//   Widget _buildHeader(
//     String name,
//     String? photoUrl,
//     int level,
//     String levelLabel,
//     int? publicId,
//     String countryCode,
//     int? age,
//     double sw,
//     double sh,
//   ) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;

//     // Proportional sizes
//     final headerH = (sh * 0.28).clamp(200.0, 280.0);
//     final avatarSize = (sw * 0.2).clamp(64.0, 96.0);
//     final cameraBadge = (avatarSize * 0.3).clamp(20.0, 28.0);
//     final titleSize = (sw * 0.055).clamp(18.0, 24.0);
//     final nameSize = (sw * 0.05).clamp(16.0, 22.0);
//     final hPad = (sw * 0.04).clamp(12.0, 20.0);

//     return Stack(
//       children: [
//         Container(
//           height: headerH,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: isDark
//                   ? [
//                       const Color(0xFF2D0A1F),
//                       const Color(0xFF0D0D0D),
//                     ]
//                   : [const Color(0xFFFFE4F0), c.bg],
//             ),
//           ),
//         ),
//         // Radial glow — proportional to screen width
//         Positioned(
//           top: -sw * 0.1,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: Container(
//               width: sw * 0.85,
//               height: sw * 0.55,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     c.pink.withOpacity(0.10),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Profile',
//                   style: GoogleFonts.poppins(
//                     color: c.textPrimary,
//                     fontSize: titleSize,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(height: sh * 0.018),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Avatar
//                     _avatar(photoUrl, avatarSize, cameraBadge),
//                     SizedBox(width: sw * 0.04),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           // Name + edit
//                           Row(
//                             children: [
//                               Flexible(
//                                 child: Text(
//                                   name,
//                                   style: GoogleFonts.poppins(
//                                     color: c.textPrimary,
//                                     fontSize: nameSize,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                   overflow:
//                                       TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               GestureDetector(
//                                 onTap: () => _editName(name),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(
//                                     5,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: c.pink.withOpacity(
//                                       0.12,
//                                     ),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     Icons.edit,
//                                     size: (nameSize * 0.6).clamp(
//                                       11.0,
//                                       15.0,
//                                     ),
//                                     color: c.pink,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           // Meta pills — Wrap handles overflow automatically
//                           Wrap(
//                             spacing: 6,
//                             runSpacing: 4,
//                             crossAxisAlignment:
//                                 WrapCrossAlignment.center,
//                             children: [
//                               if (age != null)
//                                 _metaPill(
//                                   '$age yrs',
//                                   Icons.cake_outlined,
//                                   const Color(0xFFFF8A65),
//                                 ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius:
//                                         BorderRadius.circular(3),
//                                     child: Flag.fromString(
//                                       countryCode,
//                                       width: 22,
//                                       height: 15,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     countryCode,
//                                     style: TextStyle(
//                                       color: c.textSecondary,
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               _metaPill(
//                                 'Lv.$level $levelLabel',
//                                 Icons.bolt,
//                                 c.pink,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           if (publicId != null)
//                             GestureDetector(
//                               onTap: () {
//                                 Clipboard.setData(
//                                   ClipboardData(
//                                     text: '$publicId',
//                                   ),
//                                 );
//                                 _snack('ID copied!');
//                               },
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     'ID: $publicId',
//                                     style: TextStyle(
//                                       color: c.textSecondary,
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Icon(
//                                     Icons.copy,
//                                     size: 10,
//                                     color: c.textSecondary,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Avatar (adaptive) ─────────────────────────────────────────────────────

//   Widget _avatar(
//     String? photoUrl,
//     double size,
//     double badgeSize,
//   ) {
//     final c = AppColors.of(context);
//     return GestureDetector(
//       onTap: _pickPhoto,
//       child: Stack(
//         children: [
//           Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: c.pink, width: 2.5),
//             ),
//             child: ClipOval(
//               child: _isUploadingPhoto
//                   ? Container(
//                       color: c.surface,
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: c.pink,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                     )
//                   : photoUrl != null
//                   ? CachedNetworkImage(
//                       imageUrl: photoUrl,
//                       fit: BoxFit.cover,
//                       placeholder: (_, __) =>
//                           Container(color: c.surface),
//                       errorWidget: (_, __, ___) =>
//                           _avatarFallback(size),
//                     )
//                   : _avatarFallback(size),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Container(
//               width: badgeSize,
//               height: badgeSize,
//               decoration: BoxDecoration(
//                 color: c.pink,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: c.bg, width: 2),
//               ),
//               child: Icon(
//                 Icons.camera_alt,
//                 size: badgeSize * 0.5,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _avatarFallback(double size) {
//     final c = AppColors.of(context);
//     return Container(
//       color: c.avatarFallback,
//       child: Icon(
//         Icons.person,
//         color: c.avatarIcon,
//         size: size * 0.5,
//       ),
//     );
//   }

//   Widget _metaPill(String label, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 3,
//       ),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: color),
//           const SizedBox(width: 3),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               color: color,
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Social stats ──────────────────────────────────────────────────────────

//   Widget _buildSocialStats() {
//     final c = AppColors.of(context);

//     return Material(
//       color: c.surface,
//       borderRadius: BorderRadius.circular(16),
//       clipBehavior: Clip.hardEdge,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: c.divider),
//         ),
//         child: IntrinsicHeight(
//           child: Row(
//             children: [
//               _socialStat(
//                 _followerCount,
//                 'Followers',
//                 onTap: () => _showFollowList('Followers'),
//               ),
//               VerticalDivider(width: 1, color: c.divider),
//               _socialStat(
//                 _followingCount,
//                 'Following',
//                 onTap: () => _showFollowList('Following'),
//               ),
//               VerticalDivider(width: 1, color: c.divider),
//               _socialStat(
//                 0,
//                 'Mutuals',
//                 onTap: () => _snack('Mutuals coming soon!'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _socialStat(
//     int count,
//     String label, {
//     required VoidCallback onTap,
//   }) {
//     final c = AppColors.of(context);
//     final sw = MediaQuery.of(context).size.width;
//     final fontSize = (sw * 0.045).clamp(14.0, 20.0);

//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           child: Column(
//             children: [
//               Text(
//                 _formatCount(count),
//                 style: GoogleFonts.poppins(
//                   color: c.textPrimary,
//                   fontSize: fontSize,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontSize: 11,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatCount(int n) {
//     if (n >= 1000000)
//       return '${(n / 1000000).toStringAsFixed(1)}M';
//     if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
//     return '$n';
//   }

//   // ── Coins card ────────────────────────────────────────────────────────────

//   Widget _buildCoinsCard(int coins) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     final sw = MediaQuery.of(context).size.width;
//     final iconBox = (sw * 0.12).clamp(38.0, 50.0);
//     final coinFontSize = (sw * 0.05).clamp(16.0, 22.0);

//     return Container(
//       padding: EdgeInsets.all((sw * 0.045).clamp(14.0, 20.0)),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDark
//               ? [
//                   const Color(0xFF1A0D12),
//                   const Color(0xFF221228),
//                 ]
//               : [
//                   const Color(0xFFFFF0F7),
//                   const Color(0xFFFFE4EF),
//                 ],
//         ),
//         border: Border.all(color: c.pink.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(
//             color: c.pink.withOpacity(0.08),
//             blurRadius: 20,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: iconBox,
//             height: iconBox,
//             decoration: BoxDecoration(
//               color: c.gold.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(13),
//             ),
//             child: Center(
//               child: Text(
//                 '💎',
//                 style: TextStyle(fontSize: iconBox * 0.48),
//               ),
//             ),
//           ),
//           SizedBox(width: sw * 0.035),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'My Balance',
//                   style: TextStyle(
//                     color: c.textSecondary,
//                     fontSize: 11,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '$coins coins',
//                   style: GoogleFonts.poppins(
//                     color: c.gold,
//                     fontSize: coinFontSize,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: _showTopUpSheet,
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: sw * 0.04,
//                 vertical: 9,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [c.pink, const Color(0xFFFF6B9D)],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: c.pink.withOpacity(0.35),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'Top Up',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Host earnings card ────────────────────────────────────────────────────

//   Widget _buildHostEarningsCard() {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     final sw = MediaQuery.of(context).size.width;
//     final pad = (sw * 0.045).clamp(14.0, 20.0);

//     return Container(
//       padding: EdgeInsets.all(pad),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDark
//               ? [
//                   const Color(0xFF0D1A0D),
//                   const Color(0xFF122212),
//                 ]
//               : [
//                   const Color(0xFFF0FFF0),
//                   const Color(0xFFE8F5E9),
//                 ],
//         ),
//         border: Border.all(color: c.green.withOpacity(0.25)),
//         boxShadow: [
//           BoxShadow(
//             color: c.green.withOpacity(0.06),
//             blurRadius: 20,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: c.green.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   Icons.trending_up,
//                   color: c.green,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Host Earnings',
//                   style: GoogleFonts.poppins(
//                     color: c.textPrimary,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Text(
//                 'This month',
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontSize: 11,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               _earningsStat('₹ 0', 'Available', c),
//               const SizedBox(width: 16),
//               _earningsStat('₹ 0', 'Withdrawn', c),
//               const SizedBox(width: 16),
//               _earningsStat('0', 'Call Mins', c),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                 child: _outlineButton(
//                   label: 'Bind Bank / UPI',
//                   icon: Icons.account_balance_outlined,
//                   color: c.textSecondary,
//                   onTap: () => _todo('Bind bank account'),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _outlineButton(
//                   label: 'Withdraw',
//                   icon: Icons.arrow_circle_down_outlined,
//                   color: c.green,
//                   onTap: () => _todo('Withdraw earnings'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _earningsStat(String value, String label, AppColors c) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               color: c.green,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               color: c.textSecondary,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _outlineButton({
//     required String label,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 9),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: color.withOpacity(0.4)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(width: 5),
//             Flexible(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Sheet tile ────────────────────────────────────────────────────────────

//   Widget _sheetTile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     String? subtitle,
//   }) {
//     final c = AppColors.of(context);
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Container(
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: c.pink.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, size: 18, color: c.pink),
//       ),
//       title: Text(
//         label,
//         style: TextStyle(
//           color: c.textPrimary,
//           fontWeight: FontWeight.w500,
//           fontSize: 14,
//         ),
//       ),
//       subtitle: subtitle != null
//           ? Text(
//               subtitle,
//               style: TextStyle(
//                 color: c.textSecondary,
//                 fontSize: 11,
//               ),
//             )
//           : null,
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         size: 12,
//         color: c.textSecondary,
//       ),
//       onTap: onTap,
//     );
//   }

//   // ── Logout ────────────────────────────────────────────────────────────────

//   Widget _logoutButton() {
//     return GestureDetector(
//       onTap: _confirmLogout,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.redAccent.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: Colors.redAccent.withOpacity(0.25),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.logout,
//               color: Colors.redAccent,
//               size: 18,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Log Out',
//               style: GoogleFonts.poppins(
//                 color: Colors.redAccent,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Tile components ───────────────────────────────────────────────────────

//   Widget _sectionLabel(String label) {
//     final c = AppColors.of(context);
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, left: 2),
//       child: Text(
//         label.toUpperCase(),
//         style: GoogleFonts.poppins(
//           color: c.textSecondary,
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }

//   Widget _tileGroup(List<Widget?> tiles) {
//     final c = AppColors.of(context);
//     final visible = tiles.whereType<Widget>().toList();
//     if (visible.isEmpty) return const SizedBox.shrink();
//     return Material(
//       color: c.surface,
//       borderRadius: BorderRadius.circular(16),
//       clipBehavior: Clip.hardEdge,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: c.divider),
//         ),
//         child: Column(
//           children: [
//             for (int i = 0; i < visible.length; i++) ...[
//               visible[i],
//               if (i < visible.length - 1)
//                 Divider(height: 1, color: c.divider, indent: 54),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget? _tile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     double iconSize = 19,
//     Color? iconColor,
//     Color? labelColor,
//     String? subtitle,
//     String? badge,
//     Widget? trailing,
//   }) {
//     final c = AppColors.of(context);
//     final effectiveIconColor = iconColor ?? c.textSecondary;
//     final effectiveLabelColor = labelColor ?? c.textPrimary;

//     return ListTile(
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 2,
//       ),
//       leading: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: effectiveIconColor.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(
//           icon,
//           size: iconSize,
//           color: effectiveIconColor,
//         ),
//       ),
//       title: Text(
//         label,
//         style: TextStyle(
//           color: effectiveLabelColor,
//           fontWeight: FontWeight.w500,
//           fontSize: 14,
//         ),
//       ),
//       subtitle: subtitle != null
//           ? Text(
//               subtitle,
//               style: TextStyle(
//                 color: c.textSecondary,
//                 fontSize: 11,
//               ),
//             )
//           : null,
//       trailing:
//           trailing ??
//           (badge != null
//               ? Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: c.pink.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     badge,
//                     style: TextStyle(
//                       color: c.pink,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 )
//               : Icon(
//                   Icons.arrow_forward_ios,
//                   size: 13,
//                   color: c.textSecondary.withOpacity(0.5),
//                 )),
//     );
//   }

//   // ── Theme toggle ──────────────────────────────────────────────────────────

//   Widget _themeToggle(bool isDark) {
//     return GestureDetector(
//       onTap: () => ref.read(themeModeProvider.notifier).toggle(),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         width: 52,
//         height: 28,
//         decoration: BoxDecoration(
//           gradient: isDark
//               ? const LinearGradient(
//                   colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
//                 )
//               : const LinearGradient(
//                   colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
//                 ),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: AnimatedAlign(
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeInOut,
//           alignment: isDark
//               ? Alignment.centerRight
//               : Alignment.centerLeft,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 3),
//             child: Container(
//               width: 22,
//               height: 22,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isDark ? Icons.dark_mode : Icons.light_mode,
//                 size: 13,
//                 color: isDark
//                     ? const Color(0xFF7C4DFF)
//                     : const Color(0xFFFFB300),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Helper class ────────────────────────────────────────────────────────────

// class _TxnConfig {
//   final IconData icon;
//   final Color color;
//   final String label;
//   const _TxnConfig(this.icon, this.color, this.label);
// }

// _TxnConfig _txnConfigStatic(String type) {
//   switch (type) {
//     case 'recharge':
//       return _TxnConfig(
//         Icons.add_circle_outline,
//         Colors.green,
//         'Recharge',
//       );
//     case 'call_spent':
//       return _TxnConfig(
//         Icons.videocam_outlined,
//         Colors.orange,
//         'Video Call',
//       );
//     case 'call_earned':
//       return _TxnConfig(
//         Icons.videocam_outlined,
//         Colors.green,
//         'Call Earning',
//       );
//     case 'gift_sent':
//       return _TxnConfig(
//         Icons.card_giftcard,
//         Colors.pink,
//         'Gift Sent',
//       );
//     case 'gift_received':
//       return _TxnConfig(
//         Icons.card_giftcard,
//         Colors.green,
//         'Gift Received',
//       );
//     case 'bonus':
//       return _TxnConfig(
//         Icons.stars_outlined,
//         Colors.amber.shade700,
//         'Bonus',
//       );
//     case 'signup_bonus':
//       return _TxnConfig(
//         Icons.celebration_outlined,
//         Colors.amber.shade700,
//         'Welcome Bonus',
//       );
//     case 'daily_bonus':
//       return _TxnConfig(
//         Icons.today_outlined,
//         Colors.blue,
//         'Daily Bonus',
//       );
//     case 'unlock':
//       return _TxnConfig(
//         Icons.lock_open_outlined,
//         Colors.blue,
//         'Chat Unlock',
//       );
//     case 'referral':
//       return _TxnConfig(
//         Icons.people_outline,
//         Colors.teal,
//         'Referral Reward',
//       );
//     default:
//       return _TxnConfig(
//         Icons.swap_horiz,
//         Colors.grey,
//         type.replaceAll('_', ' '),
//       );
//   }
// }

// String _monthNameStatic(int m) {
//   const months = [
//     '',
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ];
//   return m >= 1 && m <= 12 ? months[m] : '';
// }

// // ═════════════════════════════════════════════════════════════════════════════
// // FULL-SCREEN SUB-PAGES
// // ═════════════════════════════════════════════════════════════════════════════

// /// Reusable empty state widget
// class _EmptyState extends StatelessWidget {
//   const _EmptyState({
//     required this.icon,
//     required this.title,
//     this.subtitle,
//   });
//   final IconData icon;
//   final String title;
//   final String? subtitle;

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 48),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     c.pink.withOpacity(isDark ? 0.08 : 0.06),
//                     c.pink.withOpacity(0.02),
//                   ],
//                 ),
//                 border: Border.all(
//                   color: c.pink.withOpacity(0.1),
//                 ),
//               ),
//               child: Icon(
//                 icon,
//                 size: 42,
//                 color: c.pink.withOpacity(0.35),
//               ),
//             ),
//             const SizedBox(height: 28),
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 color: c.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             if (subtitle != null) ...[
//               const SizedBox(height: 10),
//               Text(
//                 subtitle!,
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Reusable AppBar for sub-pages
// PreferredSizeWidget _subPageAppBar(
//   BuildContext context,
//   String title, {
//   String? countBadge,
// }) {
//   final c = AppColors.of(context);
//   return AppBar(
//     backgroundColor: c.bg,
//     elevation: 0,
//     scrolledUnderElevation: 0.5,
//     leading: GestureDetector(
//       onTap: () => Navigator.pop(context),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Container(
//           decoration: BoxDecoration(
//             color: c.surface,
//             shape: BoxShape.circle,
//             border: Border.all(color: c.divider),
//           ),
//           child: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 16,
//             color: c.textPrimary,
//           ),
//         ),
//       ),
//     ),
//     title: Row(
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             color: c.textPrimary,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         if (countBadge != null) ...[
//           const SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: 3,
//             ),
//             decoration: BoxDecoration(
//               color: c.pink.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               countBadge,
//               style: TextStyle(
//                 color: c.pink,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ],
//     ),
//     centerTitle: false,
//   );
// }

// /// Reusable user avatar
// Widget _userAvatar(
//   String? photoUrl,
//   AppColors c, {
//   Color? borderColor,
//   double size = 50,
// }) {
//   final bc = borderColor ?? c.pink;
//   return Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       gradient: LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [bc.withOpacity(0.15), bc.withOpacity(0.05)],
//       ),
//       border: Border.all(
//         color: bc.withOpacity(0.25),
//         width: 1.5,
//       ),
//     ),
//     child: ClipOval(
//       child: photoUrl != null
//           ? Image.network(
//               photoUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Icon(
//                 Icons.person,
//                 color: bc.withOpacity(0.4),
//                 size: size * 0.44,
//               ),
//             )
//           : Icon(
//               Icons.person,
//               color: bc.withOpacity(0.4),
//               size: size * 0.44,
//             ),
//     ),
//   );
// }

// // ── User List Page (Followers / Following) ──────────────────────────────────

// class _UserListPage extends StatelessWidget {
//   const _UserListPage({
//     required this.title,
//     required this.users,
//     required this.emptyIcon,
//     required this.emptyTitle,
//     required this.emptySubtitle,
//   });
//   final String title;
//   final List<Map<String, dynamic>> users;
//   final IconData emptyIcon;
//   final String emptyTitle;
//   final String emptySubtitle;

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     return Scaffold(
//       backgroundColor: c.bg,
//       appBar: _subPageAppBar(
//         context,
//         title,
//         countBadge: '${users.length}',
//       ),
//       body: users.isEmpty
//           ? _EmptyState(
//               icon: emptyIcon,
//               title: emptyTitle,
//               subtitle: emptySubtitle,
//             )
//           : ListView.separated(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
//               itemCount: users.length,
//               separatorBuilder: (_, __) => Divider(
//                 height: 1,
//                 color: c.divider,
//                 indent: 66,
//               ),
//               itemBuilder: (_, i) {
//                 final user = users[i];
//                 final name =
//                     user['display_name'] as String? ?? 'User';
//                 final photo =
//                     user['profile_photo_url'] as String?;
//                 final pid = user['public_id'];

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       _userAvatar(photo, c),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               name,
//                               style: TextStyle(
//                                 color: c.textPrimary,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             if (pid != null) ...[
//                               const SizedBox(height: 2),
//                               Text(
//                                 'ID: $pid',
//                                 style: TextStyle(
//                                   color: c.textSecondary,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// // ── Blocked Users Page ──────────────────────────────────────────────────────

// class _BlockedUsersPage extends StatefulWidget {
//   const _BlockedUsersPage({
//     required this.blockedUsers,
//     required this.onUnblock,
//   });
//   final List<Map<String, dynamic>> blockedUsers;
//   final Future<bool> Function(String id) onUnblock;

//   @override
//   State<_BlockedUsersPage> createState() =>
//       _BlockedUsersPageState();
// }

// class _BlockedUsersPageState extends State<_BlockedUsersPage> {
//   late List<Map<String, dynamic>> _list;

//   @override
//   void initState() {
//     super.initState();
//     _list = List.from(widget.blockedUsers);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     return Scaffold(
//       backgroundColor: c.bg,
//       appBar: _subPageAppBar(
//         context,
//         'Blocked Users',
//         countBadge: '${_list.length}',
//       ),
//       body: _list.isEmpty
//           ? const _EmptyState(
//               icon: Icons.shield_outlined,
//               title: 'No blocked users',
//               subtitle:
//                   'Users you block won\'t be able to\ncall or message you',
//             )
//           : ListView.separated(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
//               itemCount: _list.length,
//               separatorBuilder: (_, __) => Divider(
//                 height: 1,
//                 color: c.divider,
//                 indent: 66,
//               ),
//               itemBuilder: (_, i) {
//                 if (i >= _list.length)
//                   return const SizedBox.shrink();
//                 final user = _list[i];
//                 final name =
//                     user['display_name'] as String? ?? 'User';
//                 final photo =
//                     user['profile_photo_url'] as String?;
//                 final pid = user['public_id'];

//                 return GestureDetector(
//                   onTap: () {
//                     // Navigate to profile details
//                     final blockedId =
//                         user['blocked_id'] as String?;
//                     if (blockedId != null) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (_) => ProfileDetailsScreen(
//                             host: HostModel(
//                               userId: blockedId,
//                               publicId: pid is int
//                                   ? pid
//                                   : int.tryParse('$pid') ?? 0,
//                               displayName: name,
//                               countryCode: 'UN',
//                               language: '',
//                               priceCoins: 0,
//                               level: 1,
//                               status: HostStatus.offline,
//                               profilePhotoUrl: photo,
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                     ),
//                     child: Row(
//                       children: [
//                         _userAvatar(
//                           photo,
//                           c,
//                           borderColor: Colors.red.shade300,
//                         ),
//                         const SizedBox(width: 14),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 name,
//                                 style: TextStyle(
//                                   color: c.textPrimary,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               if (pid != null) ...[
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   'ID: $pid',
//                                   style: TextStyle(
//                                     color: c.textSecondary,
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () async {
//                             final ok = await widget.onUnblock(
//                               user['blocked_id'] ?? '',
//                             );
//                             if (ok && mounted) {
//                               setState(() => _list.removeAt(i));
//                               ScaffoldMessenger.of(context)
//                                 ..clearSnackBars()
//                                 ..showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Unblocked $name',
//                                     ),
//                                     duration: const Duration(
//                                       milliseconds: 1500,
//                                     ),
//                                     backgroundColor: c.pink,
//                                     behavior: SnackBarBehavior
//                                         .floating,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                             10,
//                                           ),
//                                     ),
//                                   ),
//                                 );
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 18,
//                               vertical: 9,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   c.pink,
//                                   const Color(0xFFFF6B9D),
//                                 ],
//                               ),
//                               borderRadius:
//                                   BorderRadius.circular(22),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: c.pink.withOpacity(
//                                     0.25,
//                                   ),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Text(
//                               'Unblock',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// // ── Transaction History Page ─────────────────────────────────────────────────

// class _TransactionHistoryPage extends StatefulWidget {
//   const _TransactionHistoryPage({required this.ledger});
//   final List<Map<String, dynamic>> ledger;

//   @override
//   State<_TransactionHistoryPage> createState() =>
//       _TransactionHistoryPageState();
// }

// class _TransactionHistoryPageState
//     extends State<_TransactionHistoryPage> {
//   String _activeFilter = 'all';

//   static const _filters = [
//     ('all', 'All', Icons.list_rounded),
//     ('call', 'Calls', Icons.videocam_outlined),
//     ('gift', 'Gifts', Icons.card_giftcard),
//     ('recharge', 'Recharge', Icons.add_circle_outline),
//     ('unlock', 'Unlock', Icons.lock_open_outlined),
//     ('bonus', 'Bonus', Icons.stars_outlined),
//   ];

//   List<Map<String, dynamic>> get _filtered {
//     if (_activeFilter == 'all') return widget.ledger;
//     return widget.ledger.where((txn) {
//       final type = txn['type'] as String? ?? '';
//       switch (_activeFilter) {
//         case 'call':
//           return type.contains('call');
//         case 'gift':
//           return type.contains('gift');
//         case 'recharge':
//           return type == 'recharge';
//         case 'unlock':
//           return type == 'unlock';
//         case 'bonus':
//           return type.contains('bonus');
//         default:
//           return true;
//       }
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final filtered = _filtered;

//     return Scaffold(
//       backgroundColor: c.bg,
//       appBar: _subPageAppBar(
//         context,
//         'Transactions',
//         countBadge: '${widget.ledger.length}',
//       ),
//       body: Column(
//         children: [
//           // Filter chips
//           SizedBox(
//             height: 48,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//               ),
//               itemCount: _filters.length,
//               separatorBuilder: (_, __) =>
//                   const SizedBox(width: 8),
//               itemBuilder: (_, i) {
//                 final (key, label, icon) = _filters[i];
//                 final isActive = _activeFilter == key;
//                 return GestureDetector(
//                   onTap: () =>
//                       setState(() => _activeFilter = key),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isActive
//                           ? c.pink.withOpacity(0.1)
//                           : c.surface,
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(
//                         color: isActive
//                             ? c.pink.withOpacity(0.4)
//                             : c.divider,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           icon,
//                           size: 15,
//                           color: isActive
//                               ? c.pink
//                               : c.textSecondary,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           label,
//                           style: TextStyle(
//                             color: isActive
//                                 ? c.pink
//                                 : c.textSecondary,
//                             fontSize: 13,
//                             fontWeight: isActive
//                                 ? FontWeight.w600
//                                 : FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 8),
//           // List
//           Expanded(
//             child: filtered.isEmpty
//                 ? const _EmptyState(
//                     icon: Icons.receipt_long_outlined,
//                     title: 'No transactions',
//                     subtitle: 'No activity for this filter yet',
//                   )
//                 : ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(
//                       20,
//                       8,
//                       20,
//                       40,
//                     ),
//                     itemCount: filtered.length,
//                     separatorBuilder: (_, __) => Divider(
//                       height: 1,
//                       color: c.divider,
//                       indent: 66,
//                     ),
//                     itemBuilder: (_, i) {
//                       final txn = filtered[i];
//                       final amount =
//                           (txn['amount'] as num?)?.toInt() ?? 0;
//                       final type = txn['type'] as String? ?? '';
//                       final isPositive = amount > 0;
//                       final date = DateTime.tryParse(
//                         txn['created_at'] ?? '',
//                       );
//                       final dateStr = date != null
//                           ? '${date.day} ${_monthNameStatic(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
//                           : '';
//                       final config = _txnConfigStatic(type);

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 10,
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 color: config.color.withOpacity(
//                                   0.08,
//                                 ),
//                                 borderRadius:
//                                     BorderRadius.circular(15),
//                                 border: Border.all(
//                                   color: config.color
//                                       .withOpacity(0.15),
//                                 ),
//                               ),
//                               child: Icon(
//                                 config.icon,
//                                 color: config.color,
//                                 size: 22,
//                               ),
//                             ),
//                             const SizedBox(width: 14),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     config.label,
//                                     style: TextStyle(
//                                       color: c.textPrimary,
//                                       fontWeight:
//                                           FontWeight.w600,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 3),
//                                   Text(
//                                     dateStr,
//                                     style: TextStyle(
//                                       color: c.textSecondary,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding:
//                                   const EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 6,
//                                   ),
//                               decoration: BoxDecoration(
//                                 color:
//                                     (isPositive
//                                             ? Colors.green
//                                             : Colors.redAccent)
//                                         .withOpacity(0.08),
//                                 borderRadius:
//                                     BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color:
//                                       (isPositive
//                                               ? Colors.green
//                                               : Colors.redAccent)
//                                           .withOpacity(0.15),
//                                 ),
//                               ),
//                               child: Text(
//                                 '${isPositive ? '+' : ''}$amount',
//                                 style: TextStyle(
//                                   color: isPositive
//                                       ? Colors.green
//                                       : Colors.redAccent,
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Top Up Page ─────────────────────────────────────────────────────────────

// class _TopUpPage extends StatelessWidget {
//   const _TopUpPage({
//     required this.packages,
//     required this.currentCoins,
//   });
//   final List<Map<String, dynamic>> packages;
//   final int currentCoins;

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: c.bg,
//       appBar: _subPageAppBar(context, 'Top Up'),
//       body: Column(
//         children: [
//           // Hero balance
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 28),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isDark
//                       ? [
//                           const Color(0xFF2D1B4E),
//                           const Color(0xFF1A0D30),
//                         ]
//                       : [
//                           const Color(0xFFFFF0F7),
//                           const Color(0xFFFFE4EF),
//                         ],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: c.pink.withOpacity(0.2),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: c.pink.withOpacity(0.08),
//                     blurRadius: 20,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: c.gold.withOpacity(0.12),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: c.gold.withOpacity(0.2),
//                       ),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         '💎',
//                         style: TextStyle(fontSize: 30),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   Text(
//                     'Current Balance',
//                     style: TextStyle(
//                       color: c.textSecondary,
//                       fontSize: 12,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '$currentCoins',
//                     style: GoogleFonts.poppins(
//                       color: c.gold,
//                       fontSize: 36,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   Text(
//                     'coins',
//                     style: TextStyle(
//                       color: c.textSecondary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Header
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: [
//                 Text(
//                   'Choose a Pack',
//                   style: GoogleFonts.poppins(
//                     color: c.textPrimary,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.green.withOpacity(0.15),
//                     ),
//                   ),
//                   child: const Text(
//                     '100% Secure',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//           // Packages
//           Expanded(
//             child: packages.isEmpty
//                 ? Center(
//                     child: Text(
//                       'No packages available',
//                       style: TextStyle(color: c.textSecondary),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(
//                       20,
//                       0,
//                       20,
//                       40,
//                     ),
//                     itemCount: packages.length,
//                     itemBuilder: (_, i) {
//                       final pkg = packages[i];
//                       final coins =
//                           (pkg['coins_amount'] as num?)
//                               ?.toInt() ??
//                           0;
//                       final price =
//                           (pkg['price'] as num?)?.toDouble() ??
//                           0;
//                       final currency =
//                           pkg['currency'] as String? ?? 'INR';
//                       final name =
//                           pkg['name'] as String? ??
//                           '$coins Coins';
//                       final isBest =
//                           packages.length > 2 &&
//                           i == packages.length ~/ 2;

//                       return Padding(
//                         padding: const EdgeInsets.only(
//                           bottom: 12,
//                         ),
//                         child: GestureDetector(
//                           onTap: () {
//                             ScaffoldMessenger.of(
//                               context,
//                             ).showSnackBar(
//                               SnackBar(
//                                 content: const Text(
//                                   'Payment integration coming soon!',
//                                 ),
//                                 backgroundColor: c.pink,
//                                 behavior:
//                                     SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: isBest
//                                   ? c.pink.withOpacity(0.04)
//                                   : c.surface,
//                               borderRadius:
//                                   BorderRadius.circular(18),
//                               border: Border.all(
//                                 color: isBest
//                                     ? c.pink.withOpacity(0.4)
//                                     : c.divider,
//                                 width: isBest ? 1.5 : 1,
//                               ),
//                               boxShadow: isBest
//                                   ? [
//                                       BoxShadow(
//                                         color: c.pink
//                                             .withOpacity(0.08),
//                                         blurRadius: 16,
//                                       ),
//                                     ]
//                                   : null,
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 50,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         c.gold.withOpacity(0.15),
//                                         c.gold.withOpacity(0.05),
//                                       ],
//                                     ),
//                                     borderRadius:
//                                         BorderRadius.circular(
//                                           15,
//                                         ),
//                                     border: Border.all(
//                                       color: c.gold.withOpacity(
//                                         0.2,
//                                       ),
//                                     ),
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       '💎',
//                                       style: TextStyle(
//                                         fontSize: 22,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 14),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Text(
//                                             name,
//                                             style: TextStyle(
//                                               color:
//                                                   c.textPrimary,
//                                               fontSize: 15,
//                                               fontWeight:
//                                                   FontWeight
//                                                       .w700,
//                                             ),
//                                           ),
//                                           if (isBest) ...[
//                                             const SizedBox(
//                                               width: 8,
//                                             ),
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal:
//                                                         8,
//                                                     vertical: 2,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 gradient: LinearGradient(
//                                                   colors: [
//                                                     c.pink,
//                                                     const Color(
//                                                       0xFFFF6B9D,
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       10,
//                                                     ),
//                                               ),
//                                               child: const Text(
//                                                 'POPULAR',
//                                                 style: TextStyle(
//                                                   color: Colors
//                                                       .white,
//                                                   fontSize: 8,
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .w800,
//                                                   letterSpacing:
//                                                       0.5,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ],
//                                       ),
//                                       const SizedBox(height: 3),
//                                       Text(
//                                         '$coins coins',
//                                         style: TextStyle(
//                                           color: c.gold,
//                                           fontSize: 12,
//                                           fontWeight:
//                                               FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   padding:
//                                       const EdgeInsets.symmetric(
//                                         horizontal: 20,
//                                         vertical: 11,
//                                       ),
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         c.pink,
//                                         const Color(0xFFFF6B9D),
//                                       ],
//                                     ),
//                                     borderRadius:
//                                         BorderRadius.circular(
//                                           24,
//                                         ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: c.pink
//                                             .withOpacity(0.3),
//                                         blurRadius: 8,
//                                         offset: const Offset(
//                                           0,
//                                           2,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Text(
//                                     '${currency == 'INR' ? '₹' : '\$'}${price.toStringAsFixed(0)}',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight:
//                                           FontWeight.w700,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Legal Page ───────────────────────────────────────────────────────────────

// class _LegalPage extends StatelessWidget {
//   const _LegalPage({required this.title});
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     return Scaffold(
//       backgroundColor: c.bg,
//       appBar: _subPageAppBar(context, title),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 40),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: c.pink.withOpacity(0.06),
//                   border: Border.all(
//                     color: c.pink.withOpacity(0.12),
//                   ),
//                 ),
//                 child: Icon(
//                   title.contains('Privacy')
//                       ? Icons.shield_outlined
//                       : title.contains('Terms')
//                       ? Icons.description_outlined
//                       : Icons.info_outline,
//                   size: 36,
//                   color: c.pink.withOpacity(0.4),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Coming Soon',
//                 style: GoogleFonts.poppins(
//                   color: c.textPrimary,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'This content will be available when the app launches. For now, contact support for any legal inquiries.',
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/profile_screen.dart
//
// User's own profile — settings, wallet, host earnings, preferences.
// Fully adaptive to all screen sizes.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';
import 'package:cheerchat/services/auth_service.dart';
import 'package:cheerchat/services/social_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cheerchat/models/app_user.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/screens/host_application_screen.dart';
import 'package:cheerchat/screens/profile_details_screen.dart';
import 'package:cheerchat/providers/theme_provider.dart';
import 'package:cheerchat/providers/auth_provider.dart';
import 'package:cheerchat/providers/user_provider.dart';
import 'package:cheerchat/providers/wallet_provider.dart';
import 'package:cheerchat/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Map<String, dynamic>> _blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadSocialStats();
  }

  Future<void> _loadSocialStats() async {
    try {
      final social = ref.read(socialServiceProvider);
      final followers = await social.getFollowers();
      final following = await social.getFollowing();
      if (mounted) {
        setState(() {
          _followerCount = followers.length;
          _followingCount = following.length;
        });
      }
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final c = AppColors.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: isError ? Colors.redAccent : c.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _todo(String feature) => _snack('$feature coming soon!');

  // ── Photo picker ──────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null || !mounted) return;
    setState(() => _isUploadingPhoto = true);
    try {
      // TODO: Upload to Firebase Storage → PUT /api/me { profile_photo_url }
      _snack('Photo upload coming soon!');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // ── Edit name ─────────────────────────────────────────────────────────────

  void _editName(String current) {
    final c = AppColors.of(context);
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit Name',
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 24,
          style: TextStyle(color: c.textPrimary),
          cursorColor: c.pink,
          decoration: InputDecoration(
            hintText: 'Display name',
            hintStyle: TextStyle(color: c.textSecondary),
            counterStyle: TextStyle(color: c.textSecondary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.pink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              final api = ref.read(apiServiceProvider);
              final res = await api.put(
                '/api/me',
                body: {'display_name': newName},
              );
              if (res.ok) {
                ref.read(currentUserProvider.notifier).refresh();
                _snack('Name updated!');
              } else {
                _snack(
                  res.error ?? 'Could not update name',
                  isError: true,
                );
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: c.pink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  void _confirmLogout() {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out?',
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You will need to sign in again.',
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final logoutNotifier = ref.read(
                isLoggingOutProvider.notifier,
              );
              final userNotifier = ref.read(
                currentUserProvider.notifier,
              );
              final authSvc = ref.read(authServiceProvider);
              Navigator.pop(ctx);
              logoutNotifier.start();
              userNotifier.clear();
              await authSvc.signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete account ────────────────────────────────────────────────────────

  void _confirmDeleteAccount() {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.poppins(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This is permanent. All your data, coins, and history will be erased and cannot be recovered.',
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('Delete account coming soon.');
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Clear cache dialog ────────────────────────────────────────────────────

  void _showClearCacheDialog() {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear Cache?',
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Cached images and data will be removed. The app may load slower temporarily.',
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              CachedNetworkImage.evictFromCache('');
              _snack('Cache cleared');
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: c.pink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Help sheet ────────────────────────────────────────────────────────────

  void _showHelpSheet({required bool isHost}) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Help & Support',
                  style: GoogleFonts.poppins(
                    color: c.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _sheetTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contact Support',
                  onTap: () {
                    Navigator.pop(ctx);
                    _todo('Customer support');
                  },
                ),
                _sheetTile(
                  icon: Icons.quiz_outlined,
                  label: 'FAQ',
                  onTap: () {
                    Navigator.pop(ctx);
                    _todo('FAQ');
                  },
                ),
                if (isHost) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Divider(color: c.divider),
                  ),
                  Text(
                    'For Hosts',
                    style: GoogleFonts.poppins(
                      color: c.pink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _sheetTile(
                    icon: Icons.lightbulb_outline,
                    label: 'Request a Feature',
                    onTap: () {
                      Navigator.pop(ctx);
                      _todo('Feature request');
                    },
                  ),
                  _sheetTile(
                    icon: Icons.feedback_outlined,
                    label: 'Share Feedback',
                    onTap: () {
                      Navigator.pop(ctx);
                      _todo('Feedback form');
                    },
                  ),
                  _sheetTile(
                    icon: Icons.campaign_outlined,
                    label: 'Host Community',
                    onTap: () {
                      Navigator.pop(ctx);
                      _todo('Host forum');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Navigate to a full-screen list page ────────────────────────────────

  void _pushPage(Widget page) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => page));
  }

  // ── Follow list ───────────────────────────────────────────────────────────

  void _showFollowList(String type) async {
    final social = ref.read(socialServiceProvider);
    final list = type == 'Followers'
        ? await social.getFollowers()
        : await social.getFollowing();
    if (!mounted) return;
    _pushPage(
      _UserListPage(
        title: type,
        users: list,
        emptyIcon: type == 'Followers'
            ? Icons.people_outline
            : Icons.person_add_outlined,
        emptyTitle: 'No $type yet',
        emptySubtitle: type == 'Followers'
            ? 'When someone follows you, they\'ll appear here'
            : 'Hosts you follow will show up here',
      ),
    );
  }

  // ── Blocked users ─────────────────────────────────────────────────────────

  void _showBlockedUsers() async {
    final social = ref.read(socialServiceProvider);
    final blocked = await social.getBlocked();
    if (!mounted) return;
    _pushPage(
      _BlockedUsersPage(
        blockedUsers: blocked,
        onUnblock: (id) => social.unblock(id),
      ),
    );
  }

  // ── Transaction history ───────────────────────────────────────────────────

  void _showTransactionHistory() async {
    final api = ref.read(apiServiceProvider);
    final res = await api.get(
      '/api/wallet/ledger',
      query: {'limit': '100'},
    );
    final List<Map<String, dynamic>> ledger = res.ok
        ? (res.data['ledger'] as List)
              .cast<Map<String, dynamic>>()
        : [];
    if (!mounted) return;
    _pushPage(_TransactionHistoryPage(ledger: ledger));
  }

  // ── Top Up ────────────────────────────────────────────────────────────────

  void _showTopUpSheet() async {
    final api = ref.read(apiServiceProvider);
    final res = await api.get('/api/wallet/packages');
    final List<Map<String, dynamic>> packages = res.ok
        ? (res.data['packages'] as List)
              .cast<Map<String, dynamic>>()
        : [];
    if (!mounted) return;
    final walletState = ref.read(walletBalanceProvider);
    final currentCoins =
        walletState.asData?.value?.coinBalance ?? 0;
    _pushPage(
      _TopUpPage(packages: packages, currentCoins: currentCoins),
    );
  }

  // ── Legal ─────────────────────────────────────────────────────────────────

  void _showLegalPage(String title) {
    _pushPage(_LegalPage(title: title));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(currentUserProvider);
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bg,
        body: asyncUser.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: c.pink),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Could not load profile',
                  style: TextStyle(color: c.textSecondary),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref
                      .read(currentUserProvider.notifier)
                      .refresh(),
                  child: Text(
                    'Retry',
                    style: TextStyle(color: c.pink),
                  ),
                ),
              ],
            ),
          ),
          data: (user) => _buildBody(user),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(AppUser? user) {
    final coins = user?.coins ?? 0;
    final level = user?.level ?? 1;
    final levelLabel = user?.levelLabel ?? 'Newcomer';
    final publicId = user?.publicId;
    final countryCode = user?.countryCode ?? 'IN';
    final language = user?.language ?? '';
    final photoUrl = user?.profilePhotoUrl;
    final age = user?.age;
    final isHost = user?.isHost ?? false;
    final name = user?.displayName ?? 'Guest';

    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness ==
                Brightness.dark);

    // Adaptive sizing
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final hPad = (sw * 0.04).clamp(12.0, 20.0);

    return RefreshIndicator(
      color: AppColors.of(context).pink,
      onRefresh: () async {
        ref.read(currentUserProvider.notifier).refresh();
        _loadSocialStats();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(
              name,
              photoUrl,
              level,
              levelLabel,
              publicId,
              countryCode,
              age,
              sw,
              sh,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSocialStats(),
                const SizedBox(height: 12),
                _buildCoinsCard(coins),

                if (isHost) ...[
                  const SizedBox(height: 12),
                  _buildHostEarningsCard(),
                ],

                const SizedBox(height: 20),
                _sectionLabel('Discover'),
                _tileGroup([
                  if (!isHost)
                    _tile(
                      icon: FontAwesomeIcons.star,
                      iconColor: const Color(0xFFFFCA28),
                      label: 'Become a Host',
                      badge: 'Apply',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const HostApplicationScreen(),
                          ),
                        );
                      },
                    ),
                  _tile(
                    icon: FontAwesomeIcons.userGroup,
                    iconColor: const Color(0xFF42A5F5),
                    label: 'Invite Friends',
                    subtitle: 'Earn coins per referral',
                    onTap: () => _todo('Referrals'),
                  ),
                ]),

                const SizedBox(height: 20),
                _sectionLabel('Preferences'),
                _tileGroup([
                  _tile(
                    icon: isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    iconColor: isDark
                        ? const Color(0xFF7C4DFF)
                        : const Color(0xFFFFB300),
                    label: 'Appearance',
                    subtitle: isDark
                        ? 'Dark mode'
                        : 'Light mode',
                    trailing: _themeToggle(isDark),
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .toggle(),
                  ),
                  _tile(
                    icon: Icons.language_outlined,
                    label: 'App Language',
                    subtitle: language.isNotEmpty
                        ? language
                        : 'English',
                    onTap: () => _todo('Language picker'),
                  ),
                  _tile(
                    icon: Icons.notifications_outlined,
                    label: 'Notification Settings',
                    onTap: () => _todo('Notification settings'),
                  ),
                  _tile(
                    icon: Icons.auto_fix_high_outlined,
                    iconColor: const Color(0xFFCE93D8),
                    label: 'Camera Beauty',
                    onTap: () => _todo('Beauty settings'),
                  ),
                ]),

                const SizedBox(height: 20),
                _sectionLabel('Storage & Updates'),
                _tileGroup([
                  _tile(
                    icon: Icons.cleaning_services_outlined,
                    label: 'Clear Cache',
                    onTap: _showClearCacheDialog,
                  ),
                  _tile(
                    icon: Icons.system_update_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Check for Updates',
                    onTap: () => _todo('Update check'),
                  ),
                ]),

                const SizedBox(height: 20),
                _sectionLabel('Legal & Info'),
                _tileGroup([
                  _tile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy Policy',
                    onTap: () =>
                        _showLegalPage('Privacy Policy'),
                  ),
                  _tile(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    onTap: () =>
                        _showLegalPage('Terms of Service'),
                  ),
                  _tile(
                    icon: Icons.info_outline,
                    label: 'About Us',
                    onTap: () => _showLegalPage('About Us'),
                  ),
                  _tile(
                    icon: Icons.star_border_outlined,
                    iconColor: const Color(0xFFFFCA28),
                    label: 'Rate Our App',
                    onTap: () =>
                        _snack('Play Store rating coming soon!'),
                  ),
                ]),

                const SizedBox(height: 20),
                _sectionLabel('Support'),
                _tileGroup([
                  _tile(
                    icon: Icons.headset_mic_outlined,
                    label: 'Help & Support',
                    subtitle: isHost
                        ? 'Support · Feature requests · Feedback'
                        : null,
                    onTap: () => _showHelpSheet(isHost: isHost),
                  ),
                  _tile(
                    icon: Icons.bug_report_outlined,
                    label: 'Report a Bug',
                    onTap: () => _todo('Bug report'),
                  ),
                ]),

                const SizedBox(height: 20),
                _sectionLabel('Account'),
                _tileGroup([
                  _tile(
                    icon: Icons.link_outlined,
                    label: 'Bind Accounts',
                    subtitle: 'Google · Phone · Apple',
                    onTap: () => _todo('Bind accounts'),
                  ),
                  _tile(
                    icon: Icons.block_outlined,
                    label: 'Blocked Users',
                    onTap: _showBlockedUsers,
                  ),
                  _tile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaction History',
                    onTap: _showTransactionHistory,
                  ),
                  _tile(
                    icon: FontAwesomeIcons.trash,
                    iconSize: 16,
                    iconColor: Colors.redAccent,
                    label: 'Delete Account',
                    labelColor: Colors.redAccent,
                    onTap: _confirmDeleteAccount,
                  ),
                ]),

                const SizedBox(height: 20),
                _logoutButton(),
                SizedBox(height: mq.padding.bottom + 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (adaptive) ─────────────────────────────────────────────────────

  Widget _buildHeader(
    String name,
    String? photoUrl,
    int level,
    String levelLabel,
    int? publicId,
    String countryCode,
    int? age,
    double sw,
    double sh,
  ) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    // Proportional sizes
    final headerH = (sh * 0.28).clamp(200.0, 280.0);
    final avatarSize = (sw * 0.2).clamp(64.0, 96.0);
    final cameraBadge = (avatarSize * 0.3).clamp(20.0, 28.0);
    final titleSize = (sw * 0.055).clamp(18.0, 24.0);
    final nameSize = (sw * 0.05).clamp(16.0, 22.0);
    final hPad = (sw * 0.04).clamp(12.0, 20.0);

    return Stack(
      children: [
        Container(
          height: headerH,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF2D0A1F),
                      const Color(0xFF0D0D0D),
                    ]
                  : [const Color(0xFFFFE4F0), c.bg],
            ),
          ),
        ),
        // Radial glow — proportional to screen width
        Positioned(
          top: -sw * 0.1,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: sw * 0.85,
              height: sw * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.pink.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    color: c.textPrimary,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: sh * 0.018),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    _avatar(photoUrl, avatarSize, cameraBadge),
                    SizedBox(width: sw * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Name + edit
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    color: c.textPrimary,
                                    fontSize: nameSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _editName(name),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: c.pink.withOpacity(
                                      0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: (nameSize * 0.6).clamp(
                                      11.0,
                                      15.0,
                                    ),
                                    color: c.pink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Meta pills — Wrap handles overflow automatically
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment:
                                WrapCrossAlignment.center,
                            children: [
                              if (age != null)
                                _metaPill(
                                  '$age yrs',
                                  Icons.cake_outlined,
                                  const Color(0xFFFF8A65),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(3),
                                    child: Flag.fromString(
                                      countryCode,
                                      width: 22,
                                      height: 15,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    countryCode,
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              _metaPill(
                                'Lv.$level $levelLabel',
                                Icons.bolt,
                                c.pink,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (publicId != null)
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: '$publicId',
                                  ),
                                );
                                _snack('ID copied!');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ID: $publicId',
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.copy,
                                    size: 10,
                                    color: c.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Avatar (adaptive) ─────────────────────────────────────────────────────

  Widget _avatar(
    String? photoUrl,
    double size,
    double badgeSize,
  ) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: _pickPhoto,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.pink, width: 2.5),
            ),
            child: ClipOval(
              child: _isUploadingPhoto
                  ? Container(
                      color: c.surface,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: c.pink,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: c.surface),
                      errorWidget: (_, __, ___) =>
                          _avatarFallback(size),
                    )
                  : _avatarFallback(size),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: c.pink,
                shape: BoxShape.circle,
                border: Border.all(color: c.bg, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                size: badgeSize * 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(double size) {
    final c = AppColors.of(context);
    return Container(
      color: c.avatarFallback,
      child: Icon(
        Icons.person,
        color: c.avatarIcon,
        size: size * 0.5,
      ),
    );
  }

  Widget _metaPill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Social stats ──────────────────────────────────────────────────────────

  Widget _buildSocialStats() {
    final c = AppColors.of(context);

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.divider),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _socialStat(
                _followerCount,
                'Followers',
                onTap: () => _showFollowList('Followers'),
              ),
              VerticalDivider(width: 1, color: c.divider),
              _socialStat(
                _followingCount,
                'Following',
                onTap: () => _showFollowList('Following'),
              ),
              VerticalDivider(width: 1, color: c.divider),
              _socialStat(
                0,
                'Mutuals',
                onTap: () => _snack('Mutuals coming soon!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialStat(
    int count,
    String label, {
    required VoidCallback onTap,
  }) {
    final c = AppColors.of(context);
    final sw = MediaQuery.of(context).size.width;
    final fontSize = (sw * 0.045).clamp(14.0, 20.0);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(
                _formatCount(count),
                style: GoogleFonts.poppins(
                  color: c.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000)
      return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  // ── Coins card ────────────────────────────────────────────────────────────

  Widget _buildCoinsCard(int coins) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final iconBox = (sw * 0.12).clamp(38.0, 50.0);
    final coinFontSize = (sw * 0.05).clamp(16.0, 22.0);

    return Container(
      padding: EdgeInsets.all((sw * 0.045).clamp(14.0, 20.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A0D12),
                  const Color(0xFF221228),
                ]
              : [
                  const Color(0xFFFFF0F7),
                  const Color(0xFFFFE4EF),
                ],
        ),
        border: Border.all(color: c.pink.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: c.pink.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: c.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                '💎',
                style: TextStyle(fontSize: iconBox * 0.48),
              ),
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Balance',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$coins coins',
                  style: GoogleFonts.poppins(
                    color: c.gold,
                    fontSize: coinFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showTopUpSheet,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.pink, const Color(0xFFFF6B9D)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: c.pink.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Top Up',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Host earnings card ────────────────────────────────────────────────────

  Widget _buildHostEarningsCard() {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final pad = (sw * 0.045).clamp(14.0, 20.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0D1A0D),
                  const Color(0xFF122212),
                ]
              : [
                  const Color(0xFFF0FFF0),
                  const Color(0xFFE8F5E9),
                ],
        ),
        border: Border.all(color: c.green.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: c.green.withOpacity(0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: c.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Host Earnings',
                  style: GoogleFonts.poppins(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'This month',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _earningsStat('₹ 0', 'Available', c),
              const SizedBox(width: 16),
              _earningsStat('₹ 0', 'Withdrawn', c),
              const SizedBox(width: 16),
              _earningsStat('0', 'Call Mins', c),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _outlineButton(
                  label: 'Bind Bank / UPI',
                  icon: Icons.account_balance_outlined,
                  color: c.textSecondary,
                  onTap: () => _todo('Bind bank account'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineButton(
                  label: 'Withdraw',
                  icon: Icons.arrow_circle_down_outlined,
                  color: c.green,
                  onTap: () => _todo('Withdraw earnings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningsStat(String value, String label, AppColors c) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: c.green,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheet tile ────────────────────────────────────────────────────────────

  Widget _sheetTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    final c = AppColors.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.pink.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: c.pink),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: c.textSecondary,
      ),
      onTap: onTap,
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Widget _logoutButton() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tile components ───────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          color: c.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _tileGroup(List<Widget?> tiles) {
    final c = AppColors.of(context);
    final visible = tiles.whereType<Widget>().toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.divider),
        ),
        child: Column(
          children: [
            for (int i = 0; i < visible.length; i++) ...[
              visible[i],
              if (i < visible.length - 1)
                Divider(height: 1, color: c.divider, indent: 54),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double iconSize = 19,
    Color? iconColor,
    Color? labelColor,
    String? subtitle,
    String? badge,
    Widget? trailing,
  }) {
    final c = AppColors.of(context);
    final effectiveIconColor = iconColor ?? c.textSecondary;
    final effectiveLabelColor = labelColor ?? c.textPrimary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: effectiveIconColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: effectiveIconColor,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: effectiveLabelColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
              ),
            )
          : null,
      trailing:
          trailing ??
          (badge != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.pink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: c.pink,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: c.textSecondary.withOpacity(0.5),
                )),
    );
  }

  // ── Theme toggle ──────────────────────────────────────────────────────────

  Widget _themeToggle(bool isDark) {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: isDark
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 13,
                color: isDark
                    ? const Color(0xFF7C4DFF)
                    : const Color(0xFFFFB300),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper class ────────────────────────────────────────────────────────────

class _TxnConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _TxnConfig(this.icon, this.color, this.label);
}

_TxnConfig _txnConfigStatic(String type) {
  switch (type) {
    case 'recharge':
      return _TxnConfig(
        Icons.add_circle_outline,
        Colors.green,
        'Recharge',
      );
    case 'call_spent':
      return _TxnConfig(
        Icons.videocam_outlined,
        Colors.orange,
        'Video Call',
      );
    case 'call_earned':
      return _TxnConfig(
        Icons.videocam_outlined,
        Colors.green,
        'Call Earning',
      );
    case 'gift_sent':
      return _TxnConfig(
        Icons.card_giftcard,
        Colors.pink,
        'Gift Sent',
      );
    case 'gift_received':
      return _TxnConfig(
        Icons.card_giftcard,
        Colors.green,
        'Gift Received',
      );
    case 'bonus':
      return _TxnConfig(
        Icons.stars_outlined,
        Colors.amber.shade700,
        'Bonus',
      );
    case 'signup_bonus':
      return _TxnConfig(
        Icons.celebration_outlined,
        Colors.amber.shade700,
        'Welcome Bonus',
      );
    case 'daily_bonus':
      return _TxnConfig(
        Icons.today_outlined,
        Colors.blue,
        'Daily Bonus',
      );
    case 'unlock':
      return _TxnConfig(
        Icons.lock_open_outlined,
        Colors.blue,
        'Chat Unlock',
      );
    case 'referral':
      return _TxnConfig(
        Icons.people_outline,
        Colors.teal,
        'Referral Reward',
      );
    default:
      return _TxnConfig(
        Icons.swap_horiz,
        Colors.grey,
        type.replaceAll('_', ' '),
      );
  }
}

String _monthNameStatic(int m) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return m >= 1 && m <= 12 ? months[m] : '';
}

// ═════════════════════════════════════════════════════════════════════════════
// FULL-SCREEN SUB-PAGES
// ═════════════════════════════════════════════════════════════════════════════

/// Reusable empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.pink.withOpacity(isDark ? 0.08 : 0.06),
                    c.pink.withOpacity(0.02),
                  ],
                ),
                border: Border.all(
                  color: c.pink.withOpacity(0.1),
                ),
              ),
              child: Icon(
                icon,
                size: 42,
                color: c.pink.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable AppBar for sub-pages
PreferredSizeWidget _subPageAppBar(
  BuildContext context,
  String title, {
  String? countBadge,
}) {
  final c = AppColors.of(context);
  return AppBar(
    backgroundColor: c.bg,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            shape: BoxShape.circle,
            border: Border.all(color: c.divider),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: c.textPrimary,
          ),
        ),
      ),
    ),
    title: Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (countBadge != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: c.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              countBadge,
              style: TextStyle(
                color: c.pink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    ),
    centerTitle: false,
  );
}

/// Reusable user avatar
Widget _userAvatar(
  String? photoUrl,
  AppColors c, {
  Color? borderColor,
  double size = 50,
}) {
  final bc = borderColor ?? c.pink;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bc.withOpacity(0.15), bc.withOpacity(0.05)],
      ),
      border: Border.all(
        color: bc.withOpacity(0.25),
        width: 1.5,
      ),
    ),
    child: ClipOval(
      child: photoUrl != null
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person,
                color: bc.withOpacity(0.4),
                size: size * 0.44,
              ),
            )
          : Icon(
              Icons.person,
              color: bc.withOpacity(0.4),
              size: size * 0.44,
            ),
    ),
  );
}

// ── User List Page (Followers / Following) ──────────────────────────────────

class _UserListPage extends StatelessWidget {
  const _UserListPage({
    required this.title,
    required this.users,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });
  final String title;
  final List<Map<String, dynamic>> users;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: _subPageAppBar(
        context,
        title,
        countBadge: '${users.length}',
      ),
      body: users.isEmpty
          ? _EmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              subtitle: emptySubtitle,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: c.divider,
                indent: 66,
              ),
              itemBuilder: (_, i) {
                final user = users[i];
                final name =
                    user['display_name'] as String? ?? 'User';
                final photo =
                    user['profile_photo_url'] as String?;
                final pid = user['public_id'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _userAvatar(photo, c),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (pid != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'ID: $pid',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ── Blocked Users Page ──────────────────────────────────────────────────────

class _BlockedUsersPage extends StatefulWidget {
  const _BlockedUsersPage({
    required this.blockedUsers,
    required this.onUnblock,
  });
  final List<Map<String, dynamic>> blockedUsers;
  final Future<bool> Function(String id) onUnblock;

  @override
  State<_BlockedUsersPage> createState() =>
      _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<_BlockedUsersPage> {
  late List<Map<String, dynamic>> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.blockedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: _subPageAppBar(
        context,
        'Blocked Users',
        countBadge: '${_list.length}',
      ),
      body: _list.isEmpty
          ? const _EmptyState(
              icon: Icons.shield_outlined,
              title: 'No blocked users',
              subtitle:
                  'Users you block won\'t be able to\ncall or message you',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              itemCount: _list.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: c.divider,
                indent: 66,
              ),
              itemBuilder: (_, i) {
                if (i >= _list.length)
                  return const SizedBox.shrink();
                final user = _list[i];
                final name =
                    user['display_name'] as String? ?? 'User';
                final photo =
                    user['profile_photo_url'] as String?;
                final pid = user['public_id'];

                return GestureDetector(
                  onTap: () {
                    // Navigate to profile details
                    final blockedId =
                        user['blocked_id'] as String?;
                    if (blockedId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileDetailsScreen(
                            host: HostModel(
                              userId: blockedId,
                              publicId: pid is int
                                  ? pid
                                  : int.tryParse('$pid') ?? 0,
                              displayName: name,
                              countryCode: 'UN',
                              language: '',
                              priceCoins: 0,
                              level: 1,
                              status: HostStatus.offline,
                              profilePhotoUrl: photo,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _userAvatar(
                          photo,
                          c,
                          borderColor: Colors.red.shade300,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              if (pid != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'ID: $pid',
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final ok = await widget.onUnblock(
                              user['blocked_id'] ?? '',
                            );
                            if (ok && mounted) {
                              setState(() => _list.removeAt(i));
                              ScaffoldMessenger.of(context)
                                ..clearSnackBars()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Unblocked $name',
                                    ),
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                    backgroundColor: c.pink,
                                    behavior: SnackBarBehavior
                                        .floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                    ),
                                  ),
                                );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  c.pink,
                                  const Color(0xFFFF6B9D),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: c.pink.withOpacity(
                                    0.25,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Unblock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── Transaction History Page ─────────────────────────────────────────────────

class _TransactionHistoryPage extends StatefulWidget {
  const _TransactionHistoryPage({required this.ledger});
  final List<Map<String, dynamic>> ledger;

  @override
  State<_TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends State<_TransactionHistoryPage> {
  String _activeFilter = 'all';

  static const _filters = [
    ('all', 'All', Icons.list_rounded),
    ('call', 'Calls', Icons.videocam_outlined),
    ('gift', 'Gifts', Icons.card_giftcard),
    ('recharge', 'Recharge', Icons.add_circle_outline),
    ('unlock', 'Unlock', Icons.lock_open_outlined),
    ('bonus', 'Bonus', Icons.stars_outlined),
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 'all') return widget.ledger;
    return widget.ledger.where((txn) {
      final type = txn['type'] as String? ?? '';
      switch (_activeFilter) {
        case 'call':
          return type.contains('call');
        case 'gift':
          return type.contains('gift');
        case 'recharge':
          return type == 'recharge';
        case 'unlock':
          return type == 'unlock';
        case 'bonus':
          return type.contains('bonus');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _subPageAppBar(
        context,
        'Transactions',
        countBadge: '${widget.ledger.length}',
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (key, label, icon) = _filters[i];
                final isActive = _activeFilter == key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _activeFilter = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? c.pink.withOpacity(0.1)
                          : c.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive
                            ? c.pink.withOpacity(0.4)
                            : c.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 15,
                          color: isActive
                              ? c.pink
                              : c.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: isActive
                                ? c.pink
                                : c.textSecondary,
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions',
                    subtitle: 'No activity for this filter yet',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      40,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: c.divider,
                      indent: 66,
                    ),
                    itemBuilder: (_, i) {
                      final txn = filtered[i];
                      final amount =
                          (txn['amount'] as num?)?.toInt() ?? 0;
                      final type = txn['type'] as String? ?? '';
                      final isPositive = amount > 0;
                      final date = DateTime.tryParse(
                        txn['created_at'] ?? '',
                      );
                      final dateStr = date != null
                          ? '${date.day} ${_monthNameStatic(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                          : '';
                      final config = _txnConfigStatic(type);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: config.color.withOpacity(
                                  0.08,
                                ),
                                borderRadius:
                                    BorderRadius.circular(15),
                                border: Border.all(
                                  color: config.color
                                      .withOpacity(0.15),
                                ),
                              ),
                              child: Icon(
                                config.icon,
                                color: config.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    config.label,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontWeight:
                                          FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                              decoration: BoxDecoration(
                                color:
                                    (isPositive
                                            ? Colors.green
                                            : Colors.redAccent)
                                        .withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      (isPositive
                                              ? Colors.green
                                              : Colors.redAccent)
                                          .withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                '${isPositive ? '+' : ''}$amount',
                                style: TextStyle(
                                  color: isPositive
                                      ? Colors.green
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
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
    );
  }
}

// ── Top Up Page ─────────────────────────────────────────────────────────────

class _TopUpPage extends StatelessWidget {
  const _TopUpPage({
    required this.packages,
    required this.currentCoins,
  });
  final List<Map<String, dynamic>> packages;
  final int currentCoins;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _subPageAppBar(context, 'Top Up'),
      body: Column(
        children: [
          // Hero balance
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF2D1B4E),
                          const Color(0xFF1A0D30),
                        ]
                      : [
                          const Color(0xFFFFF0F7),
                          const Color(0xFFFFE4EF),
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: c.pink.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.pink.withOpacity(0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: c.gold.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c.gold.withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '💎',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentCoins',
                    style: GoogleFonts.poppins(
                      color: c.gold,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'coins',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Choose a Pack',
                  style: GoogleFonts.poppins(
                    color: c.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.15),
                    ),
                  ),
                  child: const Text(
                    '100% Secure',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Packages
          Expanded(
            child: packages.isEmpty
                ? Center(
                    child: Text(
                      'No packages available',
                      style: TextStyle(color: c.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      40,
                    ),
                    itemCount: packages.length,
                    itemBuilder: (_, i) {
                      final pkg = packages[i];
                      final coins =
                          (pkg['coins_amount'] as num?)
                              ?.toInt() ??
                          0;
                      final price =
                          (pkg['price'] as num?)?.toDouble() ??
                          0;
                      final currency =
                          pkg['currency'] as String? ?? 'INR';
                      final name =
                          pkg['name'] as String? ??
                          '$coins Coins';
                      final isBest =
                          packages.length > 2 &&
                          i == packages.length ~/ 2;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Payment integration coming soon!',
                                ),
                                backgroundColor: c.pink,
                                behavior:
                                    SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isBest
                                  ? c.pink.withOpacity(0.04)
                                  : c.surface,
                              borderRadius:
                                  BorderRadius.circular(18),
                              border: Border.all(
                                color: isBest
                                    ? c.pink.withOpacity(0.4)
                                    : c.divider,
                                width: isBest ? 1.5 : 1,
                              ),
                              boxShadow: isBest
                                  ? [
                                      BoxShadow(
                                        color: c.pink
                                            .withOpacity(0.08),
                                        blurRadius: 16,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        c.gold.withOpacity(0.15),
                                        c.gold.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          15,
                                        ),
                                    border: Border.all(
                                      color: c.gold.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '💎',
                                      style: TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color:
                                                  c.textPrimary,
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                          if (isBest) ...[
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    c.pink,
                                                    const Color(
                                                      0xFFFF6B9D,
                                                    ),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ),
                                              ),
                                              child: const Text(
                                                'POPULAR',
                                                style: TextStyle(
                                                  color: Colors
                                                      .white,
                                                  fontSize: 8,
                                                  fontWeight:
                                                      FontWeight
                                                          .w800,
                                                  letterSpacing:
                                                      0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$coins coins',
                                        style: TextStyle(
                                          color: c.gold,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 11,
                                      ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        c.pink,
                                        const Color(0xFFFF6B9D),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          24,
                                        ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: c.pink
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(
                                          0,
                                          2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${currency == 'INR' ? '₹' : '\$'}${price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Legal Page ───────────────────────────────────────────────────────────────

class _LegalPage extends StatelessWidget {
  const _LegalPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: _subPageAppBar(context, title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.pink.withOpacity(0.06),
                  border: Border.all(
                    color: c.pink.withOpacity(0.12),
                  ),
                ),
                child: Icon(
                  title.contains('Privacy')
                      ? Icons.shield_outlined
                      : title.contains('Terms')
                      ? Icons.description_outlined
                      : Icons.info_outline,
                  size: 36,
                  color: c.pink.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Coming Soon',
                style: GoogleFonts.poppins(
                  color: c.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This content will be available when the app launches. For now, contact support for any legal inquiries.',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

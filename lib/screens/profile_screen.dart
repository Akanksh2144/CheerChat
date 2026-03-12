import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cheerchat/models/app_user.dart';
import 'package:cheerchat/providers/theme_provider.dart';
import 'package:cheerchat/providers/user_provider.dart';
import 'package:cheerchat/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final c = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
      // TODO: PUT /api/me/photo → refresh()
      _snack('Photo upload coming soon!');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

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
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              // TODO: PUT /api/me {display_name} → refresh()
              _snack('Name update coming soon!');
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
              Navigator.pop(ctx);
              ref.read(currentUserProvider.notifier).clear();
              await ref.read(authServiceProvider).signOut();
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
              // TODO: DELETE /api/me → signOut
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
          'Cached images and data will be removed. The app may load slower until content is re-downloaded.',
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
              _todo('Clear cache');
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
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
              label: 'Contact Customer Support',
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
                subtitle: 'Suggest improvements for the app',
                onTap: () {
                  Navigator.pop(ctx);
                  _todo('Feature request');
                },
              ),
              _sheetTile(
                icon: Icons.feedback_outlined,
                label: 'Share Feedback',
                subtitle: "Tell us what's working or not",
                onTap: () {
                  Navigator.pop(ctx);
                  _todo('Feedback form');
                },
              ),
              _sheetTile(
                icon: Icons.campaign_outlined,
                label: 'Host Community Forum',
                subtitle: 'Connect with other hosts',
                onTap: () {
                  Navigator.pop(ctx);
                  _todo('Host forum');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Root ──────────────────────────────────────────────────────────────────

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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Social stats ──────────────────────────────────────────
              _buildSocialStats(),
              const SizedBox(height: 12),

              // ── Wallet ────────────────────────────────────────────────
              _buildCoinsCard(coins),

              // ── Host earnings ─────────────────────────────────────────
              if (isHost) ...[
                const SizedBox(height: 12),
                _buildHostEarningsCard(),
              ],

              // ── Discover ──────────────────────────────────────────────
              const SizedBox(height: 20),
              _sectionLabel('Discover'),
              _tileGroup([
                if (!isHost)
                  _tile(
                    icon: FontAwesomeIcons.star,
                    iconColor: const Color(0xFFFFCA28),
                    label: 'Become a Host',
                    badge: 'Apply',
                    onTap: () => _todo('Host application'),
                  ),
                _tile(
                  icon: FontAwesomeIcons.userGroup,
                  iconColor: const Color(0xFF42A5F5),
                  label: 'Invite Friends',
                  subtitle: 'Earn coins per referral',
                  onTap: () => _todo('Referrals'),
                ),
              ]),

              // ── Preferences ───────────────────────────────────────────
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
                  subtitle: isDark ? 'Dark mode' : 'Light mode',
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
                _tile(
                  icon: Icons.do_not_disturb_alt_outlined,
                  label: 'Do Not Disturb',
                  trailing: _toggleChip(
                    false,
                    onTap: () => _todo('Do Not Disturb'),
                  ),
                  onTap: () {},
                ),
              ]),

              // ── Storage ───────────────────────────────────────────────
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

              // ── Legal & Info ──────────────────────────────────────────
              const SizedBox(height: 20),
              _sectionLabel('Legal & Info'),
              _tileGroup([
                _tile(
                  icon: Icons.shield_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _todo('Privacy policy'),
                ),
                _tile(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () => _todo('Terms of service'),
                ),
                _tile(
                  icon: Icons.handshake_outlined,
                  label: 'User Agreement',
                  onTap: () => _todo('User agreement'),
                ),
                _tile(
                  icon: Icons.info_outline,
                  label: 'About Us',
                  onTap: () => _todo('About us'),
                ),
                _tile(
                  icon: Icons.star_border_outlined,
                  iconColor: const Color(0xFFFFCA28),
                  label: 'Rate Our App',
                  onTap: () => _todo('Rate app'),
                ),
              ]),

              // ── Support ───────────────────────────────────────────────
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

              // ── Account ───────────────────────────────────────────────
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
                  onTap: () => _todo('Blocked users'),
                ),
                _tile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transaction History',
                  onTap: () => _todo('Transaction history'),
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
              const SizedBox(height: 48),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    String name,
    String? photoUrl,
    int level,
    String levelLabel,
    int? publicId,
    String countryCode,
    int? age,
  ) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          height: 230,
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
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 320,
              height: 220,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _avatar(photoUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Name + edit pencil
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    color: c.textPrimary,
                                    fontSize: 20,
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
                                    size: 13,
                                    color: c.pink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Age · Country · Level
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

  Widget _avatar(String? photoUrl) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: _pickPhoto,
      child: Stack(
        children: [
          Container(
            width: 86,
            height: 86,
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
                          _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: c.pink,
                shape: BoxShape.circle,
                border: Border.all(color: c.bg, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    final c = AppColors.of(context);
    return Container(
      color: c.avatarFallback,
      child: Icon(Icons.person, color: c.avatarIcon, size: 44),
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
    // TODO: replace with real counts from GET /api/me/stats
    const int followers = 0;
    const int following = 0;
    const int mutuals = 0;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.divider),
        ),
        child: Row(
          children: [
            _socialStat(
              followers,
              'Followers',
              onTap: () => _todo('Followers list'),
            ),
            Container(width: 1, height: 36, color: c.divider),
            _socialStat(
              following,
              'Following',
              onTap: () => _todo('Following list'),
            ),
            Container(width: 1, height: 36, color: c.divider),
            _socialStat(
              mutuals,
              'Mutuals',
              onTap: () => _todo('Mutuals list'),
            ),
          ],
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
                  fontSize: 18,
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

    return Container(
      padding: const EdgeInsets.all(18),
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
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: c.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Text('💎', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _todo('Wallet / Top Up'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
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

    return Container(
      padding: const EdgeInsets.all(18),
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
            spreadRadius: 0,
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
              Text(
                'Host Earnings',
                style: GoogleFonts.poppins(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheet tile (used in Help bottom sheet) ────────────────────────────────

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

  // ── Logout button ─────────────────────────────────────────────────────────

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

  // ── Reusable tile components ──────────────────────────────────────────────

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

  // ── Theme toggle (pill switch in Appearance tile) ─────────────────────────

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

  // ── DND toggle chip ───────────────────────────────────────────────────────

  Widget _toggleChip(bool value, {required VoidCallback onTap}) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? c.pink : c.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// lib/screens/inbox_screen.dart
//
// Inbox — quick-access bubbles + chat list.
// Story-ring bubbles: Notifications · Visitors · Call History · Promos
// Theme-aware: calls AppColors.of(context) per method — no static palette.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cheerchat/screens/chat_screen.dart';
import 'package:cheerchat/services/chat_services.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Quick-access items ────────────────────────────────────────────────────
  // Ring colors are always vivid — they work on both light and dark bg.
  // Badge counts stubbed — replace with real unread counts from API.

  static const List<_QuickItem> _quickItems = [
    _QuickItem(
      icon: Icons.notifications_outlined,
      label: 'Notifications',
      ringColors: [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
      badge: 3, // TODO: GET /api/notifications/unread
    ),
    _QuickItem(
      icon: Icons.visibility_outlined,
      label: 'Visitors',
      ringColors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
      badge: 12, // TODO: GET /api/profile/visitors/unread
    ),
    _QuickItem(
      icon: Icons.call_outlined,
      label: 'Call History',
      ringColors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
      badge: 0,
    ),
    _QuickItem(
      icon: Icons.local_offer_outlined,
      label: 'Promos',
      ringColors: [Color(0xFFFFCA28), Color(0xFFFF9800)],
      badge: 1, // TODO: GET /api/promos/unread
    ),
  ];

  // ── Root ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildQuickAccessRow(),
              _buildSectionHeader('Messages'),
              Expanded(child: _buildChatList()),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'Inbox',
        style: GoogleFonts.poppins(
          color: c.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Quick-access bubbles ──────────────────────────────────────────────────

  Widget _buildQuickAccessRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _quickItems
            .map((item) => _buildBubble(item))
            .toList(),
      ),
    );
  }

  Widget _buildBubble(_QuickItem item) {
    final c = AppColors.of(context);
    const double outerSize = 62;
    const double innerSize = 52;
    const double iconSize = 22;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.label} coming soon!'),
            duration: const Duration(seconds: 1),
            backgroundColor: c.pink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient ring
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.badge > 0
                    ? item.ringColors
                    : [c.border, c.border],
              ),
            ),
            child: Center(
              // Inner circle — creates the ring gap illusion
              child: Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  color: c.bubbleInner,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.badge > 0
                          ? item.ringColors
                          : [c.textSecondary, c.textSecondary],
                    ).createShader(bounds),
                    child: Icon(
                      item.icon,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Badge
          if (item.badge > 0)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.ringColors,
                  ),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: c.bg, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    item.badge > 99 ? '99+' : '${item.badge}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: c.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Chat list ─────────────────────────────────────────────────────────────

  Widget _buildChatList() {
    final c = AppColors.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getInbox(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: c.textSecondary),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: c.pink),
          );
        }

        final currentUid = _auth.currentUser!.uid;

        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final deletedFor = Map<String, dynamic>.from(
            data['deletedFor'] ?? {},
          );
          return deletedFor[currentUid] != true;
        }).toList();

        docs.sort((a, b) {
          final dA = a.data() as Map<String, dynamic>;
          final dB = b.data() as Map<String, dynamic>;
          final pA =
              (dA['pinnedBy'] as Map?)?[currentUid] == true;
          final pB =
              (dB['pinnedBy'] as Map?)?[currentUid] == true;
          if (pA && !pB) return -1;
          if (!pA && pB) return 1;
          return 0;
        });

        if (docs.isEmpty) return _buildEmptyState();

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: c.divider, indent: 80),
          itemBuilder: (ctx, i) =>
              _buildChatTile(docs[i], currentUid),
        );
      },
    );
  }

  // ── Chat tile ─────────────────────────────────────────────────────────────

  Widget _buildChatTile(
    DocumentSnapshot doc,
    String currentUid,
  ) {
    final c = AppColors.of(context);
    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> participantIds =
        data['participantIds'] ?? [];
    final String? otherUserId = participantIds
        .cast<String>()
        .where((id) => id != currentUid)
        .firstOrNull;

    if (otherUserId == null) return const SizedBox.shrink();

    final int unread =
        (Map<String, dynamic>.from(
          data['unreadCount'] ?? {},
        ))[currentUid] ??
        0;
    final bool isPinned =
        (Map<String, dynamic>.from(
          data['pinnedBy'] ?? {},
        ))[currentUid] ==
        true;

    final participantsMap = Map<String, dynamic>.from(
      data['participants'] ?? {},
    );
    final otherParticipant = Map<String, dynamic>.from(
      participantsMap[otherUserId] ?? {},
    );

    final String name =
        otherParticipant['name'] as String? ?? 'Unknown';
    final String image =
        otherParticipant['profileImage'] as String? ?? '';
    final String lastMsg = data['lastMessage'] as String? ?? '';
    final String lastMsgType =
        data['lastMessageType'] as String? ?? 'text';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () =>
            _showChatOptions(doc.id, isPinned, currentUid),
        onTap: () =>
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  otherUserId: otherUserId,
                  otherUserName: name,
                  profileImage: image,
                ),
              ),
            ),
        splashColor: c.pink.withOpacity(0.06),
        highlightColor: c.surface.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 11,
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: unread > 0
                            ? c.pink
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: c.surface),
                              errorWidget: (_, __, ___) =>
                                  _avatarFallback(),
                            )
                          : _avatarFallback(),
                    ),
                  ),
                  if (isPinned)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c.bg,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Name + preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: unread > 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (lastMsgType == 'image') ...[
                          Icon(
                            Icons.photo_outlined,
                            size: 12,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: 3),
                        ] else if (lastMsgType == 'gift') ...[
                          const Text(
                            '🎁 ',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            lastMsgType == 'image'
                                ? 'Photo'
                                : lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread > 0
                                  ? c.textPrimary.withOpacity(
                                      0.8,
                                    )
                                  : c.textSecondary,
                              fontSize: 12,
                              fontWeight: unread > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timestamp + unread badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTimestamp(
                      data['lastMessageTime'] as Timestamp?,
                    ),
                    style: TextStyle(
                      color: unread > 0
                          ? c.pink
                          : c.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.pink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    final c = AppColors.of(context);
    return Container(
      color: c.avatarFallback,
      child: Icon(Icons.person, color: c.avatarIcon, size: 26),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final c = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 36,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              color: c.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a conversation by tapping a host',
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat options ──────────────────────────────────────────────────────────

  void _showChatOptions(
    String chatId,
    bool isPinned,
    String currentUid,
  ) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _optionTile(
              icon: isPinned
                  ? Icons.push_pin_outlined
                  : Icons.push_pin,
              label: isPinned ? 'Unpin Chat' : 'Pin Chat',
              color: c.textPrimary,
              onTap: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(chatId)
                    .update({'pinnedBy.$currentUid': !isPinned});
              },
            ),
            _optionTile(
              icon: Icons.delete_outline,
              label: 'Delete Chat',
              color: Colors.redAccent,
              onTap: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(chatId)
                    .update({
                      'deletedFor.$currentUid': true,
                      'clearedAt.$currentUid':
                          FieldValue.serverTimestamp(),
                      'pinnedBy.$currentUid': false,
                      'unreadCount.$currentUid': 0,
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Timestamp formatter ───────────────────────────────────────────────────

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat('hh:mm a').format(date);
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEE').format(date);
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}

// ── Quick-access item data class ──────────────────────────────────────────────

class _QuickItem {
  final IconData icon;
  final String label;
  final List<Color> ringColors;
  final int badge;

  const _QuickItem({
    required this.icon,
    required this.label,
    required this.ringColors,
    this.badge = 0,
  });
}

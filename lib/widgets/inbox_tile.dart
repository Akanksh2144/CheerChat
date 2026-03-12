import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cheerchat/theme/app_colors.dart';

class InboxTile extends StatelessWidget {
  final String userName;
  final String userImage;
  final String lastMessage;
  final String userId;
  final String time;
  final int unreadCount;
  final bool isHost;
  final VoidCallback onTap;

  const InboxTile({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isHost = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      splashColor: c.pink.withOpacity(0.06),
      highlightColor: c.pink.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: c.avatarFallback,
                  backgroundImage: NetworkImage(userImage),
                ),
                if (isHost)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: c.pink,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c.bg,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // ── Name + Last message ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: hasUnread
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: hasUnread
                          ? c.textPrimary
                          : c.textSecondary,
                      fontWeight: hasUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Time + Unread badge ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: hasUnread ? c.pink : c.textSecondary,
                    fontWeight: hasUnread
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: 5),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: c.pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount > 99
                          ? '99+'
                          : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

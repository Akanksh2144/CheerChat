import 'package:flutter/material.dart';

class InboxTile extends StatelessWidget {
  final String userName;
  final String userImage;
  final String lastMessage;
  final String userId;
  final String time;
  final int unreadCount;
  final bool isHost; // To distinguish paid hosts
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            // 1. Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(userImage),
            ),
            const SizedBox(width: 16),

            // 2. Name & Message Snippet (Expanded to take available space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // if (isHost) ...[
                      //   const SizedBox(width: 4),
                      //   const Icon(
                      //     Icons
                      //         .verified, // Or specific Host Icon
                      //     size: 16,
                      //     color: Colors.blue,
                      //   ),
                      // ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: unreadCount > 0
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Time & Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: unreadCount > 0
                        ? Colors.blue
                        : Colors.grey[500],
                    fontWeight: unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color:
                          Colors.blue, // Your primary app color
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9
                          ? '9+'
                          : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

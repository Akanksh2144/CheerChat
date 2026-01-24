import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:judotalk/screens/inbox_screen.dart';

class ChatTile extends StatelessWidget {
  final InboxChat chat;
  final void Function() onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,

      /// Profile picture
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blue.shade200,
        child: Text(
          chat.name[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// Name + last message
      title: Row(
        children: [
          Text(
            chat.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(shape: BoxShape.circle),
            height: 20,
            width: 20,

            child: Flag.fromCode(
              chat.flagscode,
              fit: BoxFit.fill,
            ),
          ),

          const SizedBox(width: 10),
          Container(
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
              chat.level,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat.unread > 0 ? Colors.black87 : Colors.grey,
          fontWeight: chat.unread > 0
              ? FontWeight.w500
              : FontWeight.normal,
        ),
      ),

      /// Time + unread badge
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (chat.unread > 0)
            Container(
              padding: const EdgeInsets.all(6),
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                // borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  chat.unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

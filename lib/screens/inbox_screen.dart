import 'package:flutter/material.dart';
import 'package:judotalk/widgets/chat_tile.dart';

import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  /// Temporary mock data (replace with backend)
  static final List<Map<String, dynamic>> chats = [
    {
      "name": "Ananya",
      "lastMessage": "Hey! Are you free now?",
      "time": "2:15 PM",
      "unread": 2,
      "image": null,
    },
    {
      "name": "Rahul",
      "lastMessage": "Call me later",
      "time": "Yesterday",
      "unread": 0,
      "image": null,
    },
    {
      "name": "Priya",
      "lastMessage": "😂😂",
      "time": "Mon",
      "unread": 5,
      "image": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats"), elevation: 1),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatTile(
            name: chat["name"],
            lastMessage: chat["lastMessage"],
            time: chat["time"],
            unreadCount: chat["unread"],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

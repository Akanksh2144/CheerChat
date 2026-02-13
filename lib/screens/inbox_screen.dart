import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:judotalk/screens/chat_screen.dart'; // Import your chat screen
import 'package:judotalk/services/chat_services.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart'; // Import your service

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    print(_auth.currentUser!.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      // 1. USE YOUR EXISTING SERVICE STREAM
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getInbox(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) =>
                const Divider(indent: 84, height: 1),
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              final currentUid = _auth.currentUser!.uid;

              // Get participants list
              final List<dynamic> participantIds =
                  data['participantIds'] ?? [];

              // Find the other user ID
              String? otherUserId;
              for (var id in participantIds) {
                if (id != currentUid) {
                  otherUserId = id;
                  break;
                }
              }

              if (otherUserId == null) {
                return const SizedBox();
              }

              // Get participants snapshot map
              final Map<String, dynamic> participantsMap =
                  Map<String, dynamic>.from(
                    data['participants'] ?? {},
                  );

              final Map<String, dynamic>? otherUserData =
                  participantsMap[otherUserId];

              final String name =
                  otherUserData?['name'] ?? "User";

              final String image =
                  otherUserData?['profileImage'] ?? "";

              final Map<String, dynamic> unreadMap =
                  Map<String, dynamic>.from(
                    data['unreadCount'] ?? {},
                  );

              final int unread = unreadMap[currentUid] ?? 0;

              return InkWell(
                onLongPress: () {
                  _showChatOptions(
                    context,
                    docs[index].id,
                    data['isPinned'] ?? false,
                  );
                },

                onTap: () {
                  pushScreenWithoutNavBar(
                    context,
                    ChatScreen(
                      otherUserId: otherUserId!,
                      otherUserName: name,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image.isNotEmpty
                            ? CachedNetworkImageProvider(image)
                            : null,
                        child: image.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['lastMessage'] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight:
                                    data['lastSenderId'] !=
                                        currentUid
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTimestamp(
                              data['lastMessageTime'],
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (unread > 0)
                            Container(
                              margin: const EdgeInsets.only(
                                top: 4,
                              ),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_chat_unread_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat('hh:mm a').format(date);
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEE').format(date); // Mon, Tue...
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  void _showChatOptions(
    BuildContext context,
    String chatId,
    bool isPinned,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chat Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: Text(
                  isPinned ? "Unpin Chat" : "Pin Chat",
                ),
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('conversations')
                      .doc(chatId)
                      .update({'isPinned': !isPinned});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text("Delete Chat"),
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('conversations')
                      .doc(chatId)
                      .delete();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

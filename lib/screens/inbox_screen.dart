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

              // 2. LOGIC TO FIND "THE OTHER USER"
              // Your participants array contains [uid1, uid2].
              // We need to find the one that is NOT the current user.
              final List<dynamic> participants =
                  data['participantIds'] ?? [];
              final currentUid = _auth.currentUser!.uid;

              String otherUserId =
                  "abmy04pG6Ye1bcIycJyZOQFx61x2";
              for (var id in participants) {
                if (id != currentUid) {
                  otherUserId = id;
                  print(otherUserId);
                  break;
                }
              }

              // 3. FETCH OTHER USER DETAILS
              // Since your 'conversations' doc currently only stores UIDs (based on your service code),
              // we need to fetch the User's name/photo.
              // Ideally, you should store name/photo in the conversation doc to avoid this extra read,
              // but for now, we will fetch it here.
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  // Default placeholders while loading user details
                  String name = "Loading...";
                  String image = "";

                  if (userSnapshot.hasData &&
                      userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data()
                            as Map<String, dynamic>;
                    name =
                        userData['name'] ??
                        "User"; // Replace 'name' with your actual user field
                    image =
                        userData['profileImage'] ??
                        ""; // Replace 'profileImage' with actual field
                  }

                  // 4. INBOX TILE UI
                  return InkWell(
                    onLongPress: () {},
                    onTap: () {
                      pushScreenWithoutNavBar(
                        context,
                        ChatScreen(
                          otherUserId: otherUserId,
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
                          // Avatar
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: image.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    image,
                                  )
                                : null,
                            child: image.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),

                          // Name & Message
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
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    // Make text bold if the last sender wasn't me (Unread logic simulation)
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

                          // Time & Status
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
                              // Optional: Add Unread Dot here later
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
}

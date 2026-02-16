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

          // final docs = snapshot.data!.docs;
          final currentUid = _auth.currentUser!.uid;

          // final docs = snapshot.data!.docs.where((doc) {
          //   final data = doc.data() as Map<String, dynamic>;
          //   final deletedFor = Map<String, dynamic>.from(
          //     data['deletedFor'] ?? {},
          //   );
          //   return deletedFor[currentUid] != true;
          // }).toList();
          // 1. Get raw docs
          var allDocs = snapshot.data!.docs;

          // 2. Filter (Your existing block, just slightly rewritten)
          var filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deletedFor = Map<String, dynamic>.from(
              data['deletedFor'] ?? {},
            );
            return deletedFor[currentUid] != true;
          }).toList();

          // 3. Sort (New Logic for Private Pins)
          filteredDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            // Check if pinned for THIS user specifically
            final pinnedA =
                (dataA['pinnedBy'] as Map?)?[currentUid] == true;
            final pinnedB =
                (dataB['pinnedBy'] as Map?)?[currentUid] == true;

            if (pinnedA && !pinnedB)
              return -1; // A is pinned, goes first
            if (!pinnedA && pinnedB)
              return 1; // B is pinned, goes first

            // If both are same status, keep the original time sort (from the query)
            return 0;
          });

          // 4. Assign back to 'docs' for the ListView
          final docs = filteredDocs;

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
              print('hi');
              print(otherUserId);

              if (otherUserId == null) {
                return const SizedBox();
              }

              final Map<String, dynamic> unreadMap =
                  Map<String, dynamic>.from(
                    data['unreadCount'] ?? {},
                  );

              final int unread = unreadMap[currentUid] ?? 0;
              // final bool isPinned = data['pinnedBy'] ?? false;
              // Check if the 'pinnedBy' map has MY user ID set to true
              final pinnedMap = Map<String, dynamic>.from(
                data['pinnedBy'] ?? {},
              );
              final bool isPinned =
                  pinnedMap[currentUid] == true;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final userData =
                      userSnapshot.data!.data()
                          as Map<String, dynamic>?;

                  final String name =
                      userData?['name'] ??
                      ''; //?? "User${otherUserId?.substring(0, 5)}";

                  final String image =
                      userData?['profileImage'] ?? "";

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
                          profileImage: image,
                        ),
                      );
                    },
                    child: Container(
                      // color: isPinned
                      //     ? Colors.orange.withOpacity(0.05)
                      //     : Colors.transparent,
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
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
                                      fontWeight:
                                          // data['lastSenderId'] !=
                                          //     currentUid
                                          unread > 0
                                          ? FontWeight.w900
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
                                if (isPinned)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                    child: Icon(
                                      Icons.push_pin,
                                      size: 18,
                                      color:
                                          const Color.fromARGB(
                                            255,
                                            123,
                                            83,
                                            22,
                                          ),
                                    ),
                                  ),
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
                                    margin:
                                        const EdgeInsets.only(
                                          top: 4,
                                        ),
                                    padding:
                                        const EdgeInsets.all(6),
                                    decoration:
                                        const BoxDecoration(
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

  void _showChatOptions(
    BuildContext context,
    String chatId,
    bool isPinned,
  ) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
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
                      .update({
                        // Update ONLY my pin status
                        'pinnedBy.$currentUid': !isPinned,
                      });
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
                  final currentUid =
                      FirebaseAuth.instance.currentUser!.uid;

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

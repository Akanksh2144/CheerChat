import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:judotalk/constants/gift_constants.dart';
import 'package:judotalk/constants/lottie_constants.dart';
import 'package:judotalk/services/chat_services.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String profileImage;

  const ChatScreen({
    super.key,
    required this.profileImage,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _messageSubscription;

  bool _isLocked = true;
  bool _hasUnlockedThisSession = false;
  StreamSubscription<DocumentSnapshot>? _roomSubscription;

  // DashChat requires these "ChatUser" objects to know who is who
  late ChatUser _currentUser;
  late ChatUser _otherUser;

  // Add these inside _ChatScreenState
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  final FocusNode _inputFocusNode = FocusNode();
  bool _isInputFocused = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // 0 is bottom in reversed chat
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty) return;

    if (_isLocked) {
      final currentUserId = _auth.currentUser!.uid;
      final chatRoomId = _chatService.getChatRoomId(
        currentUserId,
        widget.otherUserId,
      );

      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatRoomId)
          .update({
            'isUnlocked': true,
            'expiryTime': DateTime.now().add(
              const Duration(days: 7),
            ),
          });

      setState(() {
        _isLocked = false;
        _hasUnlockedThisSession = true;
      });
    }

    await _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text: message.text,
    );
    _scrollToBottom();
  }

  bool _canDeleteForEveryone(ChatMessage message) {
    final createdAt = message.createdAt;
    final now = DateTime.now();

    const limitMinutes = 5;
    return now.difference(createdAt).inMinutes < limitMinutes;
  }

  void _showDeleteSheet(ChatMessage message) {
    final isMe = message.user.id == _currentUser.id;
    if (!isMe) return;

    if (!_canDeleteForEveryone(message)) {
      //when tapped beyond 5 mins
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete message"),
          content: const Text(
            "This message will be deleted for everyone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteMessage(message);
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.shade100,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(ChatMessage message) {
    final messageId = message.customProperties?['messageId'];

    if (messageId == null) return;

    _chatService.deleteMessage(
      otherUserId: widget.otherUserId,
      messageId: messageId,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = _chatService.getChatRoomId(
      currentUserId,
      widget.otherUserId,
    );

    final messageRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    // 1️⃣ Create message immediately (local preview)
    await messageRef.set({
      'senderId': currentUserId,
      'receiverId': widget.otherUserId,
      'text': file.path, // TEMP local file path
      'type': 'image',
      'timestamp': FieldValue.serverTimestamp(),
      'isLocal': true,
    });
    _scrollToBottom();

    try {
      // 2️⃣ Upload image
      final result = await _chatService.uploadChatImage(
        File(file.path),
      );

      // 3️⃣ Update message with real URL
      await messageRef.update({
        'text': result['url'],
        'storagePath': result['path'],
        'isLocal': false,
      });

      _scrollToBottom();
    } catch (e) {
      await messageRef.update({'isUploadFailed': true});
    }
  }

  void _openGiftPicker() {
    showModalBottomSheet(
      // expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Send a Gift 🎁",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                  itemCount: GiftAssets.all.length,
                  itemBuilder: (context, index) {
                    final path = GiftAssets.all[index];
                    return GestureDetector(
                      onTap: () {
                        _sendGift(path);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Image.asset(
                          path,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLottiePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
            itemCount: LottieSmileys.all.length,
            itemBuilder: (context, index) {
              final path = LottieSmileys.all[index];
              return GestureDetector(
                onTap: () {
                  _sendLottie(path);
                  Navigator.pop(context);
                },
                child: Lottie.asset(
                  path,
                  fit:
                      BoxFit.cover, // 👈 This forces consistency
                  width: 60, // 👈 Hardcoded size for the picker
                  height: 60,
                  repeat: false,
                ), // Static or single play in picker
              );
            },
          ),
        );
      },
    );
  }

  void _sendGift(String assetPath) {
    _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text: assetPath,
      type: 'gift', // Custom type for static images
    );
    _scrollToBottom();
  }

  void _sendLottie(String assetPath) async {
    await _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text:
          assetPath, // Store the asset path string in Firestore
      type: 'lottie',
    );
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();

    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = _chatService.getChatRoomId(
      currentUserId,
      widget.otherUserId,
    );

    _roomSubscription = FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatRoomId)
        .snapshots()
        .listen((doc) {
          if (!doc.exists) return;

          final data = doc.data() as Map<String, dynamic>;

          final bool isUnlocked = data['isUnlocked'] ?? false;
          final Timestamp? expiryTs = data['expiryTime'];

          bool locked = true;

          if (isUnlocked && expiryTs != null) {
            final expiry = expiryTs.toDate();
            locked = expiry.isBefore(DateTime.now());
          }

          if (mounted) {
            setState(() {
              _isLocked = locked;
            });
          }
        });

    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addObserver(this);

    _chatService.markMessagesAsRead(widget.otherUserId);

    _messageSubscription = _chatService
        .getMessages(widget.otherUserId)
        .listen((event) {
          if (mounted && event.docChanges.isNotEmpty) {
            _chatService.markMessagesAsRead(widget.otherUserId);
          }
        });

    final uid = _auth.currentUser!.uid;
    print('hi');
    print(uid);

    _currentUser = ChatUser(
      id: uid,
      // You can add profileImage: here later
      // profileImage:
      //     "https://media.istockphoto.com/id/1455397163/photo/portrait-of-indian-dark-pretty-girl.jpg?s=2048x2048&w=is&k=20&c=3NUASBYzvRvKn8H8J3OgILfKeAVTrY8-qihYmdjRVFA=",
    );

    _otherUser = ChatUser(
      id: widget.otherUserId,
      // firstName: widget.otherUserName,
      profileImage: widget.profileImage,
      // You can add profileImage: here later
    );

    // Initialize the DB document (Silent setup for the future paywall)
    _chatService.initializeChatIfNew(widget.otherUserId);
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        // If scrolled up more than 300 pixels, show button
        final show = _scrollController.offset > 300;
        if (show != _showScrollButton) {
          setState(() => _showScrollButton = show);
        }
      }
    });
  }

  bool _keyboardVisible = false;

  @override
  void dispose() {
    _roomSubscription?.cancel();

    _inputFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset =
        WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Keyboard just opened
    if (isKeyboardOpen && !_keyboardVisible) {
      _keyboardVisible = true;
    }

    // Keyboard just closed
    if (!isKeyboardOpen && _keyboardVisible) {
      _keyboardVisible = false;

      if (_inputFocusNode.hasFocus) {
        _inputFocusNode.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white12,
        centerTitle: true,
        surfaceTintColor: Colors.pink[200],
        // foregroundColor: Colors.black,
        //animateColor: true,
        title: Text(widget.otherUserName),
        actions: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(200),
            ),

            clipBehavior: Clip.hardEdge,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},

                borderRadius: BorderRadius.circular(200),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.videocam_rounded,
                    color: Colors.green,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getMessages(widget.otherUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading messages"),
            );
          }
          // if (snapshot.hasError) {
          //   return const Center(
          //     child: Text("Error loading messages"),
          //   );
          // }

          // if (snapshot.connectionState ==
          //     ConnectionState.waiting) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }

          // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //   return const Center(child: Text("No messages yet"));
          // }

          // final docs = snapshot.data!.docs;
          final docs = snapshot.data?.docs ?? [];

          // 1. MAP FIRESTORE DATA TO DASH CHAT FORMAT
          // We take the raw docs and convert them into a list of ChatMessage objects

          // List<ChatMessage> messages = snapshot.data!.docs.map((
          List<ChatMessage> messages = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            Timestamp? ts = data['timestamp'] as Timestamp?;
            final type = data['type'];
            final bool isDeleted = data['isDeleted'] ?? false;
            // Use isDeleted to return the "🚫 This message was deleted" text
            final bool isPending = doc.metadata.hasPendingWrites;

            return ChatMessage(
              // ✅ text only for normal messages
              // text: type == 'text' ? data['text'] : '',
              text: isDeleted
                  ? "🚫 This message was deleted"
                  : (type == 'text' ||
                            type == 'lottie' ||
                            type == 'gift'
                        ? data['text']
                        : ''),

              // ✅ images ONLY for image type
              medias: type == 'image'
                  ? [
                      ChatMedia(
                        url: data['text'], // image URL
                        fileName: 'image_${doc.id}.jpg',
                        type: MediaType.image,
                        customProperties: {
                          'isLocal': data['isLocal'] ?? false,
                          'isUploadFailed':
                              data['isUploadFailed'] ?? false,
                        },
                      ),
                    ]
                  : [],

              user: data['senderId'] == _currentUser.id
                  ? _currentUser
                  : _otherUser,

              // createdAt: ts?.toDate() ?? DateTime.now(),
              createdAt:
                  ts?.toDate() ??
                  DateTime.fromMillisecondsSinceEpoch(0),

              // 🔥 emoji info lives here
              customProperties: {
                'messageId': doc.id,
                'senderId': data['senderId'],
                'type': type,
                'isDeleted': isDeleted,
                'isPending': isPending,
                'lottiePath': type == 'lottie'
                    ? data['text']
                    : null,
              },
            );
          }).toList(); //..sort(
          //   (a, b) => b.createdAt.compareTo(a.createdAt),
          // );

          // 2. RENDER THE CHAT UI
          return Stack(
            children: [
              Container(
                color: Colors.white,
                child: DashChat(
                  currentUser: _currentUser,
                  onSend: (ChatMessage message) {
                    _sendMessage(message);
                  },

                  messages: messages,

                  inputOptions: InputOptions(
                    focusNode: _inputFocusNode,
                    alwaysShowSend: true,
                    sendOnEnter: true,
                    cursorStyle: CursorStyle(hide: false),

                    leading: _isInputFocused
                        ? [] // 🔥 HIDE ICONS WHEN TYPING
                        : [
                            IconButton(
                              icon: const Icon(
                                Icons.image,
                                color: Colors.blue,
                                size: 25,
                              ),
                              onPressed: _pickImage,
                            ),
                          ],
                    inputDecoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: _openLottiePicker,
                        icon: Icon(Icons.emoji_emotions),
                        color: Colors.yellow.shade800,
                      ),
                      suffixIcon: _isInputFocused
                          ? SizedBox()
                          : IconButton(
                              icon: const Icon(
                                Icons.card_giftcard_outlined,
                                color: Colors.pink,
                                size: 25,
                              ),
                              onPressed: _openGiftPicker,
                            ),
                      hintText: "Type a message…",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    sendButtonBuilder: (onSend) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blueAccent,
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: onSend,
                          ),
                        ),
                      );
                    },
                  ),
                  scrollToBottomOptions: ScrollToBottomOptions(
                    disabled: true,
                    // ✅ Use 'builder' instead of 'widget'
                    scrollToBottomBuilder: (scrollController) {
                      return GestureDetector(
                        onTap: () {
                          // Scroll back to bottom (0.0 is the bottom in chat lists)
                          scrollController.animateTo(
                            0.0,
                            curve: Curves.easeOut,
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.2,
                                ),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  messageListOptions: MessageListOptions(
                    scrollController: _scrollController,
                  ),
                  messageOptions: MessageOptions(
                    containerColor: Colors.grey.shade200,
                    textColor: Colors.black,
                    currentUserContainerColor: Colors.blueAccent,
                    currentUserTextColor: Colors.white,

                    borderRadius: 18,
                    showCurrentUserAvatar: false,
                    showOtherUsersAvatar: true,
                    showTime: true,
                    timeTextColor: Colors.grey,
                    timeFontSize: 11,

                    onLongPressMessage: (ChatMessage message) {
                      final type =
                          message.customProperties?['type'];

                      if (type == 'gift') {
                        return; // Stop here, do not show the delete dialog
                      }
                      _showDeleteSheet(message);
                    },

                    messagePadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    messageDecorationBuilder:
                        (message, previousMessage, nextMessage) {
                          final type =
                              message.customProperties?['type'];
                          final isMe =
                              message.user.id == _currentUser.id;
                          if (type == 'lottie' ||
                              type == 'gift') {
                            return const BoxDecoration(
                              color: Colors.transparent,
                            );
                          }

                          return BoxDecoration(
                            color: isMe
                                ? Colors.blueAccent
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(
                                18,
                              ),
                              bottomLeft: isMe
                                  ? const Radius.circular(18)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(18),
                            ),
                          );
                        },

                    messageTextBuilder: (message, previousMessage, nextMessage) {
                      // 1. DEFINE isMe HERE so the rest of the code knows what it is
                      final bool isMe =
                          message.user.id == _currentUser.id;
                      final bool isDeleted =
                          message
                              .customProperties?['isDeleted'] ??
                          false;
                      final type =
                          message.customProperties?['type'];
                      final bool isPending =
                          message
                              .customProperties?['isPending'] ??
                          false;

                      if (type == 'lottie') {
                        final lottiePath = message.text;
                        final bool isPending =
                            message
                                .customProperties?['isPending'] ??
                            false;

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Lottie.asset(
                                lottiePath,
                                width:
                                    100, // Size for smiley stickers
                                height: 100,
                                repeat: true,
                                // Optional: Add a placeholder while the file loads from assets
                                frameRate: FrameRate.max,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    TimeOfDay.fromDateTime(
                                      message.createdAt,
                                    ).format(context),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (isMe && isPending)
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      if (type == 'gift') {
                        final assetPath = message.text;
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // White background makes PNGs pop
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.pink.shade100,
                                    width: 2,
                                  ),
                                ),
                                child: Image.asset(
                                  assetPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Sent a Gift",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (isMe && isPending)
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 4,
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      if (isDeleted) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.block,
                              size: 14,
                              color: isMe
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "This message was deleted",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: isMe
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }

                      // =========================
                      // A. NORMAL TEXT MESSAGE (With Time Inside)
                      // =========================
                      return Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                TimeOfDay.fromDateTime(
                                  message.createdAt,
                                ).format(context),
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 5),
                              if (isMe && isPending)
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                ),
                            ],
                          ),
                        ],
                      );
                    },

                    messageMediaBuilder: (message, previous, next) {
                      if (message.medias == null ||
                          message.medias!.isEmpty)
                        return const SizedBox();

                      final media = message.medias!.first;

                      if (media.type == MediaType.image) {
                        final bool isMe =
                            message.user.id == _currentUser.id;

                        final bool isLocal =
                            media.customProperties?['isLocal'] ??
                            false;

                        final bool isUploadFailed =
                            media
                                .customProperties?['isUploadFailed'] ??
                            false;

                        return Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(12),
                              child: GestureDetector(
                                onTap: isLocal
                                    ? null
                                    : () {
                                        // pushScreenWithoutNavBar(
                                        //   context,

                                        //   FullScreenImageView(
                                        //     imageUrl: media.url,
                                        //   ),
                                        // );
                                        pushScreen(
                                          context,
                                          withNavBar: false,
                                          screen:
                                              FullScreenImageView(
                                                imageUrl:
                                                    media.url,
                                              ),
                                          pageTransitionAnimation:
                                              PageTransitionAnimation
                                                  .fade,
                                        );
                                      },
                                child: isLocal
                                    ? Image.file(
                                        File(media.url),
                                        width: 220,
                                        height: 220,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: media.url,
                                        width: 220,
                                        height: 220,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (
                                              context,
                                              url,
                                            ) => const SizedBox(
                                              width: 220,
                                              height: 220,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                        errorWidget:
                                            (
                                              context,
                                              url,
                                              error,
                                            ) => const SizedBox(
                                              width: 220,
                                              height: 220,
                                              child: Icon(
                                                Icons
                                                    .broken_image,
                                                color:
                                                    Colors.grey,
                                              ),
                                            ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (isLocal)
                              const Text(
                                "Uploading...",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            if (isUploadFailed)
                              const Text(
                                "Upload failed",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                            if (!isLocal && !isUploadFailed)
                              Text(
                                TimeOfDay.fromDateTime(
                                  message.createdAt,
                                ).format(context),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ),

              // if (_isLocked)
              //   Positioned(
              //     left: 0,
              //     right: 0,
              //     bottom: 70, // Just above input bar
              //     child: AnimatedSwitcher(
              //       duration: const Duration(milliseconds: 300),
              //       child: Container(
              //         key: const ValueKey('unlock_banner'),
              //         margin: const EdgeInsets.symmetric(
              //           horizontal: 12,
              //         ),
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 14,
              //           vertical: 10,
              //         ),
              //         decoration: BoxDecoration(
              //           color: Colors.orange.shade100,
              //           borderRadius: BorderRadius.circular(12),
              //           border: Border.all(color: Colors.orange),
              //         ),
              //         child: Row(
              //           children: const [
              //             Icon(
              //               Icons.lock_outline,
              //               size: 18,
              //               color: Colors.orange,
              //             ),
              //             SizedBox(width: 8),
              //             Expanded(
              //               child: Text(
              //                 "Messaging this user will cost 20 coins. Unlocks for 7 days.",
              //                 style: TextStyle(fontSize: 13),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              if (_showScrollButton)
                Positioned(
                  bottom: 90, // Move it above the input bar
                  left: 0,
                  right:
                      0, // Setting left & right to 0 calculates the center
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Scroll back to bottom (0.0 is the bottom in chat)
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(
                            milliseconds: 300,
                          ),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.2,
                              ),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Wrapper to call your existing ChatService
}

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  State<FullScreenImageView> createState() =>
      _FullScreenImageViewState();
}

class _FullScreenImageViewState
    extends State<FullScreenImageView> {
  double _dragOffset = 0;
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;

          // Reduce opacity while dragging
          _opacity = (1 - (_dragOffset.abs() / 300)).clamp(
            0.5,
            1.0,
          );
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 120) {
          Navigator.pop(context); // 👈 Swipe down closes
        } else {
          // Reset if not enough swipe
          setState(() {
            _dragOffset = 0;
            _opacity = 1.0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(_opacity),
        body: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                    errorWidget: (context, url, error) =>
                        const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

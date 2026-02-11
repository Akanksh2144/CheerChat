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

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
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

  // DashChat requires these "ChatUser" objects to know who is who
  late ChatUser _currentUser;
  late ChatUser _otherUser;

  // Add these inside _ChatScreenState
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  final FocusNode _inputFocusNode = FocusNode();
  bool _isInputFocused = false;

  void _sendMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty) return;

    await _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text: message.text,
    );
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

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final XFile? file = await picker.pickImage(
  //     source: ImageSource.gallery,
  //   );

  //   if (file == null) return;

  //   final result = await _chatService.uploadChatImage(
  //     File(file.path),
  //   );

  //   await _chatService.sendImageMessage(
  //     receiverId: widget.otherUserId,
  //     imageUrl: result['url']!,
  //     storagePath: result['path']!,
  //   );
  // }
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
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatRoomId)
          .set({
            'lastMessage': '📷 Image',
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastSenderId': currentUserId,
            'isDeleted': false,
          }, SetOptions(merge: true));
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
  }

  void _sendLottie(String assetPath) async {
    await _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text:
          assetPath, // Store the asset path string in Firestore
      type: 'lottie',
    );
  }

  @override
  void initState() {
    super.initState();

    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addObserver(this);

    final uid = _auth.currentUser!.uid;

    _currentUser = ChatUser(
      id: uid,
      // You can add profileImage: here later
      // profileImage:
      //     "https://media.istockphoto.com/id/1455397163/photo/portrait-of-indian-dark-pretty-girl.jpg?s=2048x2048&w=is&k=20&c=3NUASBYzvRvKn8H8J3OgILfKeAVTrY8-qihYmdjRVFA=",
    );

    _otherUser = ChatUser(
      id: widget.otherUserId,
      // firstName: widget.otherUserName,
      profileImage:
          "https://media.istockphoto.com/id/1455397163/photo/portrait-of-indian-dark-pretty-girl.jpg?s=2048x2048&w=is&k=20&c=3NUASBYzvRvKn8H8J3OgILfKeAVTrY8-qihYmdjRVFA=",
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
    _inputFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);

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
    // final isKeyboardOpen =
    //     MediaQuery.of(context).viewInsets.bottom > 0;

    // // 🔥 If keyboard closed but focus still active → unfocus
    // if (!isKeyboardOpen && _inputFocusNode.hasFocus) {
    //   Future.microtask(() => _inputFocusNode.unfocus());
    // }

    // _wasKeyboardOpen = isKeyboardOpen;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
                    size: 30,
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

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //   return Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.chat_bubble_outline,
          //           size: 80,
          //           color: Colors.grey.shade300,
          //         ),
          //         const SizedBox(height: 16),
          //         Text(
          //           "No messages yet.",
          //           style: TextStyle(
          //             color: Colors.grey.shade500,
          //             fontSize: 18,
          //           ),
          //         ),
          //         Text(
          //           "Say Hi! 👋",
          //           style: TextStyle(
          //             color: Colors.grey.shade400,
          //           ),
          //         ),
          //       ],
          //     ),
          //   );
          // }

          // 1. MAP FIRESTORE DATA TO DASH CHAT FORMAT
          // We take the raw docs and convert them into a list of ChatMessage objects

          List<ChatMessage> messages =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                Timestamp? ts = data['timestamp'] as Timestamp?;
                final type = data['type'];
                final bool isDeleted =
                    data['isDeleted'] ?? false;
                // Use isDeleted to return the "🚫 This message was deleted" text
                final bool isPending =
                    doc.metadata.hasPendingWrites;

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
                              'isLocal':
                                  data['isLocal'] ?? false,
                              'isUploadFailed':
                                  data['isUploadFailed'] ??
                                  false,
                            },
                          ),
                        ]
                      : [],

                  user: data['senderId'] == _currentUser.id
                      ? _currentUser
                      : _otherUser,

                  createdAt: ts?.toDate() ?? DateTime.now(),

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
              }).toList()..sort(
                (a, b) => b.createdAt.compareTo(a.createdAt),
              );

          // 2. RENDER THE CHAT UI
          return Stack(
            children: [
              DashChat(
                currentUser: _currentUser,
                onSend: (ChatMessage message) {
                  _sendMessage(message);
                },

                messages: messages,

                inputOptions: InputOptions(
                  focusNode: _inputFocusNode,
                  alwaysShowSend: true,
                  sendOnEnter: true,

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
                          // IconButton(
                          //   icon: const Icon(
                          //     Icons.card_giftcard_outlined,
                          //     color: Colors.pink,
                          //     size: 25,
                          //   ),
                          //   onPressed: _openGiftPicker,
                          // ),
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
                      // Optional: Show a message explaining why
                      // ScaffoldMessenger.of(
                      //   context,
                      // ).showSnackBar(
                      //   const SnackBar(
                      //     content: Text(
                      //       "Gifts cannot be deleted.",
                      //     ),
                      //     duration: Duration(seconds: 1),
                      //   ),
                      // );
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
                        if (type == 'lottie' || type == 'gift') {
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
                            topRight: const Radius.circular(18),
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
                        message.customProperties?['isDeleted'] ??
                        false;
                    final type =
                        message.customProperties?['type'];
                    final bool isPending =
                        message.customProperties?['isPending'] ??
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
                            // Image.asset(
                            //   assetPath,
                            //   fit: BoxFit.contain,
                            // ),
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
                                padding: EdgeInsets.only(top: 4),
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
                        // Text(
                        //   // Formats time like "12:30 PM"
                        //   TimeOfDay.fromDateTime(
                        //     message.createdAt,
                        //   ).format(context),
                        //   style: TextStyle(
                        //     color: isMe
                        //         ? Colors.white70
                        //         : Colors.grey.shade600,
                        //     fontSize: 10,
                        //   ),
                        // ),
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
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
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
                                            Icons.broken_image,
                                            color: Colors.grey,
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

                    // if (media.type == MediaType.image) {
                    //   final bool isMe =
                    //       message.user.id == _currentUser.id;

                    //   final bool isPending =
                    //       message
                    //           .customProperties?['isPending'] ??
                    //       false;

                    //   return Column(
                    //     children: [
                    //       GestureDetector(
                    //         onTap: () {
                    //           pushScreenWithoutNavBar(
                    //             context,
                    //             FullScreenImageView(
                    //               imageUrl: media.url,
                    //             ),
                    //           );
                    //         },
                    //         child: ClipRRect(
                    //           borderRadius:
                    //               BorderRadius.circular(12),
                    //           // 🔥 Use CachedNetworkImage here
                    //           child: CachedNetworkImage(
                    //             imageUrl: media.url,
                    //             width: 220,
                    //             height: 220,
                    //             fit: BoxFit.cover,
                    //             placeholder: (context, url) =>
                    //                 const SizedBox(
                    //                   width: 220,
                    //                   height: 220,
                    //                   child: Center(
                    //                     child:
                    //                         CircularProgressIndicator(),
                    //                   ),
                    //                 ),
                    //             errorWidget:
                    //                 (context, url, error) =>
                    //                     const SizedBox(
                    //                       width: 220,
                    //                       height: 220,
                    //                       child: Icon(
                    //                         Icons.broken_image,
                    //                         color: Colors.grey,
                    //                       ),
                    //                     ),
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 4),
                    //       if (isMe && isPending)
                    //         const Icon(
                    //           Icons.access_time,
                    //           size: 12,
                    //           color: Colors.grey,
                    //         ),
                    //     ],
                    //   );
                    // }
                    return const SizedBox();
                  },
                ),
              ),
              if (_showScrollButton)
                Positioned(
                  bottom: 80, // Move it above the input bar
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

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          // 🔥 Use CachedNetworkImage here too
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ===========================================================================
  // 1. HELPER: Deterministic ID Generation
  // ===========================================================================
  /// Sorts UIDs alphabetically so 'UserA_HostB' is always the same Document ID
  /// regardless of who starts the chat.
  String getChatRoomId(String userId, String otherId) {
    List<String> ids = [userId, otherId];
    ids.sort(); // Crucial: Ensures Consistency
    return ids.join('_');
  }

  // ===========================================================================
  // 2. CORE: Sending a Message (Atomic Batch)
  // ===========================================================================
  /// Sends a message AND updates the Inbox preview in one "All-or-Nothing" action.

  Future<void> sendMessage({
    required String receiverId,
    required String text,
    String type = 'text',
    String? retryMessageId,
    Map<String, dynamic>? extraData,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    // 1. Get the Room Reference (UserA_UserB) - THIS IS THE PARENT
    final chatRoomId = getChatRoomId(currentUserId, receiverId);
    final roomRef = _db
        .collection('conversations')
        .doc(chatRoomId);

    // 2. Get the Message Reference (Random ID) - THIS IS THE CHILD
    final messageRef = retryMessageId != null
        ? roomRef.collection('messages').doc(retryMessageId)
        : roomRef.collection('messages').doc();

    try {
      final timestamp = FieldValue.serverTimestamp();

      // 3. Step A: Write the MESSAGE (Content Only)
      await messageRef.set({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': text,
        'type': type,
        'timestamp': timestamp,
        'status': 'sent',
        if (extraData != null) ...extraData,
      });
      // await roomRef.set({
      //   'lastMessage': lastMessagePreview,
      //   'lastMessageTime': timestamp,
      //   'lastSenderId': currentUserId,
      //   'isDeleted': false,
      // }, SetOptions(merge: true));

      // 4. PREPARE INBOX PREVIEW
      // String lastMessagePreview = text;
      final String lastMessagePreview =
          {
            'image': '📷 Image',
            'lottie': '[Emoji]',
            'gift': 'Gift 🎁',
          }[type] ??
          text;

      // if (type == 'image') lastMessagePreview = '📷 Image';
      // if (type == 'lottie') lastMessagePreview = 'Smiley 😍';
      // if (type == 'gift') lastMessagePreview = 'Gift 🎁';

      // 5. Step B: Update the ROOM (Metadata for Inbox)
      // 🔥 FIX: We update roomRef, NOT messageRef
      // await roomRef.set(
      //   {
      //     'participantIds': [currentUserId, receiverId],
      //     'lastMessage': lastMessagePreview,
      //     'lastMessageTime': timestamp,
      //     'lastSenderId': currentUserId,
      //     'isDeleted': false,
      //   },
      //   SetOptions(merge: true),
      // ); // merge: true preserves other fields like expiryTime
      await roomRef.set({
        'lastMessage': lastMessagePreview,
        'lastMessageTime': timestamp,
        'lastSenderId': currentUserId,
        'isDeleted': false,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error sending message: $e");
      rethrow;
    }
  }

  Future<Map<String, String>> uploadChatImage(File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'chat_images/$fileName';

    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    return {'url': url, 'path': path};
  }

  Future<void> sendImageMessage({
    required String receiverId,
    required String imageUrl,
    required String storagePath,
  }) async {
    await sendMessage(
      receiverId: receiverId,
      text: imageUrl,
      type: 'image',
      extraData: {'storagePath': storagePath},
    );
  }

  // Future<void> deleteMessage({
  //   required String otherUserId,
  //   required String messageId,
  // }) async {
  //   final currentUserId = _auth.currentUser!.uid;
  //   final chatRoomId = getChatRoomId(currentUserId, otherUserId);

  //   final messageRef = _db
  //       .collection('conversations')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .doc(messageId);

  //   final doc = await messageRef.get();
  //   if (!doc.exists) return;

  //   final data = doc.data()!;
  //   final type = data['type'];
  //   final storagePath = data['storagePath'];

  //   // 🔥 delete image file
  //   if (type == 'image' && storagePath != null) {
  //     await _storage.ref(storagePath).delete();
  //   }

  //   await messageRef.delete();
  // }
  Future<void> deleteMessage({
    required String otherUserId,
    required String messageId,
  }) async {
    try {
      final currentUserId = _auth.currentUser!.uid;
      final chatRoomId = getChatRoomId(
        currentUserId,
        otherUserId,
      );

      final messageRef = _db
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      final doc = await messageRef.get();
      if (!doc.exists) return;
      final roomRef = _db
          .collection('conversations')
          .doc(chatRoomId);
      final data = doc.data()!;
      final type = data['type'];
      final storagePath = data['storagePath'];

      // 1. If it's an image, delete the actual file from Firebase Storage
      if (type == 'image' && storagePath != null) {
        try {
          await _storage.ref(storagePath).delete();
        } catch (e) {
          debugPrint("Error deleting storage file: $e");
        }
      }

      // 2. Instead of messageRef.delete(), we UPDATE the document
      await messageRef.update({
        'isDeleted': true,
        'text': '', // Clear the text content for privacy
        'type':
            'text', // Optional: switch type to text for easier rendering
        'storagePath':
            null, // Remove the path since file is gone
      });
      final roomDoc = await roomRef.get();
      if (roomDoc.exists &&
          roomDoc.data()?['lastMessageTime'] ==
              data['timestamp']) {
        await roomRef.update({
          'lastMessage': '🚫 This message was deleted',
        });
      }
    } catch (e) {
      debugPrint("Error in deleteMessage: $e");
    }
  }

  // ===========================================================================
  // 3. LOGIC: Initialize 7-Day Trial
  // ===========================================================================
  /// Call this when the user opens the chat screen for the first time.
  /// It sets the timer ONLY if the chat is brand new.
  // Future<void> initializeChatIfNew(String otherUserId) async {
  //   final currentUserId = _auth.currentUser!.uid;
  //   final chatRoomId = getChatRoomId(currentUserId, otherUserId);
  //   final roomRef = _db
  //       .collection('conversations')
  //       .doc(chatRoomId);

  //   final doc = await roomRef.get();

  //   // Only write if document doesn't exist yet
  //   if (!doc.exists) {
  //     await roomRef.set({
  //       'participantIds': [currentUserId, otherUserId],
  //       'expiryTime': DateTime.now().add(
  //         const Duration(days: 7),
  //       ), // 7 Days from now
  //       'isUnlocked': false, // Locked by default
  //       'lastMessage': 'Chat Started',
  //       'lastMessageTime': FieldValue.serverTimestamp(),
  //     });
  //   }
  // }
  Future<void> initializeChatIfNew(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final roomRef = _db
        .collection('conversations')
        .doc(chatRoomId);

    final doc = await roomRef.get();

    if (!doc.exists) {
      // 🔥 Fetch both users
      final usersRef = _db.collection('users');

      final currentUserDoc = await usersRef
          .doc(currentUserId)
          .get();
      final otherUserDoc = await usersRef.doc(otherUserId).get();

      final currentUserData =
          currentUserDoc.data() as Map<String, dynamic>;
      final otherUserData =
          otherUserDoc.data() as Map<String, dynamic>;

      await roomRef.set({
        'participantIds': [currentUserId, otherUserId],

        // 🔥 NEW: Snapshot participants
        'participants': {
          currentUserId: {
            'name': currentUserData['name'],
            'profileImage': currentUserData['profileImage'],
          },
          otherUserId: {
            'name': otherUserData['name'],
            'profileImage': otherUserData['profileImage'],
          },
        },

        'expiryTime': DateTime.now().add(
          const Duration(days: 7),
        ),
        'isUnlocked': false,
        'isDeleted': false,
        'lastMessage': 'Chat Started',
        'lastSenderId': currentUserId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ===========================================================================
  // 4. STREAMS: Real-time Data for UI
  // ===========================================================================

  /// For the Chat Screen (DashChat)
  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);

    return _db
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        ) // DashChat expects newest first
        .snapshots();
  }

  /// For the Inbox Screen
  Stream<QuerySnapshot> getInbox() {
    final currentUserId = _auth.currentUser!.uid;

    return _db
        .collection('conversations')
        .where(
          'participantIds',
          arrayContains: currentUserId,
        ) // Using your Composite Index
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}

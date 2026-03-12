// // import 'dart:io';

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// // import 'package:flutter/foundation.dart';

// // class ChatService {
// //   final FirebaseFirestore _db = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseStorage _storage = FirebaseStorage.instance;

// //   String getChatRoomId(String userId, String otherId) {
// //     final ids = [userId, otherId]..sort();
// //     return ids.join('_');
// //   }

// //   Future<void> sendMessage({
// //     required String receiverId,
// //     required String text,
// //     String type = 'text',
// //     String? retryMessageId,
// //     Map<String, dynamic>? extraData,
// //   }) async {
// //     final currentUserId = _auth.currentUser!.uid;
// //     await initializeChatIfNew(receiverId);

// //     final chatRoomId = getChatRoomId(currentUserId, receiverId);
// //     final roomRef = _db
// //         .collection('conversations')
// //         .doc(chatRoomId);
// //     final messageRef = retryMessageId != null
// //         ? roomRef.collection('messages').doc(retryMessageId)
// //         : roomRef.collection('messages').doc();

// //     try {
// //       final timestamp = FieldValue.serverTimestamp();

// //       await messageRef.set({
// //         'senderId': currentUserId,
// //         'receiverId': receiverId,
// //         'text': text,
// //         'type': type,
// //         'timestamp': timestamp,
// //         'status': 'sent',
// //         if (extraData != null) ...extraData,
// //       });

// //       final String lastMessagePreview =
// //           {
// //             'image': '📷 Image',
// //             'lottie': '[Emoji]',
// //             'gift': 'Gift 🎁',
// //           }[type] ??
// //           text;

// //       await roomRef.set({
// //         'lastMessage': lastMessagePreview,
// //         'lastMessageTime': timestamp,
// //         'lastMessageType': type,
// //         'lastMessageId': messageRef.id,
// //         'lastSenderId': currentUserId,
// //         'unreadCount': {receiverId: FieldValue.increment(1)},
// //         'deletedFor': {receiverId: false},
// //       }, SetOptions(merge: true));
// //     } catch (e) {
// //       debugPrint("Error sending message: $e");
// //       rethrow;
// //     }
// //   }

// //   Future<Map<String, String>> uploadChatImage(File file) async {
// //     final fileName =
// //         '${DateTime.now().millisecondsSinceEpoch}.jpg';
// //     final path = 'chat_images/$fileName';
// //     final ref = _storage.ref().child(path);
// //     await ref.putFile(file);
// //     final url = await ref.getDownloadURL();
// //     return {'url': url, 'path': path};
// //   }

// //   Future<void> sendImageMessage({
// //     required String receiverId,
// //     required String imageUrl,
// //     required String storagePath,
// //   }) async {
// //     await sendMessage(
// //       receiverId: receiverId,
// //       text: imageUrl,
// //       type: 'image',
// //       extraData: {'storagePath': storagePath},
// //     );
// //   }

// //   Future<void> deleteMessage({
// //     required String otherUserId,
// //     required String messageId,
// //   }) async {
// //     try {
// //       final currentUserId = _auth.currentUser!.uid;
// //       final chatRoomId = getChatRoomId(
// //         currentUserId,
// //         otherUserId,
// //       );
// //       final messageRef = _db
// //           .collection('conversations')
// //           .doc(chatRoomId)
// //           .collection('messages')
// //           .doc(messageId);

// //       final doc = await messageRef.get();
// //       if (!doc.exists) return;

// //       final roomRef = _db
// //           .collection('conversations')
// //           .doc(chatRoomId);
// //       final data = doc.data()!;
// //       final storagePath = data['storagePath'];

// //       if (data['type'] == 'image' && storagePath != null) {
// //         try {
// //           await _storage.ref(storagePath).delete();
// //         } catch (e) {
// //           debugPrint("Error deleting storage file: $e");
// //         }
// //       }

// //       await messageRef.update({
// //         'isDeleted': true,
// //         'text': '',
// //         'type': 'text',
// //         'storagePath': null,
// //       });

// //       final roomDoc = await roomRef.get();
// //       if (roomDoc.exists &&
// //           roomDoc.data()?['lastMessageId'] == messageId) {
// //         await roomRef.update({
// //           'lastMessage': '🚫 This message was deleted',
// //           'lastMessageType': 'text',
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("Error in deleteMessage: $e");
// //     }
// //   }

// //   // Initializes the conversation document if it doesn't exist yet.
// //   //
// //   // IMPORTANT: We never read from Firestore's `users/` collection here
// //   // because CheerChat stores user data in PostgreSQL (not Firestore).
// //   // The caller (ChatScreen / host_card) passes in the display name and
// //   // profile image they already have from the host model / inbox tile.
// //   // The current user's own name/image is pulled from Firebase Auth
// //   // (displayName / photoURL), which is populated after phone/Google sign-in.
// //   Future<void> initializeChatIfNew(
// //     String otherUserId, {
// //     String? otherUserName,
// //     String? otherUserProfileImage,
// //   }) async {
// //     final currentUserId = _auth.currentUser!.uid;
// //     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
// //     final roomRef = _db
// //         .collection('conversations')
// //         .doc(chatRoomId);

// //     final doc = await roomRef.get();
// //     if (doc.exists)
// //       return; // Already initialised — nothing to do.

// //     // Use Firebase Auth display name / photo if available.
// //     // For phone-auth users this may be null until the profile-setup step
// //     // writes it back to Firebase Auth — that's OK, the Node.js backend
// //     // will back-fill participant data once it's live.
// //     final currentUser = _auth.currentUser!;

// //     await roomRef.set({
// //       'participantIds': [currentUserId, otherUserId],
// //       'participants': {
// //         currentUserId: {
// //           'name': currentUser.displayName,
// //           'profileImage': currentUser.photoURL,
// //         },
// //         otherUserId: {
// //           'name': otherUserName,
// //           'profileImage': otherUserProfileImage,
// //         },
// //       },
// //       'expiryTime': null,
// //       'isUnlocked': false,
// //       'deletedFor': {currentUserId: false, otherUserId: false},
// //       'lastMessage': 'Chat Started',
// //       'lastMessageType': 'system',
// //       'lastMessageId': null,
// //       'lastSenderId': currentUserId,
// //       'pinnedBy': {currentUserId: false, otherUserId: false},
// //       'unreadCount': {currentUserId: 0, otherUserId: 0},
// //       'lastMessageTime': FieldValue.serverTimestamp(),
// //       'createdAt': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   Future<void> markMessagesAsRead(String otherUserId) async {
// //     final currentUserId = _auth.currentUser!.uid;
// //     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
// //     final roomRef = _db
// //         .collection('conversations')
// //         .doc(chatRoomId);

// //     try {
// //       final doc = await roomRef.get();
// //       if (!doc.exists) return;
// //       await roomRef.update({'unreadCount.$currentUserId': 0});
// //     } catch (e) {
// //       debugPrint("Error marking as read: $e");
// //     }
// //   }

// //   Stream<QuerySnapshot> getMessages(String otherUserId) async* {
// //     final currentUserId = _auth.currentUser!.uid;
// //     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
// //     final roomRef = _db
// //         .collection('conversations')
// //         .doc(chatRoomId);

// //     final roomDoc = await roomRef.get();
// //     final clearedAt = roomDoc
// //         .data()?['clearedAt']?[currentUserId];

// //     Query query = roomRef
// //         .collection('messages')
// //         .orderBy('timestamp', descending: true);

// //     if (clearedAt != null) {
// //       query = query.where('timestamp', isGreaterThan: clearedAt);
// //     }

// //     yield* query.snapshots();
// //   }

// //   Stream<QuerySnapshot> getInbox() {
// //     final currentUserId = _auth.currentUser!.uid;
// //     return _db
// //         .collection('conversations')
// //         .where('participantIds', arrayContains: currentUserId)
// //         .orderBy('lastMessageTime', descending: true)
// //         .snapshots();
// //   }
// // }
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';

// class ChatService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   String getChatRoomId(String userId, String otherId) {
//     final ids = [userId, otherId]..sort();
//     return ids.join('_');
//   }

//   Future<void> sendMessage({
//     required String receiverId,
//     required String text,
//     String type = 'text',
//     String? retryMessageId,
//     Map<String, dynamic>? extraData,
//     // Participant display info — needed to initialise the conversation doc if
//     // it doesn't exist yet. Without these, the inbox would show null name/avatar.
//     String? otherUserName,
//     String? otherUserProfileImage,
//   }) async {
//     final currentUserId = _auth.currentUser!.uid;
//     await initializeChatIfNew(
//       receiverId,
//       otherUserName: otherUserName,
//       otherUserProfileImage: otherUserProfileImage,
//     );

//     final chatRoomId = getChatRoomId(currentUserId, receiverId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);
//     final messageRef = retryMessageId != null
//         ? roomRef.collection('messages').doc(retryMessageId)
//         : roomRef.collection('messages').doc();

//     try {
//       final timestamp = FieldValue.serverTimestamp();

//       await messageRef.set({
//         'senderId': currentUserId,
//         'receiverId': receiverId,
//         'text': text,
//         'type': type,
//         'timestamp': timestamp,
//         'status': 'sent',
//         if (extraData != null) ...extraData,
//       });

//       final String lastMessagePreview =
//           {
//             'image': '📷 Image',
//             'lottie': '[Emoji]',
//             'gift': 'Gift 🎁',
//           }[type] ??
//           text;

//       await roomRef.set({
//         'lastMessage': lastMessagePreview,
//         'lastMessageTime': timestamp,
//         'lastMessageType': type,
//         'lastMessageId': messageRef.id,
//         'lastSenderId': currentUserId,
//         'unreadCount': {receiverId: FieldValue.increment(1)},
//         'deletedFor': {receiverId: false},
//       }, SetOptions(merge: true));
//     } catch (e) {
//       debugPrint("Error sending message: $e");
//       rethrow;
//     }
//   }

//   Future<Map<String, String>> uploadChatImage(File file) async {
//     final fileName =
//         '${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final path = 'chat_images/$fileName';
//     final ref = _storage.ref().child(path);
//     await ref.putFile(file);
//     final url = await ref.getDownloadURL();
//     return {'url': url, 'path': path};
//   }

//   Future<void> sendImageMessage({
//     required String receiverId,
//     required String imageUrl,
//     required String storagePath,
//   }) async {
//     await sendMessage(
//       receiverId: receiverId,
//       text: imageUrl,
//       type: 'image',
//       extraData: {'storagePath': storagePath},
//     );
//   }

//   Future<void> deleteMessage({
//     required String otherUserId,
//     required String messageId,
//   }) async {
//     try {
//       final currentUserId = _auth.currentUser!.uid;
//       final chatRoomId = getChatRoomId(
//         currentUserId,
//         otherUserId,
//       );
//       final messageRef = _db
//           .collection('conversations')
//           .doc(chatRoomId)
//           .collection('messages')
//           .doc(messageId);

//       final doc = await messageRef.get();
//       if (!doc.exists) return;

//       final roomRef = _db
//           .collection('conversations')
//           .doc(chatRoomId);
//       final data = doc.data()!;
//       final storagePath = data['storagePath'];

//       if (data['type'] == 'image' && storagePath != null) {
//         try {
//           await _storage.ref(storagePath).delete();
//         } catch (e) {
//           debugPrint("Error deleting storage file: $e");
//         }
//       }

//       await messageRef.update({
//         'isDeleted': true,
//         'text': '',
//         'type': 'text',
//         'storagePath': null,
//       });

//       final roomDoc = await roomRef.get();
//       if (roomDoc.exists &&
//           roomDoc.data()?['lastMessageId'] == messageId) {
//         await roomRef.update({
//           'lastMessage': '🚫 This message was deleted',
//           'lastMessageType': 'text',
//         });
//       }
//     } catch (e) {
//       debugPrint("Error in deleteMessage: $e");
//     }
//   }

//   // Initializes the conversation document if it doesn't exist yet.
//   //
//   // IMPORTANT: We never read from Firestore's `users/` collection here
//   // because CheerChat stores user data in PostgreSQL (not Firestore).
//   // The caller (ChatScreen / host_card) passes in the display name and
//   // profile image they already have from the host model / inbox tile.
//   // The current user's own name/image is pulled from Firebase Auth
//   // (displayName / photoURL), which is populated after phone/Google sign-in.
//   Future<void> initializeChatIfNew(
//     String otherUserId, {
//     String? otherUserName,
//     String? otherUserProfileImage,
//   }) async {
//     final currentUserId = _auth.currentUser!.uid;
//     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);

//     final doc = await roomRef.get();
//     if (doc.exists)
//       return; // Already initialised — nothing to do.

//     // Use Firebase Auth display name / photo if available.
//     // For phone-auth users this may be null until the profile-setup step
//     // writes it back to Firebase Auth — that's OK, the Node.js backend
//     // will back-fill participant data once it's live.
//     final currentUser = _auth.currentUser!;

//     await roomRef.set({
//       'participantIds': [currentUserId, otherUserId],
//       'participants': {
//         currentUserId: {
//           'name': currentUser.displayName,
//           'profileImage': currentUser.photoURL,
//         },
//         otherUserId: {
//           'name': otherUserName,
//           'profileImage': otherUserProfileImage,
//         },
//       },
//       'expiryTime': null,
//       'isUnlocked': false,
//       'deletedFor': {currentUserId: false, otherUserId: false},
//       'lastMessage': 'Chat Started',
//       'lastMessageType': 'system',
//       'lastMessageId': null,
//       'lastSenderId': currentUserId,
//       'pinnedBy': {currentUserId: false, otherUserId: false},
//       'unreadCount': {currentUserId: 0, otherUserId: 0},
//       'lastMessageTime': FieldValue.serverTimestamp(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> markMessagesAsRead(String otherUserId) async {
//     final currentUserId = _auth.currentUser!.uid;
//     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);

//     try {
//       final doc = await roomRef.get();
//       if (!doc.exists) return;
//       await roomRef.update({'unreadCount.$currentUserId': 0});
//     } catch (e) {
//       debugPrint("Error marking as read: $e");
//     }
//   }

//   Stream<QuerySnapshot> getMessages(String otherUserId) async* {
//     final currentUserId = _auth.currentUser!.uid;
//     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);

//     final roomDoc = await roomRef.get();
//     final clearedAt = roomDoc
//         .data()?['clearedAt']?[currentUserId];

//     Query query = roomRef
//         .collection('messages')
//         .orderBy('timestamp', descending: true);

//     if (clearedAt != null) {
//       query = query.where('timestamp', isGreaterThan: clearedAt);
//     }

//     yield* query.snapshots();
//   }

//   Stream<QuerySnapshot> getInbox() {
//     final currentUserId = _auth.currentUser!.uid;
//     return _db
//         .collection('conversations')
//         .where('participantIds', arrayContains: currentUserId)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots();
//   }
// }
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';

// class ChatService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   String getChatRoomId(String userId, String otherId) {
//     final ids = [userId, otherId]..sort();
//     return ids.join('_');
//   }

//   Future<void> sendMessage({
//     required String receiverId,
//     required String text,
//     String type = 'text',
//     String? retryMessageId,
//     Map<String, dynamic>? extraData,
//   }) async {
//     final currentUserId = _auth.currentUser!.uid;
//     await initializeChatIfNew(receiverId);

//     final chatRoomId = getChatRoomId(currentUserId, receiverId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);
//     final messageRef = retryMessageId != null
//         ? roomRef.collection('messages').doc(retryMessageId)
//         : roomRef.collection('messages').doc();

//     try {
//       final timestamp = FieldValue.serverTimestamp();

//       await messageRef.set({
//         'senderId': currentUserId,
//         'receiverId': receiverId,
//         'text': text,
//         'type': type,
//         'timestamp': timestamp,
//         'status': 'sent',
//         if (extraData != null) ...extraData,
//       });

//       final String lastMessagePreview =
//           {
//             'image': '📷 Image',
//             'lottie': '[Emoji]',
//             'gift': 'Gift 🎁',
//           }[type] ??
//           text;

//       await roomRef.set({
//         'lastMessage': lastMessagePreview,
//         'lastMessageTime': timestamp,
//         'lastMessageType': type,
//         'lastMessageId': messageRef.id,
//         'lastSenderId': currentUserId,
//         'unreadCount': {receiverId: FieldValue.increment(1)},
//         'deletedFor': {receiverId: false},
//       }, SetOptions(merge: true));
//     } catch (e) {
//       debugPrint("Error sending message: $e");
//       rethrow;
//     }
//   }

//   Future<Map<String, String>> uploadChatImage(File file) async {
//     final fileName =
//         '${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final path = 'chat_images/$fileName';
//     final ref = _storage.ref().child(path);
//     await ref.putFile(file);
//     final url = await ref.getDownloadURL();
//     return {'url': url, 'path': path};
//   }

//   Future<void> sendImageMessage({
//     required String receiverId,
//     required String imageUrl,
//     required String storagePath,
//   }) async {
//     await sendMessage(
//       receiverId: receiverId,
//       text: imageUrl,
//       type: 'image',
//       extraData: {'storagePath': storagePath},
//     );
//   }

//   Future<void> deleteMessage({
//     required String otherUserId,
//     required String messageId,
//   }) async {
//     try {
//       final currentUserId = _auth.currentUser!.uid;
//       final chatRoomId = getChatRoomId(
//         currentUserId,
//         otherUserId,
//       );
//       final messageRef = _db
//           .collection('conversations')
//           .doc(chatRoomId)
//           .collection('messages')
//           .doc(messageId);

//       final doc = await messageRef.get();
//       if (!doc.exists) return;

//       final roomRef = _db
//           .collection('conversations')
//           .doc(chatRoomId);
//       final data = doc.data()!;
//       final storagePath = data['storagePath'];

//       if (data['type'] == 'image' && storagePath != null) {
//         try {
//           await _storage.ref(storagePath).delete();
//         } catch (e) {
//           debugPrint("Error deleting storage file: $e");
//         }
//       }

//       await messageRef.update({
//         'isDeleted': true,
//         'text': '',
//         'type': 'text',
//         'storagePath': null,
//       });

//       final roomDoc = await roomRef.get();
//       if (roomDoc.exists &&
//           roomDoc.data()?['lastMessageId'] == messageId) {
//         await roomRef.update({
//           'lastMessage': '🚫 This message was deleted',
//           'lastMessageType': 'text',
//         });
//       }
//     } catch (e) {
//       debugPrint("Error in deleteMessage: $e");
//     }
//   }

//   // Initializes the conversation document if it doesn't exist yet.
//   //
//   // IMPORTANT: We never read from Firestore's `users/` collection here
//   // because CheerChat stores user data in PostgreSQL (not Firestore).
//   // The caller (ChatScreen / host_card) passes in the display name and
//   // profile image they already have from the host model / inbox tile.
//   // The current user's own name/image is pulled from Firebase Auth
//   // (displayName / photoURL), which is populated after phone/Google sign-in.
//   Future<void> initializeChatIfNew(
//     String otherUserId, {
//     String? otherUserName,
//     String? otherUserProfileImage,
//   }) async {
//     final currentUserId = _auth.currentUser!.uid;
//     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);

//     final doc = await roomRef.get();
//     if (doc.exists)
//       return; // Already initialised — nothing to do.

//     // Use Firebase Auth display name / photo if available.
//     // For phone-auth users this may be null until the profile-setup step
//     // writes it back to Firebase Auth — that's OK, the Node.js backend
//     // will back-fill participant data once it's live.
//     final currentUser = _auth.currentUser!;

//     await roomRef.set({
//       'participantIds': [currentUserId, otherUserId],
//       'participants': {
//         currentUserId: {
//           'name': currentUser.displayName,
//           'profileImage': currentUser.photoURL,
//         },
//         otherUserId: {
//           'name': otherUserName,
//           'profileImage': otherUserProfileImage,
//         },
//       },
//       'expiryTime': null,
//       'isUnlocked': false,
//       'deletedFor': {currentUserId: false, otherUserId: false},
//       'lastMessage': 'Chat Started',
//       'lastMessageType': 'system',
//       'lastMessageId': null,
//       'lastSenderId': currentUserId,
//       'pinnedBy': {currentUserId: false, otherUserId: false},
//       'unreadCount': {currentUserId: 0, otherUserId: 0},
//       'lastMessageTime': FieldValue.serverTimestamp(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> markMessagesAsRead(String otherUserId) async {
//     final currentUserId = _auth.currentUser!.uid;
//     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);

//     try {
//       final doc = await roomRef.get();
//       if (!doc.exists) return;
//       await roomRef.update({'unreadCount.$currentUserId': 0});
//     } catch (e) {
//       debugPrint("Error marking as read: $e");
//     }
//   }

//   Stream<QuerySnapshot> getMessages(String otherUserId) async* {
//     final currentUserId = _auth.currentUser!.uid;
//     final chatRoomId = getChatRoomId(currentUserId, otherUserId);
//     final roomRef = _db
//         .collection('conversations')
//         .doc(chatRoomId);

//     final roomDoc = await roomRef.get();
//     final clearedAt = roomDoc
//         .data()?['clearedAt']?[currentUserId];

//     Query query = roomRef
//         .collection('messages')
//         .orderBy('timestamp', descending: true);

//     if (clearedAt != null) {
//       query = query.where('timestamp', isGreaterThan: clearedAt);
//     }

//     yield* query.snapshots();
//   }

//   Stream<QuerySnapshot> getInbox() {
//     final currentUserId = _auth.currentUser!.uid;
//     return _db
//         .collection('conversations')
//         .where('participantIds', arrayContains: currentUserId)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots();
//   }
// }
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String getChatRoomId(String userId, String otherId) {
    final ids = [userId, otherId]..sort();
    return ids.join('_');
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
    String type = 'text',
    String? retryMessageId,
    Map<String, dynamic>? extraData,
    // Participant display info — needed to initialise the conversation doc if
    // it doesn't exist yet. Without these, the inbox would show null name/avatar.
    String? otherUserName,
    String? otherUserProfileImage,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    await initializeChatIfNew(
      receiverId,
      otherUserName: otherUserName,
      otherUserProfileImage: otherUserProfileImage,
    );

    final chatRoomId = getChatRoomId(currentUserId, receiverId);
    final roomRef = _db
        .collection('conversations')
        .doc(chatRoomId);
    final messageRef = retryMessageId != null
        ? roomRef.collection('messages').doc(retryMessageId)
        : roomRef.collection('messages').doc();

    try {
      final timestamp = FieldValue.serverTimestamp();

      await messageRef.set({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': text,
        'type': type,
        'timestamp': timestamp,
        'status': 'sent',
        if (extraData != null) ...extraData,
      });

      final String lastMessagePreview =
          {
            'image': '📷 Image',
            'lottie': '[Emoji]',
            'gift': 'Gift 🎁',
          }[type] ??
          text;

      await roomRef.set({
        'lastMessage': lastMessagePreview,
        'lastMessageTime': timestamp,
        'lastMessageType': type,
        'lastMessageId': messageRef.id,
        'lastSenderId': currentUserId,
        'unreadCount': {receiverId: FieldValue.increment(1)},
        // Reset deletedFor for BOTH users — if sender had previously deleted
        // this chat and is now re-opening it, their flag must be cleared so
        // the conversation reappears in their inbox.
        'deletedFor': {receiverId: false, currentUserId: false},
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
      final storagePath = data['storagePath'];

      if (data['type'] == 'image' && storagePath != null) {
        try {
          await _storage.ref(storagePath).delete();
        } catch (e) {
          debugPrint("Error deleting storage file: $e");
        }
      }

      await messageRef.update({
        'isDeleted': true,
        'text': '',
        'type': 'text',
        'storagePath': null,
      });

      final roomDoc = await roomRef.get();
      if (roomDoc.exists &&
          roomDoc.data()?['lastMessageId'] == messageId) {
        await roomRef.update({
          'lastMessage': '🚫 This message was deleted',
          'lastMessageType': 'text',
        });
      }
    } catch (e) {
      debugPrint("Error in deleteMessage: $e");
    }
  }

  // Initializes the conversation document if it doesn't exist yet.
  //
  // IMPORTANT: We never read from Firestore's `users/` collection here
  // because CheerChat stores user data in PostgreSQL (not Firestore).
  // The caller (ChatScreen / host_card) passes in the display name and
  // profile image they already have from the host model / inbox tile.
  // The current user's own name/image is pulled from Firebase Auth
  // (displayName / photoURL), which is populated after phone/Google sign-in.
  Future<void> initializeChatIfNew(
    String otherUserId, {
    String? otherUserName,
    String? otherUserProfileImage,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final roomRef = _db
        .collection('conversations')
        .doc(chatRoomId);

    final doc = await roomRef.get();
    if (doc.exists)
      return; // Already initialised — nothing to do.

    // Use Firebase Auth display name / photo if available.
    // For phone-auth users this may be null until the profile-setup step
    // writes it back to Firebase Auth — that's OK, the Node.js backend
    // will back-fill participant data once it's live.
    final currentUser = _auth.currentUser!;

    await roomRef.set({
      'participantIds': [currentUserId, otherUserId],
      'participants': {
        currentUserId: {
          'name': currentUser.displayName,
          'profileImage': currentUser.photoURL,
        },
        otherUserId: {
          'name': otherUserName,
          'profileImage': otherUserProfileImage,
        },
      },
      'expiryTime': null,
      'isUnlocked': false,
      'deletedFor': {currentUserId: false, otherUserId: false},
      'lastMessage': 'Chat Started',
      'lastMessageType': 'system',
      'lastMessageId': null,
      'lastSenderId': currentUserId,
      'pinnedBy': {currentUserId: false, otherUserId: false},
      'unreadCount': {currentUserId: 0, otherUserId: 0},
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final roomRef = _db
        .collection('conversations')
        .doc(chatRoomId);

    try {
      final doc = await roomRef.get();
      if (!doc.exists) return;
      await roomRef.update({'unreadCount.$currentUserId': 0});
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) async* {
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final roomRef = _db
        .collection('conversations')
        .doc(chatRoomId);

    final roomDoc = await roomRef.get();
    final clearedAt = roomDoc
        .data()?['clearedAt']?[currentUserId];

    Query query = roomRef
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (clearedAt != null) {
      query = query.where('timestamp', isGreaterThan: clearedAt);
    }

    yield* query.snapshots();
  }

  Stream<QuerySnapshot> getInbox() {
    final currentUserId = _auth.currentUser!.uid;
    return _db
        .collection('conversations')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}

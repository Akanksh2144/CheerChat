import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // String getConversationId(String a, String b) {
  //   return a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
  // }
  String getConversationId(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> sendMessage({
    required String fromId,
    required String toId,
    required String text,
  }) async {
    final convoId = getConversationId(fromId, toId);
    final convoRef = _firestore
        .collection('conversations')
        .doc(convoId);

    // add message
    await convoRef.collection('messages').add({
      'senderId': fromId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'text',
    });

    // update conversation summary
    await convoRef.set({
      'members': [fromId, toId],
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


  Stream<QuerySnapshot> messageStream(
    String userA,
    String userB,
  ) {
    final convoId = getConversationId(userA, userB);

    return _firestore
        .collection('conversations')
        .doc(convoId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

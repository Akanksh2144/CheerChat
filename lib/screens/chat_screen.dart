// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:judotalk/services/chat_services.dart';

// class ChatScreen extends StatefulWidget {
//   final String otherUserId;
//   final String otherUserName;

//   const ChatScreen({
//     super.key,
//     required this.otherUserId,
//     required this.otherUserName,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final TextEditingController _controller =
//       TextEditingController();

//   // String get currentUserId =>
//   //     FirebaseAuth.instance.currentUser!.uid;
//   // String get currentUserId {
//   //   final user = FirebaseAuth.instance.currentUser;
//   //   return user?.uid ?? 'test_user_1';
//   // }
//   String get currentUserId => 'user1';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.otherUserName)),
//       body: Column(
//         children: [
//           // messages
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _chatService.messageStream(
//                 currentUserId,
//                 widget.otherUserId,
//               ),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 final docs = snapshot.data!.docs;

//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final data =
//                         docs[index].data()
//                             as Map<String, dynamic>;
//                     final isMe =
//                         data['senderId'] == currentUserId;

//                     return Align(
//                       alignment: isMe
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.all(8),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: isMe
//                               ? Colors.blue
//                               : Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(
//                             12,
//                           ),
//                         ),
//                         child: Text(
//                           data['text'],
//                           style: TextStyle(
//                             color: isMe
//                                 ? Colors.white
//                                 : Colors.black,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // input
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Type a message...',
//                     contentPadding: EdgeInsets.all(12),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: () async {
//                   if (_controller.text.trim().isEmpty) return;

//                   await _chatService.sendMessage(
//                     fromId: currentUserId,
//                     toId: widget.otherUserId,
//                     text: _controller.text.trim(),
//                   );

//                   _controller.clear();
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget{
  const ChatScreen({super.key});

  Widget build(context) {
    return Container();
  }
}
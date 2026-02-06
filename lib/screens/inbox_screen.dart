// import 'package:flag/flag.dart';
// import 'package:flutter/material.dart';
// import 'package:judotalk/widgets/chat_tile.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// import 'chat_screen.dart';

// class InboxChat {
//   final String name;
//   final String level;
//   final String lastMessage;
//   final int unread;
//   final FlagsCode flagscode;
//   final Image? image;
//   final String time;

//   const InboxChat({
//     required this.name,
//     required this.level,
//     required this.lastMessage,
//     required this.unread,
//     required this.flagscode,
//     this.image,
//     required this.time,
//   });
// }

// class InboxScreen extends StatelessWidget {
//   InboxScreen({super.key});

//   /// Temporary mock data (replace with backend)
//   final List<InboxChat> chats = [
//     InboxChat(
//       name: "Ananya",
//       level: "level 1",
//       lastMessage: "Hey! Are you free now?",
//       unread: 2,
//       flagscode: FlagsCode.PK,
//       time: "2:15 PM",
//     ),
//     InboxChat(
//       name: "Rahul",
//       level: "level 2",
//       lastMessage: "Call me later",
//       unread: 0,
//       flagscode: FlagsCode.SA,
//       time: "Yesterday",
//     ),
//     InboxChat(
//       name: "Rahul",
//       level: "level 3",
//       lastMessage: "Call me later",
//       unread: 0,
//       flagscode: FlagsCode.IN,
//       time: "Yesterday",
//     ),
//     InboxChat(
//       name: "Rahul",
//       level: "level 2",
//       lastMessage: "Call me later",
//       unread: 0,
//       flagscode: FlagsCode.PK,
//       time: "Yesterday",
//     ),
//     InboxChat(
//       name: "Rahul",
//       level: "level 2",
//       lastMessage: "Call me later",
//       unread: 0,
//       flagscode: FlagsCode.MA,
//       time: "Yesterday",
//     ),
//     InboxChat(
//       name: "Rahul",
//       level: "level 2",
//       lastMessage: "Call me later",
//       unread: 0,
//       flagscode: FlagsCode.BD,
//       time: "Yesterday",
//     ),
//     InboxChat(
//       name: "Rahul",
//       level: "level 2",
//       lastMessage: "Call me later",
//       unread: 0,
//       flagscode: FlagsCode.SA,
//       time: "Yesterday",
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Messages"),
//         elevation: 1,
//       ),
//       body: ListView.separated(
//         itemCount: chats.length,
//         separatorBuilder: (_, __) => const Divider(height: 14),
//         itemBuilder: (context, index) {
//           final chat = chats[index];
//           return ChatTile(
//             chat: chat,
//             onTap: () {
//               pushScreenWithoutNavBar(
//                 context,
//                 ChatScreen(
//                   otherUserId: 'user2',
//                   otherUserName: chat.name,
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

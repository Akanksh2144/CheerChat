import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'package:judotalk/screens/hosts_grid_view.dart';
import 'package:judotalk/screens/inbox_screen.dart';
import 'package:judotalk/screens_notcompleted/call_history.dart';
import 'package:judotalk/screens_notcompleted/profile_screen.dart';
import 'package:judotalk/screens_notcompleted/random_call_screen.dart';

class PersistentBottomNavBar extends StatefulWidget {
  const PersistentBottomNavBar({super.key});
  @override
  State<StatefulWidget> createState() {
    return _PersistentBottomNavBarState();
  }
}

class _PersistentBottomNavBarState
    extends State<PersistentBottomNavBar> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      gestureNavigationEnabled: true,
      controller: _controller,
      tabs: [
        PersistentTabConfig(
          screen: HostsGridViewScreen(),
          item: ItemConfig(
            icon: FaIcon(FontAwesomeIcons.earthAmericas),
            title: "Connect",
          ),
        ),

        PersistentTabConfig(
          screen: CallHistory(),
          item: ItemConfig(
            icon: FaIcon(FontAwesomeIcons.clockRotateLeft),
            title: "History",
          ),
        ),
        PersistentTabConfig(
          screen: RandomCallScreen(),
          // screen: InboxScreen(),
          item: ItemConfig(
            icon: FaIcon(FontAwesomeIcons.shuffle),
            title: "Random Call",
          ),
        ),
        PersistentTabConfig(
          screen: InboxScreen(
            // child: ChatScreen(
            //   otherUserId:
            //       "abmy04pG6Ye1bcIycJyZOQFx61x2", // Replace with a real ID when you have users
            //   otherUserName: "Akanksh",
            //   // otherUserId: '8b2f6dEZlXZU4VOVjtWXtT3sCuD2',
            //   // otherUserName: 'Akash',
            // ),
          ),
          item: ItemConfig(
            icon: FaIcon(FontAwesomeIcons.solidMessage),
            title: "Chat",
          ),
        ),
        PersistentTabConfig(
          screen: ProfileScreen(),
          item: ItemConfig(
            icon: FaIcon(FontAwesomeIcons.user),
            title: "Profile",
          ),
        ),
      ],

      navBarBuilder: (navBarConfig) => NeumorphicBottomNavBar(
        navBarConfig: navBarConfig,
        height: 60,
        navBarDecoration: NavBarDecoration(
          color: const Color.fromARGB(206, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
          // boxShadow: [
          //   BoxShadow(color: Colors.black26, blurRadius: 10),
          // ],
        ),
      ),
    );
  }
}

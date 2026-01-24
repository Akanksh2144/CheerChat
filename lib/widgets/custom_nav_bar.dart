import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';


class CustomNavBar extends StatelessWidget {
  final NavBarConfig navBarConfig;

  // You are free to omit this, but in combination with `DecoratedNavBar` it might make your start easier
  final NavBarDecoration navBarDecoration;

  const CustomNavBar({
    super.key,
    required this.navBarConfig,
    this.navBarDecoration = const NavBarDecoration(),
  });

  Widget _buildItem(ItemConfig item, bool isSelected) {
    // final title = item.title;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: IconTheme(
            data: IconThemeData(
              size: item.iconSize,
              color: isSelected
                  ? item.activeForegroundColor
                  : item.inactiveForegroundColor,
            ),
            child: isSelected ? item.icon : item.inactiveIcon,
          ),
        ),
        // if (title != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 15.0),
        //     child: Material(
        //       type: MaterialType.transparency,
        //       child: FittedBox(
        //         child: Text(
        //           title,
        //           style: item.textStyle.apply(
        //             color: isSelected
        //                 ? item.activeForegroundColor
        //                 : item.inactiveForegroundColor,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedNavBar(
      decoration: navBarDecoration,
      height: kBottomNavigationBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final (index, item) in navBarConfig.items.indexed)
            Expanded(
              child: InkWell(
                // This is the most important part. Without this, nothing would happen if you tap on an item.
                onTap: () => navBarConfig.onItemSelected(index),
                onDoubleTap: () {
                  if (index == 0) {
                    print("DOUBLE TAP on HostsGridView");
                  }
                  // 🔥 put your logic here
                  // scrollToTop();
                  // refreshHosts();
                },
                child: _buildItem(
                  item,
                  navBarConfig.selectedIndex == index,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

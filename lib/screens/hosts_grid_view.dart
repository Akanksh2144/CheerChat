import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:judotalk/data/hosts_data.dart';
import 'package:judotalk/screens/filters_screen.dart';
import 'package:judotalk/widgets/cards/host_card.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HostsGridViewScreen extends StatefulWidget {
  const HostsGridViewScreen({super.key});

  @override
  State<HostsGridViewScreen> createState() {
    return _HostsGridViewScreenState();
  }
}

class _HostsGridViewScreenState
    extends State<HostsGridViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime? lastBackPress;

  void _openFilterOverlay() {
    pushScreenWithoutNavBar(context, FiltersScreen());
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Connect",
          // EmojiConverter.fromAlpha2CountryCode('IN'),
          style: GoogleFonts.lato(
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.sliders),
            onPressed: () {
              _openFilterOverlay();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 5,
              left: 16,
              right: 16,
            ),
            child: GridView.builder(
              itemCount: hostData.length,
              // cacheExtent: 800,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14.0,
                    crossAxisSpacing: 14.0,
                    childAspectRatio: 6 / 8,
                  ),
              itemBuilder: (context, index) {
                final host = hostData[index];
                return HostCard(
                  key: ValueKey(hostData[index]),
                  host: host,
                );
              },
            ),
          ),
        ),
        builder: (context, child) => Padding(
          padding: EdgeInsetsGeometry.only(
            top: 100 - _animationController.value * 100,
          ),
          child: child,
        ),
      ),
    );
  }
}

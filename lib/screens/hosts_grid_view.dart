import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:judotalk/data/hosts_data.dart';
import 'package:judotalk/models/host_card.dart';
import 'package:judotalk/screens/search_screen.dart';

class HostsGridViewScreen extends StatefulWidget {
  const HostsGridViewScreen({super.key});

  @override
  State<HostsGridViewScreen> createState() {
    return _HostsGridViewScreenState();
  }
}

class _HostsGridViewScreenState
    extends State<HostsGridViewScreen> {
  

  void _openFilterOverlay() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => SearchScreen()),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Connect",
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 5,
            left: 16,
            right: 16,
          ),
          child: GridView.builder(
            itemCount: hostData.length,
            cacheExtent: 800,
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
    );
  }
}

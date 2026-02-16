import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() =>
      _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen>
    with TickerProviderStateMixin {
  bool isSearching =
      true; // State to toggle between Radar and Video Call
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    // Animation for the "Radar" ripple effect
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _toggleState() {
    setState(() {
      isSearching = !isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1: The Background (Video Feed or Blur)
          _buildBackground(),

          // LAYER 2: The Main UI Content
          SafeArea(
            child: isSearching
                ? _buildSearchingUI()
                : _buildActiveCallUI(),
          ),

          // DEBUG BUTTON: To switch modes for testing
          Positioned(
            top: 50,
            right: 20,
            child: TextButton.icon(
              onPressed: _toggleState,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                isSearching ? Icons.videocam : Icons.search,
              ),
              label: Text(
                isSearching
                    ? "Simulate Connect"
                    : "Simulate Search",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BACKGROUND LAYER
  // ---------------------------------------------------------------------------
  Widget _buildBackground() {
    if (isSearching) {
      // Dark background for searching
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
      );
    } else {
      // Placeholder for Agora/Zego Video Feed
      return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?fit=crop&w=687&q=80",
            ), // Placeholder Host Image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(
                0.1,
              ), // Slight overlay for text readability
              BlendMode.darken,
            ),
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // STATE A: SEARCHING / RADAR UI
  // ---------------------------------------------------------------------------
  Widget _buildSearchingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Radar Animation
          Stack(
            alignment: Alignment.center,
            children: [
              _buildRipple(200),
              _buildRipple(280),
              _buildRipple(360),
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/300",
                ), // Current User's Image
              ),
            ],
          ),
          const SizedBox(height: 50),
          const Text(
            "Finding a Host...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Matching based on your preferences",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(double size) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Container(
          width: size * _rippleController.value,
          height: size * _rippleController.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.pinkAccent.withOpacity(
                1.0 - _rippleController.value,
              ),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STATE B: ACTIVE CALL UI
  // ---------------------------------------------------------------------------
  Widget _buildActiveCallUI() {
    return Column(
      children: [
        // --- TOP BAR (Host Info & Timer) ---
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 10,
          ),
          child: Row(
            children: [
              // Host Profile Pill
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?fit=crop&w=100&q=80",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Jessica, 24",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "🇺🇸 USA",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.add_circle,
                      color: Colors.pinkAccent,
                    ), // Follow button
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const Spacer(),
              // Coin/Timer Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "02:45",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // --- RIGHT SIDE (Gifts) ---
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
              bottom: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSideButton(
                  Icons.card_giftcard,
                  "Gift",
                  Colors.pinkAccent,
                  () {
                    // TODO: Open Gift Bottom Sheet
                  },
                ),
                const SizedBox(height: 20),
                _buildSideButton(
                  Icons.favorite,
                  "Like",
                  Colors.white,
                  () {},
                ),
              ],
            ),
          ),
        ),

        // --- BOTTOM BAR (Controls) ---
        Container(
          padding: const EdgeInsets.only(bottom: 30, top: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlBtn(
                Icons.mic,
                Colors.white.withOpacity(0.2),
              ),
              _buildControlBtn(
                Icons.videocam,
                Colors.white.withOpacity(0.2),
              ),

              // End Call Button
              FloatingActionButton(
                onPressed:
                    _toggleState, // Ends call and goes back to search
                backgroundColor: Colors.redAccent,
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                ),
              ),

              _buildControlBtn(
                Icons.cameraswitch,
                Colors.white.withOpacity(0.2),
              ),
              _buildControlBtn(
                Icons.chat_bubble,
                Colors.white.withOpacity(0.2),
              ), // Text Chat
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildSideButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(blurRadius: 2, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:judotalk/services/agora_services.dart';

class OngoingCallScreen extends StatefulWidget {
  final AgoraService agoraService;
  final String channelId;
  final String token;
  final int localUid;

  const OngoingCallScreen({
    super.key,
    required this.agoraService,
    required this.channelId,
    required this.token,
    required this.localUid,
  });

  @override
  State<OngoingCallScreen> createState() =>
      _OngoingCallScreenState();
}

class _OngoingCallScreenState extends State<OngoingCallScreen> {
  bool _isConnecting = true;

  // Movable PIP Position
  Offset _pipOffset = const Offset(20, 100);

  // UI Toggle Logic
  bool _uiVisible = true;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  void _showRechargeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Wallet Balance",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  "1,250",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 40, color: Colors.white10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quick Recharge",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Example Recharge Options
            _buildRechargeOption("500 Coins", "\$4.99"),
            _buildRechargeOption("1200 Coins", "\$9.99"),
            _buildRechargeOption("3000 Coins", "\$24.99"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeOption(String coins, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // TODO: Integrate Payment Gateway
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    coins,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startCall() async {
    try {
      await widget.agoraService.initialize(
        appId: "YOUR_AGORA_APP_ID",
        fetchNewToken: () async => "NEW_TOKEN",
      );
      await widget.agoraService.join(
        token: widget.token,
        channelId: widget.channelId,
        uid: widget.localUid,
      );
      if (mounted) setState(() => _isConnecting = false);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _uiVisible = !_uiVisible),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Layer 1: Full Screen Remote Video
            _buildRemoteVideoBackground(),

            // Layer 2: Movable PIP (Always draggable)
            _buildMovablePIP(),

            // Layer 3: Hideable UI Elements
            if (_uiVisible) ...[
              _buildTopBar(),
              _buildChatOverlay(),
              _buildRightSideButtons(),
              _buildBottomInput(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideoBackground() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: widget.agoraService.remoteUids,
      builder: (context, uids, _) {
        if (uids.isEmpty) {
          return const Center(
            child: Text(
              "Connecting...",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return SizedBox.expand(
          child: widget.agoraService.buildRemoteVideo(
            uids.first,
          ),
        );
      },
    );
  }

  Widget _buildMovablePIP() {
    return Positioned(
      left: _pipOffset.dx,
      top: _pipOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _pipOffset += details.delta;
          });
        },
        child: Container(
          width: 110,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(blurRadius: 10, color: Colors.black45),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.agoraService.buildLocalVideo(),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // User Info
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Jessica, 24",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "00:00",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          // End Call (Top Right)
          GestureDetector(
            onTap: () => widget.agoraService.leave().then(
              (_) => Navigator.pop(context),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSideButtons() {
    return Positioned(
      bottom: 100, // Above chat bar
      right: 16,
      child: Column(
        children: [
          _buildActionButton(
            Icons.monetization_on,
            Colors.amber,
            () => _showRechargeMenu(context),
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            Icons.card_giftcard,
            Colors.pinkAccent,
            () {},
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            Icons.cameraswitch,
            Colors.white24,
            widget.agoraService.switchCamera,
          ),
          const SizedBox(height: 15),
          ValueListenableBuilder<bool>(
            valueListenable: widget.agoraService.isAudioMuted,
            builder: (context, muted, _) => _buildActionButton(
              muted ? Icons.mic_off : Icons.mic,
              muted ? Colors.red : Colors.white24,
              widget.agoraService.toggleMuteAudio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOverlay() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 80, // Leave room for side buttons
      height: 180,
      child: ListView.builder(
        reverse: true, // Latest messages at bottom
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "User: Message appears here without background",
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 4, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInput() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            // Swapped FaIcon for standard Icon and added slight right padding
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.send,
                size: 28,
                color: Colors.white,
              ),
            ),
            hintText: "Say something...",
            hintStyle: const TextStyle(color: Colors.white60),
            filled: true,
            fillColor: Colors.black38,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            // Added vertical padding to balance the height and center the icon
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

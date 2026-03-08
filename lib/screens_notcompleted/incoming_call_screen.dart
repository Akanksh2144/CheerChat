import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends StatefulWidget {
  final int remoteUid; // The ID of the person you are calling

  const CallScreen({Key? key, required this.remoteUid})
    : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // We'll manage chat messages in a simple list for now
  final List<String> _messages = [];
  final TextEditingController _chatController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: The Remote User (Full Screen)
            _buildRemoteVideo(),

            // Layer 2: The Local User (Small box, top right)
            Positioned(
              top: 20,
              right: 20,
              child: _buildLocalVideo(),
            ),

            // Layer 3: The In-Call Messaging Overlay (Bottom, just above controls)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: _buildChatOverlay(),
            ),

            // Layer 4: Call Controls (Bottom edge)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildCallControls(),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildRemoteVideo() {
    // If the remote user hasn't joined yet, show a loading indicator
    if (widget.remoteUid == 0) {
      return const Center(
        child: Text(
          "Waiting for user to join...",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    // Agora's widget to display the remote video stream
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine:
            createAgoraRtcEngine(), // We'll pass the real engine later
        canvas: VideoCanvas(uid: widget.remoteUid),
        connection: const RtcConnection(
          channelId: 'your_channel_name',
        ),
      ),
    );
  }

  Widget _buildLocalVideo() {
    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      // Agora's widget to display your own camera
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine:
              createAgoraRtcEngine(), // We'll pass the real engine later
          canvas: const VideoCanvas(
            uid: 0,
          ), // uid 0 means "local user"
        ),
      ),
    );
  }

  Widget _buildChatOverlay() {
    return Container(
      height:
          200, // Restrict chat height so it doesn't block the video
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // The list of messages
          Expanded(
            child: ListView.builder(
              reverse: true, // Newest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                  ),
                  child: Text(
                    _messages[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          // The text input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.black45,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  // TODO: Send via Agora RTM
                  setState(() {
                    _messages.insert(
                      0,
                      "Me: ${_chatController.text}",
                    );
                    _chatController.clear();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: "mute",
            backgroundColor: Colors.white,
            onPressed: () {
              /* TODO: Toggle Mic */
            },
            child: const Icon(Icons.mic, color: Colors.black),
          ),
          FloatingActionButton(
            heroTag: "end_call",
            backgroundColor: Colors.red,
            onPressed: () {
              /* TODO: Leave Channel and Pop Screen */
            },
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            heroTag: "switch_camera",
            backgroundColor: Colors.white,
            onPressed: () {
              /* TODO: Flip Camera */
            },
            child: const Icon(
              Icons.cameraswitch,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

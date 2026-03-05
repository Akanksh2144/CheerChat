import 'package:flutter/material.dart';
import 'package:judotalk/screens_notcompleted/ongoing_call_screen.dart';
import 'package:judotalk/services/agora_services.dart';
// Ensure this path is correct
// Import your OngoingCallScreen file here if it's in a different file

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UITestEntryScreen(),
    ),
  );
}

class UITestEntryScreen extends StatelessWidget {
  const UITestEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Sandbox')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OngoingCallScreen(
                  agoraService:
                      FakeAgoraService(), // 👉 Injecting the Fake
                  channelId: 'test_room',
                  token: 'dummy_token',
                  localUid: 1,
                ),
              ),
            );
          },
          child: const Text('Launch Ongoing Call UI'),
        ),
      ),
    );
  }
}

/// =========================================
/// FAKE SERVICE FOR UI TESTING ONLY
/// =========================================
class FakeAgoraService extends AgoraService {
  @override
  Future<void> initialize({
    required String appId,
    required Future<String> Function() fetchNewToken,
  }) async {
    // Simulate a 1.5 second network delay for initialization
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Future<void> join({
    required String token,
    required String channelId,
    required int uid,
  }) async {
    // Simulate a 1-second network delay for joining the channel
    await Future.delayed(const Duration(seconds: 1));

    // 👉 Simulate a remote user joining the call 3 seconds later!
    Future.delayed(const Duration(seconds: 3), () {
      remoteUids.value = {999}; // Adds a dummy user
    });
  }

  @override
  Widget buildLocalVideo() {
    // Fake local camera (PIP window)
    return Container(
      color: Colors.blueGrey.shade800,
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white54,
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget buildRemoteVideo(int uid) {
    // Fake remote camera (Background)
    return Container(
      color: Colors.teal.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              'User $uid Video Feed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> toggleMuteAudio() async {
    isAudioMuted.value = !isAudioMuted.value;
  }

  @override
  Future<void> toggleMuteVideo() async {
    isVideoMuted.value = !isVideoMuted.value;
  }

  @override
  Future<void> switchCamera() async {
    debugPrint("Camera Switched");
  }

  @override
  Future<void> leave() async {
    debugPrint("Call Ended");
  }
}

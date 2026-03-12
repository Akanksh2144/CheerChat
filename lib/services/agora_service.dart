import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  late final RtcEngine _engine;

  // Internal State
  bool _isInitialized = false;
  bool _isJoined = false;
  String? _currentChannelId;

  // Public Getters
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;

  // Reactive State for UI
  final ValueNotifier<Set<int>> remoteUids = ValueNotifier({});
  final ValueNotifier<bool> isAudioMuted = ValueNotifier(false);
  final ValueNotifier<bool> isVideoMuted = ValueNotifier(false);

  // 👉 Monetization & Billing State
  final VoidCallback? onBillableSessionStart;
  final VoidCallback? onBillableSessionEnd;

  bool _isBillingActive = false;
  Timer? _billingDisconnectTimer; // Buffer for network flickers

  AgoraService({
    this.onBillableSessionStart,
    this.onBillableSessionEnd,
  });

  /// ============================
  /// 1. INITIALIZE ENGINE
  /// ============================
  Future<void> initialize({
    required String appId,
    required Future<String> Function() fetchNewToken,
  }) async {
    if (_isInitialized) return;

    final status = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (status[Permission.microphone] !=
            PermissionStatus.granted ||
        status[Permission.camera] != PermissionStatus.granted) {
      throw Exception(
        'Camera and Microphone permissions are required.',
      );
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: appId));

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess:
              (RtcConnection connection, int elapsed) {
                debugPrint(
                  '✅ Joined channel: ${connection.channelId}',
                );
                _isJoined = true;
              },
          onUserJoined:
              (
                RtcConnection connection,
                int remoteUid,
                int elapsed,
              ) {
                debugPrint('👤 Remote user joined: $remoteUid.');

                // Cancel any pending disconnect timers since someone is here
                _billingDisconnectTimer?.cancel();

                remoteUids.value = {
                  ...remoteUids.value,
                  remoteUid,
                };

                // 👉 GUARANTEED BILLING RESTART
                // This ensures billing starts (or resumes) safely, even if state desynced
                if (!_isBillingActive) {
                  _isBillingActive = true;
                  debugPrint(
                    '⏱️ Starting billable session timer.',
                  );
                  onBillableSessionStart?.call();
                }
              },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                debugPrint(
                  '👋 Remote user left: $remoteUid. Reason: $reason',
                );

                final currentUids = Set<int>.from(
                  remoteUids.value,
                );
                currentUids.remove(remoteUid);
                remoteUids.value = currentUids;

                // 👉 Guarded Billing Stop
                if (remoteUids.value.isEmpty &&
                    _isBillingActive) {
                  _isBillingActive = false;
                  debugPrint(
                    '🛑 Stopping billable session timer.',
                  );
                  onBillableSessionEnd?.call();
                }
              },
          onConnectionStateChanged:
              (
                RtcConnection connection,
                ConnectionStateType state,
                ConnectionChangedReasonType reason,
              ) {
                debugPrint(
                  '🔄 Connection state: $state | Reason: $reason',
                );

                // Catch native reconnects to cancel the disconnect timer
                if (state ==
                    ConnectionStateType
                        .connectionStateConnected) {
                  _billingDisconnectTimer?.cancel();
                }
              },
          onConnectionLost: (RtcConnection connection) {
            debugPrint(
              '⚠️ Connection lost. Initiating 10-second buffer...',
            );

            // 👉 10-Second Buffer Before Cutting Billing
            if (_isBillingActive) {
              _billingDisconnectTimer?.cancel();
              _billingDisconnectTimer = Timer(
                const Duration(seconds: 10),
                () {
                  if (_isBillingActive) {
                    // Double check it hasn't restarted
                    _isBillingActive = false;
                    debugPrint(
                      '🛑 Network drop timeout. Stopping billable session.',
                    );
                    onBillableSessionEnd?.call();
                  }
                },
              );
            }
          },
          onTokenPrivilegeWillExpire:
              (RtcConnection connection, String token) async {
                debugPrint(
                  '⚠️ Token expiring. Fetching new token automatically...',
                );
                try {
                  final newToken = await fetchNewToken();
                  await renewToken(newToken);
                } catch (e) {
                  debugPrint(
                    '❌ Critical: Failed to auto-renew token: $e',
                  );
                }
              },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('❌ Agora Error: $err - $msg');
          },
        ),
      );

      // 👉 Optimized Video Dimensions (960x540)
      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 960, height: 540),
          frameRate: 15,
          bitrate: 0,
        ),
      );

      await _engine.enableVideo();
      await _engine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );
      await _engine.startPreview();

      _isInitialized = true;
      debugPrint('🚀 Agora initialized successfully.');
    } catch (e) {
      throw Exception('Failed to initialize Agora: $e');
    }
  }

  /// ============================
  /// 2. JOIN CHANNEL
  /// ============================
  Future<void> join({
    required String token,
    required String channelId,
    required int uid,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Agora not initialized. Call initialize() first.',
      );
    }
    if (_isJoined) {
      throw Exception('Already joined a channel.');
    }
    if (token.isEmpty) {
      throw Exception(
        'Invalid Agora token. Token cannot be empty.',
      );
    }

    try {
      _currentChannelId = channelId;

      await _engine.joinChannel(
        token: token,
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      _currentChannelId = null;
      debugPrint('❌ Error joining channel: $e');
      rethrow;
    }
  }

  /// ============================
  /// 3. UI BUILDERS
  /// ============================
  Widget buildLocalVideo() {
    if (!_isInitialized || !_isJoined) {
      return const Center(child: Text('Not connected'));
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isVideoMuted,
      builder: (context, isMuted, child) {
        if (isMuted) {
          return const Center(
            child: Icon(
              Icons.videocam_off,
              color: Colors.grey,
              size: 50,
            ),
          );
        }

        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      },
    );
  }

  Widget buildRemoteVideo(int uid) {
    if (!_isInitialized || _currentChannelId == null) {
      return const Center(child: Text('Not connected'));
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: _currentChannelId!),
      ),
    );
  }

  /// ============================
  /// 4. HARDWARE CONTROLS
  /// ============================
  Future<void> toggleMuteAudio() async {
    if (!_isInitialized) return;
    try {
      final newState = !isAudioMuted.value;
      await _engine.muteLocalAudioStream(newState);
      isAudioMuted.value = newState;
    } catch (e) {
      debugPrint('❌ Error toggling audio: $e');
    }
  }

  Future<void> toggleMuteVideo() async {
    if (!_isInitialized) return;
    try {
      final newState = !isVideoMuted.value;
      await _engine.muteLocalVideoStream(newState);
      isVideoMuted.value = newState;
    } catch (e) {
      debugPrint('❌ Error toggling video: $e');
    }
  }

  Future<void> switchCamera() async {
    if (!_isInitialized) return;
    try {
      await _engine.switchCamera();
    } catch (e) {
      debugPrint('❌ Error switching camera: $e');
    }
  }

  /// ============================
  /// 5. LIFECYCLE MANAGEMENT
  /// ============================
  Future<void> renewToken(String newToken) async {
    if (!_isInitialized || !_isJoined) return;
    try {
      await _engine.renewToken(newToken);
      debugPrint('🔄 Token renewed successfully.');
    } catch (e) {
      debugPrint('❌ Error renewing token: $e');
    }
  }

  Future<void> leave() async {
    if (!_isInitialized || !_isJoined) return;

    try {
      await _engine.stopPreview();
      await _engine.leaveChannel();

      _isJoined = false;
      _currentChannelId = null;

      // 👉 Clean up billing state and timers
      _billingDisconnectTimer?.cancel();
      if (_isBillingActive) {
        _isBillingActive = false;
        onBillableSessionEnd?.call();
      }

      remoteUids.value = {};
      debugPrint('🚪 Left channel successfully.');
    } catch (e) {
      debugPrint('❌ Error leaving channel: $e');
    }
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      if (_isJoined) {
        await _engine.leaveChannel();
      }

      await _engine.stopPreview();
      await _engine.release();

      _isInitialized = false;
      _isJoined = false;
      _currentChannelId = null;

      // 👉 Clean up timers to prevent memory leaks
      _billingDisconnectTimer?.cancel();
      _isBillingActive = false;

      remoteUids.value = {};
      isAudioMuted.value = false;
      isVideoMuted.value = false;

      debugPrint('🗑️ Agora engine disposed.');
    } catch (e) {
      debugPrint('❌ Error disposing Agora engine: $e');
    }
  }
}

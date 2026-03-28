import 'dart:async';

import 'package:cheerchat/constants/app_constants.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/providers/follow_provider.dart';
import 'package:cheerchat/providers/wallet_provider.dart';
import 'package:cheerchat/services/agora_service.dart';
import 'package:cheerchat/services/call_api_service.dart';
import 'package:cheerchat/services/gift_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// OngoingCallScreen
//
// ✅ WIRED TO BACKEND:
//   - sessionId from POST /api/calls/start (passed in from host_card)
//   - _endCall → POST /api/calls/:sessionId/end
//   - Token refresh → POST /api/calls/token
//   - Wallet refresh on call end
//
// Entry point — caller passes host + coins + Agora creds + sessionId.
//
// How to push this screen:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => OngoingCallScreen(
//       host: host,
//       initialCoins: userCoins,
//       sessionId: 'uuid-from-server',
//       channelId: 'channel_abc',
//       token: 'agora_token_from_server',
//       localUid: 1,
//     ),
//   ));
// ---------------------------------------------------------------------------
class OngoingCallScreen extends ConsumerStatefulWidget {
  const OngoingCallScreen({
    super.key,
    required this.host,
    required this.initialCoins,
    this.sessionId,
    this.channelId = 'test_channel',
    this.token = 'test_token',
    this.localUid = 0,
    this.testMode = false,
    this.isAlreadyFollowing = false,
  });

  final HostModel host;

  /// User's current wallet balance — used for local UI display only.
  /// Real deduction happens server-side via Node.js billing ticks.
  final int initialCoins;

  /// Server-generated call session ID (from POST /api/calls/start).
  /// Required for ending the call and billing.
  final String? sessionId;

  final String channelId;
  final String token;
  final int localUid;

  /// When true: skips Agora entirely, simulates a connected call after 2s.
  final bool testMode;

  /// If user already follows this host before joining the call,
  /// the follow button is hidden entirely.
  final bool isAlreadyFollowing;

  @override
  ConsumerState<OngoingCallScreen> createState() =>
      _OngoingCallScreenState();
}

class _OngoingCallScreenState
    extends ConsumerState<OngoingCallScreen>
    with WidgetsBindingObserver {
  // ── Agora ────────────────────────────────────────────────────────────────
  late final AgoraService _agora;

  // ── Call state ───────────────────────────────────────────────────────────
  bool _isConnecting = true;
  bool _callEnded = false;
  bool _remoteConnected = false;
  String? _errorMessage;

  // ── Timer & coins ────────────────────────────────────────────────────────
  Timer? _durationTimer;
  Timer? _coinDrainTimer;
  int _elapsedSeconds = 0;
  late int _coinsRemaining;

  // ── UI state ─────────────────────────────────────────────────────────────
  bool _uiVisible = true;
  late bool _isFollowed;
  Offset _pipOffset = const Offset(20, 120);

  // Chat overlay
  final List<_ChatMessage> _chatMessages = [];
  final TextEditingController _chatController =
      TextEditingController();
  final FocusNode _chatFocus = FocusNode();

  // ── Getters ──────────────────────────────────────────────────────────────
  bool get _isLowCoins =>
      _coinsRemaining <
      widget.host.priceCoins *
          AppConstants.lowCoinWarningMinutes;

  String get _formattedDuration {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _coinsSpent => widget.initialCoins - _coinsRemaining;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coinsRemaining = widget.initialCoins;
    _isFollowed = widget.isAlreadyFollowing;
    _agora = AgoraService(
      onBillableSessionStart: _onBillableSessionStart,
      onBillableSessionEnd: _onBillableSessionEnd,
    );
    // Pre-fetch gift catalog so it's ready when user opens the sheet
    ref.read(giftCatalogProvider);
    _startCall();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _coinDrainTimer?.cancel();
    _chatController.dispose();
    _chatFocus.dispose();
    _agora.dispose();
    super.dispose();
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Mute video when app goes to background
      if (!_agora.isVideoMuted.value) {
        _agora.toggleMuteVideo();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Unmute video when app returns to foreground
      if (_agora.isVideoMuted.value) {
        _agora.toggleMuteVideo();
      }
    }
  }

  // ── Agora init ───────────────────────────────────────────────────────────
  Future<void> _startCall() async {
    if (widget.testMode) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isConnecting = false);
      _onBillableSessionStart();
      return;
    }

    try {
      await _agora.initialize(
        appId: AppConstants.agoraAppId,
        fetchNewToken: () async {
          final callApi = ref.read(callApiServiceProvider);
          final newToken = await callApi.getAgoraToken(
            widget.channelId,
            uid: widget.localUid,
          );
          return newToken ?? widget.token;
        },
      );
      await _agora.join(
        token: widget.token,
        channelId: widget.channelId,
        uid: widget.localUid,
      );

      if (mounted) setState(() => _isConnecting = false);

      // Wait 2 seconds for Agora to stabilize before listening to events.
      // This eliminates the rapid join/leave glitch during channel setup.
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || _callEnded) return;

      // Check if remote is already here
      if (_agora.remoteUids.value.isNotEmpty) {
        _remoteConnected = true;
        if (mounted) setState(() {});
      }

      _agora.remoteUids.addListener(_onRemoteUidsChanged);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  void _onRemoteUidsChanged() {
    if (_callEnded) return;

    if (_agora.remoteUids.value.isNotEmpty) {
      _remoteConnected = true;
      if (mounted) setState(() {});
      return;
    }

    // Remote left after being connected → end immediately
    if (_remoteConnected) {
      _endCall(hostLeft: true);
    }
  }

  // ── Billing callbacks ────────────────────────────────────────────────────
  void _onBillableSessionStart() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    _deductCoins();
    _coinDrainTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        if (!mounted) return;
        _deductCoins();
      },
    );
  }

  void _deductCoins() {
    if (!mounted) return;
    setState(() {
      _coinsRemaining =
          (_coinsRemaining - widget.host.priceCoins).clamp(
            0,
            9999999,
          );
    });
    if (_coinsRemaining <= 0) _endCall(outOfCoins: true);
  }

  void _onBillableSessionEnd() {
    _durationTimer?.cancel();
    _coinDrainTimer?.cancel();
  }

  // ── End call ──────────────────────────────────────────────────────────────
  Future<void> _endCall({
    bool hostLeft = false,
    bool outOfCoins = false,
  }) async {
    if (_callEnded) return;
    _durationTimer?.cancel();
    _coinDrainTimer?.cancel();
    if (!widget.testMode) await _agora.leave();
    if (mounted) setState(() => _callEnded = true);

    // ✅ Tell the server the call ended
    if (widget.sessionId != null) {
      final callApi = ref.read(callApiServiceProvider);
      final endedBy = hostLeft
          ? 'host'
          : outOfCoins
          ? 'system'
          : 'caller';
      await callApi.endCall(
        sessionId: widget.sessionId!,
        endedBy: endedBy,
      );
    }

    // ✅ Refresh wallet balance so home screen shows correct coins
    ref.read(walletBalanceProvider.notifier).refresh();
  }

  // ── Chat ──────────────────────────────────────────────────────────────────
  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add(_ChatMessage(text: text, isLocal: true));
    });
    _chatController.clear();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _endCall();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            final keyboardOpen =
                MediaQuery.of(context).viewInsets.bottom > 0;
            if (keyboardOpen) {
              _chatFocus.unfocus();
            } else {
              setState(() => _uiVisible = !_uiVisible);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              _buildRemoteVideo(),
              _buildPip(),
              if (_uiVisible && !_callEnded) ...[
                _buildTopBar(),
                _buildChatOverlay(),
                _buildRightActions(),
                _buildBottomInput(),
              ],
              if (_isConnecting && !_callEnded)
                _buildConnectingOverlay(),
              if (_errorMessage != null) _buildErrorOverlay(),
              if (_callEnded) _buildCallEndedOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Remote video ──────────────────────────────────────────────────────────
  Widget _buildRemoteVideo() {
    if (widget.testMode) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: _isConnecting
            ? null
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 72,
                      backgroundColor: Colors.pink.withValues(
                        alpha: 0.2,
                      ),
                      backgroundImage:
                          widget.host.profilePhotoUrl != null
                          ? NetworkImage(
                              widget.host.profilePhotoUrl!,
                            )
                          : null,
                      child: widget.host.profilePhotoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 72,
                              color: Colors.white38,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.host.displayName,
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '[ Test Mode — No real video ]',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      );
    }

    return ValueListenableBuilder<Set<int>>(
      valueListenable: _agora.remoteUids,
      builder: (_, uids, __) {
        if (uids.isEmpty) {
          return Container(
            color: const Color(0xFF1A1A2E),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.host.profilePhotoUrl != null)
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(
                        widget.host.profilePhotoUrl!,
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.pink.withValues(
                        alpha: 0.3,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 56,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    widget.host.displayName,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _PulsingDots(),
                ],
              ),
            ),
          );
        }
        return SizedBox.expand(
          child: _agora.buildRemoteVideo(uids.first),
        );
      },
    );
  }

  // ── Local PIP ─────────────────────────────────────────────────────────────
  Widget _buildPip() {
    return Positioned(
      left: _pipOffset.dx,
      top: _pipOffset.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          final size = MediaQuery.of(context).size;
          setState(() {
            _pipOffset = Offset(
              (_pipOffset.dx + d.delta.dx).clamp(
                0,
                size.width - 110,
              ),
              (_pipOffset.dy + d.delta.dy).clamp(
                0,
                size.height - 150,
              ),
            );
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 110,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              boxShadow: const [
                BoxShadow(blurRadius: 12, color: Colors.black54),
              ],
            ),
            child: widget.testMode
                ? Container(
                    color: const Color(0xFF2A2A2A),
                    child: const Center(
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white30,
                        size: 28,
                      ),
                    ),
                  )
                : _agora.buildLocalVideo(),
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final safePad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: safePad + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.host.profilePhotoUrl != null)
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      widget.host.profilePhotoUrl!,
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.pink,
                    child: Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.host.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.host.countryCode.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                        if (widget.host.age != null) ...[
                          const Text(
                            '  ·  ',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${widget.host.age} yrs',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (!widget.isAlreadyFollowing) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(followNotifierProvider.notifier)
                          .toggle(widget.host.userId);
                    },
                    child: Builder(
                      builder: (context) {
                        final isFollowed = ref.watch(
                          followStateProvider(
                            widget.host.userId,
                          ),
                        );
                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isFollowed
                                ? Colors.white.withValues(
                                    alpha: 0.15,
                                  )
                                : Colors.pink,
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            isFollowed ? 'Following' : 'Follow',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          _glassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedDuration,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _endCall(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat overlay ──────────────────────────────────────────────────────────
  Widget _buildChatOverlay() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 80,
      height: 180,
      child: ListView.builder(
        reverse: true,
        itemCount: _chatMessages.length,
        itemBuilder: (_, i) {
          final msg =
              _chatMessages[_chatMessages.length - 1 - i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${msg.isLocal ? 'You' : widget.host.displayName}: ${msg.text}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black87),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Right side action buttons ─────────────────────────────────────────────
  Widget _buildRightActions() {
    return Positioned(
      bottom: 90,
      right: 16,
      child: Column(
        children: [
          _actionButton(
            icon: Icons.monetization_on,
            color: Colors.amber,
            onTap: _showRechargeSheet,
          ),
          const SizedBox(height: 14),
          _actionButton(
            icon: Icons.card_giftcard,
            color: Colors.pinkAccent,
            onTap: _showGiftSheet,
          ),
          const SizedBox(height: 14),
          _actionButton(
            icon: Icons.cameraswitch_rounded,
            color: Colors.white24,
            onTap: _agora.switchCamera,
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<bool>(
            valueListenable: _agora.isAudioMuted,
            builder: (_, muted, __) => _actionButton(
              icon: muted
                  ? Icons.mic_off_rounded
                  : Icons.mic_rounded,
              color: muted ? Colors.red : Colors.white24,
              onTap: _agora.toggleMuteAudio,
            ),
          ),
          const SizedBox(height: 14),
          _actionButton(
            icon: Icons.auto_fix_high_rounded,
            color: Colors.purpleAccent.withValues(alpha: 0.8),
            onTap: _showBeautySheet,
          ),
        ],
      ),
    );
  }

  // ── Bottom chat input ─────────────────────────────────────────────────────
  Widget _buildBottomInput() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomPad,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                focusNode: _chatFocus,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _sendChatMessage(),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: Colors.black45,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendChatMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Connecting overlay ────────────────────────────────────────────────────
  Widget _buildConnectingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.pink),
            const SizedBox(height: 20),
            Text(
              'Connecting to ${widget.host.displayName}...',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error overlay ─────────────────────────────────────────────────────────
  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not connect',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Call ended summary overlay ────────────────────────────────────────────
  Widget _buildCallEndedOverlay() {
    final bool isHost = widget.localUid == 2;

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _callEnded) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
        Navigator.of(context).pop();
      }
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Color(0xFF000000)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D1B3D), Color(0xFF1A1A2E)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + checkmark
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.withOpacity(0.3),
                          Colors.purple.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.pink.withOpacity(
                        0.15,
                      ),
                      backgroundImage:
                          widget.host.profilePhotoUrl != null
                          ? NetworkImage(
                              widget.host.profilePhotoUrl!,
                            )
                          : null,
                      child: widget.host.profilePhotoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.white38,
                            )
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Call Ended',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'with ${widget.host.displayName}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    _summaryStatColumn(
                      Icons.timer_outlined,
                      Colors.blue.shade300,
                      'Duration',
                      _formattedDuration,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    _summaryStatColumn(
                      isHost
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      isHost
                          ? Colors.green.shade300
                          : Colors.amber.shade300,
                      isHost ? 'Earned' : 'Spent',
                      '$_coinsSpent coins',
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    _summaryStatColumn(
                      Icons.account_balance_wallet_outlined,
                      Colors.purple.shade200,
                      'Balance',
                      '$_coinsRemaining',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Auto-closing in 5 seconds...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryStatColumn(
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Beauty effects sheet ─────────────────────────────────────────────────
  void _showBeautySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
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
            Text(
              'Beauty Effects',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _beautyOption(
              Icons.face_retouching_natural,
              'Smooth Skin',
            ),
            _beautyOption(Icons.wb_sunny_outlined, 'Brighten'),
            _beautyOption(Icons.blur_on, 'Blur Background'),
            _beautyOption(Icons.color_lens_outlined, 'Filters'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Full beauty effects coming soon via Banuba SDK',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _beautyOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Text(
              'Coming soon',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gift sheet ────────────────────────────────────────────────────────────
  void _showGiftSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Consumer(
        builder: (context, sheetRef, _) {
          final catalogAsync = sheetRef.watch(
            giftCatalogProvider,
          );
          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2D1B3D), Color(0xFF1A1A2E)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.pink.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Send a Gift',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'to ${widget.host.displayName}',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: catalogAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pink,
                      ),
                    ),
                    error: (_, __) => const Center(
                      child: Text(
                        'Could not load gifts',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    data: (catalogData) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.68,
                            ),
                        itemCount: catalogData.length,
                        itemBuilder: (_, i) {
                          final g = catalogData[i];
                          final giftId = '${g['id']}';
                          final name = g['name'] as String;
                          final assetPath =
                              g['media_url'] as String;
                          final coinCost =
                              (g['coin_cost'] as num).toInt();
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _sendGiftFromCall(
                                giftId,
                                assetPath,
                                coinCost,
                                name,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.05,
                                ),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.08),
                                ),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      assetPath,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                            _,
                                            __,
                                            ___,
                                          ) => const Icon(
                                            Icons.card_giftcard,
                                            color: Colors.pink,
                                            size: 28,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(
                                            8,
                                          ),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Colors.amber,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$coinCost',
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Balance bar at bottom
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Balance: $_coinsRemaining coins',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendGiftFromCall(
    String giftId,
    String assetPath,
    int coinCost,
    String giftName,
  ) async {
    final giftApi = ref.read(giftApiServiceProvider);
    final res = await giftApi.sendGift(
      receiverId: widget.host.userId,
      giftId: giftId,
      callSessionId: widget.sessionId,
    );

    if (!mounted) return;

    if (!res.ok) {
      final error = res.error ?? 'Could not send gift';
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text(
              error.contains('Insufficient')
                  ? 'Not enough coins! This gift costs $coinCost coins.'
                  : error,
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      return;
    }

    // Deduct coins locally for instant UI feedback
    setState(() {
      _coinsRemaining = (_coinsRemaining - coinCost).clamp(
        0,
        9999999,
      );
      // Show gift in chat overlay
      _chatMessages.add(
        _ChatMessage(text: '🎁 Sent $giftName', isLocal: true),
      );
    });

    ref.read(walletBalanceProvider.notifier).refresh();
  }

  // ── Recharge sheet ────────────────────────────────────────────────────────
  void _showRechargeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1233), Color(0xFF1A1A2E)],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.amber.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            // Coin balance display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.12),
                    Colors.amber.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Balance',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _coinsRemaining.toString(),
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Recharge',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _rechargeOption(500, '₹49', false),
            _rechargeOption(1200, '₹99', true),
            _rechargeOption(3000, '₹249', false),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _rechargeOption(
    int coins,
    String price,
    bool isBestValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // TODO: launch Razorpay/Stripe payment flow
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isBestValue
                ? Colors.amber.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBestValue
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$coins Coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isBestValue)
                      const Text(
                        'Best value',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB800),
                      Color(0xFFFF8C00),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _glassChip({required Widget child, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing dots
// ---------------------------------------------------------------------------
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Text(
        'Connecting...',
        style: GoogleFonts.lato(
          color: Colors.white60,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal chat message model
// ---------------------------------------------------------------------------
class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isLocal,
  });
  final String text;
  final bool isLocal;
}

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cheerchat/constants/gift_constants.dart';
import 'package:cheerchat/constants/lottie_constants.dart';
import 'package:cheerchat/services/chat_services.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Gift item metadata
// ─────────────────────────────────────────────────────────────────────────────

class _GiftItem {
  const _GiftItem(this.path, this.name, this.coins);
  final String path;
  final String name;
  final int coins;
}

const List<_GiftItem> _kGifts = [
  _GiftItem(GiftAssets.chocolate, 'Chocolate', 10),
  _GiftItem(GiftAssets.burger, 'Burger', 15),
  _GiftItem(GiftAssets.pizza, 'Pizza', 20),
  _GiftItem(GiftAssets.frock, 'Frock', 30),
  _GiftItem(GiftAssets.handbag, 'Handbag', 50),
  _GiftItem(GiftAssets.sunglasses, 'Sunnies', 40),
  _GiftItem(GiftAssets.kiss, 'Kiss', 25),
  _GiftItem(GiftAssets.lehenga, 'Lehenga', 80),
  _GiftItem(GiftAssets.lipstick, 'Lipstick', 35),
  _GiftItem(GiftAssets.makeupkit, 'Makeup Kit', 60),
  _GiftItem(GiftAssets.necklace, 'Necklace', 100),
  _GiftItem(GiftAssets.scarf, 'Scarf', 30),
  _GiftItem(GiftAssets.sneakers, 'Sneakers', 55),
  _GiftItem(GiftAssets.teddy, 'Teddy', 45),
  _GiftItem(GiftAssets.vodka, 'Vodka', 70),
  _GiftItem(GiftAssets.villa, 'Villa', 500),
  _GiftItem(GiftAssets.tajmahal, 'Taj Mahal', 999),
  _GiftItem(GiftAssets.pool, 'Pool', 800),
  _GiftItem(GiftAssets.porsche, 'Porsche', 750),
  _GiftItem(GiftAssets.jetboat, 'Jet Boat', 600),
];

// ─────────────────────────────────────────────────────────────────────────────
// VERSION B — avatar left, name + detail row (country · age · price)
// ─────────────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String profileImage;
  // Optional host details shown in subtitle row
  final String? countryEmoji; // e.g. "🇮🇳"
  final int? age; // e.g. 24
  final int? priceCoins; // e.g. 50  (coins/min)

  const ChatScreen({
    super.key,
    required this.profileImage,
    required this.otherUserId,
    required this.otherUserName,
    this.countryEmoji,
    this.age,
    this.priceCoins,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _messageSubscription;
  StreamSubscription<DocumentSnapshot>? _roomSubscription;

  bool _isLocked = true;
  bool _hasUnlockedThisSession = false;

  late ChatUser _currentUser;
  late ChatUser _otherUser;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  final FocusNode _inputFocusNode = FocusNode();
  bool _isInputFocused = false;
  bool _keyboardVisible = false;

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ── Sending ───────────────────────────────────────────────────────────────

  void _sendMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty) return;
    if (_isLocked) {
      final currentUserId = _auth.currentUser!.uid;
      final chatRoomId = _chatService.getChatRoomId(
        currentUserId,
        widget.otherUserId,
      );
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatRoomId)
          .update({
            'isUnlocked': true,
            'expiryTime': DateTime.now().add(
              const Duration(days: 7),
            ),
          });
      setState(() {
        _isLocked = false;
        _hasUnlockedThisSession = true;
      });
    }
    await _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text: message.text,
      otherUserName: widget.otherUserName,
      otherUserProfileImage: widget.profileImage,
    );
    _scrollToBottom();
  }

  void _sendGift(String assetPath) {
    _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text: assetPath,
      type: 'gift',
      otherUserName: widget.otherUserName,
      otherUserProfileImage: widget.profileImage,
    );
    _scrollToBottom();
  }

  void _sendLottie(String assetPath) async {
    await _chatService.sendMessage(
      receiverId: widget.otherUserId,
      text: assetPath,
      type: 'lottie',
      otherUserName: widget.otherUserName,
      otherUserProfileImage: widget.profileImage,
    );
    _scrollToBottom();
  }

  void _deleteMessage(ChatMessage message) {
    final messageId = message.customProperties?['messageId'];
    if (messageId == null) return;
    _chatService.deleteMessage(
      otherUserId: widget.otherUserId,
      messageId: messageId,
    );
  }

  bool _canDeleteForEveryone(ChatMessage message) =>
      DateTime.now().difference(message.createdAt).inMinutes < 5;

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showDeleteSheet(ChatMessage message) {
    final isMe = message.user.id == _currentUser.id;
    if (!isMe || !_canDeleteForEveryone(message)) return;
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete message',
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This message will be deleted for everyone.',
          style: GoogleFonts.poppins(
            color: c.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteMessage(message);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Image ─────────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return;
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = _chatService.getChatRoomId(
      currentUserId,
      widget.otherUserId,
    );
    final messageRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .doc();
    await messageRef.set({
      'senderId': currentUserId,
      'receiverId': widget.otherUserId,
      'text': file.path,
      'type': 'image',
      'timestamp': FieldValue.serverTimestamp(),
      'isLocal': true,
    });
    _scrollToBottom();
    try {
      final result = await _chatService.uploadChatImage(
        File(file.path),
      );
      await messageRef.update({
        'text': result['url'],
        'storagePath': result['path'],
        'isLocal': false,
      });
      _scrollToBottom();
    } catch (e) {
      await messageRef.update({'isUploadFailed': true});
    }
  }

  // ── Gift picker ───────────────────────────────────────────────────────────

  void _openGiftPicker() {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    String? selected;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, set) {
          final sel = selected != null
              ? _kGifts.firstWhere((g) => g.path == selected)
              : null;
          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: isDark ? c.card : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    isDark ? 0.4 : 0.10,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '🎁',
                        style: TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Send a Gift',
                        style: GoogleFonts.poppins(
                          color: c.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // Animated cost badge
                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        child: sel != null
                            ? Container(
                                key: ValueKey(sel.coins),
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                decoration: BoxDecoration(
                                  color: c.gold.withOpacity(
                                    0.12,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: c.gold.withOpacity(
                                      0.35,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .monetization_on_rounded,
                                      color: c.gold,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${sel.coins}',
                                      style: GoogleFonts.poppins(
                                        color: c.gold,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: c.divider),
                const SizedBox(height: 8),
                // Gift grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      4,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: _kGifts.length,
                    itemBuilder: (_, i) {
                      final gift = _kGifts[i];
                      final isSel = selected == gift.path;
                      return _GiftCard(
                        gift: gift,
                        isSelected: isSel,
                        isDark: isDark,
                        c: c,
                        onTap: () => set(
                          () => selected = isSel
                              ? null
                              : gift.path,
                        ),
                      );
                    },
                  ),
                ),
                // Send button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                        ),
                    child: selected == null
                        ? SizedBox(
                            key: const ValueKey('empty'),
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: c.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Select a gift',
                                style: GoogleFonts.poppins(
                                  color: c.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            key: const ValueKey('send'),
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    c.pink,
                                    Color.lerp(
                                      c.pink,
                                      const Color(0xFF7B0050),
                                      0.45,
                                    )!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: c.pink.withOpacity(
                                      0.38,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(sheetCtx);
                                  _sendGift(selected!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.transparent,
                                  shadowColor:
                                      Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                          16,
                                        ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '🎁',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Send ${sel!.name}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(0.22),
                                        borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                      ),
                                      child: Text(
                                        '${sel.coins} 🪙',
                                        style:
                                            GoogleFonts.poppins(
                                              color:
                                                  Colors.white,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Lottie picker ─────────────────────────────────────────────────────────

  void _openLottiePicker() {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: isDark ? c.card : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
              itemCount: LottieSmileys.all.length,
              itemBuilder: (context, index) {
                final path = LottieSmileys.all[index];
                return GestureDetector(
                  onTap: () {
                    _sendLottie(path);
                    Navigator.pop(sheetCtx);
                  },
                  child: Lottie.asset(
                    path,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    repeat: false,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final currentUserId = _auth.currentUser!.uid;
    final chatRoomId = _chatService.getChatRoomId(
      currentUserId,
      widget.otherUserId,
    );

    _roomSubscription = FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatRoomId)
        .snapshots()
        .listen((doc) {
          if (!doc.exists) return;
          final data = doc.data() as Map<String, dynamic>;
          final bool isUnlocked = data['isUnlocked'] ?? false;
          final Timestamp? expiryTs = data['expiryTime'];
          bool locked = true;
          if (isUnlocked && expiryTs != null)
            locked = expiryTs.toDate().isBefore(DateTime.now());
          if (mounted) setState(() => _isLocked = locked);
        });

    _inputFocusNode.addListener(() {
      if (mounted)
        setState(
          () => _isInputFocused = _inputFocusNode.hasFocus,
        );
    });

    WidgetsBinding.instance.addObserver(this);
    _chatService.markMessagesAsRead(widget.otherUserId);
    _messageSubscription = _chatService
        .getMessages(widget.otherUserId)
        .listen((event) {
          if (mounted && event.docChanges.isNotEmpty)
            _chatService.markMessagesAsRead(widget.otherUserId);
        });

    _currentUser = ChatUser(id: currentUserId);
    _otherUser = ChatUser(
      id: widget.otherUserId,
      profileImage: widget.profileImage,
    );
    _chatService.initializeChatIfNew(
      widget.otherUserId,
      otherUserName: widget.otherUserName,
      otherUserProfileImage: widget.profileImage,
    );

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final show = _scrollController.offset > 300;
        if (show != _showScrollButton)
          setState(() => _showScrollButton = show);
      }
    });
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _inputFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final view =
        WidgetsBinding.instance.platformDispatcher.views.first;
    final isKeyboardOpen = view.viewInsets.bottom > 0;
    if (isKeyboardOpen && !_keyboardVisible)
      _keyboardVisible = true;
    if (!isKeyboardOpen && _keyboardVisible) {
      _keyboardVisible = false;
      if (_inputFocusNode.hasFocus) _inputFocusNode.unfocus();
    }
  }

  // ── AppBar detail chips ───────────────────────────────────────────────────

  bool get _hasDetails =>
      widget.countryEmoji != null ||
      widget.age != null ||
      widget.priceCoins != null;

  List<Widget> _buildDetailChips(AppColors c) {
    final items = <String>[];
    if (widget.countryEmoji != null)
      items.add(widget.countryEmoji!);

    if (widget.age != null) items.add('${widget.age} yrs');
    // items.add('25 yrs');
    // if (widget.priceCoins != null)
    // items.add('🪙 ${widget.priceCoins}/min');

    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      widgets.add(
        Text(
          items[i],
          style: GoogleFonts.poppins(
            color: c.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
      if (i < items.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '·',
              style: TextStyle(
                color: c.textSecondary.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final senderGrad = LinearGradient(
      colors: [
        c.pink,
        Color.lerp(c.pink, const Color(0xFF6B0040), 0.55)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bg,
        resizeToAvoidBottomInset: true,

        // ════════════════════════════════════════════════════════════════════
        // APP BAR — VERSION B
        // Avatar left-aligned, name + detail row (country · age · price).
        // No status dot/text — online dot is on the avatar only.
        // ════════════════════════════════════════════════════════════════════
        appBar: AppBar(
          backgroundColor: isDark ? c.surface : Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : c.pink.withOpacity(0.12),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: c.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              _AppBarAvatar(
                profileImage: widget.profileImage,
                c: c,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              // Name + detail row in a column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name with ellipsis
                    Text(
                      widget.otherUserName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Detail row — shows any combo of country · age · price
                    if (_hasDetails)
                      Row(children: _buildDetailChips(c)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _CallButton(c: c),
            ),
          ],
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        body: Stack(
          children: [
            Positioned.fill(
              child: _ChatBackground(c: c, isDark: isDark),
            ),
            _buildChatContent(c, isDark, senderGrad),
            if (_showScrollButton)
              Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: c.pink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.pink.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Chat content (stream + DashChat) ─────────────────────────────────────

  Widget _buildChatContent(
    AppColors c,
    bool isDark,
    LinearGradient senderGrad,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.otherUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages',
              style: TextStyle(color: c.textSecondary),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final List<ChatMessage> messages = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final Timestamp? ts = data['timestamp'] as Timestamp?;
          final type = data['type'];
          final bool isDeleted = data['isDeleted'] ?? false;
          final bool isPending = doc.metadata.hasPendingWrites;
          return ChatMessage(
            text: isDeleted
                ? '🚫 Deleted'
                : (type != 'image' ? (data['text'] ?? '') : ''),
            medias: type == 'image'
                ? [
                    ChatMedia(
                      url: data['text'],
                      fileName: 'img_${doc.id}.jpg',
                      type: MediaType.image,
                      customProperties: {
                        'isLocal': data['isLocal'] ?? false,
                        'isUploadFailed':
                            data['isUploadFailed'] ?? false,
                      },
                    ),
                  ]
                : [],
            user: data['senderId'] == _currentUser.id
                ? _currentUser
                : _otherUser,
            createdAt:
                ts?.toDate() ??
                DateTime.fromMillisecondsSinceEpoch(0),
            customProperties: {
              'messageId': doc.id,
              'senderId': data['senderId'],
              'type': type,
              'isDeleted': isDeleted,
              'isPending': isPending,
            },
          );
        }).toList();

        return DashChat(
          currentUser: _currentUser,
          onSend: _sendMessage,
          messages: messages,

          // ── Input bar ────────────────────────────────────────────────────
          inputOptions: InputOptions(
            focusNode: _inputFocusNode,
            alwaysShowSend: true,
            sendOnEnter: true,
            cursorStyle: const CursorStyle(hide: false),
            // Image button: plain icon, no bubble
            leading: _isInputFocused
                ? []
                : [
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.image_outlined,
                        size: 26,
                        color: Color(0xFF4A90E2),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                    ),
                  ],
            inputDecoration: InputDecoration(
              // Emoji button inside field left
              prefixIcon: IconButton(
                onPressed: _openLottiePicker,
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  size: 26,
                  color: Color(0xFFF5A623),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
              ),
              // Gift button inside field right (hidden when typing)
              suffixIcon: _isInputFocused
                  ? null
                  : IconButton(
                      onPressed: _openGiftPicker,
                      icon: Builder(
                        builder: (ctx) {
                          final c2 = AppColors.of(ctx);
                          return Icon(
                            Icons.card_giftcard_outlined,
                            size: 26,
                            color: c2.pink,
                          );
                        },
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                    ),
              hintText: 'Message…',
              hintStyle: GoogleFonts.poppins(
                color: c.textSecondary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.85),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : c.pink.withOpacity(0.15),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: c.pink,
                  width: 1.5,
                ),
              ),
            ),
            sendButtonBuilder: (onSend) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _SendButton(pink: c.pink, onSend: onSend),
            ),
          ),

          scrollToBottomOptions: ScrollToBottomOptions(
            disabled: true,
          ),
          messageListOptions: MessageListOptions(
            scrollController: _scrollController,
          ),

          // ── Bubble options ───────────────────────────────────────────────
          messageOptions: MessageOptions(
            containerColor: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.white,
            textColor: c.textPrimary,
            currentUserContainerColor: c.pink,
            currentUserTextColor: Colors.white,
            borderRadius: 20,
            showCurrentUserAvatar: false,
            showOtherUsersAvatar: true,
            showTime: false,
            onLongPressMessage: (msg) {
              if (msg.customProperties?['type'] == 'gift')
                return;
              _showDeleteSheet(msg);
            },
            // Zero global padding — lottie/gift need zero, text adds its own
            messagePadding: EdgeInsets.zero,

            // ── Bubble shape & colour ──────────────────────────────────────
            messageDecorationBuilder: (message, prev, next) {
              final type = message.customProperties?['type'];
              final isMe = message.user.id == _currentUser.id;
              if (type == 'lottie' || type == 'gift') {
                return const BoxDecoration(
                  color: Colors.transparent,
                );
              }
              return BoxDecoration(
                gradient: isMe ? senderGrad : null,
                color: isMe
                    ? null
                    : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.09)
                            : c.pink.withOpacity(0.12),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? c.pink.withOpacity(
                            isDark ? 0.22 : 0.20,
                          )
                        : Colors.black.withOpacity(
                            isDark ? 0.18 : 0.06,
                          ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              );
            },

            // ── Message content ────────────────────────────────────────────
            messageTextBuilder: (message, prev, next) {
              final bool isMe =
                  message.user.id == _currentUser.id;
              final bool isDeleted =
                  message.customProperties?['isDeleted'] ??
                  false;
              final type = message.customProperties?['type'];
              final bool isPending =
                  message.customProperties?['isPending'] ??
                  false;
              final timeStr = TimeOfDay.fromDateTime(
                message.createdAt,
              ).format(context);

              // Lottie emoji — sized tightly to the animation, no extra space
              if (type == 'lottie') {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Lottie.asset(
                      message.text,
                      width: 80,
                      height: 80,
                      repeat: true,
                      frameRate: FrameRate.max,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 2,
                        left: 4,
                        right: 4,
                        bottom: 4,
                      ),
                      child: _TimeRow(
                        time: timeStr,
                        isMe: isMe,
                        isPending: isPending,
                        c: c,
                      ),
                    ),
                  ],
                );
              }

              // Gift bubble — hugs sender edge, no outer padding
              if (type == 'gift') {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110,
                          decoration: BoxDecoration(
                            color: isDark
                                ? c.surface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(
                              18,
                            ),
                            border: Border.all(
                              color: c.pink.withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.pink.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      c.pink,
                                      Color.lerp(
                                        c.pink,
                                        const Color(0xFF7B0050),
                                        0.45,
                                      )!,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius:
                                      const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                ),
                                child: Center(
                                  child: Text(
                                    '🎁 Gift',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  10,
                                ),
                                child: Image.asset(
                                  message.text,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: _TimeRow(
                            time: timeStr,
                            isMe: isMe,
                            isPending: isPending,
                            c: c,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              // Deleted
              if (isDeleted) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        size: 13,
                        color: isMe
                            ? Colors.white54
                            : c.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'This message was deleted',
                        style: GoogleFonts.poppins(
                          fontStyle: FontStyle.italic,
                          color: isMe
                              ? Colors.white54
                              : c.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Normal text
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: GoogleFonts.poppins(
                        color: isMe
                            ? Colors.white
                            : c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _TimeRow(
                      time: timeStr,
                      isMe: isMe,
                      isPending: isPending,
                      c: c,
                    ),
                  ],
                ),
              );
            },

            // ── Image media ────────────────────────────────────────────────
            messageMediaBuilder: (message, previous, next) {
              if (message.medias == null ||
                  message.medias!.isEmpty)
                return const SizedBox();
              final media = message.medias!.first;
              if (media.type != MediaType.image)
                return const SizedBox();
              final bool isMe =
                  message.user.id == _currentUser.id;
              final bool isLocal =
                  media.customProperties?['isLocal'] ?? false;
              final bool isUploadFailed =
                  media.customProperties?['isUploadFailed'] ??
                  false;

              return Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: isMe
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: isLocal
                          ? null
                          : () =>
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FullScreenImageView(
                                          imageUrl: media.url,
                                        ),
                                  ),
                                ),
                      child: isLocal
                          ? Image.file(
                              File(media.url),
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: media.url,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 220,
                                height: 220,
                                color: isDark
                                    ? Colors.white.withOpacity(
                                        0.05,
                                      )
                                    : c.card,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(
                                        color: c.pink,
                                        strokeWidth: 2,
                                      ),
                                ),
                              ),
                              errorWidget: (_, __, ___) =>
                                  SizedBox(
                                    width: 220,
                                    height: 220,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: c.textSecondary,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isLocal)
                    Text(
                      'Uploading…',
                      style: TextStyle(
                        fontSize: 10,
                        color: c.textSecondary,
                      ),
                    ),
                  if (isUploadFailed)
                    const Text(
                      'Upload failed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.redAccent,
                      ),
                    ),
                  if (!isLocal && !isUploadFailed)
                    Text(
                      TimeOfDay.fromDateTime(
                        message.createdAt,
                      ).format(context),
                      style: TextStyle(
                        fontSize: 10,
                        color: c.textSecondary,
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar avatar (glow ring + online dot)
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarAvatar extends StatelessWidget {
  const _AppBarAvatar({
    required this.profileImage,
    required this.c,
    required this.isDark,
  });
  final String profileImage;
  final AppColors c;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow ring
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                c.pink.withOpacity(0.8),
                c.pink.withOpacity(0.2),
                c.pink.withOpacity(0.8),
              ],
            ),
          ),
        ),
        // Gap
        Positioned(
          top: 2,
          left: 2,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? c.surface : Colors.white,
            ),
          ),
        ),
        // Photo
        Positioned(
          top: 3,
          left: 3,
          child: ClipOval(
            child: SizedBox(
              width: 34,
              height: 34,
              child: profileImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profileImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: c.card),
                      errorWidget: (_, __, ___) =>
                          _AvatarFallback(c: c),
                    )
                  : _AvatarFallback(c: c),
            ),
          ),
        ),
        // Online dot
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: c.green,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? c.surface : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video call button
// ─────────────────────────────────────────────────────────────────────────────

class _CallButton extends StatelessWidget {
  const _CallButton({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: push call screen
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              c.pink,
              Color.lerp(c.pink, const Color(0xFF7B0050), 0.45)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.pink.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.videocam_rounded,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Atmospheric background
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Chat screen background — "Constellation" design.
// Distinct from login (which uses two large pink blobs).
// Uses: purple accent blob + ring outlines + micro-dot clusters.
// ALL positions use top:/left:/right: — never bottom: — so the keyboard
// opening never shifts decorative elements.
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBackground extends StatelessWidget {
  const _ChatBackground({required this.c, required this.isDark});
  final AppColors c;
  final bool isDark;

  // Accent colour unique to chat — soft violet/purple.
  static const Color _violet = Color(0xFF7B61FF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Helper to build a circle ring (outline, no fill).
    Widget _ring(double d, Color col, double strokeW) =>
        Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: col, width: strokeW),
          ),
        );

    // Helper to build a filled dot.
    Widget _dot(double d, Color col) => Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: col,
      ),
    );

    return Container(
      color: c.bg,
      child: Stack(
        children: [
          // ── Soft blobs (top: anchored — keyboard-safe) ────────────────────

          // Top-right pink blob — smaller than login's to feel different.
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.pink.withOpacity(isDark ? 0.07 : 0.09),
              ),
            ),
          ),

          // Center-left violet blob — the key differentiator vs login.
          Positioned(
            top: size.height * 0.36,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _violet.withOpacity(
                  isDark ? 0.05 : 0.065,
                ),
              ),
            ),
          ),

          // ── Ring accents ──────────────────────────────────────────────────

          // Large ring — top area, right side.
          Positioned(
            top: size.height * 0.18,
            right: size.width * 0.06,
            child: _ring(
              72,
              c.pink.withOpacity(isDark ? 0.11 : 0.13),
              1.5,
            ),
          ),

          // Medium ring — lower, left side.
          Positioned(
            top: size.height * 0.70,
            left: size.width * 0.55,
            child: _ring(
              44,
              _violet.withOpacity(isDark ? 0.13 : 0.15),
              1.0,
            ),
          ),

          // Small ring — upper-left.
          Positioned(
            top: size.height * 0.09,
            left: size.width * 0.06,
            child: _ring(
              28,
              _violet.withOpacity(isDark ? 0.10 : 0.12),
              1.0,
            ),
          ),

          // ── Micro dot clusters ────────────────────────────────────────────

          // Cluster A — right side, upper-middle.
          Positioned(
            top: size.height * 0.28,
            right: size.width * 0.10,
            child: _dot(
              7,
              c.pink.withOpacity(isDark ? 0.20 : 0.24),
            ),
          ),
          Positioned(
            top: size.height * 0.28 + 14,
            right: size.width * 0.10 - 14,
            child: _dot(
              4,
              _violet.withOpacity(isDark ? 0.18 : 0.21),
            ),
          ),
          Positioned(
            top: size.height * 0.28 + 6,
            right: size.width * 0.10 + 16,
            child: _dot(
              3,
              c.pink.withOpacity(isDark ? 0.14 : 0.16),
            ),
          ),

          // Cluster B — left side, below center blob.
          Positioned(
            top: size.height * 0.58,
            left: size.width * 0.14,
            child: _dot(
              5,
              _violet.withOpacity(isDark ? 0.18 : 0.22),
            ),
          ),
          Positioned(
            top: size.height * 0.58 + 12,
            left: size.width * 0.14 + 12,
            child: _dot(
              3,
              c.pink.withOpacity(isDark ? 0.16 : 0.19),
            ),
          ),

          // Cluster C — top, between rings.
          Positioned(
            top: size.height * 0.13,
            left: size.width * 0.42,
            child: _dot(
              4,
              c.pink.withOpacity(isDark ? 0.16 : 0.19),
            ),
          ),
          Positioned(
            top: size.height * 0.13 + 10,
            left: size.width * 0.42 + 10,
            child: _dot(
              6,
              _violet.withOpacity(isDark ? 0.13 : 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gift card (grid item in picker)
// ─────────────────────────────────────────────────────────────────────────────

class _GiftCard extends StatefulWidget {
  const _GiftCard({
    required this.gift,
    required this.isSelected,
    required this.isDark,
    required this.c,
    required this.onTap,
  });
  final _GiftItem gift;
  final bool isSelected;
  final bool isDark;
  final AppColors c;
  final VoidCallback onTap;

  @override
  State<_GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<_GiftCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? c.pink.withOpacity(widget.isDark ? 0.18 : 0.10)
                : (widget.isDark ? c.surface : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected ? c.pink : c.border,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: c.pink.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  widget.gift.path,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.gift.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: c.textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: c.gold,
                    size: 9,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.gift.coins}',
                    style: GoogleFonts.poppins(
                      color: c.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.time,
    required this.isMe,
    required this.isPending,
    required this.c,
  });
  final String time;
  final bool isMe;
  final bool isPending;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: isMe ? Colors.white54 : c.textSecondary,
            fontSize: 10,
          ),
        ),
        if (isMe && isPending) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.access_time,
            size: 11,
            color: isMe ? Colors.white54 : c.textSecondary,
          ),
        ],
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) => Container(
    color: c.avatarFallback,
    child: Icon(Icons.person, color: c.avatarIcon, size: 18),
  );
}

class _SendButton extends StatefulWidget {
  const _SendButton({required this.pink, required this.onSend});
  final Color pink;
  final VoidCallback onSend;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onSend();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.pink,
                Color.lerp(
                  widget.pink,
                  const Color(0xFF7B0050),
                  0.50,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.pink.withOpacity(0.45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen image viewer
// ─────────────────────────────────────────────────────────────────────────────

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  State<FullScreenImageView> createState() =>
      _FullScreenImageViewState();
}

class _FullScreenImageViewState
    extends State<FullScreenImageView> {
  double _dragOffset = 0;
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (d) => setState(() {
        _dragOffset += d.delta.dy;
        _opacity = (1 - (_dragOffset.abs() / 300)).clamp(
          0.5,
          1.0,
        );
      }),
      onVerticalDragEnd: (d) {
        if (_dragOffset > 120) {
          Navigator.pop(context);
        } else {
          setState(() {
            _dragOffset = 0;
            _opacity = 1.0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(_opacity),
        body: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) =>
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CallLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Call this right before or after widget.agoraService.join()
  Future<void> createInitialCallLog({
    required String channelId, // Used as the Document ID
    required String conversationId,
    required String callerId,
    required String receiverId,
    required Map<String, dynamic> participantsMap,
    String callType = 'video',
  }) async {
    final callLogRef = _db
        .collection('call_logs')
        .doc(channelId);

    // We check if it exists first, because both the caller and receiver
    // might trigger this when they join the screen. We only want to create it once.
    final snapshot = await callLogRef.get();

    if (!snapshot.exists) {
      await callLogRef.set({
        'callId': channelId,
        'conversationId': conversationId,
        'callerId': callerId,
        'receiverId': receiverId,
        'status': 'ongoing',
        'callType': callType,
        'startedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'durationInSeconds': 0,
        'totalCoinsSpent': 0,
        'participantIds': [callerId, receiverId],
        'participants': participantsMap,
      });
      debugPrint("📞 Call log created successfully!");
    }
  }

  // 2. Call this inside your _endCall() method
  Future<void> endCallLog({
    required String channelId,
    required int durationInSeconds,
    required int totalCoinsSpent,
  }) async {
    final callLogRef = _db
        .collection('call_logs')
        .doc(channelId);

    try {
      await callLogRef.update({
        'status': 'completed',
        'endedAt': FieldValue.serverTimestamp(),
        'durationInSeconds': durationInSeconds,
        'totalCoinsSpent': totalCoinsSpent,
      });
      debugPrint("📞 Call log completed & saved!");
    } catch (e) {
      debugPrint("Failed to end call log: $e");
    }
  }
}

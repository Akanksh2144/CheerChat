import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheerchat/services/agora_service.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  final service = AgoraService();
  ref.onDispose(() {
    service.leave();
  });
  return service;
});

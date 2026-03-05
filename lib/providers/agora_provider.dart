import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:judotalk/services/agora_services.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  final service = AgoraService();
  ref.onDispose(() {
    service.leave();
  });
  return service;
});

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cheerchat/services/agora_service.dart';

// final agoraServiceProvider = Provider<AgoraService>((ref) {
//   final service = AgoraService();
//   ref.onDispose(() {
//     service.leave();
//   });
//   return service;
// });
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheerchat/services/agora_service.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  final service = AgoraService();
  ref.onDispose(() {
    // dispose() releases the engine and resets all state.
    // leave() only drops the channel — engine would stay allocated.
    service.dispose();
  });
  return service;
});

// // // lib/services/call_api_service.dart
// // //
// // // Server-side call management: start, end, random match, Agora token.
// // // Works alongside the existing AgoraService for the actual video stream.

// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // import 'package:cheerchat/services/api_service.dart';

// // final callApiServiceProvider = Provider((ref) => CallApiService(ref));

// // class CallApiService {
// //   final Ref _ref;
// //   ApiService get _api => _ref.read(apiServiceProvider);

// //   CallApiService(this._ref);

// //   /// Start a call. Returns session details including Agora tokens.
// //   /// Response: { session_id, channel_name, price_per_minute,
// //   ///             caller_token, host_token, caller_uid, host_uid }
// //   Future<ApiResponse> startCall({
// //     required String hostId,
// //     String callType = 'normal',
// //   }) async {
// //     return _api.post('/api/calls/start', body: {
// //       'host_id': hostId,
// //       'call_type': callType,
// //     });
// //   }

// //   /// End an active call.
// //   Future<ApiResponse> endCall({
// //     required String sessionId,
// //     String endedBy = 'caller',
// //   }) async {
// //     return _api.post('/api/calls/$sessionId/end', body: {
// //       'ended_by': endedBy,
// //     });
// //   }

// //   /// Get an Agora RTC token (used if token expires mid-call).
// //   Future<String?> getAgoraToken(String channelName, {int uid = 0}) async {
// //     final res = await _api.post('/api/calls/token', body: {
// //       'channel_name': channelName,
// //       'uid': uid,
// //     });
// //     return res.ok ? res.data['token'] as String? : null;
// //   }

// //   /// Find a random available host.
// //   /// Response: { matched_host_id, price_coins } or error.
// //   Future<ApiResponse> findRandomHost({
// //     String? country,
// //     String? language,
// //     String? gender,
// //   }) async {
// //     return _api.post('/api/calls/random', body: {
// //       if (country != null) 'country': country,
// //       if (language != null) 'language': language,
// //       if (gender != null) 'gender': gender,
// //     });
// //   }

// //   /// Join the call queue for a busy host.
// //   Future<ApiResponse> joinQueue(String hostId) async {
// //     return _api.post('/api/calls/queue', body: {
// //       'host_id': hostId,
// //     });
// //   }
// // }
// // lib/services/call_api_service.dart
// //
// // Server-side call management: start, end, random match, Agora token.
// // Works alongside the existing AgoraService for the actual video stream.

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:cheerchat/services/api_service.dart';

// final callApiServiceProvider = Provider(
//   (ref) => CallApiService(ref),
// );

// class CallApiService {
//   final Ref _ref;
//   ApiService get _api => _ref.read(apiServiceProvider);

//   CallApiService(this._ref);

//   /// Start a call. Returns session details including Agora tokens.
//   /// Response: { session_id, channel_name, price_per_minute,
//   ///             caller_token, host_token, caller_uid, host_uid }
//   Future<ApiResponse> startCall({
//     required String hostId,
//     String callType = 'normal',
//   }) async {
//     return _api.post(
//       '/api/calls/start',
//       body: {'host_id': hostId, 'call_type': callType},
//     );
//   }

//   /// End an active call.
//   Future<ApiResponse> endCall({
//     required String sessionId,
//     String endedBy = 'caller',
//   }) async {
//     return _api.post(
//       '/api/calls/$sessionId/end',
//       body: {'ended_by': endedBy},
//     );
//   }

//   /// Get an Agora RTC token (used if token expires mid-call).
//   Future<String?> getAgoraToken(
//     String channelName, {
//     int uid = 0,
//   }) async {
//     final res = await _api.post(
//       '/api/calls/token',
//       body: {'channel_name': channelName, 'uid': uid},
//     );
//     return res.ok ? res.data['token'] as String? : null;
//   }

//   /// Find a random available host.
//   /// Response: { matched_host_id, price_coins } or error.
//   Future<ApiResponse> findRandomHost({
//     String? country,
//     String? language,
//     String? gender,
//   }) async {
//     return _api.post(
//       '/api/calls/random',
//       body: {
//         if (country != null) 'country': country,
//         if (language != null) 'language': language,
//         if (gender != null) 'gender': gender,
//       },
//     );
//   }

//   /// Join the call queue for a busy host.
//   Future<ApiResponse> joinQueue(String hostId) async {
//     return _api.post(
//       '/api/calls/queue',
//       body: {'host_id': hostId},
//     );
//   }

//   /// Check session status (used to detect if host declined).
//   /// Returns 'ongoing', 'ended', or null on error.
//   Future<String?> getSessionStatus(String sessionId) async {
//     final res = await _api.get('/api/calls/$sessionId/status');
//     return res.ok ? res.data['status'] as String? : null;
//   }
// }
// lib/services/call_api_service.dart
//
// Server-side call management: start, end, random match, Agora token.
// Works alongside the existing AgoraService for the actual video stream.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final callApiServiceProvider = Provider(
  (ref) => CallApiService(ref),
);

class CallApiService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  CallApiService(this._ref);

  /// Start a call. Returns session details including Agora tokens.
  /// Response: { session_id, channel_name, price_per_minute,
  ///             caller_token, host_token, caller_uid, host_uid }
  Future<ApiResponse> startCall({
    required String hostId,
    String callType = 'normal',
  }) async {
    return _api.post(
      '/api/calls/start',
      body: {'host_id': hostId, 'call_type': callType},
    );
  }

  /// End an active call.
  Future<ApiResponse> endCall({
    required String sessionId,
    String endedBy = 'caller',
  }) async {
    return _api.post(
      '/api/calls/$sessionId/end',
      body: {'ended_by': endedBy},
    );
  }

  /// Get an Agora RTC token (used if token expires mid-call).
  Future<String?> getAgoraToken(
    String channelName, {
    int uid = 0,
  }) async {
    final res = await _api.post(
      '/api/calls/token',
      body: {'channel_name': channelName, 'uid': uid},
    );
    return res.ok ? res.data['token'] as String? : null;
  }

  /// Find a random available host.
  /// Response: { matched_host_id, price_coins } or error.
  Future<ApiResponse> findRandomHost({
    String? country,
    String? language,
    String? gender,
  }) async {
    return _api.post(
      '/api/calls/random',
      body: {
        if (country != null) 'country': country,
        if (language != null) 'language': language,
        if (gender != null) 'gender': gender,
      },
    );
  }

  /// Join the call queue for a busy host.
  Future<ApiResponse> joinQueue(String hostId) async {
    return _api.post(
      '/api/calls/queue',
      body: {'host_id': hostId},
    );
  }

  /// Check session status (used to detect if host declined).
  /// Returns 'ongoing', 'ended', or null on error.
  Future<String?> getSessionStatus(String sessionId) async {
    final res = await _api.get('/api/calls/$sessionId/status');
    return res.ok ? res.data['status'] as String? : null;
  }
}

// lib/services/host_application_service.dart
//
// Apply to become a host, submit KYC video, check status.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final hostApplicationServiceProvider =
    Provider((ref) => HostApplicationService(ref));

class HostApplicationService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  HostApplicationService(this._ref);

  /// Apply to become a host.
  Future<ApiResponse> apply({
    required String displayName,
    String? bio,
    String? profilePhotoUrl,
    String? country,
    String? language,
  }) async {
    return _api.post('/api/host-application', body: {
      'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (country != null) 'country': country,
      if (language != null) 'language': language,
    });
  }

  /// Submit KYC selfie video for verification.
  Future<ApiResponse> submitVerification({
    required String videoUrl,
    required String randomCode,
  }) async {
    return _api.post('/api/host-application/verify', body: {
      'video_url': videoUrl,
      'random_code': randomCode,
    });
  }

  /// Check application status.
  /// Returns { approval_status, verification_status, admin_notes, applied_at }.
  Future<Map<String, dynamic>?> getStatus() async {
    final res = await _api.get('/api/host-application/status');
    return res.ok ? res.data : null;
  }
}

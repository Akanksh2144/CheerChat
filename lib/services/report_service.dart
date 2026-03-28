// lib/services/report_service.dart
//
// Submit user reports with optional attachments.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final reportServiceProvider = Provider((ref) => ReportService(ref));

class ReportService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  ReportService(this._ref);

  /// Submit a report against another user.
  Future<ApiResponse> submit({
    required String reportedUserId,
    required String reason,
    String? description,
    String? callSessionId,
    List<Map<String, String>>? attachments,
  }) async {
    return _api.post('/api/reports', body: {
      'reported_user_id': reportedUserId,
      'reason': reason,
      if (description != null) 'description': description,
      if (callSessionId != null) 'call_session_id': callSessionId,
      if (attachments != null) 'attachments': attachments,
    });
  }
}

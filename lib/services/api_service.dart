// lib/services/api_service.dart
//
// Centralized HTTP client for the CheerChat Node.js backend.
// All API calls go through this class so auth headers, error handling,
// and retry logic are in one place.
//
// Usage:
//   final api = ref.read(apiServiceProvider);
//   final hosts = await api.get('/api/hosts?online_only=true');

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:cheerchat/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────

final apiServiceProvider = Provider((ref) => ApiService());

// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  static const _baseUrl = AppConstants.apiBaseUrl;
  static const _timeout = Duration(seconds: 10);

  // ── Auth header ──────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Core HTTP methods ────────────────────────────────────────────────────

  Future<ApiResponse> get(String path, {Map<String, String>? query}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(res);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(res);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .put(
            Uri.parse('$_baseUrl$path'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(res);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$_baseUrl$path'), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(res);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ── Response handling ────────────────────────────────────────────────────

  ApiResponse _handleResponse(http.Response res) {
    final body = res.body.isNotEmpty
        ? jsonDecode(res.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResponse.success(body, res.statusCode);
    }

    final error = body['error'] as String? ?? 'Request failed';
    debugPrint('[API] ${res.statusCode}: $error');
    return ApiResponse.failure(error, res.statusCode);
  }

  ApiResponse _handleError(Object e) {
    if (e is SocketException) {
      debugPrint('[API] Network error: ${e.message}');
      return ApiResponse.failure('No internet connection', 0);
    }
    if (e is HttpException) {
      debugPrint('[API] HTTP error: ${e.message}');
      return ApiResponse.failure('Server error', 0);
    }
    debugPrint('[API] Error: $e');
    return ApiResponse.failure('Connection failed', 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response wrapper
// ─────────────────────────────────────────────────────────────────────────────

class ApiResponse {
  final bool ok;
  final int statusCode;
  final Map<String, dynamic> data;
  final String? error;

  const ApiResponse._({
    required this.ok,
    required this.statusCode,
    required this.data,
    this.error,
  });

  factory ApiResponse.success(Map<String, dynamic> data, int statusCode) {
    return ApiResponse._(ok: true, statusCode: statusCode, data: data);
  }

  factory ApiResponse.failure(String error, int statusCode) {
    return ApiResponse._(
      ok: false,
      statusCode: statusCode,
      data: const {},
      error: error,
    );
  }

  /// Convenience: treat response data as a list from a specific key.
  List<Map<String, dynamic>> list(String key) {
    final raw = data[key];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

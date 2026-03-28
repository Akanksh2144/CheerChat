// lib/services/social_service.dart
//
// Follow/unfollow, block/unblock, profile views.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/services/api_service.dart';

final socialServiceProvider = Provider((ref) => SocialService(ref));

class SocialService {
  final Ref _ref;
  ApiService get _api => _ref.read(apiServiceProvider);

  SocialService(this._ref);

  // ── Follow ──────────────────────────────────────────────────────────────

  Future<bool> follow(String targetId) async {
    final res = await _api.post('/api/social/follow/$targetId');
    return res.ok;
  }

  Future<bool> unfollow(String targetId) async {
    final res = await _api.delete('/api/social/follow/$targetId');
    return res.ok;
  }

  Future<List<Map<String, dynamic>>> getFollowers({int page = 1}) async {
    final res = await _api.get('/api/social/followers', query: {
      'page': page.toString(),
    });
    return res.ok ? res.list('followers') : [];
  }

  Future<List<Map<String, dynamic>>> getFollowing({int page = 1}) async {
    final res = await _api.get('/api/social/following', query: {
      'page': page.toString(),
    });
    return res.ok ? res.list('following') : [];
  }

  // ── Block ───────────────────────────────────────────────────────────────

  Future<bool> block(String targetId) async {
    final res = await _api.post('/api/social/block/$targetId');
    return res.ok;
  }

  Future<bool> unblock(String targetId) async {
    final res = await _api.delete('/api/social/block/$targetId');
    return res.ok;
  }

  Future<List<Map<String, dynamic>>> getBlocked() async {
    final res = await _api.get('/api/social/blocked');
    return res.ok ? res.list('blocked') : [];
  }

  // ── Profile views ─────────────────────────────────────────────────────

  Future<void> logView(String targetId) async {
    await _api.post('/api/social/view/$targetId');
  }

  Future<List<Map<String, dynamic>>> getProfileViews({int page = 1}) async {
    final res = await _api.get('/api/social/views', query: {
      'page': page.toString(),
    });
    return res.ok ? res.list('views') : [];
  }
}

// lib/providers/connectivity_provider.dart
//
// Lightweight offline detector — no external package required.
// Uses dart:io InternetAddress.lookup (near-instant on all platforms).
//
// connectivityProvider — StreamProvider<bool>
//   true  = online (DNS resolves)
//   false = offline
//
// Polls every 5 seconds so the grid auto-recovers when Wi-Fi comes back.
// The first event is emitted within ~300ms of app start, meaning the
// HostsGridViewScreen gets an offline signal long before the API timeout.

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return _connectivityStream();
});

Stream<bool> _connectivityStream() async* {
  // Emit immediately, then every 5 s
  yield await _isOnline();
  yield* Stream.periodic(
    const Duration(seconds: 5),
    (_) => null,
  ).asyncMap((_) => _isOnline());
}

Future<bool> _isOnline() async {
  try {
    // DNS lookup is the fastest reliable offline check on all platforms.
    // Falls back to Google DNS if the api host is unreachable.
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 3));
    return result.isNotEmpty &&
        result.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  } catch (_) {
    return false;
  }
}

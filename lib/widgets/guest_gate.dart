// lib/widgets/guest_gate.dart
//
// GuestGate — reserved for a future "Browse as Guest" feature (Phase 2+).
//
// Currently a no-op stub. Anonymous sign-in has been removed from this phase.
// When guest/anonymous support is re-introduced, restore the full implementation
// from git history and re-enable the anonymous sign-in flow in auth_service.dart.

// ignore_for_file: unused_element

import 'package:flutter/material.dart';

enum GuestGateReason { chat, call, gift, emoji }

class GuestGate {
  GuestGate._();

  /// Always returns false — guest mode is not active in this phase.
  static bool isGuest() => false;

  /// Always returns false — GuestGate is disabled.
  /// Kept for call-site compatibility.
  static bool show(
    BuildContext context, {
    GuestGateReason reason = GuestGateReason.chat,
  }) {
    return false;
  }
}

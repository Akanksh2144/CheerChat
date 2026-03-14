// lib/utils/app_transitions.dart
//
// Centralised page-transition factory.
// All Navigator.of(...).push() calls across the app use one of these routes
// so animation timings and curves are consistent.
//
// Usage:
//   Navigator.of(context, rootNavigator: true)
//       .push(AppTransitions.slide(const ChatScreen(...)));

import 'package:flutter/material.dart';

abstract final class AppTransitions {
  // ── Horizontal slide + soft fade ─────────────────────────────────────────
  // Use for: detail screens, chat screen (feels like going "deeper").
  static Route<T> slide<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(
        milliseconds: 280,
      ),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final push = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        // Current screen slides left as new screen slides in from right
        return Stack(
          children: [
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(-0.25, 0),
                  ).animate(
                    CurvedAnimation(
                      parent: secondaryAnimation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(
                    alpha: 0.15 * secondaryAnimation.value,
                  ),
                  BlendMode.srcOver,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0),
                end: Offset.zero,
              ).animate(push),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.6,
                  end: 1.0,
                ).animate(push),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Slide up from bottom ──────────────────────────────────────────────────
  // Use for: filters screen, secondary overlays that feel modal.
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(
        milliseconds: 300,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  // ── Fade (opaque or transparent overlay) ─────────────────────────────────
  // Use for: fullscreen photo viewer, any overlay screen.
  static Route<T> fade<T>(
    Widget page, {
    bool opaque = true,
    Color barrierColor = Colors.black,
  }) {
    return PageRouteBuilder<T>(
      opaque: opaque,
      barrierColor: opaque ? null : barrierColor,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(
        milliseconds: 240,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

  // ── Hero + fade (route fades; Hero widget handles the image morph) ────────
  // Use for: host card → ProfileDetailsScreen.
  // The Hero widget in host_card (source) and profile_details (destination)
  // handle the image animation; this route fades everything else.
  static Route<T> heroFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(
        milliseconds: 360,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: child,
        );
      },
    );
  }

  // ── Scale + fade (dramatic zoom) ─────────────────────────────────────────
  // Use for: OngoingCallScreen — should feel like entering a different world.
  static Route<T> scaleUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 480),
      reverseTransitionDuration: const Duration(
        milliseconds: 380,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.86,
            end: 1.0,
          ).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(
                  0.0,
                  0.65,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

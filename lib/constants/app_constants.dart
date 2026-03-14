// lib/constants/app_constants.dart
//
// Central place for all app-level configuration constants.
// Replace placeholder values before release.

class AppConstants {
  AppConstants._();

  // ── Agora ────────────────────────────────────────────────────────────────
  // Get your App ID from https://console.agora.io
  // TODO: Move to --dart-define or flutter_dotenv before production
  static const String agoraAppId = '9d5a986de25b4f2b941d5e0514f81ba7';

  // ── Call billing ─────────────────────────────────────────────────────────
  // How many seconds of grace period before billing starts
  // (matches the server-side buffer in Node.js)
  static const int callBillingGraceSeconds = 6;

  // Warn the user when their balance drops below this many minutes of call time
  static const int lowCoinWarningMinutes = 2;

  // ── API ───────────────────────────────────────────────────────────────────
  // TODO: Replace with your DigitalOcean App Platform URL
  // static const String apiBaseUrl =
  //     'https://your-api.digitalocean.app';
  // static const String apiBaseUrl =
  //   'http://10.0.2.2:3000';
  static const String apiBaseUrl =
    'http://192.168.1.11:3000';
}

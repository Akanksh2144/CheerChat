// lib/screens/login_page.dart
//
// Login / sign-up entry point.
// Three internal "pages" managed by a PageController:
//   0 → Landing    (choose auth method)
//   1 → Phone      (enter number + country code)
//   2 → OTP        (verify 6-digit code)
//
// Auth routing (handled by AuthGate, not here):
//   • New user  → Firebase sign-in succeeds → GET /api/me returns 404
//                 → AuthGate routes to ProfileSetupScreen
//   • Returning → Firebase sign-in succeeds → GET /api/me returns 200
//                 → AuthGate routes to App
//   • Guest     → signInAnonymously → AuthGate routes to App (browse only)
//
// Facebook: button is visible but shows "coming soon" snackbar.
//   Wire up flutter_facebook_auth when ready.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cheerchat/services/auth_service.dart';
import 'package:cheerchat/theme/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();

  // Phone flow
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String _countryCode = '+91';
  String? _verificationId;
  bool _loading = false;
  String? _error;

  // Entry animation
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim =
        Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _fadeCtrl,
            curve: Curves.easeOut,
          ),
        );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goTo(int page) {
    setState(() => _error = null);
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _setError(String? msg) => setState(() => _error = msg);
  void _setLoading(bool v) => setState(() => _loading = v);

  // ── Phone: step 1 — send OTP ───────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _setError('Enter your phone number');
      return;
    }
    _setError(null);
    _setLoading(true);

    await ref
        .read(authServiceProvider)
        .verifyPhone(
          phoneNumber: '$_countryCode$phone',
          onCodeSent: (verificationId) {
            _verificationId = verificationId;
            _setLoading(false);
            _goTo(2);
            Future.delayed(
              const Duration(milliseconds: 400),
              () => _otpFocus.requestFocus(),
            );
          },
          onError: (msg) {
            _setLoading(false);
            _setError(msg);
          },
          onAutoVerified: (_) {
            // Android SMS auto-read — AuthGate handles navigation
            _setLoading(false);
          },
        );
  }

  // ── Phone: step 2 — verify OTP ────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 6) {
      _setError('Enter the 6-digit code');
      return;
    }
    if (_verificationId == null) {
      _setError('Session expired. Go back and try again.');
      return;
    }
    _setError(null);
    _setLoading(true);

    try {
      await ref
          .read(authServiceProvider)
          .signInWithOtp(
            verificationId: _verificationId!,
            smsCode: code,
          );
      // Success — AuthGate watches authStateProvider and auto-navigates.
      // New user  → 404 from /api/me → AuthGate → ProfileSetupScreen
      // Returning → 200 from /api/me → AuthGate → App
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      switch (e.code) {
        case 'invalid-verification-code':
          _setError('Incorrect code. Please try again.');
          break;
        case 'session-expired':
          _setError(
            'Code expired. Tap Resend to get a new one.',
          );
          break;
        default:
          _setError(e.message ?? 'Verification failed.');
      }
    } catch (_) {
      _setLoading(false);
      _setError('Something went wrong. Please try again.');
    }
  }

  // ── Google ─────────────────────────────────────────────────────────────────

  Future<void> _googleSignIn() async {
    _setError(null);
    _setLoading(true);
    try {
      final result = await ref
          .read(authServiceProvider)
          .signInWithGoogle();
      // null = user cancelled the picker — clear loading, no error shown
      if (result == null) _setLoading(false);
      // On success, AuthGate reacts to authStateProvider automatically
    } catch (e) {
      _setLoading(false);
      // Surface the RAW error so we can diagnose it
      final raw = e.toString();
      debugPrint('[LoginPage] Google sign-in error: $raw');

      final lower = raw.toLowerCase();

      // User cancelled — silent
      if (lower.contains('canceled') ||
          lower.contains('cancelled') ||
          lower.contains('sign_in_canceled') ||
          lower.contains('sign_in_failed') &&
              lower.contains('12501')) {
        return;
      }

      // ApiException 10 = SHA-1 not registered in Firebase Console
      if (lower.contains('apiexception: 10') ||
          lower.contains('sign_in_failed') ||
          lower.contains('developer_error')) {
        _setError(
          'Google sign-in setup incomplete.\n'
          'SHA-1 fingerprint missing in Firebase Console.\n'
          'Run: cd android && ./gradlew signingReport',
        );
        return;
      }

      // Network
      if (lower.contains('network') ||
          lower.contains('socket') ||
          lower.contains('unable to resolve')) {
        _setError('No internet connection. Please try again.');
        return;
      }

      // Show the real error for anything else
      _setError('Google sign-in failed:\n$raw');
    }
  }

  // ── Facebook — stub (coming soon) ─────────────────────────────────────────
  // Does NOT touch _loading. Does NOT show an error banner.
  // Shows a branded snackbar instead.

  void _facebookSignIn() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('👍', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(
                'Facebook sign-in coming soon!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1877F2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bg,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            _Background(c: c, isDark: isDark, size: size),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: PageView(
                    controller: _pageCtrl,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    children: [
                      _LandingPage(
                        c: c,
                        isDark: isDark,
                        loading: _loading,
                        error: _error,
                        onPhone: () {
                          _setError(null);
                          _goTo(1);
                          Future.delayed(
                            const Duration(milliseconds: 400),
                            () => _phoneFocus.requestFocus(),
                          );
                        },
                        onGoogle: _googleSignIn,
                        onFacebook: _facebookSignIn,
                      ),
                      _PhonePage(
                        c: c,
                        isDark: isDark,
                        loading: _loading,
                        error: _error,
                        focusNode: _phoneFocus,
                        controller: _phoneCtrl,
                        countryCode: _countryCode,
                        onCountryCodeChanged: (v) =>
                            setState(() => _countryCode = v),
                        onBack: () => _goTo(0),
                        onSend: _sendOtp,
                      ),
                      _OtpPage(
                        c: c,
                        isDark: isDark,
                        loading: _loading,
                        error: _error,
                        focusNode: _otpFocus,
                        controller: _otpCtrl,
                        phone:
                            '$_countryCode${_phoneCtrl.text.trim()}',
                        onBack: () => _goTo(1),
                        onVerify: _verifyOtp,
                        onResend: () {
                          _otpCtrl.clear();
                          _setError(null);
                          _sendOtp();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 0 — Landing
// ─────────────────────────────────────────────────────────────────────────────

class _LandingPage extends StatelessWidget {
  const _LandingPage({
    required this.c,
    required this.isDark,
    required this.loading,
    required this.error,
    required this.onPhone,
    required this.onGoogle,
    required this.onFacebook,
  });

  final AppColors c;
  final bool isDark;
  final bool loading;
  final String? error;
  final VoidCallback onPhone;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _Logo(c: c),
          const SizedBox(height: 20),
          Text(
            'CheerChat',
            style: GoogleFonts.poppins(
              color: c.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connect with amazing hosts',
            style: GoogleFonts.poppins(
              color: c.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 56),

          // Phone — primary CTA
          _PrimaryButton(
            c: c,
            label: 'Continue with Phone',
            icon: Icons.phone_rounded,
            onTap: loading ? null : onPhone,
          ),
          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: c.border)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Text(
                  'or',
                  style: GoogleFonts.poppins(
                    color: c.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: c.border)),
            ],
          ),
          const SizedBox(height: 16),

          // Social row: Google + Facebook
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  c: c,
                  isDark: isDark,
                  label: 'Google',
                  asset: 'assets/icons/google.png',
                  fallbackIcon: Icons.g_mobiledata_rounded,
                  onTap: loading ? null : onGoogle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialButton(
                  c: c,
                  isDark: isDark,
                  label: 'Facebook',
                  asset: 'assets/icons/facebook.png',
                  fallbackIcon: Icons.facebook_rounded,
                  // Facebook is always tappable — never blocked by _loading
                  onTap: onFacebook,
                  comingSoon: true,
                ),
              ),
            ],
          ),

          // Error banner (Google / Phone only — Facebook uses snackbar)
          if (error != null) ...[
            const SizedBox(height: 18),
            _ErrorBanner(message: error!, c: c),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 — Phone number entry
// ─────────────────────────────────────────────────────────────────────────────

class _PhonePage extends StatelessWidget {
  const _PhonePage({
    required this.c,
    required this.isDark,
    required this.loading,
    required this.error,
    required this.focusNode,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    required this.onBack,
    required this.onSend,
  });

  final AppColors c;
  final bool isDark;
  final bool loading;
  final String? error;
  final FocusNode focusNode;
  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final VoidCallback onBack;
  final VoidCallback onSend;

  static const _codes = [
    ('🇮🇳', '+91', 'India'),
    ('🇵🇰', '+92', 'Pakistan'),
    ('🇧🇩', '+880', 'Bangladesh'),
    ('🇳🇵', '+977', 'Nepal'),
    ('🇺🇸', '+1', 'USA'),
    ('🇬🇧', '+44', 'UK'),
    ('🇦🇺', '+61', 'Australia'),
    ('🇦🇪', '+971', 'UAE'),
    ('🇸🇦', '+966', 'Saudi Arabia'),
    ('🇸🇬', '+65', 'Singapore'),
    ('🇨🇦', '+1', 'Canada'),
    ('🇩🇪', '+49', 'Germany'),
    ('🇫🇷', '+33', 'France'),
    ('🇧🇷', '+55', 'Brazil'),
    ('🇵🇭', '+63', 'Philippines'),
    ('🇮🇩', '+62', 'Indonesia'),
    ('🇲🇾', '+60', 'Malaysia'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: c.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Enter your\nnumber',
            style: GoogleFonts.poppins(
              color: c.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "We'll send you a one-time verification code",
            style: GoogleFonts.poppins(
              color: c.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),

          // Phone input row
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : c.pink.withOpacity(0.20),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: c.pink.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _CountryCodePicker(
                  c: c,
                  isDark: isDark,
                  selected: countryCode,
                  codes: _codes,
                  onChanged: onCountryCodeChanged,
                ),
                Container(width: 1, height: 26, color: c.border),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: GoogleFonts.poppins(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '98765 43210',
                      hintStyle: GoogleFonts.poppins(
                        color: c.textSecondary,
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: error!, c: c),
          ],

          const SizedBox(height: 32),
          _PrimaryButton(
            c: c,
            label: loading ? 'Sending code…' : 'Send Code',
            icon: Icons.send_rounded,
            loading: loading,
            onTap: loading ? null : onSend,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — OTP verification
// ─────────────────────────────────────────────────────────────────────────────

class _OtpPage extends StatelessWidget {
  const _OtpPage({
    required this.c,
    required this.isDark,
    required this.loading,
    required this.error,
    required this.focusNode,
    required this.controller,
    required this.phone,
    required this.onBack,
    required this.onVerify,
    required this.onResend,
  });

  final AppColors c;
  final bool isDark;
  final bool loading;
  final String? error;
  final FocusNode focusNode;
  final TextEditingController controller;
  final String phone;
  final VoidCallback onBack;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: c.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Verify\nyour number',
            style: GoogleFonts.poppins(
              color: c.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: c.textSecondary,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'Code sent to '),
                TextSpan(
                  text: phone,
                  style: GoogleFonts.poppins(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // OTP input — auto-submits at 6 digits
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : c.pink.withOpacity(0.20),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: c.pink.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: c.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 12,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '------',
                hintStyle: GoogleFonts.poppins(
                  color: c.textSecondary.withOpacity(0.4),
                  fontSize: 28,
                  letterSpacing: 12,
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
              ),
              onChanged: (v) {
                if (v.length == 6) onVerify();
              },
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: error!, c: c),
          ],

          const SizedBox(height: 32),
          _PrimaryButton(
            c: c,
            label: loading ? 'Verifying…' : 'Verify & Continue',
            icon: Icons.verified_rounded,
            loading: loading,
            onTap: loading ? null : onVerify,
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: loading ? null : onResend,
              child: Text(
                'Resend code',
                style: GoogleFonts.poppins(
                  color: c.pink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: c.pink.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Country code bottom-sheet picker
// ─────────────────────────────────────────────────────────────────────────────

class _CountryCodePicker extends StatelessWidget {
  const _CountryCodePicker({
    required this.c,
    required this.isDark,
    required this.selected,
    required this.codes,
    required this.onChanged,
  });

  final AppColors c;
  final bool isDark;
  final String selected;
  final List<(String, String, String)> codes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: GoogleFonts.poppins(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: c.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? c.card : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          0,
          16,
          0,
          MediaQuery.of(ctx).padding.bottom + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: codes
                    .map(
                      (code) => ListTile(
                        leading: Text(
                          code.$1,
                          style: const TextStyle(fontSize: 22),
                        ),
                        title: Text(
                          code.$3,
                          style: GoogleFonts.poppins(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Text(
                          code.$2,
                          style: GoogleFonts.poppins(
                            color: c.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        selected: selected == code.$2,
                        selectedColor: c.pink,
                        onTap: () {
                          onChanged(code.$2);
                          Navigator.pop(ctx);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo
// ─────────────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            c.pink,
            Color.lerp(c.pink, const Color(0xFF7B0050), 0.55)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: c.pink.withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text('💬', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary gradient button
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.c,
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  final AppColors c;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !loading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : LinearGradient(
                  colors: [
                    c.pink,
                    Color.lerp(
                      c.pink,
                      const Color(0xFF7B0050),
                      0.45,
                    )!,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: disabled ? c.border : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: c.pink.withOpacity(0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social button (Google / Facebook)
// ─────────────────────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.c,
    required this.isDark,
    required this.label,
    required this.asset,
    required this.fallbackIcon,
    required this.onTap,
    this.comingSoon = false,
  });

  final AppColors c;
  final bool isDark;
  final String label;
  final String asset;
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              side: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : c.border,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    asset,
                    errorBuilder: (_, __, ___) => Icon(
                      fallbackIcon,
                      color: c.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      color: c.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Gold "Soon" badge on Facebook button
        if (comingSoon)
          Positioned(
            top: -6,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: c.gold,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Soon',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error banner
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.c});
  final String message;
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background — two pink blobs, keyboard-safe (top: only, never bottom:)
// ─────────────────────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({
    required this.c,
    required this.isDark,
    required this.size,
  });

  final AppColors c;
  final bool isDark;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: c.bg),
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.pink.withOpacity(isDark ? 0.08 : 0.10),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.56,
          left: -60,
          child: Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.pink.withOpacity(isDark ? 0.05 : 0.07),
            ),
          ),
        ),
      ],
    );
  }
}

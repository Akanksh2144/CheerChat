// lib/screens/host_application_screen.dart
//
// Become a Host — application form.
// Step 1: Fill profile (display name, bio, language)
// Step 2: Submitted → shows status (pending/approved/rejected)

// import 'package:cheerchat/providers/theme_provider.dart';
import 'package:cheerchat/services/host_application_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cheerchat/theme/app_colors.dart'; 

class HostApplicationScreen extends ConsumerStatefulWidget {
  const HostApplicationScreen({super.key});

  @override
  ConsumerState<HostApplicationScreen> createState() =>
      _HostApplicationScreenState();
}

class _HostApplicationScreenState
    extends ConsumerState<HostApplicationScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String _language = 'Hindi';
  bool _loading = false;
  bool _checking = true;

  // Status from backend
  String?
  _status; // null = not applied, 'pending', 'approved', 'rejected'
  String? _statusMessage;

  static const _languages = [
    'Hindi',
    'English',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Urdu',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
    'Arabic',
    'Spanish',
    'Portuguese',
    'Indonesian',
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkExistingApplication() async {
    try {
      final svc = ref.read(hostApplicationServiceProvider);
      final status = await svc.getStatus();
      if (status != null && mounted) {
        setState(() {
          _status =
              status['approval_status'] as String? ??
              status['status'] as String?;
          _statusMessage = status['admin_notes'] as String?;
          _checking = false;
        });
      } else {
        if (mounted) setState(() => _checking = false);
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: const Text('Please enter a display name'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      return;
    }

    setState(() => _loading = true);

    try {
      final svc = ref.read(hostApplicationServiceProvider);
      final res = await svc.apply(
        displayName: name,
        bio: _bioCtrl.text.trim().isNotEmpty
            ? _bioCtrl.text.trim()
            : null,
        language: _language,
      );

      if (!mounted) return;

      if (res.ok) {
        setState(() {
          _status = res.data['status'] as String? ?? 'pending';
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 1500),
              content: Text(res.error ?? 'Submission failed'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 1500),
              content: Text('Error: $e'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: c.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Become a Host',
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : _status != null && _status != 'not_applied'
          ? _buildStatusView(c, mq)
          : _buildApplicationForm(c, mq),
    );
  }

  // ── Status View (pending/approved/rejected) ──────────────────────────────

  Widget _buildStatusView(AppColors c, MediaQueryData mq) {
    final isPending = _status == 'pending';
    final isApproved = _status == 'approved';

    final icon = isApproved
        ? Icons.check_circle_rounded
        : isPending
        ? Icons.hourglass_top_rounded
        : Icons.cancel_rounded;
    final color = isApproved
        ? Colors.green
        : isPending
        ? Colors.orange
        : Colors.red;
    final title = isApproved
        ? 'You\'re a Host!'
        : isPending
        ? 'Application Under Review'
        : 'Application Not Approved';
    final subtitle = isApproved
        ? 'Congratulations! You can now receive calls and earn coins.'
        : isPending
        ? 'We\'re reviewing your application. This usually takes 24-48 hours.'
        : _statusMessage ??
              'You can reapply with updated information.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, size: 52, color: color),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: c.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: c.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            if (!isApproved)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.pink),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.poppins(
                      color: c.pink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Application Form ─────────────────────────────────────────────────────

  Widget _buildApplicationForm(AppColors c, MediaQueryData mq) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        mq.padding.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header illustration
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [c.pink, const Color(0xFFFF6B9D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.pink.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Start earning on CheerChat',
              style: GoogleFonts.poppins(
                color: c.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Display Name
          _label('Display Name *', c),
          const SizedBox(height: 8),
          _textField(
            controller: _nameCtrl,
            hint: 'How users will see you',
            c: c,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 24),

          // Bio
          _label('About You', c),
          const SizedBox(height: 8),
          _textField(
            controller: _bioCtrl,
            hint: 'Tell callers a bit about yourself...',
            c: c,
            icon: Icons.edit_note_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Language
          _label('Primary Language', c),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _language,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: c.textSecondary,
                ),
                dropdownColor: c.surface,
                style: GoogleFonts.poppins(
                  color: c.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: _languages
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(l),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _language = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.pink.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: c.pink.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: c.pink,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'What happens next?',
                      style: GoogleFonts.poppins(
                        color: c.pink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoBullet(
                  'We review your application (24-48 hrs)',
                  c,
                ),
                _infoBullet(
                  'You\'ll be notified once approved',
                  c,
                ),
                _infoBullet(
                  'Set your price per minute and go online',
                  c,
                ),
                _infoBullet(
                  'Start receiving calls and earning coins',
                  c,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.pink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Application',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _label(String text, AppColors c) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: c.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required AppColors c,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        color: c.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: c.textSecondary.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: c.textSecondary, size: 20)
            : null,
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.pink, width: 1.5),
        ),
      ),
    );
  }

  Widget _infoBullet(String text, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: c.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

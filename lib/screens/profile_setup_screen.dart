// // import 'dart:io';

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import 'package:cheerchat/providers/user_provider.dart';
// // import 'package:cheerchat/theme/app_colors.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Data
// // // ─────────────────────────────────────────────────────────────────────────────

// // // Other removed per spec
// // const _kGenders = ['Male', 'Female'];

// // const _kCountries = [
// //   ('🇮🇳', 'IN', 'India'),
// //   ('🇵🇰', 'PK', 'Pakistan'),
// //   ('🇧🇩', 'BD', 'Bangladesh'),
// //   ('🇳🇵', 'NP', 'Nepal'),
// //   ('🇦🇪', 'AE', 'UAE'),
// //   ('🇸🇦', 'SA', 'Saudi Arabia'),
// //   ('🇺🇸', 'US', 'United States'),
// //   ('🇬🇧', 'GB', 'United Kingdom'),
// //   ('🇨🇦', 'CA', 'Canada'),
// //   ('🇦🇺', 'AU', 'Australia'),
// //   ('🇸🇬', 'SG', 'Singapore'),
// //   ('🇩🇪', 'DE', 'Germany'),
// //   ('🇫🇷', 'FR', 'France'),
// //   ('🇧🇷', 'BR', 'Brazil'),
// //   ('🇵🇭', 'PH', 'Philippines'),
// //   ('🇮🇩', 'ID', 'Indonesia'),
// //   ('🇲🇾', 'MY', 'Malaysia'),
// //   ('🇹🇷', 'TR', 'Turkey'),
// //   ('🇲🇦', 'MA', 'Morocco'),
// //   ('🇪🇬', 'EG', 'Egypt'),
// //   ('🇻🇳', 'VN', 'Vietnam'),
// //   ('🇱🇰', 'LK', 'Sri Lanka'),
// //   ('🇰🇪', 'KE', 'Kenya'),
// //   ('🇿🇦', 'ZA', 'South Africa'),
// //   ('🇲🇽', 'MX', 'Mexico'),
// //   ('🇦🇷', 'AR', 'Argentina'),
// //   ('🇺🇦', 'UA', 'Ukraine'),
// //   ('🇷🇺', 'RU', 'Russia'),
// //   ('🇯🇵', 'JP', 'Japan'),
// //   ('🇰🇷', 'KR', 'South Korea'),
// // ];

// // const _kLanguages = [
// //   'English',
// //   'Hindi',
// //   'Telugu',
// //   'Tamil',
// //   'Malayalam',
// //   'Kannada',
// //   'Bengali',
// //   'Urdu',
// //   'Arabic',
// //   'Spanish',
// //   'Portuguese',
// //   'German',
// //   'French',
// //   'Bahasa Indonesia',
// //   'Malay',
// //   'Nepali',
// //   'Filipino',
// //   'Turkish',
// //   'Ukrainian',
// //   'Vietnamese',
// //   'Japanese',
// //   'Korean',
// //   'Sinhala',
// // ];

// // // SharedPreferences keys for GPS country cache
// // const _kGpsCountryKey = 'cheerchat_gps_country';
// // const _kGpsTsKey = 'cheerchat_gps_country_ts';
// // const _k24h = 86400000; // ms

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Screen
// // // ─────────────────────────────────────────────────────────────────────────────

// // class ProfileSetupScreen extends ConsumerStatefulWidget {
// //   const ProfileSetupScreen({super.key});

// //   @override
// //   ConsumerState<ProfileSetupScreen> createState() =>
// //       _ProfileSetupScreenState();
// // }

// // class _ProfileSetupScreenState
// //     extends ConsumerState<ProfileSetupScreen>
// //     with SingleTickerProviderStateMixin {
// //   // ── Controllers ───────────────────────────────────────────────────────────
// //   final _nameCtrl = TextEditingController();
// //   final _nameFocus = FocusNode();

// //   // ── Form state ────────────────────────────────────────────────────────────
// //   String _gender = 'Male';
// //   String _countryCode = 'IN';
// //   String _language = 'English';
// //   DateTime? _dob;
// //   bool _dobMissing =
// //       false; // shows red border when user tries to submit without DOB

// //   // ── Photo ─────────────────────────────────────────────────────────────────
// //   File? _photoFile;
// //   bool _uploadingPhoto = false;

// //   // ── Location ──────────────────────────────────────────────────────────────
// //   bool _gpsLoading = false;
// //   bool _gpsDetected = false;

// //   // ── Submit ────────────────────────────────────────────────────────────────
// //   bool _loading = false;
// //   String? _error;

// //   // ── Animation ─────────────────────────────────────────────────────────────
// //   late final AnimationController _fadeCtrl;
// //   late final Animation<double> _fadeAnim;
// //   late final Animation<Offset> _slideAnim;

// //   // ── 18+ constraint: lastDate for the calendar ────────────────────────────
// //   DateTime get _maxDob {
// //     final now = DateTime.now();
// //     return DateTime(now.year - 18, now.month, now.day);
// //   }

// //   // ─────────────────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();

// //     // Default display name = "user" + first 9 chars of Firebase UID
// //     final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
// //     final suffix = uid.length >= 9 ? uid.substring(0, 9) : uid;
// //     _nameCtrl.text = 'user$suffix';

// //     // Entrance animation
// //     _fadeCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 600),
// //     );
// //     _fadeAnim = CurvedAnimation(
// //       parent: _fadeCtrl,
// //       curve: Curves.easeOut,
// //     );
// //     _slideAnim =
// //         Tween<Offset>(
// //           begin: const Offset(0, 0.05),
// //           end: Offset.zero,
// //         ).animate(
// //           CurvedAnimation(
// //             parent: _fadeCtrl,
// //             curve: Curves.easeOut,
// //           ),
// //         );
// //     _fadeCtrl.forward();

// //     // Auto-detect country
// //     _detectCountry();
// //   }

// //   @override
// //   void dispose() {
// //     _nameCtrl.dispose();
// //     _nameFocus.dispose();
// //     _fadeCtrl.dispose();
// //     super.dispose();
// //   }

// //   // ─────────────────────────────────────────────────────────────────────────
// //   // GPS country detection
// //   // ─────────────────────────────────────────────────────────────────────────
// //   //
// //   // 1. Check SharedPreferences — if < 24h old, use cached value instantly.
// //   // 2. Otherwise request permission → get coarse position → reverse-geocode
// //   //    → extract ISO code → match _kCountries.
// //   // 3. Save result + timestamp to cache.
// //   // 4. Any failure → silent fallback; the manual dropdown is always editable.

// //   Future<void> _detectCountry() async {
// //     // ── Try cached value first ────────────────────────────────────────────
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cached = prefs.getString(_kGpsCountryKey);
// //       final ts = prefs.getInt(_kGpsTsKey) ?? 0;
// //       final age = DateTime.now().millisecondsSinceEpoch - ts;
// //       if (cached != null && age < _k24h) {
// //         final match = _kCountries
// //             .where((c) => c.$2 == cached)
// //             .firstOrNull;
// //         if (match != null && mounted) {
// //           setState(() {
// //             _countryCode = match.$2;
// //             _gpsDetected = true;
// //           });
// //           return;
// //         }
// //       }
// //     } catch (_) {}

// //     // ── Live GPS ──────────────────────────────────────────────────────────
// //     if (!mounted) return;
// //     setState(() => _gpsLoading = true);

// //     try {
// //       // Check / request permission
// //       var perm = await Geolocator.checkPermission();
// //       if (perm == LocationPermission.denied) {
// //         perm = await Geolocator.requestPermission();
// //       }
// //       if (perm == LocationPermission.denied ||
// //           perm == LocationPermission.deniedForever) {
// //         if (mounted) setState(() => _gpsLoading = false);
// //         return; // silently stay on default
// //       }

// //       // Coarse accuracy is enough to know the country (and saves battery)
// //       final pos = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.low,
// //         timeLimit: const Duration(seconds: 12),
// //       );

// //       final marks = await placemarkFromCoordinates(
// //         pos.latitude,
// //         pos.longitude,
// //       );

// //       if (marks.isNotEmpty && mounted) {
// //         final iso = marks.first.isoCountryCode?.toUpperCase();
// //         if (iso != null && iso.isNotEmpty) {
// //           final match = _kCountries
// //               .where((c) => c.$2 == iso)
// //               .firstOrNull;
// //           if (match != null) {
// //             setState(() {
// //               _countryCode = match.$2;
// //               _gpsDetected = true;
// //             });
// //             // Cache for 24h
// //             final prefs = await SharedPreferences.getInstance();
// //             await prefs.setString(_kGpsCountryKey, match.$2);
// //             await prefs.setInt(
// //               _kGpsTsKey,
// //               DateTime.now().millisecondsSinceEpoch,
// //             );
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint('[ProfileSetup] GPS failed: $e');
// //     } finally {
// //       if (mounted) setState(() => _gpsLoading = false);
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────────────────────
// //   // Photo picker
// //   // ─────────────────────────────────────────────────────────────────────────

// //   Future<void> _pickPhoto() async {
// //     final XFile? picked = await ImagePicker().pickImage(
// //       source: ImageSource.gallery,
// //       imageQuality: 85,
// //       maxWidth: 600,
// //     );
// //     if (picked == null || !mounted) return;
// //     setState(() => _photoFile = File(picked.path));
// //   }

// //   // ─────────────────────────────────────────────────────────────────────────
// //   // DOB picker — hard-capped at 18+ (lastDate = today − 18 years)
// //   // ─────────────────────────────────────────────────────────────────────────

// //   Future<void> _pickDob() async {
// //     final c = AppColors.of(context);
// //     final initial =
// //         _dob ??
// //         DateTime(_maxDob.year - 2, _maxDob.month, _maxDob.day);
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: initial,
// //       firstDate: DateTime(1940),
// //       lastDate: _maxDob, // enforces 18+ at the calendar UI level
// //       helpText: 'Date of Birth  (18+ only)',
// //       builder: (ctx, child) => Theme(
// //         data: Theme.of(ctx).copyWith(
// //           colorScheme: Theme.of(ctx).colorScheme.copyWith(
// //             primary: c.pink,
// //             onSurface: c.textPrimary,
// //           ),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (picked != null && mounted) {
// //       setState(() {
// //         _dob = picked;
// //         _dobMissing = false;
// //       });
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────────────────────
// //   // Submit
// //   // ─────────────────────────────────────────────────────────────────────────

// //   Future<void> _submit() async {
// //     _nameFocus.unfocus();

// //     // DOB is required
// //     if (_dob == null) {
// //       setState(() {
// //         _dobMissing = true;
// //         _error = 'Please select your date of birth.';
// //       });
// //       return;
// //     }

// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //       _dobMissing = false;
// //     });

// //     // ── Optional photo upload ────────────────────────────────────────────
// //     String? photoUrl;
// //     if (_photoFile != null) {
// //       setState(() => _uploadingPhoto = true);
// //       try {
// //         final uid =
// //             FirebaseAuth.instance.currentUser?.uid ?? 'tmp';
// //         final ref = FirebaseStorage.instance.ref().child(
// //           'profile_photos/$uid.jpg',
// //         );
// //         await ref.putFile(_photoFile!);
// //         photoUrl = await ref.getDownloadURL();
// //       } catch (e) {
// //         debugPrint(
// //           '[ProfileSetup] Photo upload failed (non-fatal): $e',
// //         );
// //       } finally {
// //         if (mounted) setState(() => _uploadingPhoto = false);
// //       }
// //     }

// //     // ── Resolve display name ─────────────────────────────────────────────
// //     final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
// //     final suffix = uid.length >= 9 ? uid.substring(0, 9) : uid;
// //     final typed = _nameCtrl.text.trim();
// //     final displayName = typed.isEmpty ? 'user$suffix' : typed;

// //     // ── Register ─────────────────────────────────────────────────────────
// //     final user = await ref
// //         .read(currentUserProvider.notifier)
// //         .register(
// //           displayName: displayName,
// //           countryCode: _countryCode,
// //           language: _language,
// //           gender: _gender.toLowerCase(),
// //           dateOfBirth: _dob,
// //           profilePhotoUrl: photoUrl,
// //         );

// //     if (!mounted) return;
// //     setState(() => _loading = false);

// //     if (user == null) {
// //       setState(
// //         () => _error = 'Something went wrong. Please try again.',
// //       );
// //     }
// //     // On success AuthGate auto-navigates — no push needed.
// //   }

// //   // ─────────────────────────────────────────────────────────────────────────
// //   // Build
// //   // ─────────────────────────────────────────────────────────────────────────

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = AppColors.of(context);
// //     final isDark =
// //         Theme.of(context).brightness == Brightness.dark;
// //     final size = MediaQuery.of(context).size;

// //     return AnnotatedRegion<SystemUiOverlayStyle>(
// //       value: isDark
// //           ? SystemUiOverlayStyle.light
// //           : SystemUiOverlayStyle.dark,
// //       child: Scaffold(
// //         backgroundColor: c.bg,
// //         resizeToAvoidBottomInset: true,
// //         body: Stack(
// //           children: [
// //             _SetupBackground(c: c, isDark: isDark, size: size),
// //             SafeArea(
// //               child: FadeTransition(
// //                 opacity: _fadeAnim,
// //                 child: SlideTransition(
// //                   position: _slideAnim,
// //                   child: SingleChildScrollView(
// //                     padding: const EdgeInsets.fromLTRB(
// //                       28,
// //                       0,
// //                       28,
// //                       48,
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment:
// //                           CrossAxisAlignment.start,
// //                       children: [
// //                         const SizedBox(height: 36),

// //                         // ── Header ─────────────────────────────────────
// //                         Center(
// //                           child: Text(
// //                             'Set Up Profile',
// //                             style: GoogleFonts.poppins(
// //                               color: c.textPrimary,
// //                               fontSize: 26,
// //                               fontWeight: FontWeight.w800,
// //                               letterSpacing: -0.5,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Center(
// //                           child: Text(
// //                             'Tell us a bit about yourself',
// //                             style: GoogleFonts.poppins(
// //                               color: c.textSecondary,
// //                               fontSize: 13,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 32),

// //                         // ── Profile photo ──────────────────────────────
// //                         Center(
// //                           child: _PhotoPicker(
// //                             c: c,
// //                             photoFile: _photoFile,
// //                             onTap: _pickPhoto,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 36),

// //                         // ── Display name (optional) ────────────────────
// //                         _Label(
// //                           label: 'Display Name',
// //                           c: c,
// //                           optional: true,
// //                         ),
// //                         const SizedBox(height: 8),
// //                         _InputField(
// //                           controller: _nameCtrl,
// //                           focusNode: _nameFocus,
// //                           c: c,
// //                           isDark: isDark,
// //                           hint: 'Your display name',
// //                           maxLength: 30,
// //                         ),
// //                         const SizedBox(height: 5),
// //                         Text(
// //                           'Optional — clear to keep the default.',
// //                           style: GoogleFonts.poppins(
// //                             color: c.textSecondary,
// //                             fontSize: 11,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 28),

// //                         // ── Gender (Male / Female only) ────────────────
// //                         _Label(label: 'I am a…', c: c),
// //                         const SizedBox(height: 10),
// //                         Row(
// //                           children: _kGenders.map((g) {
// //                             return Expanded(
// //                               child: Padding(
// //                                 padding: EdgeInsets.only(
// //                                   right: g != _kGenders.last
// //                                       ? 12
// //                                       : 0,
// //                                 ),
// //                                 child: _GenderChip(
// //                                   label: g,
// //                                   selected: _gender == g,
// //                                   c: c,
// //                                   isDark: isDark,
// //                                   onTap: () => setState(
// //                                     () => _gender = g,
// //                                   ),
// //                                 ),
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ),
// //                         const SizedBox(height: 28),

// //                         // ── Date of birth (required, 18+) ──────────────
// //                         _Label(label: 'Date of Birth', c: c),
// //                         const SizedBox(height: 8),
// //                         _TapField(
// //                           value: _dob != null
// //                               ? '${_dob!.day.toString().padLeft(2, '0')} / '
// //                                     '${_dob!.month.toString().padLeft(2, '0')} / '
// //                                     '${_dob!.year}'
// //                               : null,
// //                           hint: 'Tap to select  (18+ only)',
// //                           icon: Icons.cake_outlined,
// //                           c: c,
// //                           isDark: isDark,
// //                           hasError: _dobMissing,
// //                           onTap: _pickDob,
// //                           trailing: _dob != null
// //                               ? GestureDetector(
// //                                   onTap: () => setState(() {
// //                                     _dob = null;
// //                                     _dobMissing = false;
// //                                   }),
// //                                   child: Icon(
// //                                     Icons.close_rounded,
// //                                     size: 16,
// //                                     color: c.textSecondary,
// //                                   ),
// //                                 )
// //                               : null,
// //                         ),
// //                         const SizedBox(height: 28),

// //                         // ── Country (GPS auto-detect) ──────────────────
// //                         _Label(label: 'Country', c: c),
// //                         const SizedBox(height: 8),
// //                         if (_gpsLoading)
// //                           _GpsLoadingTile(c: c)
// //                         else
// //                           Column(
// //                             crossAxisAlignment:
// //                                 CrossAxisAlignment.start,
// //                             children: [
// //                               _DropdownField<String>(
// //                                 value: _countryCode,
// //                                 c: c,
// //                                 isDark: isDark,
// //                                 items: _kCountries
// //                                     .map(
// //                                       (e) => DropdownMenuItem(
// //                                         value: e.$2,
// //                                         child: Text(
// //                                           '${e.$1}  ${e.$3}',
// //                                           style:
// //                                               GoogleFonts.poppins(
// //                                                 color: c
// //                                                     .textPrimary,
// //                                                 fontSize: 14,
// //                                                 fontWeight:
// //                                                     FontWeight
// //                                                         .w500,
// //                                               ),
// //                                         ),
// //                                       ),
// //                                     )
// //                                     .toList(),
// //                                 onChanged: (v) {
// //                                   if (v != null) {
// //                                     setState(() {
// //                                       _countryCode = v;
// //                                       // User overrode GPS — hide the tag
// //                                       _gpsDetected = false;
// //                                     });
// //                                   }
// //                                 },
// //                               ),
// //                               if (_gpsDetected)
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(
// //                                     top: 6,
// //                                     left: 2,
// //                                   ),
// //                                   child: Row(
// //                                     children: [
// //                                       Icon(
// //                                         Icons
// //                                             .location_on_rounded,
// //                                         size: 12,
// //                                         color: c.green,
// //                                       ),
// //                                       const SizedBox(width: 4),
// //                                       Text(
// //                                         'Auto-detected from your device',
// //                                         style:
// //                                             GoogleFonts.poppins(
// //                                               color: c.green,
// //                                               fontSize: 11,
// //                                               fontWeight:
// //                                                   FontWeight
// //                                                       .w500,
// //                                             ),
// //                                       ),
// //                                       const SizedBox(width: 8),
// //                                       GestureDetector(
// //                                         onTap: () {
// //                                           setState(() {
// //                                             _gpsDetected = false;
// //                                             _gpsLoading = false;
// //                                           });
// //                                           _detectCountry();
// //                                         },
// //                                         child: Text(
// //                                           'Refresh',
// //                                           style: GoogleFonts.poppins(
// //                                             color:
// //                                                 c.textSecondary,
// //                                             fontSize: 11,
// //                                             decoration:
// //                                                 TextDecoration
// //                                                     .underline,
// //                                             decorationColor:
// //                                                 c.textSecondary,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                         const SizedBox(height: 28),

// //                         // ── Language ───────────────────────────────────
// //                         _Label(label: 'Language', c: c),
// //                         const SizedBox(height: 8),
// //                         _DropdownField<String>(
// //                           value: _language,
// //                           c: c,
// //                           isDark: isDark,
// //                           items: _kLanguages
// //                               .map(
// //                                 (l) => DropdownMenuItem(
// //                                   value: l,
// //                                   child: Text(
// //                                     l,
// //                                     style: GoogleFonts.poppins(
// //                                       color: c.textPrimary,
// //                                       fontSize: 14,
// //                                       fontWeight:
// //                                           FontWeight.w500,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               )
// //                               .toList(),
// //                           onChanged: (v) {
// //                             if (v != null)
// //                               setState(() => _language = v);
// //                           },
// //                         ),

// //                         // ── Error ──────────────────────────────────────
// //                         if (_error != null) ...[
// //                           const SizedBox(height: 20),
// //                           _ErrorBanner(message: _error!, c: c),
// //                         ],

// //                         const SizedBox(height: 36),

// //                         // ── CTA ────────────────────────────────────────
// //                         _SubmitButton(
// //                           c: c,
// //                           loading: _loading || _uploadingPhoto,
// //                           label: _uploadingPhoto
// //                               ? 'Uploading photo…'
// //                               : _loading
// //                               ? 'Setting up…'
// //                               : 'Get Started',
// //                           onTap: (_loading || _uploadingPhoto)
// //                               ? null
// //                               : _submit,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Photo picker widget
// // // ─────────────────────────────────────────────────────────────────────────────

// // class _PhotoPicker extends StatelessWidget {
// //   const _PhotoPicker({
// //     required this.c,
// //     required this.photoFile,
// //     required this.onTap,
// //   });
// //   final AppColors c;
// //   final File? photoFile;
// //   final VoidCallback onTap;

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Stack(
// //         clipBehavior: Clip.none,
// //         children: [
// //           // Avatar circle
// //           Container(
// //             width: 104,
// //             height: 104,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: c.avatarFallback,
// //               border: Border.all(
// //                 color: photoFile != null ? c.pink : c.border,
// //                 width: 2.5,
// //               ),
// //               image: photoFile != null
// //                   ? DecorationImage(
// //                       image: FileImage(photoFile!),
// //                       fit: BoxFit.cover,
// //                     )
// //                   : null,
// //             ),
// //             child: photoFile == null
// //                 ? Icon(
// //                     Icons.person_rounded,
// //                     size: 56,
// //                     color: c.avatarIcon,
// //                   )
// //                 : null,
// //           ),

// //           // Camera badge
// //           Positioned(
// //             bottom: 2,
// //             right: 2,
// //             child: Container(
// //               width: 32,
// //               height: 32,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: c.pink,
// //                 border: Border.all(color: c.bg, width: 2.5),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: c.pink.withOpacity(0.45),
// //                     blurRadius: 8,
// //                     offset: const Offset(0, 3),
// //                   ),
// //                 ],
// //               ),
// //               child: const Icon(
// //                 Icons.camera_alt_rounded,
// //                 color: Colors.white,
// //                 size: 15,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // GPS loading tile
// // // ─────────────────────────────────────────────────────────────────────────────

// // class _GpsLoadingTile extends StatelessWidget {
// //   const _GpsLoadingTile({required this.c});
// //   final AppColors c;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(
// //         horizontal: 18,
// //         vertical: 16,
// //       ),
// //       decoration: BoxDecoration(
// //         color: c.card,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: c.border),
// //       ),
// //       child: Row(
// //         children: [
// //           SizedBox(
// //             width: 16,
// //             height: 16,
// //             child: CircularProgressIndicator(
// //               color: c.pink,
// //               strokeWidth: 2,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Text(
// //             'Detecting your location…',
// //             style: GoogleFonts.poppins(
// //               color: c.textSecondary,
// //               fontSize: 14,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Background
// // // ─────────────────────────────────────────────────────────────────────────────

// // class _SetupBackground extends StatelessWidget {
// //   const _SetupBackground({
// //     required this.c,
// //     required this.isDark,
// //     required this.size,
// //   });
// //   final AppColors c;
// //   final bool isDark;
// //   final Size size;

// //   @override
// //   Widget build(BuildContext context) {
// //     const amber = Color(0xFFFF9500);
// //     return Stack(
// //       children: [
// //         Container(color: c.bg),
// //         Positioned(
// //           top: -70,
// //           left: -70,
// //           child: Container(
// //             width: size.width * 0.60,
// //             height: size.width * 0.60,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: c.pink.withOpacity(isDark ? 0.07 : 0.09),
// //             ),
// //           ),
// //         ),
// //         Positioned(
// //           top: size.height * 0.10,
// //           right: -60,
// //           child: Container(
// //             width: size.width * 0.45,
// //             height: size.width * 0.45,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: amber.withOpacity(isDark ? 0.05 : 0.07),
// //             ),
// //           ),
// //         ),
// //         Positioned(
// //           top: size.height * 0.48,
// //           right: size.width * 0.08,
// //           child: Container(
// //             width: 52,
// //             height: 52,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               border: Border.all(
// //                 color: c.pink.withOpacity(isDark ? 0.12 : 0.16),
// //                 width: 1.5,
// //               ),
// //             ),
// //           ),
// //         ),
// //         Positioned(
// //           top: size.height * 0.72,
// //           left: size.width * 0.08,
// //           child: Container(
// //             width: 8,
// //             height: 8,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: amber.withOpacity(isDark ? 0.22 : 0.28),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Sub-widgets
// // // ─────────────────────────────────────────────────────────────────────────────

// // class _Label extends StatelessWidget {
// //   const _Label({
// //     required this.label,
// //     required this.c,
// //     this.optional = false,
// //   });
// //   final String label;
// //   final AppColors c;
// //   final bool optional;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         Text(
// //           label,
// //           style: GoogleFonts.poppins(
// //             color: c.textPrimary,
// //             fontSize: 13,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         if (!optional) ...[
// //           const SizedBox(width: 3),
// //           Text(
// //             '*',
// //             style: GoogleFonts.poppins(
// //               color: c.pink,
// //               fontSize: 14,
// //               fontWeight: FontWeight.w800,
// //             ),
// //           ),
// //         ] else ...[
// //           const SizedBox(width: 6),
// //           Text(
// //             'optional',
// //             style: GoogleFonts.poppins(
// //               color: c.textSecondary,
// //               fontSize: 11,
// //             ),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// // }

// // class _InputField extends StatelessWidget {
// //   const _InputField({
// //     required this.controller,
// //     required this.focusNode,
// //     required this.c,
// //     required this.isDark,
// //     required this.hint,
// //     this.maxLength,
// //   });
// //   final TextEditingController controller;
// //   final FocusNode focusNode;
// //   final AppColors c;
// //   final bool isDark;
// //   final String hint;
// //   final int? maxLength;

// //   @override
// //   Widget build(BuildContext context) {
// //     return TextField(
// //       controller: controller,
// //       focusNode: focusNode,
// //       maxLength: maxLength,
// //       style: GoogleFonts.poppins(
// //         color: c.textPrimary,
// //         fontSize: 15,
// //         fontWeight: FontWeight.w500,
// //       ),
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle: GoogleFonts.poppins(
// //           color: c.textSecondary,
// //           fontSize: 14,
// //         ),
// //         counterText: '',
// //         filled: true,
// //         fillColor: isDark
// //             ? Colors.white.withOpacity(0.06)
// //             : Colors.white,
// //         contentPadding: const EdgeInsets.symmetric(
// //           horizontal: 18,
// //           vertical: 16,
// //         ),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(14),
// //           borderSide: BorderSide.none,
// //         ),
// //         enabledBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(14),
// //           borderSide: BorderSide(
// //             color: isDark
// //                 ? Colors.white.withOpacity(0.10)
// //                 : c.pink.withOpacity(0.18),
// //             width: 1.5,
// //           ),
// //         ),
// //         focusedBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(14),
// //           borderSide: BorderSide(color: c.pink, width: 1.5),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _TapField extends StatelessWidget {
// //   const _TapField({
// //     required this.hint,
// //     required this.icon,
// //     required this.c,
// //     required this.isDark,
// //     required this.onTap,
// //     this.value,
// //     this.trailing,
// //     this.hasError = false,
// //   });
// //   final String hint;
// //   final IconData icon;
// //   final AppColors c;
// //   final bool isDark;
// //   final VoidCallback onTap;
// //   final String? value;
// //   final Widget? trailing;
// //   final bool hasError;

// //   @override
// //   Widget build(BuildContext context) {
// //     final borderColor = hasError
// //         ? Colors.redAccent
// //         : (isDark
// //               ? Colors.white.withOpacity(0.10)
// //               : c.pink.withOpacity(0.18));
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(
// //           horizontal: 18,
// //           vertical: 16,
// //         ),
// //         decoration: BoxDecoration(
// //           color: isDark
// //               ? Colors.white.withOpacity(0.06)
// //               : Colors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: borderColor, width: 1.5),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(
// //               icon,
// //               color: hasError
// //                   ? Colors.redAccent
// //                   : c.textSecondary,
// //               size: 18,
// //             ),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 value ?? hint,
// //                 style: GoogleFonts.poppins(
// //                   color: value != null
// //                       ? c.textPrimary
// //                       : (hasError
// //                             ? Colors.redAccent
// //                             : c.textSecondary),
// //                   fontSize: value != null ? 15 : 14,
// //                   fontWeight: value != null
// //                       ? FontWeight.w500
// //                       : FontWeight.w400,
// //                 ),
// //               ),
// //             ),
// //             trailing ??
// //                 Icon(
// //                   Icons.keyboard_arrow_down_rounded,
// //                   color: c.textSecondary,
// //                   size: 18,
// //                 ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _DropdownField<T> extends StatelessWidget {
// //   const _DropdownField({
// //     required this.value,
// //     required this.c,
// //     required this.isDark,
// //     required this.items,
// //     required this.onChanged,
// //   });
// //   final T value;
// //   final AppColors c;
// //   final bool isDark;
// //   final List<DropdownMenuItem<T>> items;
// //   final ValueChanged<T?> onChanged;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 14),
// //       decoration: BoxDecoration(
// //         color: isDark
// //             ? Colors.white.withOpacity(0.06)
// //             : Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(
// //           color: isDark
// //               ? Colors.white.withOpacity(0.10)
// //               : c.pink.withOpacity(0.18),
// //           width: 1.5,
// //         ),
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<T>(
// //           value: value,
// //           items: items,
// //           onChanged: onChanged,
// //           isExpanded: true,
// //           dropdownColor: isDark ? c.card : Colors.white,
// //           icon: Icon(
// //             Icons.keyboard_arrow_down_rounded,
// //             color: c.textSecondary,
// //             size: 20,
// //           ),
// //           style: GoogleFonts.poppins(
// //             color: c.textPrimary,
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _GenderChip extends StatelessWidget {
// //   const _GenderChip({
// //     required this.label,
// //     required this.selected,
// //     required this.c,
// //     required this.isDark,
// //     required this.onTap,
// //   });
// //   final String label;
// //   final bool selected;
// //   final AppColors c;
// //   final bool isDark;
// //   final VoidCallback onTap;

// //   @override
// //   Widget build(BuildContext context) {
// //     final icon = label == 'Male' ? '♂' : '♀';
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 180),
// //         height: 54,
// //         decoration: BoxDecoration(
// //           gradient: selected
// //               ? LinearGradient(
// //                   colors: [
// //                     c.pink,
// //                     Color.lerp(
// //                       c.pink,
// //                       const Color(0xFF7B0050),
// //                       0.45,
// //                     )!,
// //                   ],
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                 )
// //               : null,
// //           color: selected
// //               ? null
// //               : (isDark
// //                     ? Colors.white.withOpacity(0.06)
// //                     : Colors.white),
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(
// //             color: selected
// //                 ? Colors.transparent
// //                 : (isDark
// //                       ? Colors.white.withOpacity(0.10)
// //                       : c.pink.withOpacity(0.18)),
// //             width: 1.5,
// //           ),
// //           boxShadow: selected
// //               ? [
// //                   BoxShadow(
// //                     color: c.pink.withOpacity(0.35),
// //                     blurRadius: 12,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ]
// //               : [],
// //         ),
// //         child: Center(
// //           child: Text(
// //             '$icon  $label',
// //             style: GoogleFonts.poppins(
// //               color: selected ? Colors.white : c.textSecondary,
// //               fontSize: 14,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _SubmitButton extends StatelessWidget {
// //   const _SubmitButton({
// //     required this.c,
// //     required this.loading,
// //     required this.label,
// //     required this.onTap,
// //   });
// //   final AppColors c;
// //   final bool loading;
// //   final String label;
// //   final VoidCallback? onTap;

// //   @override
// //   Widget build(BuildContext context) {
// //     final disabled = onTap == null;
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 56,
// //       child: DecoratedBox(
// //         decoration: BoxDecoration(
// //           gradient: disabled
// //               ? null
// //               : LinearGradient(
// //                   colors: [
// //                     c.pink,
// //                     Color.lerp(
// //                       c.pink,
// //                       const Color(0xFF7B0050),
// //                       0.45,
// //                     )!,
// //                   ],
// //                   begin: Alignment.centerLeft,
// //                   end: Alignment.centerRight,
// //                 ),
// //           color: disabled ? c.border : null,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: disabled
// //               ? []
// //               : [
// //                   BoxShadow(
// //                     color: c.pink.withOpacity(0.40),
// //                     blurRadius: 18,
// //                     offset: const Offset(0, 6),
// //                   ),
// //                 ],
// //         ),
// //         child: ElevatedButton(
// //           onPressed: onTap,
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: Colors.transparent,
// //             shadowColor: Colors.transparent,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //           ),
// //           child: loading
// //               ? const SizedBox(
// //                   width: 22,
// //                   height: 22,
// //                   child: CircularProgressIndicator(
// //                     color: Colors.white,
// //                     strokeWidth: 2.5,
// //                   ),
// //                 )
// //               : Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     const Text(
// //                       '🚀',
// //                       style: TextStyle(fontSize: 18),
// //                     ),
// //                     const SizedBox(width: 10),
// //                     Text(
// //                       label,
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.white,
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _ErrorBanner extends StatelessWidget {
// //   const _ErrorBanner({required this.message, required this.c});
// //   final String message;
// //   final AppColors c;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.symmetric(
// //         horizontal: 14,
// //         vertical: 10,
// //       ),
// //       decoration: BoxDecoration(
// //         color: Colors.redAccent.withOpacity(0.10),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: Colors.redAccent.withOpacity(0.3),
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(
// //             Icons.error_outline_rounded,
// //             color: Colors.redAccent,
// //             size: 16,
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               message,
// //               style: GoogleFonts.poppins(
// //                 color: Colors.redAccent,
// //                 fontSize: 12,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:cheerchat/providers/user_provider.dart';
// import 'package:cheerchat/theme/app_colors.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Data
// // ─────────────────────────────────────────────────────────────────────────────

// // Other removed per spec
// const _kGenders = ['Male', 'Female'];

// const _kCountries = [
//   ('🇮🇳', 'IN', 'India'),
//   ('🇵🇰', 'PK', 'Pakistan'),
//   ('🇧🇩', 'BD', 'Bangladesh'),
//   ('🇳🇵', 'NP', 'Nepal'),
//   ('🇦🇪', 'AE', 'UAE'),
//   ('🇸🇦', 'SA', 'Saudi Arabia'),
//   ('🇺🇸', 'US', 'United States'),
//   ('🇬🇧', 'GB', 'United Kingdom'),
//   ('🇨🇦', 'CA', 'Canada'),
//   ('🇦🇺', 'AU', 'Australia'),
//   ('🇸🇬', 'SG', 'Singapore'),
//   ('🇩🇪', 'DE', 'Germany'),
//   ('🇫🇷', 'FR', 'France'),
//   ('🇧🇷', 'BR', 'Brazil'),
//   ('🇵🇭', 'PH', 'Philippines'),
//   ('🇮🇩', 'ID', 'Indonesia'),
//   ('🇲🇾', 'MY', 'Malaysia'),
//   ('🇹🇷', 'TR', 'Turkey'),
//   ('🇲🇦', 'MA', 'Morocco'),
//   ('🇪🇬', 'EG', 'Egypt'),
//   ('🇻🇳', 'VN', 'Vietnam'),
//   ('🇱🇰', 'LK', 'Sri Lanka'),
//   ('🇰🇪', 'KE', 'Kenya'),
//   ('🇿🇦', 'ZA', 'South Africa'),
//   ('🇲🇽', 'MX', 'Mexico'),
//   ('🇦🇷', 'AR', 'Argentina'),
//   ('🇺🇦', 'UA', 'Ukraine'),
//   ('🇷🇺', 'RU', 'Russia'),
//   ('🇯🇵', 'JP', 'Japan'),
//   ('🇰🇷', 'KR', 'South Korea'),
// ];

// const _kLanguages = [
//   'English',
//   'Hindi',
//   'Telugu',
//   'Tamil',
//   'Malayalam',
//   'Kannada',
//   'Bengali',
//   'Urdu',
//   'Arabic',
//   'Spanish',
//   'Portuguese',
//   'German',
//   'French',
//   'Bahasa Indonesia',
//   'Malay',
//   'Nepali',
//   'Filipino',
//   'Turkish',
//   'Ukrainian',
//   'Vietnamese',
//   'Japanese',
//   'Korean',
//   'Sinhala',
// ];

// // SharedPreferences keys for GPS country cache
// const _kGpsCountryKey = 'cheerchat_gps_country';
// const _kGpsTsKey = 'cheerchat_gps_country_ts';
// const _k24h = 86400000; // ms

// // ─────────────────────────────────────────────────────────────────────────────
// // Screen
// // ─────────────────────────────────────────────────────────────────────────────

// class ProfileSetupScreen extends ConsumerStatefulWidget {
//   const ProfileSetupScreen({super.key});

//   @override
//   ConsumerState<ProfileSetupScreen> createState() =>
//       _ProfileSetupScreenState();
// }

// class _ProfileSetupScreenState
//     extends ConsumerState<ProfileSetupScreen>
//     with SingleTickerProviderStateMixin {
//   // ── Controllers ───────────────────────────────────────────────────────────
//   final _nameCtrl = TextEditingController();
//   final _nameFocus = FocusNode();

//   // ── Form state ────────────────────────────────────────────────────────────
//   String _gender = 'Male';
//   String _countryCode = 'IN';
//   String _language = 'English';
//   DateTime? _dob;
//   bool _dobMissing =
//       false; // shows red border when user tries to submit without DOB

//   // ── Photo ─────────────────────────────────────────────────────────────────
//   File? _photoFile;
//   bool _uploadingPhoto = false;

//   // ── Location ──────────────────────────────────────────────────────────────
//   bool _gpsLoading = false;
//   bool _gpsDetected = false;

//   // ── Submit ────────────────────────────────────────────────────────────────
//   bool _loading = false;
//   String? _error;

//   // ── Animation ─────────────────────────────────────────────────────────────
//   late final AnimationController _fadeCtrl;
//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset> _slideAnim;

//   // ── 18+ constraint: lastDate for the calendar ────────────────────────────
//   DateTime get _maxDob {
//     final now = DateTime.now();
//     return DateTime(now.year - 18, now.month, now.day);
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();

//     // Default display name = "user" + first 9 chars of Firebase UID
//     final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
//     final suffix = uid.length >= 9 ? uid.substring(0, 9) : uid;
//     _nameCtrl.text = 'user$suffix';

//     // Entrance animation
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnim = CurvedAnimation(
//       parent: _fadeCtrl,
//       curve: Curves.easeOut,
//     );
//     _slideAnim =
//         Tween<Offset>(
//           begin: const Offset(0, 0.05),
//           end: Offset.zero,
//         ).animate(
//           CurvedAnimation(
//             parent: _fadeCtrl,
//             curve: Curves.easeOut,
//           ),
//         );
//     _fadeCtrl.forward();

//     // Auto-detect country
//     _detectCountry();
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _nameFocus.dispose();
//     _fadeCtrl.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // GPS country detection
//   // ─────────────────────────────────────────────────────────────────────────
//   //
//   // 1. Check SharedPreferences — if < 24h old, use cached value instantly.
//   // 2. Otherwise request permission → get coarse position → reverse-geocode
//   //    → extract ISO code → match _kCountries.
//   // 3. Save result + timestamp to cache.
//   // 4. Any failure → silent fallback; the manual dropdown is always editable.

//   Future<void> _detectCountry() async {
//     // ── Try cached value first ────────────────────────────────────────────
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cached = prefs.getString(_kGpsCountryKey);
//       final ts = prefs.getInt(_kGpsTsKey) ?? 0;
//       final age = DateTime.now().millisecondsSinceEpoch - ts;
//       if (cached != null && age < _k24h) {
//         final match = _kCountries
//             .where((c) => c.$2 == cached)
//             .firstOrNull;
//         if (match != null && mounted) {
//           setState(() {
//             _countryCode = match.$2;
//             _gpsDetected = true;
//           });
//           return;
//         }
//       }
//     } catch (_) {}

//     // ── Live GPS ──────────────────────────────────────────────────────────
//     if (!mounted) return;
//     setState(() => _gpsLoading = true);

//     try {
//       // Check / request permission
//       var perm = await Geolocator.checkPermission();
//       if (perm == LocationPermission.denied) {
//         perm = await Geolocator.requestPermission();
//       }
//       if (perm == LocationPermission.denied ||
//           perm == LocationPermission.deniedForever) {
//         if (mounted) setState(() => _gpsLoading = false);
//         return; // silently stay on default
//       }

//       // Coarse accuracy is enough to know the country (and saves battery)
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.low,
//         timeLimit: const Duration(seconds: 12),
//       );

//       final marks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );

//       if (marks.isNotEmpty && mounted) {
//         final iso = marks.first.isoCountryCode?.toUpperCase();
//         if (iso != null && iso.isNotEmpty) {
//           final match = _kCountries
//               .where((c) => c.$2 == iso)
//               .firstOrNull;
//           if (match != null) {
//             setState(() {
//               _countryCode = match.$2;
//               _gpsDetected = true;
//             });
//             // Cache for 24h
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.setString(_kGpsCountryKey, match.$2);
//             await prefs.setInt(
//               _kGpsTsKey,
//               DateTime.now().millisecondsSinceEpoch,
//             );
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('[ProfileSetup] GPS failed: $e');
//     } finally {
//       if (mounted) setState(() => _gpsLoading = false);
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Photo picker
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _pickPhoto() async {
//     final XFile? picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//       maxWidth: 600,
//     );
//     if (picked == null || !mounted) return;
//     setState(() => _photoFile = File(picked.path));
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // DOB picker — hard-capped at 18+ (lastDate = today − 18 years)
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _pickDob() async {
//     final c = AppColors.of(context);
//     final initial =
//         _dob ??
//         DateTime(_maxDob.year - 2, _maxDob.month, _maxDob.day);
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(1940),
//       lastDate: _maxDob, // enforces 18+ at the calendar UI level
//       helpText: 'Date of Birth  (18+ only)',
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: Theme.of(ctx).colorScheme.copyWith(
//             primary: c.pink,
//             onSurface: c.textPrimary,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null && mounted) {
//       setState(() {
//         _dob = picked;
//         _dobMissing = false;
//       });
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Submit
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _submit() async {
//     _nameFocus.unfocus();

//     // DOB is required
//     if (_dob == null) {
//       setState(() {
//         _dobMissing = true;
//         _error = 'Please select your date of birth.';
//       });
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _error = null;
//       _dobMissing = false;
//     });

//     // ── Optional photo upload ────────────────────────────────────────────
//     String? photoUrl;
//     if (_photoFile != null) {
//       setState(() => _uploadingPhoto = true);
//       try {
//         final uid =
//             FirebaseAuth.instance.currentUser?.uid ?? 'tmp';
//         final ref = FirebaseStorage.instance.ref().child(
//           'profile_photos/$uid.jpg',
//         );
//         await ref.putFile(_photoFile!);
//         photoUrl = await ref.getDownloadURL();
//       } catch (e) {
//         debugPrint(
//           '[ProfileSetup] Photo upload failed (non-fatal): $e',
//         );
//       } finally {
//         if (mounted) setState(() => _uploadingPhoto = false);
//       }
//     }

//     // ── Resolve display name ─────────────────────────────────────────────
//     final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
//     final suffix = uid.length >= 9 ? uid.substring(0, 9) : uid;
//     final typed = _nameCtrl.text.trim();
//     final displayName = typed.isEmpty ? 'user$suffix' : typed;

//     // ── Register ─────────────────────────────────────────────────────────
//     final user = await ref
//         .read(currentUserProvider.notifier)
//         .register(
//           displayName: displayName,
//           countryCode: _countryCode,
//           language: _language,
//           gender: _gender.toLowerCase(),
//           dateOfBirth: _dob,
//           profilePhotoUrl: photoUrl,
//         );

//     if (!mounted) return;
//     setState(() => _loading = false);

//     if (user == null) {
//       setState(
//         () => _error = 'Something went wrong. Please try again.',
//       );
//     }
//     // On success AuthGate auto-navigates — no push needed.
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Build
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final c = AppColors.of(context);
//     final isDark =
//         Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.of(context).size;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: isDark
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: c.bg,
//         resizeToAvoidBottomInset: true,
//         body: Stack(
//           children: [
//             _SetupBackground(c: c, isDark: isDark, size: size),
//             SafeArea(
//               child: FadeTransition(
//                 opacity: _fadeAnim,
//                 child: SlideTransition(
//                   position: _slideAnim,
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.fromLTRB(
//                       28,
//                       0,
//                       28,
//                       48,
//                     ),
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 36),

//                         // ── Header ─────────────────────────────────────
//                         Center(
//                           child: Text(
//                             'Set Up Profile',
//                             style: GoogleFonts.poppins(
//                               color: c.textPrimary,
//                               fontSize: 26,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: -0.5,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Center(
//                           child: Text(
//                             'Tell us a bit about yourself',
//                             style: GoogleFonts.poppins(
//                               color: c.textSecondary,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),

//                         // ── Profile photo ──────────────────────────────
//                         Center(
//                           child: _PhotoPicker(
//                             c: c,
//                             photoFile: _photoFile,
//                             onTap: _pickPhoto,
//                           ),
//                         ),
//                         const SizedBox(height: 36),

//                         // ── Display name (optional) ────────────────────
//                         _Label(
//                           label: 'Display Name',
//                           c: c,
//                           optional: true,
//                         ),
//                         const SizedBox(height: 8),
//                         _InputField(
//                           controller: _nameCtrl,
//                           focusNode: _nameFocus,
//                           c: c,
//                           isDark: isDark,
//                           hint: 'Your display name',
//                           maxLength: 30,
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           'Optional — clear to keep the default.',
//                           style: GoogleFonts.poppins(
//                             color: c.textSecondary,
//                             fontSize: 11,
//                           ),
//                         ),
//                         const SizedBox(height: 28),

//                         // ── Gender (Male / Female only) ────────────────
//                         _Label(label: 'I am a…', c: c),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: _kGenders.map((g) {
//                             return Expanded(
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                   right: g != _kGenders.last
//                                       ? 12
//                                       : 0,
//                                 ),
//                                 child: _GenderChip(
//                                   label: g,
//                                   selected: _gender == g,
//                                   c: c,
//                                   isDark: isDark,
//                                   onTap: () => setState(
//                                     () => _gender = g,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                         const SizedBox(height: 28),

//                         // ── Date of birth (required, 18+) ──────────────
//                         _Label(label: 'Date of Birth', c: c),
//                         const SizedBox(height: 8),
//                         _TapField(
//                           value: _dob != null
//                               ? '${_dob!.day.toString().padLeft(2, '0')} / '
//                                     '${_dob!.month.toString().padLeft(2, '0')} / '
//                                     '${_dob!.year}'
//                               : null,
//                           hint: 'Tap to select  (18+ only)',
//                           icon: Icons.cake_outlined,
//                           c: c,
//                           isDark: isDark,
//                           hasError: _dobMissing,
//                           onTap: _pickDob,
//                           trailing: _dob != null
//                               ? GestureDetector(
//                                   onTap: () => setState(() {
//                                     _dob = null;
//                                     _dobMissing = false;
//                                   }),
//                                   child: Icon(
//                                     Icons.close_rounded,
//                                     size: 16,
//                                     color: c.textSecondary,
//                                   ),
//                                 )
//                               : null,
//                         ),
//                         const SizedBox(height: 28),

//                         // ── Language ───────────────────────────────────
//                         _Label(label: 'Language', c: c),
//                         const SizedBox(height: 8),
//                         _DropdownField<String>(
//                           value: _language,
//                           c: c,
//                           isDark: isDark,
//                           items: _kLanguages
//                               .map(
//                                 (l) => DropdownMenuItem(
//                                   value: l,
//                                   child: Text(
//                                     l,
//                                     style: GoogleFonts.poppins(
//                                       color: c.textPrimary,
//                                       fontSize: 14,
//                                       fontWeight:
//                                           FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                               .toList(),
//                           onChanged: (v) {
//                             if (v != null)
//                               setState(() => _language = v);
//                           },
//                         ),

//                         // ── Error ──────────────────────────────────────
//                         if (_error != null) ...[
//                           const SizedBox(height: 20),
//                           _ErrorBanner(message: _error!, c: c),
//                         ],

//                         const SizedBox(height: 36),

//                         // ── CTA ────────────────────────────────────────
//                         _SubmitButton(
//                           c: c,
//                           loading: _loading || _uploadingPhoto,
//                           label: _uploadingPhoto
//                               ? 'Uploading photo…'
//                               : _loading
//                               ? 'Setting up…'
//                               : 'Get Started',
//                           onTap: (_loading || _uploadingPhoto)
//                               ? null
//                               : _submit,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Photo picker widget
// // ─────────────────────────────────────────────────────────────────────────────

// class _PhotoPicker extends StatelessWidget {
//   const _PhotoPicker({
//     required this.c,
//     required this.photoFile,
//     required this.onTap,
//   });
//   final AppColors c;
//   final File? photoFile;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Avatar circle
//           Container(
//             width: 104,
//             height: 104,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: c.avatarFallback,
//               border: Border.all(
//                 color: photoFile != null ? c.pink : c.border,
//                 width: 2.5,
//               ),
//               image: photoFile != null
//                   ? DecorationImage(
//                       image: FileImage(photoFile!),
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//             ),
//             child: photoFile == null
//                 ? Icon(
//                     Icons.person_rounded,
//                     size: 56,
//                     color: c.avatarIcon,
//                   )
//                 : null,
//           ),

//           // Camera badge
//           Positioned(
//             bottom: 2,
//             right: 2,
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: c.pink,
//                 border: Border.all(color: c.bg, width: 2.5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: c.pink.withOpacity(0.45),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.camera_alt_rounded,
//                 color: Colors.white,
//                 size: 15,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // GPS loading tile
// // ─────────────────────────────────────────────────────────────────────────────

// class _GpsLoadingTile extends StatelessWidget {
//   const _GpsLoadingTile({required this.c});
//   final AppColors c;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 18,
//         vertical: 16,
//       ),
//       decoration: BoxDecoration(
//         color: c.card,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: c.border),
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 16,
//             height: 16,
//             child: CircularProgressIndicator(
//               color: c.pink,
//               strokeWidth: 2,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             'Detecting your location…',
//             style: GoogleFonts.poppins(
//               color: c.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Background
// // ─────────────────────────────────────────────────────────────────────────────

// class _SetupBackground extends StatelessWidget {
//   const _SetupBackground({
//     required this.c,
//     required this.isDark,
//     required this.size,
//   });
//   final AppColors c;
//   final bool isDark;
//   final Size size;

//   @override
//   Widget build(BuildContext context) {
//     const amber = Color(0xFFFF9500);
//     return Stack(
//       children: [
//         Container(color: c.bg),
//         Positioned(
//           top: -70,
//           left: -70,
//           child: Container(
//             width: size.width * 0.60,
//             height: size.width * 0.60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: c.pink.withOpacity(isDark ? 0.07 : 0.09),
//             ),
//           ),
//         ),
//         Positioned(
//           top: size.height * 0.10,
//           right: -60,
//           child: Container(
//             width: size.width * 0.45,
//             height: size.width * 0.45,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: amber.withOpacity(isDark ? 0.05 : 0.07),
//             ),
//           ),
//         ),
//         Positioned(
//           top: size.height * 0.48,
//           right: size.width * 0.08,
//           child: Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: c.pink.withOpacity(isDark ? 0.12 : 0.16),
//                 width: 1.5,
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           top: size.height * 0.72,
//           left: size.width * 0.08,
//           child: Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: amber.withOpacity(isDark ? 0.22 : 0.28),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Sub-widgets
// // ─────────────────────────────────────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   const _Label({
//     required this.label,
//     required this.c,
//     this.optional = false,
//   });
//   final String label;
//   final AppColors c;
//   final bool optional;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             color: c.textPrimary,
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         if (!optional) ...[
//           const SizedBox(width: 3),
//           Text(
//             '*',
//             style: GoogleFonts.poppins(
//               color: c.pink,
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ] else ...[
//           const SizedBox(width: 6),
//           Text(
//             'optional',
//             style: GoogleFonts.poppins(
//               color: c.textSecondary,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

// class _InputField extends StatelessWidget {
//   const _InputField({
//     required this.controller,
//     required this.focusNode,
//     required this.c,
//     required this.isDark,
//     required this.hint,
//     this.maxLength,
//   });
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final AppColors c;
//   final bool isDark;
//   final String hint;
//   final int? maxLength;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       focusNode: focusNode,
//       maxLength: maxLength,
//       style: GoogleFonts.poppins(
//         color: c.textPrimary,
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: GoogleFonts.poppins(
//           color: c.textSecondary,
//           fontSize: 14,
//         ),
//         counterText: '',
//         filled: true,
//         fillColor: isDark
//             ? Colors.white.withOpacity(0.06)
//             : Colors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 18,
//           vertical: 16,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide(
//             color: isDark
//                 ? Colors.white.withOpacity(0.10)
//                 : c.pink.withOpacity(0.18),
//             width: 1.5,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide(color: c.pink, width: 1.5),
//         ),
//       ),
//     );
//   }
// }

// class _TapField extends StatelessWidget {
//   const _TapField({
//     required this.hint,
//     required this.icon,
//     required this.c,
//     required this.isDark,
//     required this.onTap,
//     this.value,
//     this.trailing,
//     this.hasError = false,
//   });
//   final String hint;
//   final IconData icon;
//   final AppColors c;
//   final bool isDark;
//   final VoidCallback onTap;
//   final String? value;
//   final Widget? trailing;
//   final bool hasError;

//   @override
//   Widget build(BuildContext context) {
//     final borderColor = hasError
//         ? Colors.redAccent
//         : (isDark
//               ? Colors.white.withOpacity(0.10)
//               : c.pink.withOpacity(0.18));
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 18,
//           vertical: 16,
//         ),
//         decoration: BoxDecoration(
//           color: isDark
//               ? Colors.white.withOpacity(0.06)
//               : Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: borderColor, width: 1.5),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: hasError
//                   ? Colors.redAccent
//                   : c.textSecondary,
//               size: 18,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 value ?? hint,
//                 style: GoogleFonts.poppins(
//                   color: value != null
//                       ? c.textPrimary
//                       : (hasError
//                             ? Colors.redAccent
//                             : c.textSecondary),
//                   fontSize: value != null ? 15 : 14,
//                   fontWeight: value != null
//                       ? FontWeight.w500
//                       : FontWeight.w400,
//                 ),
//               ),
//             ),
//             trailing ??
//                 Icon(
//                   Icons.keyboard_arrow_down_rounded,
//                   color: c.textSecondary,
//                   size: 18,
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DropdownField<T> extends StatelessWidget {
//   const _DropdownField({
//     required this.value,
//     required this.c,
//     required this.isDark,
//     required this.items,
//     required this.onChanged,
//   });
//   final T value;
//   final AppColors c;
//   final bool isDark;
//   final List<DropdownMenuItem<T>> items;
//   final ValueChanged<T?> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: isDark
//             ? Colors.white.withOpacity(0.06)
//             : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isDark
//               ? Colors.white.withOpacity(0.10)
//               : c.pink.withOpacity(0.18),
//           width: 1.5,
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<T>(
//           value: value,
//           items: items,
//           onChanged: onChanged,
//           isExpanded: true,
//           dropdownColor: isDark ? c.card : Colors.white,
//           icon: Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: c.textSecondary,
//             size: 20,
//           ),
//           style: GoogleFonts.poppins(
//             color: c.textPrimary,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _GenderChip extends StatelessWidget {
//   const _GenderChip({
//     required this.label,
//     required this.selected,
//     required this.c,
//     required this.isDark,
//     required this.onTap,
//   });
//   final String label;
//   final bool selected;
//   final AppColors c;
//   final bool isDark;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final icon = label == 'Male' ? '♂' : '♀';
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         height: 54,
//         decoration: BoxDecoration(
//           gradient: selected
//               ? LinearGradient(
//                   colors: [
//                     c.pink,
//                     Color.lerp(
//                       c.pink,
//                       const Color(0xFF7B0050),
//                       0.45,
//                     )!,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : null,
//           color: selected
//               ? null
//               : (isDark
//                     ? Colors.white.withOpacity(0.06)
//                     : Colors.white),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: selected
//                 ? Colors.transparent
//                 : (isDark
//                       ? Colors.white.withOpacity(0.10)
//                       : c.pink.withOpacity(0.18)),
//             width: 1.5,
//           ),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: c.pink.withOpacity(0.35),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Center(
//           child: Text(
//             '$icon  $label',
//             style: GoogleFonts.poppins(
//               color: selected ? Colors.white : c.textSecondary,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SubmitButton extends StatelessWidget {
//   const _SubmitButton({
//     required this.c,
//     required this.loading,
//     required this.label,
//     required this.onTap,
//   });
//   final AppColors c;
//   final bool loading;
//   final String label;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final disabled = onTap == null;
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           gradient: disabled
//               ? null
//               : LinearGradient(
//                   colors: [
//                     c.pink,
//                     Color.lerp(
//                       c.pink,
//                       const Color(0xFF7B0050),
//                       0.45,
//                     )!,
//                   ],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//           color: disabled ? c.border : null,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: disabled
//               ? []
//               : [
//                   BoxShadow(
//                     color: c.pink.withOpacity(0.40),
//                     blurRadius: 18,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//         ),
//         child: ElevatedButton(
//           onPressed: onTap,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//           child: loading
//               ? const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2.5,
//                   ),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       '🚀',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       label,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

// class _ErrorBanner extends StatelessWidget {
//   const _ErrorBanner({required this.message, required this.c});
//   final String message;
//   final AppColors c;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 10,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.redAccent.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.redAccent.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.error_outline_rounded,
//             color: Colors.redAccent,
//             size: 16,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               message,
//               style: GoogleFonts.poppins(
//                 color: Colors.redAccent,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cheerchat/providers/user_provider.dart';
import 'package:cheerchat/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

// Other removed per spec
const _kGenders = ['Male', 'Female'];

const _kCountries = [
  ('🇮🇳', 'IN', 'India'),
  ('🇵🇰', 'PK', 'Pakistan'),
  ('🇧🇩', 'BD', 'Bangladesh'),
  ('🇳🇵', 'NP', 'Nepal'),
  ('🇦🇪', 'AE', 'UAE'),
  ('🇸🇦', 'SA', 'Saudi Arabia'),
  ('🇺🇸', 'US', 'United States'),
  ('🇬🇧', 'GB', 'United Kingdom'),
  ('🇨🇦', 'CA', 'Canada'),
  ('🇦🇺', 'AU', 'Australia'),
  ('🇸🇬', 'SG', 'Singapore'),
  ('🇩🇪', 'DE', 'Germany'),
  ('🇫🇷', 'FR', 'France'),
  ('🇧🇷', 'BR', 'Brazil'),
  ('🇵🇭', 'PH', 'Philippines'),
  ('🇮🇩', 'ID', 'Indonesia'),
  ('🇲🇾', 'MY', 'Malaysia'),
  ('🇹🇷', 'TR', 'Turkey'),
  ('🇲🇦', 'MA', 'Morocco'),
  ('🇪🇬', 'EG', 'Egypt'),
  ('🇻🇳', 'VN', 'Vietnam'),
  ('🇱🇰', 'LK', 'Sri Lanka'),
  ('🇰🇪', 'KE', 'Kenya'),
  ('🇿🇦', 'ZA', 'South Africa'),
  ('🇲🇽', 'MX', 'Mexico'),
  ('🇦🇷', 'AR', 'Argentina'),
  ('🇺🇦', 'UA', 'Ukraine'),
  ('🇷🇺', 'RU', 'Russia'),
  ('🇯🇵', 'JP', 'Japan'),
  ('🇰🇷', 'KR', 'South Korea'),
];

const _kLanguages = [
  'English',
  'Hindi',
  'Telugu',
  'Tamil',
  'Malayalam',
  'Kannada',
  'Bengali',
  'Urdu',
  'Arabic',
  'Spanish',
  'Portuguese',
  'German',
  'French',
  'Bahasa Indonesia',
  'Malay',
  'Nepali',
  'Filipino',
  'Turkish',
  'Ukrainian',
  'Vietnamese',
  'Japanese',
  'Korean',
  'Sinhala',
];

// SharedPreferences keys for GPS country cache
const _kGpsCountryKey = 'cheerchat_gps_country';
const _kGpsTsKey = 'cheerchat_gps_country_ts';
const _k24h = 86400000; // ms

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();

  // ── Form state ────────────────────────────────────────────────────────────
  String _gender = 'Male';
  String _countryCode = 'IN';
  String _language = 'English';
  DateTime? _dob;
  bool _dobMissing =
      false; // shows red border when user tries to submit without DOB

  // ── Photo ─────────────────────────────────────────────────────────────────
  File? _photoFile;
  bool _uploadingPhoto = false;

  // ── Location ──────────────────────────────────────────────────────────────
  bool _gpsLoading = false;
  bool _gpsDetected = false;

  // ── Submit ────────────────────────────────────────────────────────────────
  bool _loading = false;
  String? _error;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── 18+ constraint: lastDate for the calendar ────────────────────────────
  DateTime get _maxDob {
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Default display name = "user" + first 9 chars of Firebase UID
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final suffix = uid.length >= 9 ? uid.substring(0, 9) : uid;
    _nameCtrl.text = 'user$suffix';

    // Entrance animation
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim =
        Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _fadeCtrl,
            curve: Curves.easeOut,
          ),
        );
    _fadeCtrl.forward();

    // Auto-detect country
    _detectCountry();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GPS country detection
  // ─────────────────────────────────────────────────────────────────────────
  //
  // 1. Check SharedPreferences — if < 24h old, use cached value instantly.
  // 2. Otherwise request permission → get coarse position → reverse-geocode
  //    → extract ISO code → match _kCountries.
  // 3. Save result + timestamp to cache.
  // 4. Any failure → silent fallback; the manual dropdown is always editable.

  Future<void> _detectCountry() async {
    // ── Try cached value first ────────────────────────────────────────────
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_kGpsCountryKey);
      final ts = prefs.getInt(_kGpsTsKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (cached != null && age < _k24h) {
        final match = _kCountries
            .where((c) => c.$2 == cached)
            .firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _countryCode = match.$2;
            _gpsDetected = true;
          });
          return;
        }
      }
    } catch (_) {}

    // ── Live GPS ──────────────────────────────────────────────────────────
    if (!mounted) return;
    setState(() => _gpsLoading = true);

    try {
      // Check / request permission
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _gpsLoading = false);
        return; // silently stay on default
      }

      // Coarse accuracy is enough to know the country (and saves battery)
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 12),
      );

      final marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (marks.isNotEmpty && mounted) {
        final iso = marks.first.isoCountryCode?.toUpperCase();
        if (iso != null && iso.isNotEmpty) {
          final match = _kCountries
              .where((c) => c.$2 == iso)
              .firstOrNull;
          if (match != null) {
            setState(() {
              _countryCode = match.$2;
              _gpsDetected = true;
            });
            // Cache for 24h
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_kGpsCountryKey, match.$2);
            await prefs.setInt(
              _kGpsTsKey,
              DateTime.now().millisecondsSinceEpoch,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[ProfileSetup] GPS failed: $e');
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Photo picker
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 600,
    );
    if (picked == null || !mounted) return;
    setState(() => _photoFile = File(picked.path));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOB picker — hard-capped at 18+ (lastDate = today − 18 years)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickDob() async {
    final c = AppColors.of(context);
    final initial =
        _dob ??
        DateTime(_maxDob.year - 2, _maxDob.month, _maxDob.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: _maxDob, // enforces 18+ at the calendar UI level
      helpText: 'Date of Birth  (18+ only)',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: c.pink,
            onSurface: c.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _dob = picked;
        _dobMissing = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Submit
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    _nameFocus.unfocus();

    // DOB is required
    if (_dob == null) {
      setState(() {
        _dobMissing = true;
        _error = 'Please select your date of birth.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _dobMissing = false;
    });

    // ── Optional photo upload ────────────────────────────────────────────
    String? photoUrl;
    if (_photoFile != null) {
      setState(() => _uploadingPhoto = true);
      try {
        final uid =
            FirebaseAuth.instance.currentUser?.uid ?? 'tmp';
        final ref = FirebaseStorage.instance.ref().child(
          'profile_photos/$uid.jpg',
        );
        await ref.putFile(_photoFile!);
        photoUrl = await ref.getDownloadURL();
      } catch (e) {
        debugPrint(
          '[ProfileSetup] Photo upload failed (non-fatal): $e',
        );
      } finally {
        if (mounted) setState(() => _uploadingPhoto = false);
      }
    }

    // ── Resolve display name ─────────────────────────────────────────────
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final suffix = uid.length >= 9 ? uid.substring(0, 9) : uid;
    final typed = _nameCtrl.text.trim();
    final displayName = typed.isEmpty ? 'user$suffix' : typed;

    // ── Register ─────────────────────────────────────────────────────────
    final user = await ref
        .read(currentUserProvider.notifier)
        .register(
          displayName: displayName,
          countryCode: _countryCode,
          language: _language,
          gender: _gender.toLowerCase(),
          dateOfBirth: _dob,
          profilePhotoUrl: photoUrl,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null) {
      setState(
        () => _error = 'Something went wrong. Please try again.',
      );
    }
    // On success AuthGate auto-navigates — no push needed.
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

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
            _SetupBackground(c: c, isDark: isDark, size: size),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      0,
                      28,
                      48,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 36),

                        // ── Header ─────────────────────────────────────
                        Center(
                          child: Text(
                            'Set Up Profile',
                            style: GoogleFonts.poppins(
                              color: c.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Tell us a bit about yourself',
                            style: GoogleFonts.poppins(
                              color: c.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Profile photo ──────────────────────────────
                        Center(
                          child: _PhotoPicker(
                            c: c,
                            photoFile: _photoFile,
                            onTap: _pickPhoto,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Display name (optional) ────────────────────
                        _Label(
                          label: 'Display Name',
                          c: c,
                          optional: true,
                        ),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          c: c,
                          isDark: isDark,
                          hint: 'Your display name',
                          maxLength: 30,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Optional — clear to keep the default.',
                          style: GoogleFonts.poppins(
                            color: c.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Gender (Male / Female only) ────────────────
                        _Label(label: 'I am a…', c: c),
                        const SizedBox(height: 10),
                        Row(
                          children: _kGenders.map((g) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: g != _kGenders.last
                                      ? 12
                                      : 0,
                                ),
                                child: _GenderChip(
                                  label: g,
                                  selected: _gender == g,
                                  c: c,
                                  isDark: isDark,
                                  onTap: () => setState(
                                    () => _gender = g,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),

                        // ── Date of birth (required, 18+) ──────────────
                        _Label(label: 'Date of Birth', c: c),
                        const SizedBox(height: 8),
                        _TapField(
                          value: _dob != null
                              ? '${_dob!.day.toString().padLeft(2, '0')} / '
                                    '${_dob!.month.toString().padLeft(2, '0')} / '
                                    '${_dob!.year}'
                              : null,
                          hint: 'Tap to select  (18+ only)',
                          icon: Icons.cake_outlined,
                          c: c,
                          isDark: isDark,
                          hasError: _dobMissing,
                          onTap: _pickDob,
                          trailing: _dob != null
                              ? GestureDetector(
                                  onTap: () => setState(() {
                                    _dob = null;
                                    _dobMissing = false;
                                  }),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: c.textSecondary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 28),

                        // ── Language ───────────────────────────────────
                        _Label(label: 'Language', c: c),
                        const SizedBox(height: 8),
                        _DropdownField<String>(
                          value: _language,
                          c: c,
                          isDark: isDark,
                          items: _kLanguages
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(
                                    l,
                                    style: GoogleFonts.poppins(
                                      color: c.textPrimary,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              setState(() => _language = v);
                          },
                        ),

                        // ── Error ──────────────────────────────────────
                        if (_error != null) ...[
                          const SizedBox(height: 20),
                          _ErrorBanner(message: _error!, c: c),
                        ],

                        const SizedBox(height: 36),

                        // ── CTA ────────────────────────────────────────
                        _SubmitButton(
                          c: c,
                          loading: _loading || _uploadingPhoto,
                          label: _uploadingPhoto
                              ? 'Uploading photo…'
                              : _loading
                              ? 'Setting up…'
                              : 'Get Started',
                          onTap: (_loading || _uploadingPhoto)
                              ? null
                              : _submit,
                        ),
                      ],
                    ),
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
// Photo picker widget
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.c,
    required this.photoFile,
    required this.onTap,
  });
  final AppColors c;
  final File? photoFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.avatarFallback,
              border: Border.all(
                color: photoFile != null ? c.pink : c.border,
                width: 2.5,
              ),
              image: photoFile != null
                  ? DecorationImage(
                      image: FileImage(photoFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoFile == null
                ? Icon(
                    Icons.person_rounded,
                    size: 56,
                    color: c.avatarIcon,
                  )
                : null,
          ),

          // Camera badge
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.pink,
                border: Border.all(color: c.bg, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: c.pink.withOpacity(0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS loading tile
// ─────────────────────────────────────────────────────────────────────────────

class _GpsLoadingTile extends StatelessWidget {
  const _GpsLoadingTile({required this.c});
  final AppColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: c.pink,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Detecting your location…',
            style: GoogleFonts.poppins(
              color: c.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background
// ─────────────────────────────────────────────────────────────────────────────

class _SetupBackground extends StatelessWidget {
  const _SetupBackground({
    required this.c,
    required this.isDark,
    required this.size,
  });
  final AppColors c;
  final bool isDark;
  final Size size;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFF9500);
    return Stack(
      children: [
        Container(color: c.bg),
        Positioned(
          top: -70,
          left: -70,
          child: Container(
            width: size.width * 0.60,
            height: size.width * 0.60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.pink.withOpacity(isDark ? 0.07 : 0.09),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.10,
          right: -60,
          child: Container(
            width: size.width * 0.45,
            height: size.width * 0.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amber.withOpacity(isDark ? 0.05 : 0.07),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.48,
          right: size.width * 0.08,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: c.pink.withOpacity(isDark ? 0.12 : 0.16),
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.72,
          left: size.width * 0.08,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amber.withOpacity(isDark ? 0.22 : 0.28),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label({
    required this.label,
    required this.c,
    this.optional = false,
  });
  final String label;
  final AppColors c;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!optional) ...[
          const SizedBox(width: 3),
          Text(
            '*',
            style: GoogleFonts.poppins(
              color: c.pink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ] else ...[
          const SizedBox(width: 6),
          Text(
            'optional',
            style: GoogleFonts.poppins(
              color: c.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.c,
    required this.isDark,
    required this.hint,
    this.maxLength,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppColors c;
  final bool isDark;
  final String hint;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLength: maxLength,
      style: GoogleFonts.poppins(
        color: c.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: c.textSecondary,
          fontSize: 14,
        ),
        counterText: '',
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.10)
                : c.pink.withOpacity(0.18),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.pink, width: 1.5),
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.hint,
    required this.icon,
    required this.c,
    required this.isDark,
    required this.onTap,
    this.value,
    this.trailing,
    this.hasError = false,
  });
  final String hint;
  final IconData icon;
  final AppColors c;
  final bool isDark;
  final VoidCallback onTap;
  final String? value;
  final Widget? trailing;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? Colors.redAccent
        : (isDark
              ? Colors.white.withOpacity(0.10)
              : c.pink.withOpacity(0.18));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasError
                  ? Colors.redAccent
                  : c.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: GoogleFonts.poppins(
                  color: value != null
                      ? c.textPrimary
                      : (hasError
                            ? Colors.redAccent
                            : c.textSecondary),
                  fontSize: value != null ? 15 : 14,
                  fontWeight: value != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
            trailing ??
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
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.c,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });
  final T value;
  final AppColors c;
  final bool isDark;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.10)
              : c.pink.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: isDark ? c.card : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: c.textSecondary,
            size: 20,
          ),
          style: GoogleFonts.poppins(
            color: c.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.c,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final AppColors c;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = label == 'Male' ? '♂' : '♀';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    c.pink,
                    Color.lerp(
                      c.pink,
                      const Color(0xFF7B0050),
                      0.45,
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected
              ? null
              : (isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark
                      ? Colors.white.withOpacity(0.10)
                      : c.pink.withOpacity(0.18)),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: c.pink.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '$icon  $label',
            style: GoogleFonts.poppins(
              color: selected ? Colors.white : c.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.c,
    required this.loading,
    required this.label,
    required this.onTap,
  });
  final AppColors c;
  final bool loading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
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
                    blurRadius: 18,
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
                    const Text(
                      '🚀',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
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

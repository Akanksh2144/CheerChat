// user_signup_details_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml: intl: ^0.18.1
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:http/http.dart'
    as http; // Assuming you post to your API
import 'dart:convert';

class UserSignupDetailsPage extends StatefulWidget {
  // Pass the newly created user_id from the users table after signup
  final String userId;

  const UserSignupDetailsPage({Key? key, required this.userId})
    : super(key: key);

  @override
  _UserSignupDetailsPageState createState() =>
      _UserSignupDetailsPageState();
}

class _UserSignupDetailsPageState
    extends State<UserSignupDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Requirement: Name prompt (mandatory)
  // Requirement: Default from Firebase Auth, trimmed to 10 chars
  final TextEditingController _nameController =
      TextEditingController();

  // Requirement: Date of Birth prompt (necessary/mandatory)
  DateTime? _selectedDate;
  final TextEditingController _dobController =
      TextEditingController(); // To display the formatted date

  // Requirement: Bio prompt (optional)
  final TextEditingController _bioController =
      TextEditingController();

  // Requirement: Profile photo (default: generic default image)
  // Initially null/generic; user has option to edit. We track the URL.
  String? _profilePhotoUrl;

  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultFields();
  }

  void _initializeDefaultFields() {
    // 1. Requirement: Pre-populate Name from FirebaseAuth display name, trimmed to 10 chars
    try {
      final user =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null) {
        String authName = user.displayName!.trim();
        _nameController.text = authName.length > 10
            ? authName.substring(0, 10)
            : authName;
      }
    } catch (e) {
      print(
        "Warning: FirebaseAuth initialization error or user not signed in for defaults: $e",
      );
    }

    // 2. Requirement: Set default profile photo
    // Replace with the actual generic default image URL on your server
    _profilePhotoUrl =
        "https://yourserver.com/images/default_avatar.png";
  }

  // Helper function to show the date picker for mandatory DOB field
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // Default view: 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // DOB must be in the past
      helpText: "SELECT DATE OF BIRTH (REQUIRED)",
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked); // Correct format for PG 'date' type
      });
    }
  }

  // Placeholder for image upload logic
  Future<void> _uploadProfilePhoto() async {
    setState(() => _isUploadingImage = true);
    // YOUR LOGIC: Open image picker, upload to storage (Firebase/S3), get URL
    // String? uploadedUrl = await imageStorageService.upload();
    String? uploadedUrl = null; // Faking failure for now

    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate upload time

    if (uploadedUrl != null) {
      setState(() {
        _profilePhotoUrl = uploadedUrl;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to upload image. Using default.",
          ),
        ),
      );
    }
    setState(() => _isUploadingImage = false);
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Preparing the payload according to your user_profiles schema
      final Map<String, dynamic> profileData = {
        "user_id": widget.userId, // Required linking key
        "display_name": _nameController.text
            .trim(), //varchar(50)
        "date_of_birth": _dobController.text, // date
        "bio": _bioController.text.isNotEmpty
            ? _bioController.text.trim()
            : null, // text
        "profile_photo_url": _profilePhotoUrl, // text
      };

      try {
        // Implementation logic to hit your Digital Ocean backend API
        final response = await http.post(
          Uri.parse(
            'https://your-api.digitalocean.app/api/profiles',
          ), // Your actual endpoint
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(profileData),
        );

        if (response.statusCode == 200 ||
            response.statusCode == 201) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Handle specific API error responses
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Profile creation failed: ${responseBody['message'] ?? response.body}",
              ),
            ),
          );
        }
      } catch (e) {
        print("API Submit failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "An error occurred during profile setup: $e",
            ),
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Your Profile"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // 1. Profile Photo Widget
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profilePhotoUrl != null
                          ? NetworkImage(_profilePhotoUrl!)
                          : null,
                      child:
                          (_profilePhotoUrl == null &&
                              !_isUploadingImage)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: _isUploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : InkWell(
                                onTap: _uploadProfilePhoto,
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Welcome! Please complete your information to proceed.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 2. Display Name Input (Mandatory, max 50 from schema)
              const Text(
                "Display Name *",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                maxLength:
                    50, // character varying(50) constraint from schema
                decoration: const InputDecoration(
                  hintText: "Enter your name or use default",
                ),
                validator: (value) => value!.trim().isEmpty
                    ? "Display name is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. Date of Birth Input (Mandatory, necessary)
              const Text(
                "Date of Birth *",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dobController,
                readOnly:
                    true, // Prevents manual typing, forcing date picker use
                onTap: () => _selectDateOfBirth(context),
                decoration: const InputDecoration(
                  hintText: "Select DOB (YYYY-MM-DD)",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value!.isEmpty
                    ? "Date of Birth is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // 4. Bio Input (Optional)
              const Text(
                "Bio (Optional)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines:
                    4, // Allow multi-line bio as PG 'text' supports it
                maxLength:
                    250, // Example UI constraint, schema 'text' is flexible
                decoration: const InputDecoration(
                  hintText: "Tell us a bit about yourself...",
                ),
              ),

              const Spacer(), // Pushes content down
              const SizedBox(height: 20),

              // 5. Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text("Finish Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

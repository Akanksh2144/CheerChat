// file_name: signup_details_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl' to pubspec.yaml for date formatting

class SignupDetailsForm extends StatefulWidget {
  // Pass the Firebase UID here from your authentication step
  final String firebaseUid;

  const SignupDetailsForm({super.key, required this.firebaseUid});

  @override
  SignupDetailsFormState createState() =>
      SignupDetailsFormState();
}

class SignupDetailsFormState extends State<SignupDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _dobController =
      TextEditingController();
  final TextEditingController _bioController =
      TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  // This would track a locally picked image file path in a real app
  String? _pickedImagePath;

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
        2000,
      ), // A reasonable default starting point
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  void _submitDetails() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 1. Process Display Name: Use input, or fallback to trimmed Firebase UID
      String finalDisplayName = _nameController.text.trim();
      if (finalDisplayName.isEmpty) {
        finalDisplayName = widget.firebaseUid.length > 10
            ? widget.firebaseUid.substring(0, 10)
            : widget.firebaseUid;
      }

      // 2. Process Bio: Send null if empty
      String? finalBio = _bioController.text.trim();
      if (finalBio.isEmpty) finalBio = null;

      // 3. Process Profile Photo: Use uploaded, or fallback to your default
      String finalPhotoUrl =
          _pickedImagePath ??
          "https://yourserver.com/assets/default_avatar.png";

      // 4. The final payload ready for your backend API
      final Map<String, dynamic> signupData = {
        "firebase_uid":
            widget.firebaseUid, // To link auth_identities
        "display_name": finalDisplayName,
        "date_of_birth": _dobController
            .text, // Guaranteed to be filled by the validator
        "bio": finalBio,
        "profile_photo_url": finalPhotoUrl,
      };

      print("Payload ready for backend: $signupData");

      // Simulate API Call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        // Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Signup payload generated successfully!",
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Photo Selector (Basic UI representation)
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Logic to open image picker goes here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Image picker tapped"),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _pickedImagePath != null
                        ? NetworkImage(_pickedImagePath!)
                        : null,
                    child: _pickedImagePath == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Tap to add photo (Optional)",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),

              // Display Name (Optional)
              TextFormField(
                controller: _nameController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: "Display Name (Optional)",
                  hintText: "Leave blank to use default",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth (Mandatory)
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDateOfBirth(context),
                decoration: const InputDecoration(
                  labelText: "Date of Birth *",
                  hintText: "YYYY-MM-DD",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                    ? "Date of Birth is mandatory"
                    : null,
              ),
              const SizedBox(height: 16),

              // Bio (Optional)
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 250,
                decoration: const InputDecoration(
                  labelText: "Bio (Optional)",
                  hintText: "Tell us about yourself...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitDetails,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Complete Signup",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

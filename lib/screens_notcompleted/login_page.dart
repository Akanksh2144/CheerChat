import 'package:flutter/material.dart';
import '../screens/hosts_grid_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _navigate(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HostsGridViewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              _loginButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onTap: () => _navigate(context),
              ),
              _loginButton(
                text: 'Continue with Facebook',
                icon: Icons.facebook,
                onTap: () => _navigate(context),
              ),
              _loginButton(
                text: 'Login with Phone Number',
                icon: Icons.phone,
                onTap: () => _navigate(context),
              ),
              _loginButton(
                text: 'Continue Anonymously',
                icon: Icons.person_outline,
                onTap: () => _navigate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}

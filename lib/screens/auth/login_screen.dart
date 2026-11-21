import 'package:flutter/material.dart';
import '../../routes.dart';

// PLACEHOLDER – Yusuf Arif Özkuttaş will replace this file with the real screen.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Center(
        child: ElevatedButton(
          // Opens the main app so the tabs can be tested before Log In is ready.
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          ),
          child: const Text('Open app'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../routes.dart';

// PLACEHOLDER – Necdet Alp Özdemir will replace this file with the real screen.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyHabits')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          child: const Text('Log in'),
        ),
      ),
    );
  }
}

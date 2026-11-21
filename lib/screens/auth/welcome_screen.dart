import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// First screen after launch. Shows two local images (the illustration and
/// the app logo) and lets the user choose to log in or create an account.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // LayoutBuilder tells us how tall the screen is, so the illustration
        // can take a share of it on both small and large phones.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // Local image bundled in assets/images/.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.42,
                    ),
                    child: Image.asset(
                      'assets/images/welcome.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // App logo, also a local image.
                  Image.asset('assets/images/logo.png', width: 56, height: 56),
                  const SizedBox(height: AppSpacing.md),
                  const Text('MyHabits', style: AppTextStyles.display),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Build small routines.\nCheck them off every day.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: 'Log in',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Create account',
                    variant: ButtonVariant.outlined,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

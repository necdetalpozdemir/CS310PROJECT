import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Log In screen: email + password with inline validation.
///
/// Step 2: a valid form simply opens the main app.
/// Step 3: this is where Firebase Auth `signInWithEmailAndPassword` will go.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Gives us access to the Form, so we can call validate() on all fields.
  final _formKey = GlobalKey<FormState>();

  // Hold what the user typed in each field.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Controllers use memory; free it when the screen is closed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() runs every field's validator. If any returns an error
    // message, the message is shown under that field and we stop here.
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // Open the main app and remove Welcome / Log In from the stack,
    // so the back button can't return to the login form.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The back arrow appears automatically only when there is a screen
      // to go back to (Welcome). After log out there isn't, so no arrow.
      appBar: AppBar(),
      body: SafeArea(
        // Scrolls on small phones / when the keyboard is open (no overflow).
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Welcome back', style: AppTextStyles.heading),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  "Log in to see today's habits.",
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  label: 'Email',
                  hintText: 'name@sabanciuniv.edu',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                ),

                // "Forgot password?" link, right-aligned under the field.
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.forgotPassword,
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                PrimaryButton(label: 'Log in', onPressed: _submit),
                const SizedBox(height: AppSpacing.xl),

                // "Don't have an account? Sign up"
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.signUp),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

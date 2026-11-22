import 'package:flutter/material.dart';

import '../../data/user_session.dart';
import '../../routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Sign Up screen with inline validation.
///
/// Step 2: a valid form stores the name and email locally and opens the app.
/// Step 3: Firebase Auth `createUserWithEmailAndPassword` will go here.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    UserSession.displayName = _nameController.text.trim();
    UserSession.email = _emailController.text.trim();

    // The back button must not return to the sign-up form.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  // Keeps Welcome underneath, and avoids stacking Log In twice
  // when the user came here from the Log In screen.
  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      ModalRoute.withName(AppRoutes.welcome),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create account', style: AppTextStyles.heading),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Display name',
                  hintText: 'Alp',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.notEmpty(value, 'your display name'),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                  hintText: 'At least 6 characters',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Confirm password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmController,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirm,
                ),
                const SizedBox(height: AppSpacing.sm),
                // FormField lets the checkbox show an inline error too.
                FormField<bool>(
                  initialValue: false,
                  validator: (value) => value == true
                      ? null
                      : 'Please agree to the terms to continue',
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: field.value,
                        onChanged: field.didChange,
                        title: const Text(
                          'I agree to the terms',
                          style: AppTextStyles.body,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(label: 'Create account', onPressed: _submit),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text('Log in'),
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

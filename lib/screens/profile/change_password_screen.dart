import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Opened from Profile > Change password. UI only in Step 2;
/// in Step 3 the password is changed with Firebase Auth
/// (re-authenticate + updatePassword).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    final error = Validators.password(value);
    if (error != null) return error;
    if (value == _currentController.text) {
      return 'New password must be different from the current one';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your new password';
    if (value != _newController.text) return 'Passwords do not match';
    return null;
  }

  /// validate() runs every validator and shows the errors under the fields.
  /// Only a valid form shows the confirmation and closes the screen.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              const Text(
                'For your security, enter your current password first.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Current password',
                controller: _currentController,
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'New password',
                hintText: 'At least 6 characters',
                controller: _newController,
                icon: Icons.lock_reset,
                isPassword: true,
                textInputAction: TextInputAction.next,
                validator: _validateNewPassword,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Confirm new password',
                controller: _confirmController,
                icon: Icons.lock_reset,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: _validateConfirm,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(label: 'Update password', onPressed: _submit),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                child: const Text('Forgot your current password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

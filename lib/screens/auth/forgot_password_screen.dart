import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Forgot Password screen (TA feedback).
///
/// One screen with two states:
///  1. a form that asks for the email,
///  2. "Check your email" confirmation after a valid request.
///
/// Step 3: `_sendLink` will call Firebase Auth `sendPasswordResetEmail`.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// false = show the form, true = show the "Check your email" state.
  bool _linkSent = false;

  /// How long the user must wait before asking for another email.
  static const _resendCooldown = Duration(minutes: 1);

  /// Ticks once per second while the cooldown is running.
  Timer? _timer;

  /// Seconds until "Resend email" can be tapped again (0 = allowed now).
  int _secondsLeft = 0;

  @override
  void dispose() {
    _emailController.dispose();
    // A running timer would keep calling setState on a closed screen.
    _timer?.cancel();
    super.dispose();
  }

  void _sendLink() {
    if (!_formKey.currentState!.validate()) return;

    // Switching this flag rebuilds the screen in its second state.
    setState(() => _linkSent = true);
    // The first email was just sent, so the wait starts now.
    _startCooldown();
  }

  void _resend() {
    final messenger = ScaffoldMessenger.of(context);
    // Close the previous message so they don't pile up.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('Reset link sent again to ${_email()}')),
    );
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown.inSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  /// 119 -> "1:59"
  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  String _email() => _emailController.text.trim();

  /// Closes this screen and goes back to where it was opened from
  /// (Log In, or Change Password).
  void _backToLogin() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          // Pick which state to draw.
          child: _linkSent ? _buildSentState() : _buildForm(),
        ),
      ),
    );
  }

  // ---------- State 1: the form ----------
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CircleIcon(
            icon: Icons.key_outlined,
            color: AppColors.primary,
            background: AppColors.primaryLight,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Forgot password?', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            "Enter the email you signed up with and we'll send you "
            'a link to reset your password.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Email',
            hintText: 'name@sabanciuniv.edu',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Send reset link', onPressed: _sendLink),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton.icon(
              onPressed: _backToLogin,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to log in'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- State 2: "Check your email" ----------
  Widget _buildSentState() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const _CircleIcon(
          icon: Icons.mark_email_read_outlined,
          color: AppColors.success,
          background: AppColors.successLight,
          size: 72,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Check your email', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.sm),
        // Text.rich lets one sentence mix normal and bold parts.
        Text.rich(
          TextSpan(
            style: AppTextStyles.caption,
            children: [
              const TextSpan(text: 'We sent a password reset link to\n'),
              TextSpan(
                text: _email(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(
                text: '.\nFollow the link to choose a new password, '
                    'then log in again.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(label: 'Back to log in', onPressed: _backToLogin),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Didn't get it?",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            // null onPressed = disabled while the cooldown is running.
            TextButton(
              onPressed: _secondsLeft > 0 ? null : _resend,
              child: Text(
                _secondsLeft > 0
                    ? 'Resend in ${_formatSeconds(_secondsLeft)}'
                    : 'Resend email',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// An icon inside a soft colored circle (used at the top of both states).
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.color,
    required this.background,
    this.size = 56,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

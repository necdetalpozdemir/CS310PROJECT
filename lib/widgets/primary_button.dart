import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// The three looks a [PrimaryButton] can have (from the Step 2.1 wireframes).
enum ButtonVariant {
  /// Solid blue, e.g. "Log in", "Save habit", "Mark today as done".
  filled,

  /// Blue outline, e.g. "Create account" on Welcome.
  outlined,

  /// Red outline, e.g. "Delete habit", "Log out".
  danger,
}

/// A full-width action button used on every form and detail screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.icon,
  });

  /// The text shown on the button.
  final String label;

  /// Called when the button is tapped.
  /// If this is null, Flutter draws the button greyed out (disabled).
  final VoidCallback? onPressed;

  /// Which look to use. Defaults to [ButtonVariant.filled].
  final ButtonVariant variant;

  /// Optional icon in front of the label, e.g. Icons.check or Icons.logout.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    );
    const textStyle = AppTextStyles.button;

    // The content is the same for every variant: optional icon + label.
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    // A switch expression picks one button type per variant.
    final Widget button = switch (variant) {
      ButtonVariant.filled => FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: shape,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: child,
        ),
      ButtonVariant.outlined => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: shape,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          child: child,
        ),
      ButtonVariant.danger => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: shape,
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          child: child,
        ),
    };

    // SizedBox with infinite width makes the button as wide as its parent.
    // Height 50 matches the button theme in app_theme.dart.
    return SizedBox(width: double.infinity, height: 50, child: button);
  }
}

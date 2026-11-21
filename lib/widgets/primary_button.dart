import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    // The content is the same for every variant: optional icon + label.
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
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
          style: FilledButton.styleFrom(shape: shape),
          child: child,
        ),
      ButtonVariant.outlined => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: shape,
            side: BorderSide(color: scheme.primary),
          ),
          child: child,
        ),
      ButtonVariant.danger => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: shape,
            foregroundColor: scheme.error,
            side: BorderSide(color: scheme.error),
          ),
          child: child,
        ),
    };

    // SizedBox with infinite width makes the button as wide as its parent.
    return SizedBox(width: double.infinity, height: 52, child: button);
  }
}

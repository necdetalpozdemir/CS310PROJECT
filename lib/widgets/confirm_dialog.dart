import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// A yes/no dialog with an icon, a title, a message and Cancel / Confirm.
///
/// Used for "Delete habit?" (My Habits, Habit Detail) and "Log out?" (Profile).
///
/// Usage:
/// ```dart
/// final confirmed = await ConfirmDialog.show(
///   context,
///   title: 'Delete "Gym"?',
///   message: 'This habit and its streak will be removed.',
///   confirmLabel: 'Delete',
///   icon: Icons.delete_outline,
/// );
/// if (confirmed) { ... }
/// ```
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.icon,
    this.isDanger = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Optional icon shown in a soft circle next to the title.
  final IconData? icon;

  /// Red confirm button and icon (delete, log out). False = primary blue.
  final bool isDanger;

  /// Opens the dialog and waits for the answer.
  /// Returns true if the user tapped confirm, false otherwise
  /// (Cancel, tapping outside, or the back button).
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData? icon,
    bool isDanger = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        isDanger: isDanger,
      ),
    );
    // Closing the dialog without a button gives null; treat it as "no".
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final accent = isDanger ? AppColors.danger : AppColors.primary;
    final accentLight = isDanger ? AppColors.dangerLight : AppColors.primaryLight;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(child: Text(title, style: AppTextStyles.title)),
        ],
      ),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        // pop(value) closes the dialog AND sends value back to show().
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: accent),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

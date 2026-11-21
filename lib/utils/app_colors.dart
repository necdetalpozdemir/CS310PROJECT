import 'package:flutter/material.dart';

/// All colors used in the app. Screens never use hard-coded colors directly,
/// so the design stays consistent and easy to change.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3B6FD8);
  static const Color primaryLight = Color(0xFFDFE8FA);

  static const Color success = Color(0xFF2F9E6A);
  static const Color successLight = Color(0xFFB9E2CD);

  static const Color danger = Color(0xFFC94A4A);
  static const Color dangerLight = Color(0xFFF6D5D5);

  static const Color warning = Color(0xFFE08A2E);

  static const Color background = Color(0xFFF6F7F9);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E5EA);

  static const Color textPrimary = Color(0xFF1F2328);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  /// Colors the user can choose for a habit.
  static const List<Color> habitColors = [
    Color(0xFF3B6FD8), // blue
    Color(0xFF2F9E6A), // green
    Color(0xFFE08A2E), // orange
    Color(0xFFD9534F), // red
    Color(0xFF7B5CD6), // purple
    Color(0xFF1E9AA8), // teal
  ];
}

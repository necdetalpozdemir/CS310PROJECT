import 'package:flutter/material.dart';

/// Shared spacing scale and corner radii.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;

  /// Default padding around the content of a screen.
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);

  /// Padding for scrollable screens that have a floating action button,
  /// so the last item is not hidden behind the button.
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(lg, xs, lg, 96);
}

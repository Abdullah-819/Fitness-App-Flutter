import 'package:flutter/material.dart';

/// Central palette of colors used across the Step Counter application.
class AppColors {
  AppColors._();

  /// Vibrant brand purple matching the TrackFit design (#7F27FF)
  static const Color primaryPurple = Color(0xFF7F27FF);

  /// White accents for icons and typography
  static const Color white = Colors.white;

  /// Background dark purple variant
  static const Color darkPurple = Color(0xFF6B1EDB);

  /// Subtle text / faded elements
  static const Color textMuted = Color(0xCCFFFFFF);

  /// Text colors for light screens
  static const Color textPrimary = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF71727A);
  static const Color textLight = Color(0xFF8F9098);

  /// Button / Pill background light purple
  static const Color lightPurpleBg = Color(0xFFF5EEFF);

  /// Inactive dot indicator
  static const Color indicatorInactive = Color(0xFFEDECED);

  /// Input field background fill
  static const Color fieldFill = Color(0xFFF7F8F9);

  /// Border and divider lines
  static const Color borderLight = Color(0xFFE4E6EA);
  static const Color dividerColor = Color(0xFFEDEEF2);
}

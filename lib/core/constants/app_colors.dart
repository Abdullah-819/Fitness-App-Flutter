import 'package:flutter/material.dart';

/// Central palette of colors used across the Step Counter application.
///
/// Values come from the TrackFit design-system color sheet.
class AppColors {
  AppColors._();

  // ---- Primary ----
  /// Brand purple (#6F41EC)
  static const Color primaryPurple = Color(0xFF6F41EC);

  /// Pressed / deeper brand purple (derived from the primary)
  static const Color darkPurple = Color(0xFF5B31D0);

  /// Secondary primary tint (#F6F3FF)
  static const Color lightPurpleBg = Color(0xFFF6F3FF);

  // ---- Strokes ----
  static const Color stroke = Color(0xFFD9D9D9);
  static const Color stroke1 = Color(0xFFF4F4F4);
  static const Color stroke2 = Color(0xFF6F41EC);

  // ---- Text / Heading ----
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFFACACAC);

  /// Alias of [textTertiary] kept for existing call sites.
  static const Color textLight = textTertiary;

  // ---- Backgrounds ----
  static const Color backgroundMain = Color(0xFFEFEFEF);
  static const Color backgroundSecondary = Color(0xFFF4F4F4);
  static const Color backgroundTertiary = Color(0xFFF5F1FF);

  // ---- Alert ----
  static const Color danger = Color(0xFFEC2727);
  static const Color dangerSecondary = Color(0xFFFFEFEF);
  static const Color success = Color(0xFF4FA531);
  static const Color successSecondary = Color(0xFFE8F5E7);

  // ---- Icons ----
  static const Color icon1 = Color(0xFF6B6B6B);
  static const Color icon2 = Color(0xFF111111);
  static const Color icon3 = Color(0xFF7A7A7A);

  // ---- Convenience ----
  /// White accents for icons and typography
  static const Color white = Colors.white;

  /// Subtle text / faded elements on purple backgrounds
  static const Color textMuted = Color(0xCCFFFFFF);

  /// Inactive dot indicator
  static const Color indicatorInactive = Color(0xFFEDECED);

  /// Input field background fill
  static const Color fieldFill = backgroundSecondary;

  /// Border and divider lines
  static const Color borderLight = stroke;
  static const Color dividerColor = stroke1;
}

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Light / dark colour set used by the dashboard feature screens.
///
/// Read the active set with [AppPalette.of], which follows the current
/// [Theme] brightness (driven by [ThemeController]).
class AppPalette {
  final Color background;
  final Color card;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color ringTrack;
  final Color ringTick;
  final Color navBackground;
  final Color navBorder;
  final Color navInactive;
  final Color navActive;
  final Color border;
  final Color danger;
  final bool isDark;

  const AppPalette({
    required this.background,
    required this.card,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.ringTrack,
    required this.ringTick,
    required this.navBackground,
    required this.navBorder,
    required this.navInactive,
    required this.navActive,
    required this.border,
    required this.danger,
    required this.isDark,
  });

  static const AppPalette light = AppPalette(
    background: AppColors.backgroundMain,
    card: Colors.white,
    divider: AppColors.stroke1,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    ringTrack: AppColors.backgroundMain,
    ringTick: AppColors.stroke,
    navBackground: Colors.white,
    navBorder: AppColors.stroke1,
    navInactive: AppColors.icon3,
    navActive: AppColors.primaryPurple,
    border: AppColors.stroke,
    danger: AppColors.danger,
    isDark: false,
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF181920),
    card: Color(0xFF21232C),
    divider: Color(0xFF2C2E39),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB8BAC4),
    ringTrack: Color(0xFF2B2D38),
    ringTick: Color(0xFF5A5C68),
    navBackground: Color(0xFF1E1F27),
    navBorder: Color(0xFF2C2E39),
    navInactive: Color(0xFFB8BAC4),
    navActive: Colors.white,
    border: Color(0xFF3A3C48),
    danger: AppColors.danger,
    isDark: true,
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

import 'package:flutter/material.dart';

/// Shared motion for popups so every dialog, sheet and menu feels the same.
class AppAnimations {
  AppAnimations._();

  /// Dialogs: scale + fade with a soft overshoot.
  static final AnimationStyle dialog = AnimationStyle(
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 200),
  );

  /// Bottom sheets: smooth slide up.
  static final AnimationStyle sheet = AnimationStyle(
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
    duration: const Duration(milliseconds: 380),
    reverseDuration: const Duration(milliseconds: 240),
  );

  /// Popup (3-dot / overflow) menus.
  static final AnimationStyle menu = AnimationStyle(
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 180),
  );
}

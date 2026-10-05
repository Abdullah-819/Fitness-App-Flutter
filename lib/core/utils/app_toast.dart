import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/app_colors.dart';

/// Centralized utility for presenting consistent, beautiful toast messages across the app.
class AppToast {
  AppToast._();

  /// Displays a green success toast message at the bottom of the screen.
  static void success(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success, // Vibrant emerald green
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays a red error toast message at the bottom of the screen.
  static void error(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.danger, // Vibrant crimson red
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays an informational toast message with brand purple background.
  static void info(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primaryPurple,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Modal loading dialog matching 18_Light_sign in loading.png.
class SignInLoadingDialog extends StatelessWidget {
  final String message;

  const SignInLoadingDialog({super.key, this.message = 'Sign in...'});

  /// Static helper to display the dialog
  static Future<void> show(
    BuildContext context, {
    String message = 'Sign in...',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => SignInLoadingDialog(message: message),
    );
  }

  /// Static helper to dismiss the dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.inkDrop(
                color: AppColors.primaryPurple,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Pill-shaped social authentication button with strictly aligned leading icon
/// and centered label, guaranteeing identical alignment and equal sizings.
class SocialSignInButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const SocialSignInButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.borderLight, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(child: icon),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

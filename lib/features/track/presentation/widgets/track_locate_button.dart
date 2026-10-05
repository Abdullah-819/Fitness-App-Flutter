import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Floating round purple "locate me" button matching designs 30 and 31.
class TrackLocateButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isTracking;

  const TrackLocateButton({
    super.key,
    required this.onTap,
    this.isTracking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              LucideIcons.locateFixed,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

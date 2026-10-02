import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Modal dialog for requesting Physical Activity permission.
///
/// Direct pixel-accurate implementation of:
/// `design/DashBoard/23_Light_physical activity permission request.png`
class PhysicalActivityPermissionDialog extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onCancel;

  const PhysicalActivityPermissionDialog({
    super.key,
    required this.onGrant,
    required this.onCancel,
  });

  /// Displays the dialog centered with a dimmed backdrop.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => PhysicalActivityPermissionDialog(
        onGrant: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: p.card,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top circular icon container
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.accessibility,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Dialog Title
            Text(
              'Physical Activity\nPermission Request',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: p.textPrimary,
                height: 1.25,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 16),

            // Dialog Description
            Text(
              'TrackFit needs permission to access your physical activity data to accurately count your steps and monitor your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: p.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 28),

            // Grant Permission Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onGrant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  'Grant Permission',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.lightPurpleBg,
                  foregroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Celebration modal dialog displayed when the user reaches their step goal.
///
/// Direct pixel-accurate implementation of:
/// `design/DashBoard/27_Light_home - steps counter active - modal step goal passed.png`
class GoalCompletionDialog extends StatelessWidget {
  final int stepGoal;
  final String durationString;
  final String caloriesString;
  final String distanceKmString;
  final VoidCallback onStopStep;
  final VoidCallback onContinueSteps;

  const GoalCompletionDialog({
    super.key,
    required this.stepGoal,
    required this.durationString,
    required this.caloriesString,
    required this.distanceKmString,
    required this.onStopStep,
    required this.onContinueSteps,
  });

  /// Displays the modal sheet or dialog.
  static Future<bool?> show({
    required BuildContext context,
    required int stepGoal,
    required String durationString,
    required String caloriesString,
    required String distanceKmString,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalCompletionDialog(
        stepGoal: stepGoal,
        durationString: durationString,
        caloriesString: caloriesString,
        distanceKmString: distanceKmString,
        onStopStep: () => Navigator.of(context).pop(false),
        onContinueSteps: () => Navigator.of(context).pop(true),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Trophy with confetti celebration illustration
            Image.asset(
              AppAssets.goalCompletionTrophy,
              width: 230,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Graceful fallback if image is not loaded
                return Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7DF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFB800),
                    size: 80,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Goal Title
            Text(
              '${_formatNumber(stepGoal)} Steps!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: p.textPrimary,
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 8),

            // Congratulations Subtitle
            Text(
              'Congratulations!\nYou\'ve completed the step goal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: p.textSecondary,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 26),

            // Summary Metrics Row
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: LucideIcons.clock,
                    iconColor: const Color(0xFFFF9500),
                    value: durationString,
                    label: 'time',
                  ),
                ),
                Container(
                  height: 44,
                  width: 1,
                  color: p.divider,
                ),
                Expanded(
                  child: _SummaryMetric(
                    icon: LucideIcons.flame,
                    iconColor: const Color(0xFFFF453A),
                    value: caloriesString,
                    label: 'kcal',
                  ),
                ),
                Container(
                  height: 44,
                  width: 1,
                  color: p.divider,
                ),
                Expanded(
                  child: _SummaryMetric(
                    icon: LucideIcons.mapPin,
                    iconColor: const Color(0xFF34C759),
                    value: distanceKmString,
                    label: 'km',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                // Stop Step button
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: TextButton(
                      onPressed: onStopStep,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.lightPurpleBg,
                        foregroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: const Text(
                        'Stop Step',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Continue Steps button
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onContinueSteps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: const Text(
                        'Continue Steps',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: p.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: p.textSecondary,
          ),
        ),
      ],
    );
  }
}

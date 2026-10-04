import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/track_session.dart';

/// Modal dialog presented when a live tracking workout is stopped.
class TrackSummaryDialog extends StatelessWidget {
  final TrackSession session;

  const TrackSummaryDialog({super.key, required this.session});

  static Future<void> show(BuildContext context, TrackSession session) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TrackSummaryDialog(session: session),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return Dialog(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.award,
                color: AppColors.primaryPurple,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Workout Saved!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Great job on your outdoor session!',
              style: TextStyle(fontSize: 14, color: p.textSecondary),
            ),
            const SizedBox(height: 20),

            // Summary grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Distance',
                    value: '${session.distanceKm.toStringAsFixed(2)} km',
                    icon: LucideIcons.mapPin,
                    iconColor: const Color(0xFF34C759),
                    p: p,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Steps',
                    value: '${session.steps}',
                    icon: LucideIcons.footprints,
                    iconColor: const Color(0xFF2F9BFF),
                    p: p,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Duration',
                    value: _formatDuration(session.durationSeconds),
                    icon: LucideIcons.clock,
                    iconColor: const Color(0xFFFF9500),
                    p: p,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Calories',
                    value: '${session.kcal} kcal',
                    icon: LucideIcons.flame,
                    iconColor: const Color(0xFFFF3B30),
                    p: p,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final AppPalette p;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: p.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ],
    );
  }
}

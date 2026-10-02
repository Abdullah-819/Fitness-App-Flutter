import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Three-column daily activity statistics row (Time, Calories, Distance).
///
/// Designed to match screens 25, 26, 28, and 29 of the Dashboard UI.
class DailyStatsRow extends StatelessWidget {
  final String timeString;
  final String caloriesString;
  final String distanceKmString;

  const DailyStatsRow({
    super.key,
    required this.timeString,
    required this.caloriesString,
    required this.distanceKmString,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              icon: LucideIcons.clock,
              iconColor: const Color(0xFFFF9500),
              value: timeString,
              label: 'time',
            ),
          ),
          Container(
            height: 48,
            width: 1,
            color: const Color(0xFFEDEEF2),
          ),
          Expanded(
            child: _StatColumn(
              icon: LucideIcons.flame,
              iconColor: const Color(0xFFFF453A),
              value: caloriesString,
              label: 'kcal',
            ),
          ),
          Container(
            height: 48,
            width: 1,
            color: const Color(0xFFEDEEF2),
          ),
          Expanded(
            child: _StatColumn(
              icon: LucideIcons.mapPin,
              iconColor: const Color(0xFF34C759),
              value: distanceKmString,
              label: 'km',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

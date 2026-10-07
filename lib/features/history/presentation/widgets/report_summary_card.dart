import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';

/// Top summary card in the Report screen matching `design/History/32_Light_report.png`.
///
/// Displays:
/// - Centered twin footprint icon + large bold total step count
/// - "Total steps all the time" subtitle
/// - Horizontal dividing line
/// - Three columns: time (orange clock), calories (red flame), distance (green pin)
class ReportSummaryCard extends StatelessWidget {
  final String totalSteps;
  final String timeString;
  final String caloriesString;
  final String distanceKmString;

  const ReportSummaryCard({
    super.key,
    required this.totalSteps,
    required this.timeString,
    required this.caloriesString,
    required this.distanceKmString,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.border.withValues(alpha: palette.isDark ? 0.3 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: palette.isDark ? 0.2 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Steps Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FootprintsIcon(
                size: 26,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  totalSteps,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total steps all the time',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: palette.textSecondary,
            ),
          ),

          const SizedBox(height: 18),
          Divider(height: 1, thickness: 1, color: palette.divider),
          const SizedBox(height: 18),

          // Three Metrics Columns
          Row(
            children: [
              Expanded(
                child: _SummaryColumn(
                  icon: LucideIcons.clock,
                  iconColor: const Color(0xFFFF9500),
                  value: timeString,
                  label: 'time',
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: palette.divider,
              ),
              Expanded(
                child: _SummaryColumn(
                  icon: LucideIcons.flame,
                  iconColor: const Color(0xFFFF4B4B),
                  value: caloriesString,
                  label: 'kcal',
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: palette.divider,
              ),
              Expanded(
                child: _SummaryColumn(
                  icon: LucideIcons.mapPin,
                  iconColor: const Color(0xFF22C55E),
                  value: distanceKmString,
                  label: 'km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

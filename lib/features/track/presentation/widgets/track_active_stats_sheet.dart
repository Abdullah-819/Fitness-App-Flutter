import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Bottom stats card shown during active tracking matching design
/// 31_Light_track - steps counter active.png.
class TrackActiveStatsSheet extends StatelessWidget {
  final int steps;
  final String formattedTime;
  final int kcal;
  final double distanceKm;
  final VoidCallback onStop;

  const TrackActiveStatsSheet({
    super.key,
    required this.steps,
    required this.formattedTime,
    required this.kcal,
    required this.distanceKm,
    required this.onStop,
  });

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
      width: double.infinity,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top drag handle indicator
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: p.divider.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4 Stats columns: steps, time, kcal, km
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: LucideIcons.footprints,
                iconColor: const Color(0xFF2F9BFF),
                value: _formatNumber(steps),
                label: 'steps',
                textColor: p.textPrimary,
                subColor: p.textSecondary,
              ),
              _Divider(dividerColor: p.divider),
              _StatItem(
                icon: LucideIcons.clock,
                iconColor: const Color(0xFFFF9500),
                value: formattedTime,
                label: 'time',
                textColor: p.textPrimary,
                subColor: p.textSecondary,
              ),
              _Divider(dividerColor: p.divider),
              _StatItem(
                icon: LucideIcons.flame,
                iconColor: const Color(0xFFFF3B30),
                value: '$kcal',
                label: 'kcal',
                textColor: p.textPrimary,
                subColor: p.textSecondary,
              ),
              _Divider(dividerColor: p.divider),
              _StatItem(
                icon: LucideIcons.mapPin,
                iconColor: const Color(0xFF34C759),
                value: distanceKm.toStringAsFixed(2),
                label: 'km',
                textColor: p.textPrimary,
                subColor: p.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Full-width Stop button with light-purple pill background
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: p.isDark
                  ? const Color(0xFF2A2342)
                  : const Color(0xFFF3EEFD),
              borderRadius: BorderRadius.circular(26),
              child: InkWell(
                onTap: onStop,
                borderRadius: BorderRadius.circular(26),
                child: const Center(
                  child: Text(
                    'Stop',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color textColor;
  final Color subColor;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: subColor,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color dividerColor;

  const _Divider({required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: dividerColor.withValues(alpha: 0.5),
    );
  }
}

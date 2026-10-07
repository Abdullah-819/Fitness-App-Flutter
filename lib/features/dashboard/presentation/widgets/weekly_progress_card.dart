import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../widgets/animated_dropdown.dart';

/// Data model representing a single day in the weekly progress row.
class DayProgressData {
  final String dayName;
  final int dayNumber;
  final double progress; // 0.0 to 1.0+
  final bool isToday;

  const DayProgressData({
    required this.dayName,
    required this.dayNumber,
    required this.progress,
    this.isToday = false,
  });
}

/// "Your Progress" weekly step completion card matching Dashboard designs 25-29.
class WeeklyProgressCard extends StatelessWidget {
  final List<DayProgressData> days;
  final String selectedPeriod;
  final ValueChanged<String>? onPeriodChanged;

  const WeeklyProgressCard({
    super.key,
    required this.days,
    this.selectedPeriod = 'This Week',
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: p.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (pillContext) => InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final picked = await showAnimatedDropdown<String>(
                      pillContext,
                      selected: selectedPeriod,
                      options: const [
                        DropdownOption(value: 'This Week', label: 'This Week'),
                        DropdownOption(value: 'Last Week', label: 'Last Week'),
                        DropdownOption(
                          value: 'This Month',
                          label: 'This Month',
                        ),
                      ],
                    );
                    if (picked != null) onPeriodChanged?.call(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedPeriod,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 16,
                          color: p.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: p.divider),
          const SizedBox(height: 14),

          // 7-day circular indicators row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) => _DayItem(data: day)).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final DayProgressData data;

  const _DayItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(42, 42),
                painter: _DayRingPainter(
                  progress: data.progress,
                  isToday: data.isToday,
                  activeColor: AppColors.primaryPurple,
                  trackColor: p.ringTrack,
                ),
              ),
              Text(
                '${data.dayNumber}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: data.isToday ? AppColors.primaryPurple : p.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.isToday ? 'Today' : data.dayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: data.isToday ? AppColors.primaryPurple : p.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DayRingPainter extends CustomPainter {
  final double progress;
  final bool isToday;
  final Color activeColor;
  final Color trackColor;

  _DayRingPainter({
    required this.progress,
    required this.isToday,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2.0;
    const strokeWidth = 3.5;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress
    if (progress > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = (2 * math.pi) * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DayRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isToday != isToday ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              PopupMenuButton<String>(
                initialValue: selectedPeriod,
                onSelected: onPeriodChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'This Week',
                    child: Text('This Week'),
                  ),
                  PopupMenuItem(
                    value: 'Last Week',
                    child: Text('Last Week'),
                  ),
                  PopupMenuItem(
                    value: 'This Month',
                    child: Text('This Month'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE4E6EA)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPeriod,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(40, 40),
                painter: _DayRingPainter(
                  progress: data.progress,
                  isToday: data.isToday,
                  activeColor: AppColors.primaryPurple,
                  trackColor: const Color(0xFFEBECEF),
                ),
              ),
              Text(
                '${data.dayNumber}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: data.isToday
                      ? AppColors.primaryPurple
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.isToday ? 'Today' : data.dayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: data.isToday ? FontWeight.w700 : FontWeight.w500,
            color: data.isToday
                ? AppColors.primaryPurple
                : AppColors.textSecondary,
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
    const strokeWidth = 2.8;

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

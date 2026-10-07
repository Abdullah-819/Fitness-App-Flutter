import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/models/report_metrics.dart';
import 'date_range_picker_dialog.dart';

/// "Your Progress" monthly calendar card matching `design/History/32_Light_report.png`.
///
/// Features:
/// - Header with dropdown filter pill ("This Month")
/// - Month switcher with previous/next chevrons ("December 2024")
/// - Days of week row: Sun, Mon, Tue, Wed, Thu, Fri, Sat
/// - Calendar grid of circular progress rings with progress arc and centered day number
class ProgressCalendarCard extends StatelessWidget {
  final DateTime month;
  final List<CalendarDayProgress> days;
  final int selectedDay;
  final ReportPeriodFilter periodFilter;
  final ValueChanged<ReportPeriodFilter> onPeriodChanged;
  final ValueChanged<int> onSelectDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const ProgressCalendarCard({
    super.key,
    required this.month,
    required this.days,
    required this.selectedDay,
    required this.periodFilter,
    required this.onPeriodChanged,
    required this.onSelectDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  static const List<String> _weekDayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final monthTitle = '${_monthNames[month.month - 1]} ${month.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Your Progress" & Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final chosen = await DateRangePickerModal.show(
                    context,
                    currentFilter: periodFilter,
                  );
                  if (chosen != null) {
                    onPeriodChanged(chosen);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: palette.border.withValues(alpha: palette.isDark ? 0.4 : 0.9),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: palette.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Month Navigation Row (< Month Year >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
                color: palette.textPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPreviousMonth,
              ),
              Text(
                monthTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.chevronRight, size: 20),
                color: palette.textPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onNextMonth,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDayNames.map((name) {
              return Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Calendar Grid (7 columns x 5 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final dayItem = days[index];
              final isHighlighted = dayItem.isCurrentMonth && (dayItem.dayNumber == selectedDay);

              return GestureDetector(
                onTap: () {
                  if (dayItem.isCurrentMonth) {
                    onSelectDay(dayItem.dayNumber);
                  }
                },
                child: Center(
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(38, 38),
                          painter: _CalendarProgressPainter(
                            progress: dayItem.progressRatio,
                            isSelected: isHighlighted,
                            isCurrentMonth: dayItem.isCurrentMonth,
                            activeColor: AppColors.primaryPurple,
                            trackColor: palette.isDark
                                ? const Color(0xFF2C2E39)
                                : const Color(0xFFF3EFFF),
                            inactiveColor: palette.isDark
                                ? const Color(0xFF333542)
                                : const Color(0xFFEDEDED),
                          ),
                        ),
                        Text(
                          '${dayItem.dayNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isHighlighted
                                ? FontWeight.w800
                                : (dayItem.isCurrentMonth && !dayItem.isFuture && dayItem.progressRatio > 0
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                            color: isHighlighted
                                ? AppColors.primaryPurple
                                : (dayItem.isCurrentMonth
                                    ? (dayItem.isFuture || dayItem.progressRatio == 0
                                        ? palette.textPrimary.withValues(alpha: 0.7)
                                        : palette.textPrimary)
                                    : palette.textSecondary.withValues(alpha: 0.4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Draws circular progress ring for each calendar day.
class _CalendarProgressPainter extends CustomPainter {
  final double progress;
  final bool isSelected;
  final bool isCurrentMonth;
  final Color activeColor;
  final Color trackColor;
  final Color inactiveColor;

  _CalendarProgressPainter({
    required this.progress,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.activeColor,
    required this.trackColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 1.5;
    const strokeWidth = 2.4;

    if (!isCurrentMonth) {
      // Inactive day outside current month
      final paint = Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    if (isSelected || progress >= 1.0) {
      // Complete purple ring
      final ringPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, ringPaint);
    } else if (progress > 0.0) {
      // Track
      final trackPaint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, trackPaint);

      // Active progress arc
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
    } else {
      // Zero progress day: subtle circle border
      final paint = Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isCurrentMonth != isCurrentMonth ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

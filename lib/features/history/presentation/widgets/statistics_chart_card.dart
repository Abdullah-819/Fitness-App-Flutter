import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/models/report_metrics.dart';
import 'date_range_picker_dialog.dart';

/// "Statistics" card matching `design/History/32_Light_report.png`.
///
/// Features:
/// - Header with dropdown filter pill ("This Week")
/// - Interactive bar chart with left Y-axis labels (7k..1k)
/// - 7 rounded capsule bars with soft lavender (inactive) and vivid purple (selected)
/// - Callout tooltip pin pointing to the selected bar ("5,289 steps")
/// - Bottom metric switcher pills: Steps, Time, Calorie, Distance
class StatisticsChartCard extends StatelessWidget {
  final List<ChartDayData> days;
  final ReportPeriodFilter periodFilter;
  final ReportMetricType metricType;
  final int selectedIndex;
  final ValueChanged<ReportPeriodFilter> onPeriodChanged;
  final ValueChanged<ReportMetricType> onMetricChanged;
  final ValueChanged<int> onSelectDay;

  const StatisticsChartCard({
    super.key,
    required this.days,
    required this.periodFilter,
    required this.metricType,
    required this.selectedIndex,
    required this.onPeriodChanged,
    required this.onMetricChanged,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    // Compute max scale for the active metric
    double maxValue = 0;
    for (final day in days) {
      final val = day.valueFor(metricType);
      if (val > maxValue) maxValue = val;
    }
    if (maxValue <= 0) maxValue = 1;

    // Appropriate scale ceiling
    final double scaleCeiling;
    final List<String> yLabels;
    switch (metricType) {
      case ReportMetricType.steps:
        scaleCeiling = 7500;
        yLabels = const ['7k', '6k', '5k', '4k', '3k', '2k', '1k'];
        break;
      case ReportMetricType.time:
        scaleCeiling = 120; // up to 120 minutes (2 hours)
        yLabels = const ['120m', '100m', '80m', '60m', '40m', '20m', '10m'];
        break;
      case ReportMetricType.calorie:
        scaleCeiling = 600;
        yLabels = const ['600', '500', '400', '300', '200', '100', '50'];
        break;
      case ReportMetricType.distance:
        scaleCeiling = 8.0;
        yLabels = const ['8km', '7km', '6km', '5km', '4km', '3km', '2km'];
        break;
    }

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
          // Header: "Statistics" & Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Statistics',
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
                        periodFilter.label,
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

          const SizedBox(height: 22),

          // Chart: Y-Axis and 7 Bars
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-Axis Labels
                SizedBox(
                  width: 32,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: yLabels.map((lbl) {
                      return Text(
                        lbl,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: palette.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),

                // Bars with Tooltip and Day labels
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const tooltipHeight = 48.0;
                      const labelHeight = 18.0;
                      const spacing = 16.0;
                      final maxBarHeight = constraints.maxHeight - tooltipHeight - labelHeight - spacing;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(days.length, (index) {
                          final day = days[index];
                          final isSelected = index == selectedIndex;
                          final value = day.valueFor(metricType);
                          final normalized = (value / scaleCeiling).clamp(0.12, 1.0);
                          final barHeight = (normalized * maxBarHeight).clamp(24.0, maxBarHeight);

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelectDay(index),
                            child: SizedBox(
                              width: (constraints.maxWidth - 20) / days.length,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tooltip badge for active bar
                                  if (isSelected)
                                    _TooltipBadge(
                                      value: day.formattedValueFor(metricType),
                                      unit: metricType.unit,
                                    )
                                  else
                                    const SizedBox(height: tooltipHeight),

                                  const SizedBox(height: 4),

                                  // Rounded capsule bar
                                  Container(
                                    width: 32,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryPurple
                                          : (palette.isDark
                                              ? const Color(0xFF8A6CD8)
                                              : const Color(0xFFC4A5FD)),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryPurple.withValues(alpha: 0.35),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // X-Axis Day number
                                  Text(
                                    day.dayLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? palette.textPrimary
                                          : palette.textPrimary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Metric Switcher Pills: Steps, Time, Calorie, Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ReportMetricType.values.map((metric) {
              final isActive = metric == metricType;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => onMetricChanged(metric),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? null
                            : Border.all(
                                color: palette.border.withValues(
                                  alpha: palette.isDark ? 0.35 : 0.8,
                                ),
                                width: 1.2,
                              ),
                      ),
                      child: Center(
                        child: Text(
                          metric.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : palette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Circular speech bubble with downward pointer triangle matching the design tooltip.
class _TooltipBadge extends StatelessWidget {
  final String value;
  final String unit;

  const _TooltipBadge({
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: palette.card,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryPurple,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                    color: palette.textSecondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: CustomPaint(
            size: const Size(10, 5),
            painter: _TrianglePointerPainter(
              borderColor: AppColors.primaryPurple,
              fillColor: palette.card,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrianglePointerPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  _TrianglePointerPainter({
    required this.borderColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) => false;
}

import 'package:flutter/foundation.dart';

/// Supported time range filters for the report statistics.
enum ReportPeriodFilter {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  last6Months('Last 6 Months'),
  thisYear('This Year'),
  lastYear('Last Year'),
  allTime('All Time'),
  customRange('Custom Range');

  final String label;
  const ReportPeriodFilter(this.label);
}

/// Supported metric types for the statistics bar chart.
enum ReportMetricType {
  steps('Steps', 'steps'),
  time('Time', 'min'),
  calorie('Calorie', 'kcal'),
  distance('Distance', 'km');

  final String label;
  final String unit;
  const ReportMetricType(this.label, this.unit);
}

/// Represents a single day's data point for the bar chart.
@immutable
class ChartDayData {
  final int dayNumber;
  final String dayLabel;
  final int steps;
  final int activeMinutes;
  final int calories;
  final double distanceKm;
  final bool isHighlighted;

  const ChartDayData({
    required this.dayNumber,
    required this.dayLabel,
    required this.steps,
    required this.activeMinutes,
    required this.calories,
    required this.distanceKm,
    this.isHighlighted = false,
  });

  /// Returns numeric value corresponding to the active [ReportMetricType].
  double valueFor(ReportMetricType metric) {
    switch (metric) {
      case ReportMetricType.steps:
        return steps.toDouble();
      case ReportMetricType.time:
        return activeMinutes.toDouble();
      case ReportMetricType.calorie:
        return calories.toDouble();
      case ReportMetricType.distance:
        return distanceKm;
    }
  }

  /// Formatted display string for tooltip.
  String formattedValueFor(ReportMetricType metric) {
    switch (metric) {
      case ReportMetricType.steps:
        return _formatNumber(steps);
      case ReportMetricType.time:
        final h = activeMinutes ~/ 60;
        final m = activeMinutes % 60;
        if (h > 0) return '${h}h ${m}m';
        return '${m}m';
      case ReportMetricType.calorie:
        return _formatNumber(calories);
      case ReportMetricType.distance:
        return distanceKm.toStringAsFixed(2);
    }
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Represents a calendar date item in the "Your Progress" monthly grid.
@immutable
class CalendarDayProgress {
  final DateTime date;
  final int dayNumber;
  final double progressRatio; // 0.0 to 1.0+
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isFuture;

  const CalendarDayProgress({
    required this.date,
    required this.dayNumber,
    required this.progressRatio,
    this.isCurrentMonth = true,
    this.isSelected = false,
    this.isFuture = false,
  });

  CalendarDayProgress copyWith({
    bool? isSelected,
  }) {
    return CalendarDayProgress(
      date: date,
      dayNumber: dayNumber,
      progressRatio: progressRatio,
      isCurrentMonth: isCurrentMonth,
      isSelected: isSelected ?? this.isSelected,
      isFuture: isFuture,
    );
  }
}

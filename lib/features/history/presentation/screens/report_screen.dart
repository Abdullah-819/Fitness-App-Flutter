import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../widgets/fade_slide_in.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';
import '../../providers/history_provider.dart';
import '../widgets/progress_calendar_card.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/statistics_chart_card.dart';

/// Complete Report screen implementing `design/History/32_Light_report.png`
/// and date range selection from `33_Light_report - select date range.png`.
///
/// Can be displayed standalone or embedded within the [DashboardScreen] tab view.
class ReportScreen extends StatelessWidget {
  final bool embeddedInDashboard;

  const ReportScreen({
    super.key,
    this.embeddedInDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    // Provide a localized HistoryProvider if not already in context tree
    Widget content;
    try {
      Provider.of<HistoryProvider>(context, listen: false);
      content = const _ReportScreenContent();
    } catch (_) {
      content = ChangeNotifierProvider<HistoryProvider>(
        create: (_) => HistoryProvider(),
        child: const _ReportScreenContent(),
      );
    }

    if (embeddedInDashboard) {
      return content;
    }

    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(
            child: FootprintsIcon(
              size: 28,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
        title: Text(
          'Report',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.ellipsisVertical,
              color: palette.textPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: content,
      ),
    );
  }
}

class _ReportScreenContent extends StatelessWidget {
  const _ReportScreenContent();

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryProvider>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overview Summary Card (Total Steps All Time, Time, Kcal, Km)
          FadeSlideIn(
            child: ReportSummaryCard(
              totalSteps: history.formattedTotalSteps,
              timeString: history.formattedTotalTime,
              caloriesString: history.formattedTotalCalories,
              distanceKmString: history.formattedTotalDistance,
            ),
          ),

          const SizedBox(height: 16),

          // 2. "Statistics" Bar Chart Card
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: StatisticsChartCard(
              days: history.weeklyChartDays,
              periodFilter: history.periodFilter,
              metricType: history.metricType,
              selectedIndex: history.selectedBarIndex,
              onPeriodChanged: history.setPeriodFilter,
              onMetricChanged: history.setMetricType,
              onSelectDay: history.selectBarIndex,
            ),
          ),

          const SizedBox(height: 16),

          // 3. "Your Progress" Monthly Calendar Progress Card
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: ProgressCalendarCard(
              month: history.currentMonth,
              days: history.buildMonthCalendarGrid(),
              selectedDay: history.selectedCalendarDay,
              periodFilter: history.periodFilter,
              onPeriodChanged: history.setPeriodFilter,
              onSelectDay: history.selectCalendarDay,
              onPreviousMonth: history.previousMonth,
              onNextMonth: history.nextMonth,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../widgets/fade_slide_in.dart';
import '../widgets/animated_int_text.dart';
import '../widgets/floating_amount_label.dart';
import '../widgets/water_drink_button.dart';
import '../widgets/water_droplet_indicator.dart';
import '../widgets/water_history_chart.dart';
import '../widgets/water_sheets.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int _currentMl = 1750;
  int _targetGoalMl = 4000;
  String _selectedRange = 'This Week';

  // Animation state
  int _splashCount = 0; // bumps on every drink -> splash + ripples
  int _lastAddedMl = 0;
  bool _isDrinking = false;
  Timer? _drinkTimer;

  // Sample history records matching the design (Days 16 - 22)
  final List<WaterDailyRecord> _historyRecords = const [
    WaterDailyRecord(day: 16, amountMl: 3100),
    WaterDailyRecord(day: 17, amountMl: 2400),
    WaterDailyRecord(day: 18, amountMl: 3400),
    WaterDailyRecord(day: 19, amountMl: 3850),
    WaterDailyRecord(day: 20, amountMl: 2750),
    WaterDailyRecord(day: 21, amountMl: 3500),
    WaterDailyRecord(day: 22, amountMl: 2900),
  ];

  double get _progress => (_currentMl / _targetGoalMl).clamp(0.0, 1.0);
  int get _percentage => (_progress * 100).round();
  bool get _goalReached => _currentMl >= _targetGoalMl;

  @override
  void dispose() {
    _drinkTimer?.cancel();
    super.dispose();
  }

  Future<void> _onDrinkPressed() async {
    final amount = await showAddWaterSheet(context);
    if (amount != null && mounted) _addWater(amount);
  }

  void _addWater(int amount) {
    final wasReached = _goalReached;
    HapticFeedback.mediumImpact();

    setState(() {
      _currentMl = (_currentMl + amount).clamp(0, 10000);
      _lastAddedMl = amount;
      _splashCount++;
      _isDrinking = true;
    });

    if (!wasReached && _goalReached) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        HapticFeedback.heavyImpact();
      });
    }

    // Back to "Drink" once the level has finished rising.
    _drinkTimer?.cancel();
    _drinkTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _isDrinking = false);
    });
  }

  Future<void> _openSettings() async {
    final goal = await showWaterGoalDialog(context, _targetGoalMl);
    if (goal != null && mounted) {
      setState(() => _targetGoalMl = goal);
    }
  }

  Future<void> _openRangeFilter() async {
    final range = await showWaterRangeSheet(context, _selectedRange);
    if (range != null && mounted) {
      setState(() => _selectedRange = range);
    }
  }

  BoxDecoration _cardDecoration(AppPalette p) => BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.isDark ? p.divider : const Color(0xFFECEEF2)),
        boxShadow: p.isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Water Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: p.textPrimary),
            onPressed: _openSettings,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            // ================= 1. TOP CARD (Droplet & Drink) =================
            FadeSlideIn(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: _cardDecoration(p),
                child: Column(
                  children: [
                    // Teardrop gauge with the floating "+250 ml" label
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          WaterDropletIndicator(
                            progress: _progress,
                            width: 170,
                            height: 215,
                            isDark: p.isDark,
                            splashTrigger: _splashCount,
                            celebrate: _goalReached,
                          ),
                          Positioned(
                            top: 70,
                            child: FloatingAmountLabel(
                              amountMl: _lastAddedMl,
                              triggerId: _splashCount,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Percentage (counts up / down smoothly)
                    AnimatedIntText(
                      value: _percentage,
                      builder: (context, value) => Text(
                        '$value%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: p.textPrimary,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Current / Target
                    AnimatedIntText(
                      value: _currentMl,
                      builder: (context, current) => AnimatedIntText(
                        value: _targetGoalMl,
                        builder: (context, goal) => Text(
                          '${formatMl(current)} / ${formatMl(goal)} ml',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: p.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),

                    // Goal reached chip grows in / out smoothly
                    AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        ),
                        child: _goalReached
                            ? Padding(
                                key: const ValueKey('goal_chip'),
                                padding: const EdgeInsets.only(top: 14),
                                child: _GoalReachedChip(isDark: p.isDark),
                              )
                            : const SizedBox.shrink(key: ValueKey('no_chip')),
                      ),
                    ),

                    const SizedBox(height: 24),

                    WaterDrinkButton(
                      isDrinking: _isDrinking,
                      onPressed: _onDrinkPressed,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= 2. BOTTOM CARD (History) =================
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                decoration: _cardDecoration(p),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: p.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: _openRangeFilter,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: p.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: p.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Label cross-fades when the range changes
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Text(
                                    _selectedRange,
                                    key: ValueKey(_selectedRange),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: p.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: p.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    Divider(color: p.divider, height: 1),
                    const SizedBox(height: 18),

                    WaterHistoryChart(
                      records: _historyRecords,
                      maxAmountMl: 4000,
                      initialSelectedDay: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalReachedChip extends StatelessWidget {
  final bool isDark;

  const _GoalReachedChip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.successSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined, size: 18, color: AppColors.success),
          SizedBox(width: 6),
          Text(
            'Daily goal reached!',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

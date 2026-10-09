import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import 'animated_int_text.dart';

/// Model representing a single day's intake record for the history chart.
class WaterDailyRecord {
  final int day;
  final int amountMl;

  const WaterDailyRecord({
    required this.day,
    required this.amountMl,
  });
}

/// 7-day bar chart. Bars grow in one after another, the selected bar's
/// tooltip pops into place, and selection changes animate smoothly.
class WaterHistoryChart extends StatefulWidget {
  final List<WaterDailyRecord> records;
  final int maxAmountMl;
  final int initialSelectedDay;
  final ValueChanged<WaterDailyRecord>? onDaySelected;

  const WaterHistoryChart({
    super.key,
    required this.records,
    this.maxAmountMl = 4000,
    this.initialSelectedDay = 20,
    this.onDaySelected,
  });

  @override
  State<WaterHistoryChart> createState() => _WaterHistoryChartState();
}

class _WaterHistoryChartState extends State<WaterHistoryChart>
    with SingleTickerProviderStateMixin {
  static const double _chartHeight = 180.0;
  static const double _barAreaHeight = 150.0;

  late int _selectedDay;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDay;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WaterHistoryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // New data (e.g. another range): replay the grow-in.
    if (!identical(oldWidget.records, widget.records)) {
      _entrance.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _select(WaterDailyRecord record) {
    if (record.day == _selectedDay) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedDay = record.day);
    widget.onDaySelected?.call(record);
  }

  /// 0..1 grow progress for bar [index], staggered left to right.
  double _grow(int index) {
    final start = (index * 0.07).clamp(0.0, 0.5);
    return Interval(start, start + 0.5, curve: Curves.easeOutCubic)
        .transform(_entrance.value);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    final selectedRecord = widget.records.firstWhere(
      (r) => r.day == _selectedDay,
      orElse: () => widget.records.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 40;
        final itemWidth = totalWidth / widget.records.length;

        return Column(
          children: [
            SizedBox(
              height: _chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // --- Y-Axis Labels ---
                  SizedBox(
                    width: 32,
                    height: _barAreaHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final label in const ['4k', '3k', '2k', '1k'])
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: p.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // --- Bar Chart Area ---
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _entrance,
                      builder: (context, _) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (var i = 0;
                                      i < widget.records.length;
                                      i++)
                                    _buildBar(p, i, itemWidth),
                                ],
                              ),
                            ),
                            _buildTooltip(selectedRecord, totalWidth),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- X-Axis Day Numbers ---
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final record in widget.records)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(record),
                      child: SizedBox(
                        width: itemWidth,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: record.day == _selectedDay
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: record.day == _selectedDay
                                  ? p.textPrimary
                                  : p.textSecondary,
                            ),
                            child: Text(record.day.toString()),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBar(AppPalette p, int index, double itemWidth) {
    final record = widget.records[index];
    final isSelected = record.day == _selectedDay;
    final fillFraction =
        (record.amountMl / widget.maxAmountMl).clamp(0.08, 1.0);
    final barHeight = _barAreaHeight * fillFraction * _grow(index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _select(record),
      child: SizedBox(
        width: itemWidth,
        height: _barAreaHeight,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 24,
            height: barHeight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple
                    : (p.isDark
                        ? const Color(0xFF4B2A96)
                        : AppColors.primaryPurple.withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(12),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(WaterDailyRecord selectedRecord, double totalWidth) {
    final index =
        widget.records.indexWhere((r) => r.day == selectedRecord.day);
    if (index == -1) return const SizedBox.shrink();

    final itemWidth = totalWidth / widget.records.length;
    final barCenterX = (index * itemWidth) + (itemWidth / 2);

    final fillFraction =
        (selectedRecord.amountMl / widget.maxAmountMl).clamp(0.08, 1.0);
    final fullBarHeight = _barAreaHeight * fillFraction;

    const tooltipWidth = 46.0;
    const tooltipHeight = 52.0;
    // Rides on top of the growing bar so it never floats in empty space.
    final currentBarHeight = fullBarHeight * _grow(index);
    final topOffset = _barAreaHeight - currentBarHeight - tooltipHeight + 4;

    // Appears once the bars have mostly grown.
    final appear = Interval(0.55, 0.9, curve: Curves.easeOut)
        .transform(_entrance.value);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: (barCenterX - tooltipWidth / 2)
          .clamp(0.0, totalWidth - tooltipWidth),
      top: topOffset.clamp(-8.0, _barAreaHeight - 30),
      child: IgnorePointer(
        child: Opacity(
          opacity: appear,
          // Pops each time a different day is selected.
          child: TweenAnimationBuilder<double>(
            key: ValueKey(selectedRecord.day),
            tween: Tween<double>(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
            child: SizedBox(
              width: tooltipWidth,
              height: tooltipHeight,
              child: CustomPaint(
                painter: _TooltipBubblePainter(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatMl(selectedRecord.amountMl),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'ml',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFE9D5FF),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bubbleHeight = h - 7;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, bubbleHeight),
      Radius.circular(w / 2),
    );

    final path = Path()..addRRect(bubbleRect);

    // Downward pointed arrow tip
    path.moveTo(w * 0.35, bubbleHeight - 1);
    path.lineTo(w * 0.5, h);
    path.lineTo(w * 0.65, bubbleHeight - 1);
    path.close();

    // Shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x596F41EC)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main fill: deep vivid purple
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );

    // Glowing border outline
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFA78BFA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

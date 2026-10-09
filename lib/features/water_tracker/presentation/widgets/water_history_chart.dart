import 'package:flutter/material.dart';

/// Model representing a single day's intake record for the history chart.
class WaterDailyRecord {
  final int day;
  final int amountMl;

  const WaterDailyRecord({
    required this.day,
    required this.amountMl,
  });
}

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

class _WaterHistoryChartState extends State<WaterHistoryChart> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDay;
  }

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 180.0;
    const double barAreaHeight = 150.0;

    final selectedRecord = widget.records.firstWhere(
      (r) => r.day == _selectedDay,
      orElse: () => widget.records.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // --- Y-Axis Labels ---
                  SizedBox(
                    width: 32,
                    height: barAreaHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '4k',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '3k',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '2k',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '1k',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // --- Bar Chart Area ---
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Bars Row
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: widget.records.map((record) {
                              final isSelected = record.day == _selectedDay;
                              final fillFraction =
                                  (record.amountMl / widget.maxAmountMl)
                                      .clamp(0.08, 1.0);
                              final barHeight = barAreaHeight * fillFraction;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    _selectedDay = record.day;
                                  });
                                  widget.onDaySelected?.call(record);
                                },
                                child: SizedBox(
                                  width: (constraints.maxWidth - 40) /
                                      widget.records.length,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                        width: 24,
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF7C3AED)
                                              : const Color(0xAD5B21B6),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: isSelected
                                              ? const [
                                                  BoxShadow(
                                                    color: Color(0x597C3AED),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 3),
                                                  )
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Animated Tooltip Bubble above selected bar
                        _buildTooltipOverlay(
                          records: widget.records,
                          selectedRecord: selectedRecord,
                          totalWidth: constraints.maxWidth - 40,
                          barAreaHeight: barAreaHeight,
                        ),
                      ],
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
                children: widget.records.map((record) {
                  final isSelected = record.day == _selectedDay;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _selectedDay = record.day;
                      });
                      widget.onDaySelected?.call(record);
                    },
                    child: SizedBox(
                      width: (constraints.maxWidth - 40) / widget.records.length,
                      child: Center(
                        child: Text(
                          record.day.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF111827)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTooltipOverlay({
    required List<WaterDailyRecord> records,
    required WaterDailyRecord selectedRecord,
    required double totalWidth,
    required double barAreaHeight,
  }) {
    final index = records.indexWhere((r) => r.day == selectedRecord.day);
    if (index == -1) return const SizedBox.shrink();

    final itemWidth = totalWidth / records.length;
    final barCenterX = (index * itemWidth) + (itemWidth / 2);

    final fillFraction =
        (selectedRecord.amountMl / widget.maxAmountMl).clamp(0.08, 1.0);
    final barHeight = barAreaHeight * fillFraction;

    // Position tooltip directly above top of selected bar
    const tooltipWidth = 46.0;
    const tooltipHeight = 52.0;
    final topOffset = barAreaHeight - barHeight - tooltipHeight + 4;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: (barCenterX - tooltipWidth / 2).clamp(0.0, totalWidth - tooltipWidth),
      top: topOffset.clamp(-8.0, barAreaHeight - 30),
      child: IgnorePointer(
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
                      _formatAmount(selectedRecord.amountMl),
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
    );
  }

  String _formatAmount(int ml) {
    if (ml >= 1000) {
      final whole = ml ~/ 1000;
      final remainder = (ml % 1000).toString().padLeft(3, '0');
      return '$whole,$remainder';
    }
    return ml.toString();
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
    final shadowPaint = Paint()
      ..color = const Color(0x597C3AED)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);

    // Main Fill: deep vivid purple
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFF6D28D9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Glowing border outline
    final strokePaint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

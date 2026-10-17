import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../widgets/fade_slide_in.dart';
import '../../data/weight_models.dart';
import '../widgets/bmi_gauge.dart';
import '../widgets/weight_line_chart.dart';
import '../widgets/weight_sheets.dart';

class WeightTrackerScreen extends StatefulWidget {
  /// Profile values used to seed the screen; both optional.
  final double? initialWeightKg;
  final double? heightCm;

  const WeightTrackerScreen({super.key, this.initialWeightKg, this.heightCm});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  late double _heightCm;
  String _selectedRange = 'Last 6 Months';
  late List<WeightEntry> _entries;

  @override
  void initState() {
    super.initState();
    _heightCm = widget.heightCm ?? 185;
    _entries = _seedEntries();
  }

  /// Six monthly samples ending this month, matching the design's curve.
  /// The most recent one follows the profile weight when it is known.
  List<WeightEntry> _seedEntries() {
    final now = DateTime.now();
    const sample = [78.5, 77.5, 78.0, 76.5, 77.1, 76.5];
    return [
      for (var i = 0; i < sample.length; i++)
        WeightEntry(
          date: DateTime(now.year, now.month - (sample.length - 1 - i), 15),
          kg: i == sample.length - 1
              ? (widget.initialWeightKg ?? sample[i])
              : sample[i],
        ),
    ];
  }

  WeightEntry get _latest => _entries.last;

  List<WeightEntry> get _visibleEntries {
    final now = DateTime.now();
    final months = weightRanges[_selectedRange]!;
    final from = DateTime(now.year, now.month - months + 1, 1);
    return List.unmodifiable(_entries.where((e) => !e.date.isBefore(from)));
  }

  Future<void> _addWeight() async {
    final kg = await showAddWeightSheet(context, _latest.kg.round());
    if (kg == null || !mounted) return;
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    setState(() {
      // One entry per day: logging again today replaces it.
      _entries = [
        ..._entries.where(
          (e) =>
              e.date.year != now.year ||
              e.date.month != now.month ||
              e.date.day != now.day,
        ),
        WeightEntry(date: now, kg: kg.toDouble()),
      ]..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  Future<void> _editHeight() async {
    final cm = await showEditHeightSheet(context, _heightCm.round());
    if (cm != null && mounted) setState(() => _heightCm = cm.toDouble());
  }

  Future<void> _openRangeFilter() async {
    final range = await showWeightRangeSheet(context, _selectedRange);
    if (range != null && mounted) setState(() => _selectedRange = range);
  }

  BoxDecoration _cardDecoration(AppPalette p) => BoxDecoration(
    color: p.card,
    borderRadius: BorderRadius.circular(20),
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
    final bmi = calculateBmi(_latest.kg, _heightCm);

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
          'Weight Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            // ================= 1. WEIGHT CHART CARD =================
            FadeSlideIn(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: _cardDecoration(p),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Weight',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: _openRangeFilter,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
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
                                    Flexible(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: Text(
                                          _selectedRange,
                                          key: ValueKey(_selectedRange),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: p.textPrimary,
                                          ),
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
                          ),
                        ),
                        IconButton(
                          tooltip: 'Add weight',
                          icon: Icon(Icons.add, color: p.textPrimary),
                          onPressed: _addWeight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: p.divider, height: 1),
                    const SizedBox(height: 16),
                    WeightLineChart(
                      key: ValueKey(_selectedRange),
                      entries: _visibleEntries,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= 2. BMI CARD =================
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: _cardDecoration(p),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'BMI (kg/m2): ${bmi.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: p.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit height',
                          icon: Icon(Icons.edit_outlined, color: p.textPrimary),
                          onPressed: _editHeight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: p.divider, height: 1),
                    const SizedBox(height: 20),
                    BmiGauge(bmi: bmi),
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

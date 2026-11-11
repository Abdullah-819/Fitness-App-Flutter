import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// One logged body-weight measurement.
class WeightEntry {
  final DateTime date;
  final double kg;

  const WeightEntry({required this.date, required this.kg});

  Map<String, Object> toMap() => {'date': date.toIso8601String(), 'kg': kg};

  factory WeightEntry.fromMap(Map<dynamic, dynamic> map) => WeightEntry(
    date: DateTime.parse(map['date'] as String),
    kg: (map['kg'] as num).toDouble(),
  );
}

/// Persists weight history and the height used for BMI calculations.
class WeightStore {
  WeightStore._();

  static final WeightStore instance = WeightStore._();
  static const _boxName = 'weight_tracker_box';
  static const _entriesKey = 'entries';
  static const _heightKey = 'heightCm';

  Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<dynamic>(_boxName);
    await Hive.initFlutter();
    return Hive.openBox<dynamic>(_boxName);
  }

  Future<({List<WeightEntry>? entries, double? heightCm})> load() async {
    try {
      final box = await _box();
      final rawEntries = box.get(_entriesKey);
      final entries = rawEntries is List
          ? rawEntries
                .map(
                  (entry) => WeightEntry.fromMap(
                    Map<dynamic, dynamic>.from(entry as Map),
                  ),
                )
                .toList()
          : null;
      final rawHeight = box.get(_heightKey);
      return (
        entries: entries,
        heightCm: rawHeight is num ? rawHeight.toDouble() : null,
      );
    } catch (error) {
      debugPrint('WeightStore: load failed ($error)');
      return (entries: null, heightCm: null);
    }
  }

  Future<void> save({
    required List<WeightEntry> entries,
    required double heightCm,
  }) async {
    try {
      final box = await _box();
      await box.put(
        _entriesKey,
        entries.map((entry) => entry.toMap()).toList(),
      );
      await box.put(_heightKey, heightCm);
    } catch (error) {
      debugPrint('WeightStore: save failed ($error)');
    }
  }
}

/// A WHO BMI band shown on the gauge.
class BmiCategory {
  final String label;
  final String range;
  final double min;
  final double max;
  final Color color;

  const BmiCategory(this.label, this.range, this.min, this.max, this.color);
}

const bmiCategories = [
  BmiCategory('Underweight', '< 18.5', 0, 18.5, Color(0xFF1E96F0)),
  BmiCategory('Normal', '18.5 - 24.9', 18.5, 25, Color(0xFF4CAF50)),
  BmiCategory('Overweight', '25 - 29.9', 25, 30, Color(0xFFFFEB3B)),
  BmiCategory('Obese', '30 - 39.9', 30, 40, Color(0xFFF44336)),
  BmiCategory('Morbidly Obese', '> 40', 40, 100, Color(0xFFB3261E)),
];

double calculateBmi(double kg, double heightCm) {
  final m = heightCm / 100;
  return kg / (m * m);
}

BmiCategory bmiCategoryFor(double bmi) => bmiCategories.firstWhere(
  (c) => bmi < c.max,
  orElse: () => bmiCategories.last,
);

const weightRanges = {
  'Last 3 Months': 3,
  'Last 6 Months': 6,
  'Last 12 Months': 12,
};

const monthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

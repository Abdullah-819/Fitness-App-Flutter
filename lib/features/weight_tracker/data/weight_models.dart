import 'package:flutter/material.dart';

/// One logged body-weight measurement.
class WeightEntry {
  final DateTime date;
  final double kg;

  const WeightEntry({required this.date, required this.kg});
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

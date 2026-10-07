import 'package:flutter/foundation.dart';

/// Represents a discrete logged activity entry for the History list.
@immutable
class HistoryRecordModel {
  final String id;
  final String sectionTitle; // e.g. "Today", "Saturday, Dec 21 2024"
  final DateTime timestamp;
  final int steps;
  final int durationMinutes;
  final int calories;
  final double distanceKm;

  const HistoryRecordModel({
    required this.id,
    required this.sectionTitle,
    required this.timestamp,
    required this.steps,
    required this.durationMinutes,
    required this.calories,
    required this.distanceKm,
  });

  String get formattedTime {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  String get formattedSteps {
    return steps.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  HistoryRecordModel copyWith({
    String? id,
    String? sectionTitle,
    DateTime? timestamp,
    int? steps,
    int? durationMinutes,
    int? calories,
    double? distanceKm,
  }) {
    return HistoryRecordModel(
      id: id ?? this.id,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      timestamp: timestamp ?? this.timestamp,
      steps: steps ?? this.steps,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Represents daily summary metrics for a single calendar date.
@immutable
class DailyHistoryModel {
  /// The date key formatted as 'yyyy-MM-dd'.
  final String dateString;
  final int steps;
  final int goal;
  final double distanceKm;
  final int calories;
  final int activeMinutes;
  final bool isGoalReached;
  final bool isSynced;

  const DailyHistoryModel({
    required this.dateString,
    required this.steps,
    required this.goal,
    required this.distanceKm,
    required this.calories,
    required this.activeMinutes,
    required this.isGoalReached,
    this.isSynced = false,
  });

  /// Formats a [DateTime] into a standard 'yyyy-MM-dd' string key.
  static String formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Factory constructor for a given date with default initial values.
  factory DailyHistoryModel.empty(DateTime date, {int goal = 6000}) {
    return DailyHistoryModel(
      dateString: formatDateKey(date),
      steps: 0,
      goal: goal,
      distanceKm: 0.0,
      calories: 0,
      activeMinutes: 0,
      isGoalReached: false,
      isSynced: false,
    );
  }

  /// Parses the [dateString] back into a [DateTime].
  DateTime get date {
    try {
      final parts = dateString.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Progress ratio (0.0 to 1.0) towards the daily goal.
  double get progressRatio => goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

  /// Progress percentage (0% to 100%+).
  double get progressPercentage => goal > 0 ? (steps / goal) * 100 : 0.0;

  /// Create a copy with modified fields.
  DailyHistoryModel copyWith({
    String? dateString,
    int? steps,
    int? goal,
    double? distanceKm,
    int? calories,
    int? activeMinutes,
    bool? isGoalReached,
    bool? isSynced,
  }) {
    final newSteps = steps ?? this.steps;
    final newGoal = goal ?? this.goal;
    final reached = isGoalReached ?? (newSteps >= newGoal);

    return DailyHistoryModel(
      dateString: dateString ?? this.dateString,
      steps: newSteps,
      goal: newGoal,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      isGoalReached: reached,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert to Map for Firestore / JSON / CSV.
  Map<String, dynamic> toMap() {
    return {
      'dateString': dateString,
      'steps': steps,
      'goal': goal,
      'distanceKm': distanceKm,
      'calories': calories,
      'activeMinutes': activeMinutes,
      'isGoalReached': isGoalReached,
      'isSynced': isSynced,
    };
  }

  /// Reconstruct from Firestore document map or JSON.
  factory DailyHistoryModel.fromMap(Map<String, dynamic> map) {
    final steps = (map['steps'] as num?)?.toInt() ?? 0;
    final goal = (map['goal'] as num?)?.toInt() ?? 6000;
    final isReached = (map['isGoalReached'] as bool?) ?? (steps >= goal);

    return DailyHistoryModel(
      dateString: (map['dateString'] as String?) ?? '',
      steps: steps,
      goal: goal,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      activeMinutes: (map['activeMinutes'] as num?)?.toInt() ?? 0,
      isGoalReached: isReached,
      isSynced: (map['isSynced'] as bool?) ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyHistoryModel &&
          runtimeType == other.runtimeType &&
          dateString == other.dateString &&
          steps == other.steps &&
          goal == other.goal &&
          distanceKm == other.distanceKm &&
          calories == other.calories &&
          activeMinutes == other.activeMinutes &&
          isGoalReached == other.isGoalReached &&
          isSynced == other.isSynced;

  @override
  int get hashCode =>
      dateString.hashCode ^
      steps.hashCode ^
      goal.hashCode ^
      distanceKm.hashCode ^
      calories.hashCode ^
      activeMinutes.hashCode ^
      isGoalReached.hashCode ^
      isSynced.hashCode;

  @override
  String toString() {
    return 'DailyHistoryModel(dateString: $dateString, steps: $steps, goal: $goal, distanceKm: $distanceKm, calories: $calories, activeMinutes: $activeMinutes, isGoalReached: $isGoalReached, isSynced: $isSynced)';
  }
}

/// Hive TypeAdapter for [DailyHistoryModel] with typeId = 2.
class DailyHistoryModelAdapter extends TypeAdapter<DailyHistoryModel> {
  @override
  final int typeId = 2;

  @override
  DailyHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DailyHistoryModel(
      dateString: (fields[0] as String?) ?? '',
      steps: (fields[1] as num?)?.toInt() ?? 0,
      goal: (fields[2] as num?)?.toInt() ?? 6000,
      distanceKm: (fields[3] as num?)?.toDouble() ?? 0.0,
      calories: (fields[4] as num?)?.toInt() ?? 0,
      activeMinutes: (fields[5] as num?)?.toInt() ?? 0,
      isGoalReached: (fields[6] as bool?) ?? false,
      isSynced: (fields[7] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, DailyHistoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dateString)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.goal)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.activeMinutes)
      ..writeByte(6)
      ..write(obj.isGoalReached)
      ..writeByte(7)
      ..write(obj.isSynced);
  }
}

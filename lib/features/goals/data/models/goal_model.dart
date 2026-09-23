import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Represents user-configured daily fitness goals.
@immutable
class GoalModel {
  final String id;
  final int dailyStepGoal;
  final double dailyDistanceGoalKm;
  final int dailyCalorieGoal;
  final DateTime updatedAt;
  final bool isSynced;

  const GoalModel({
    required this.id,
    required this.dailyStepGoal,
    required this.dailyDistanceGoalKm,
    required this.dailyCalorieGoal,
    required this.updatedAt,
    this.isSynced = false,
  });

  /// Factory constructor providing default standard goals (6,000 steps, 5.0 km, 300 kcal).
  factory GoalModel.defaultGoal({String id = 'default_goal'}) {
    return GoalModel(
      id: id,
      dailyStepGoal: 6000,
      dailyDistanceGoalKm: 5.0,
      dailyCalorieGoal: 300,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  /// Create a copy with modified fields.
  GoalModel copyWith({
    String? id,
    int? dailyStepGoal,
    double? dailyDistanceGoalKm,
    int? dailyCalorieGoal,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return GoalModel(
      id: id ?? this.id,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyDistanceGoalKm: dailyDistanceGoalKm ?? this.dailyDistanceGoalKm,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert to Map for JSON / local persistence.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dailyStepGoal': dailyStepGoal,
      'dailyDistanceGoalKm': dailyDistanceGoalKm,
      'dailyCalorieGoal': dailyCalorieGoal,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  /// Reconstruct from Map or JSON.
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: (map['id'] as String?) ?? 'default_goal',
      dailyStepGoal: (map['dailyStepGoal'] as num?)?.toInt() ?? 6000,
      dailyDistanceGoalKm: (map['dailyDistanceGoalKm'] as num?)?.toDouble() ?? 5.0,
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt() ?? 300,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSynced: (map['isSynced'] as bool?) ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          dailyStepGoal == other.dailyStepGoal &&
          dailyDistanceGoalKm == other.dailyDistanceGoalKm &&
          dailyCalorieGoal == other.dailyCalorieGoal &&
          updatedAt.millisecondsSinceEpoch == other.updatedAt.millisecondsSinceEpoch &&
          isSynced == other.isSynced;

  @override
  int get hashCode =>
      id.hashCode ^
      dailyStepGoal.hashCode ^
      dailyDistanceGoalKm.hashCode ^
      dailyCalorieGoal.hashCode ^
      updatedAt.millisecondsSinceEpoch.hashCode ^
      isSynced.hashCode;

  @override
  String toString() {
    return 'GoalModel(id: $id, dailyStepGoal: $dailyStepGoal, dailyDistanceGoalKm: $dailyDistanceGoalKm, dailyCalorieGoal: $dailyCalorieGoal, updatedAt: $updatedAt, isSynced: $isSynced)';
  }
}

/// Hive TypeAdapter for [GoalModel] with typeId = 1.
class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 1;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return GoalModel(
      id: (fields[0] as String?) ?? 'default_goal',
      dailyStepGoal: (fields[1] as num?)?.toInt() ?? 6000,
      dailyDistanceGoalKm: (fields[2] as num?)?.toDouble() ?? 5.0,
      dailyCalorieGoal: (fields[3] as num?)?.toInt() ?? 300,
      updatedAt: fields[4] is int
          ? DateTime.fromMillisecondsSinceEpoch(fields[4] as int)
          : DateTime.tryParse((fields[4] as String?) ?? '') ?? DateTime.now(),
      isSynced: (fields[5] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dailyStepGoal)
      ..writeByte(2)
      ..write(obj.dailyDistanceGoalKm)
      ..writeByte(3)
      ..write(obj.dailyCalorieGoal)
      ..writeByte(4)
      ..write(obj.updatedAt.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.isSynced);
  }
}

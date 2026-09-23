import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Represents a discrete recorded interval or live snapshot of steps.
@immutable
class StepRecordModel {
  final String id;
  final DateTime timestamp;
  final int steps;
  final double distanceKm;
  final int calories;
  final int activeMinutes;
  final bool isSynced;

  const StepRecordModel({
    required this.id,
    required this.timestamp,
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.activeMinutes,
    this.isSynced = false,
  });

  /// Factory constructor to create an empty or initial record.
  factory StepRecordModel.initial({String? id}) {
    return StepRecordModel(
      id: id ?? DateTime.now().toIso8601String(),
      timestamp: DateTime.now(),
      steps: 0,
      distanceKm: 0.0,
      calories: 0,
      activeMinutes: 0,
      isSynced: false,
    );
  }

  /// Create a copy with modified fields.
  StepRecordModel copyWith({
    String? id,
    DateTime? timestamp,
    int? steps,
    double? distanceKm,
    int? calories,
    int? activeMinutes,
    bool? isSynced,
  }) {
    return StepRecordModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert to a map for JSON serialization and local persistence.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'steps': steps,
      'distanceKm': distanceKm,
      'calories': calories,
      'activeMinutes': activeMinutes,
      'isSynced': isSynced,
    };
  }

  /// Reconstruct from Map or JSON.
  factory StepRecordModel.fromMap(Map<String, dynamic> map) {
    return StepRecordModel(
      id: (map['id'] as String?) ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      activeMinutes: (map['activeMinutes'] as num?)?.toInt() ?? 0,
      isSynced: (map['isSynced'] as bool?) ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepRecordModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp.millisecondsSinceEpoch == other.timestamp.millisecondsSinceEpoch &&
          steps == other.steps &&
          distanceKm == other.distanceKm &&
          calories == other.calories &&
          activeMinutes == other.activeMinutes &&
          isSynced == other.isSynced;

  @override
  int get hashCode =>
      id.hashCode ^
      timestamp.millisecondsSinceEpoch.hashCode ^
      steps.hashCode ^
      distanceKm.hashCode ^
      calories.hashCode ^
      activeMinutes.hashCode ^
      isSynced.hashCode;

  @override
  String toString() {
    return 'StepRecordModel(id: $id, timestamp: $timestamp, steps: $steps, distanceKm: $distanceKm, calories: $calories, activeMinutes: $activeMinutes, isSynced: $isSynced)';
  }
}

/// Hive TypeAdapter for [StepRecordModel] with typeId = 0.
class StepRecordModelAdapter extends TypeAdapter<StepRecordModel> {
  @override
  final int typeId = 0;

  @override
  StepRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return StepRecordModel(
      id: (fields[0] as String?) ?? '',
      timestamp: fields[1] is int
          ? DateTime.fromMillisecondsSinceEpoch(fields[1] as int)
          : DateTime.tryParse((fields[1] as String?) ?? '') ?? DateTime.now(),
      steps: (fields[2] as num?)?.toInt() ?? 0,
      distanceKm: (fields[3] as num?)?.toDouble() ?? 0.0,
      calories: (fields[4] as num?)?.toInt() ?? 0,
      activeMinutes: (fields[5] as num?)?.toInt() ?? 0,
      isSynced: (fields[6] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, StepRecordModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.activeMinutes)
      ..writeByte(6)
      ..write(obj.isSynced);
  }
}

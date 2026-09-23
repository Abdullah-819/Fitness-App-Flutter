import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Represents streak metrics for consecutive goal completion days.
@immutable
class StreakModel {
  final String id;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDate;
  final List<String> completedDates;
  final bool isSynced;

  const StreakModel({
    required this.id,
    required this.currentStreak,
    required this.bestStreak,
    this.lastActiveDate,
    this.completedDates = const [],
    this.isSynced = false,
  });

  /// Factory constructor providing initial default streak values.
  factory StreakModel.initial({String id = 'streak_tracker'}) {
    return StreakModel(
      id: id,
      currentStreak: 0,
      bestStreak: 0,
      lastActiveDate: null,
      completedDates: const [],
      isSynced: false,
    );
  }

  /// Create a copy with modified fields.
  StreakModel copyWith({
    String? id,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActiveDate,
    List<String>? completedDates,
    bool? isSynced,
  }) {
    return StreakModel(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedDates: completedDates ?? this.completedDates,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert to Map for JSON / local persistence.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'completedDates': completedDates,
      'isSynced': isSynced,
    };
  }

  /// Reconstruct from Map or JSON.
  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      id: (map['id'] as String?) ?? 'streak_tracker',
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.tryParse(map['lastActiveDate'].toString())
          : null,
      completedDates: (map['completedDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isSynced: (map['isSynced'] as bool?) ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          currentStreak == other.currentStreak &&
          bestStreak == other.bestStreak &&
          lastActiveDate?.millisecondsSinceEpoch ==
              other.lastActiveDate?.millisecondsSinceEpoch &&
          listEquals(completedDates, other.completedDates) &&
          isSynced == other.isSynced;

  @override
  int get hashCode =>
      id.hashCode ^
      currentStreak.hashCode ^
      bestStreak.hashCode ^
      (lastActiveDate?.millisecondsSinceEpoch ?? 0).hashCode ^
      Object.hashAll(completedDates) ^
      isSynced.hashCode;

  @override
  String toString() {
    return 'StreakModel(id: $id, currentStreak: $currentStreak, bestStreak: $bestStreak, lastActiveDate: $lastActiveDate, completedDates: $completedDates, isSynced: $isSynced)';
  }
}

/// Hive TypeAdapter for [StreakModel] with typeId = 3.
class StreakModelAdapter extends TypeAdapter<StreakModel> {
  @override
  final int typeId = 3;

  @override
  StreakModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return StreakModel(
      id: (fields[0] as String?) ?? 'streak_tracker',
      currentStreak: (fields[1] as num?)?.toInt() ?? 0,
      bestStreak: (fields[2] as num?)?.toInt() ?? 0,
      lastActiveDate: fields[3] is int
          ? DateTime.fromMillisecondsSinceEpoch(fields[3] as int)
          : DateTime.tryParse((fields[3] as String?) ?? ''),
      completedDates: (fields[4] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isSynced: (fields[5] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, StreakModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.bestStreak)
      ..writeByte(3)
      ..write(obj.lastActiveDate?.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.completedDates)
      ..writeByte(5)
      ..write(obj.isSynced);
  }
}

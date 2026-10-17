import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UnitSystem { metric, imperial }

/// App-level preferences that are not part of the user's profile.
class AppPreferences {
  final UnitSystem unitSystem;
  final String sensitivity;
  final int stepLengthCm;
  final String firstDayOfWeek;
  final bool reminderEnabled;

  /// Minutes after midnight.
  final int reminderMinutes;

  const AppPreferences({
    this.unitSystem = UnitSystem.metric,
    this.sensitivity = 'Medium',
    this.stepLengthCm = 74,
    this.firstDayOfWeek = 'Sunday',
    this.reminderEnabled = true,
    this.reminderMinutes = 7 * 60,
  });

  static const sensitivities = ['Low', 'Medium', 'High'];
  static const weekdays = ['Saturday', 'Sunday', 'Monday'];

  AppPreferences copyWith({
    UnitSystem? unitSystem,
    String? sensitivity,
    int? stepLengthCm,
    String? firstDayOfWeek,
    bool? reminderEnabled,
    int? reminderMinutes,
  }) => AppPreferences(
    unitSystem: unitSystem ?? this.unitSystem,
    sensitivity: sensitivity ?? this.sensitivity,
    stepLengthCm: stepLengthCm ?? this.stepLengthCm,
    firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
  );

  Map<String, Object?> toMap() => {
    'unit': unitSystem.name,
    'sensitivity': sensitivity,
    'stepLengthCm': stepLengthCm,
    'firstDay': firstDayOfWeek,
    'reminder': reminderEnabled,
    'reminderMinutes': reminderMinutes,
  };

  factory AppPreferences.fromMap(Map<dynamic, dynamic>? map) {
    const d = AppPreferences();
    if (map == null) return d;
    final sensitivity = map['sensitivity'] as String?;
    final firstDay = map['firstDay'] as String?;
    return AppPreferences(
      unitSystem: map['unit'] == 'imperial'
          ? UnitSystem.imperial
          : UnitSystem.metric,
      sensitivity: sensitivities.contains(sensitivity)
          ? sensitivity!
          : d.sensitivity,
      stepLengthCm: map['stepLengthCm'] as int? ?? d.stepLengthCm,
      firstDayOfWeek: weekdays.contains(firstDay) ? firstDay! : d.firstDayOfWeek,
      reminderEnabled: map['reminder'] as bool? ?? d.reminderEnabled,
      reminderMinutes: map['reminderMinutes'] as int? ?? d.reminderMinutes,
    );
  }
}

/// Persists [AppPreferences] in a small Hive box.
class PreferencesStore {
  PreferencesStore._();

  static final PreferencesStore instance = PreferencesStore._();

  static const String _boxName = 'preferences_box';
  static const String _key = 'app';

  Future<Box<Map<dynamic, dynamic>>> _box() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Map<dynamic, dynamic>>(_boxName);
    }
    await Hive.initFlutter();
    return Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  Future<AppPreferences> load() async {
    try {
      return AppPreferences.fromMap((await _box()).get(_key));
    } catch (e) {
      debugPrint('PreferencesStore: load failed ($e)');
      return const AppPreferences();
    }
  }

  Future<void> save(AppPreferences prefs) async {
    try {
      await (await _box()).put(_key, prefs.toMap());
    } catch (e) {
      debugPrint('PreferencesStore: save failed ($e)');
    }
  }
}

/// Display helpers that convert the metric values the app stores.
class UnitFormat {
  const UnitFormat._();

  static const _lbsPerKg = 2.20462;
  static const _cmPerInch = 2.54;

  static String weight(double kg, UnitSystem u) => u == UnitSystem.metric
      ? '${kg.round()} kg'
      : '${(kg * _lbsPerKg).round()} lbs';

  static String height(double cm, UnitSystem u) {
    if (u == UnitSystem.metric) return '${cm.round()} cm';
    final totalInches = (cm / _cmPerInch).round();
    return '${totalInches ~/ 12}\'${totalInches % 12}"';
  }

  static String length(int cm, UnitSystem u) => u == UnitSystem.metric
      ? '$cm cm'
      : '${(cm / _cmPerInch).round()} in';

  static String distanceUnits(UnitSystem u) =>
      u == UnitSystem.metric ? 'kg / cm / km' : 'lbs / ft / mi';

  static String time(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';
}

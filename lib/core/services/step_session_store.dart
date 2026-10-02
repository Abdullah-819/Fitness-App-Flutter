import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Snapshot of today's step counting session, saved so counting can resume
/// (and catch up on steps taken while the app was closed) after a restart.
class StepSession {
  /// Calendar day the snapshot belongs to (yyyy-mm-dd).
  final String day;
  final int steps;
  final int elapsedSeconds;

  /// Whether the user had counting switched on when the snapshot was saved.
  final bool active;

  /// Raw hardware step-counter value that corresponds to [steps].
  final int? sensorBaseline;

  /// Milliseconds since epoch when the snapshot was saved.
  final int savedAtMs;

  const StepSession({
    required this.day,
    required this.steps,
    required this.elapsedSeconds,
    required this.active,
    required this.sensorBaseline,
    required this.savedAtMs,
  });

  static String dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, Object?> toMap() => {
    'day': day,
    'steps': steps,
    'elapsed': elapsedSeconds,
    'active': active,
    'baseline': sensorBaseline,
    'savedAt': savedAtMs,
  };

  static StepSession? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    return StepSession(
      day: map['day'] as String? ?? '',
      steps: map['steps'] as int? ?? 0,
      elapsedSeconds: map['elapsed'] as int? ?? 0,
      active: map['active'] as bool? ?? false,
      sensorBaseline: map['baseline'] as int?,
      savedAtMs: map['savedAt'] as int? ?? 0,
    );
  }
}

/// Persists the current [StepSession] in a small Hive box.
class StepSessionStore {
  StepSessionStore._();

  static final StepSessionStore instance = StepSessionStore._();

  static const String _boxName = 'step_session_box';
  static const String _key = 'current';

  Future<Box<Map<dynamic, dynamic>>> _box() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Map<dynamic, dynamic>>(_boxName);
    }
    await Hive.initFlutter();
    return Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  Future<StepSession?> load() async {
    try {
      final box = await _box();
      return StepSession.fromMap(box.get(_key));
    } catch (e) {
      debugPrint('StepSessionStore: load failed ($e)');
      return null;
    }
  }

  Future<void> save(StepSession session) async {
    try {
      final box = await _box();
      await box.put(_key, session.toMap());
    } catch (e) {
      debugPrint('StepSessionStore: save failed ($e)');
    }
  }
}

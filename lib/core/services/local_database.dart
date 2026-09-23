import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/goals/data/models/goal_model.dart';
import '../../features/history/data/models/daily_history_model.dart';
import '../../features/home/data/models/step_record_model.dart';
import '../../features/streak/data/models/streak_model.dart';

/// Central local persistence service managing Hive initialization,
/// adapter registration, and box lifecycles across the application.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  // Box name constants
  static const String boxStepRecords = 'step_records_box';
  static const String boxGoals = 'goals_box';
  static const String boxDailyHistory = 'daily_history_box';
  static const String boxStreaks = 'streaks_box';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  late Box<StepRecordModel> _stepRecordsBox;
  late Box<GoalModel> _goalsBox;
  late Box<DailyHistoryModel> _historyBox;
  late Box<StreakModel> _streakBox;

  Box<StepRecordModel> get stepRecordsBox => _stepRecordsBox;
  Box<GoalModel> get goalsBox => _goalsBox;
  Box<DailyHistoryModel> get historyBox => _historyBox;
  Box<StreakModel> get streakBox => _streakBox;

  /// Initializes Hive on the local device, registers all TypeAdapters,
  /// and opens the required persistent boxes.
  ///
  /// In production, [customPath] is null and [Hive.initFlutter] is used.
  /// In unit tests, pass a temporary directory path.
  Future<void> init([String? customPath]) async {
    if (_isInitialized) return;

    // Initialize Hive with Flutter-specific directory support or custom path
    if (customPath != null) {
      Hive.init(customPath);
    } else {
      await Hive.initFlutter();
    }

    // Register Model Adapters if not already registered
    _registerAdapters();

    // Open persistent typed boxes
    _stepRecordsBox = await Hive.openBox<StepRecordModel>(boxStepRecords);
    _goalsBox = await Hive.openBox<GoalModel>(boxGoals);
    _historyBox = await Hive.openBox<DailyHistoryModel>(boxDailyHistory);
    _streakBox = await Hive.openBox<StreakModel>(boxStreaks);

    _isInitialized = true;
    debugPrint('LocalDatabase: Hive initialized and all boxes opened successfully.');
  }

  /// Registers binary TypeAdapters for all persistent database models.
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StepRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GoalModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DailyHistoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(StreakModelAdapter());
    }
  }

  /// Clears all local box data across all features (useful on sign-out or account reset).
  Future<void> clearAll() async {
    if (!_isInitialized) return;
    await Future.wait([
      _stepRecordsBox.clear(),
      _goalsBox.clear(),
      _historyBox.clear(),
      _streakBox.clear(),
    ]);
    debugPrint('LocalDatabase: All boxes cleared successfully.');
  }

  /// Closes all opened boxes cleanly.
  Future<void> closeAll() async {
    if (!_isInitialized) return;
    await Future.wait([
      _stepRecordsBox.close(),
      _goalsBox.close(),
      _historyBox.close(),
      _streakBox.close(),
    ]);
    _isInitialized = false;
    debugPrint('LocalDatabase: All boxes closed.');
  }
}

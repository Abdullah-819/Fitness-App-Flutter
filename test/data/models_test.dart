import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:step_counter/features/goals/data/models/goal_model.dart';
import 'package:step_counter/features/history/data/models/daily_history_model.dart';
import 'package:step_counter/features/home/data/models/step_record_model.dart';
import 'package:step_counter/features/streak/data/models/streak_model.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_models_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(StepRecordModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(DailyHistoryModelAdapter());
    Hive.registerAdapter(StreakModelAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('StepRecordModel Tests', () {
    test('serialization toMap and fromMap works correctly', () {
      final now = DateTime(2026, 9, 24, 10, 30);
      final model = StepRecordModel(
        id: 'rec_1',
        timestamp: now,
        steps: 1500,
        distanceKm: 1.15,
        calories: 75,
        activeMinutes: 18,
        isSynced: true,
      );

      final map = model.toMap();
      final reconstructed = StepRecordModel.fromMap(map);

      expect(reconstructed.id, equals('rec_1'));
      expect(reconstructed.steps, equals(1500));
      expect(reconstructed.distanceKm, closeTo(1.15, 0.001));
      expect(reconstructed.calories, equals(75));
      expect(reconstructed.activeMinutes, equals(18));
      expect(reconstructed.isSynced, isTrue);
    });

    test('copyWith updates specified fields only', () {
      final model = StepRecordModel.initial(id: 'init_1');
      final updated = model.copyWith(steps: 2500, calories: 120);

      expect(updated.id, equals('init_1'));
      expect(updated.steps, equals(2500));
      expect(updated.calories, equals(120));
      expect(updated.distanceKm, equals(0.0));
    });

    test('StepRecordModel stores and retrieves from Hive box correctly', () async {
      final box = await Hive.openBox<StepRecordModel>('step_records_test_box');
      final now = DateTime(2026, 9, 24, 12, 0);
      final original = StepRecordModel(
        id: 'step_adapter_test',
        timestamp: now,
        steps: 3200,
        distanceKm: 2.45,
        calories: 160,
        activeMinutes: 30,
        isSynced: false,
      );

      await box.put(original.id, original);
      final retrieved = box.get(original.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(original.id));
      expect(retrieved.steps, equals(original.steps));
      expect(retrieved.distanceKm, closeTo(original.distanceKm, 0.001));
      expect(retrieved.calories, equals(original.calories));
      expect(retrieved.activeMinutes, equals(original.activeMinutes));
      expect(retrieved.isSynced, equals(original.isSynced));

      await box.close();
    });
  });

  group('GoalModel Tests', () {
    test('defaultGoal creates standard 6000 steps goal', () {
      final goal = GoalModel.defaultGoal();
      expect(goal.dailyStepGoal, equals(6000));
      expect(goal.dailyDistanceGoalKm, equals(5.0));
      expect(goal.dailyCalorieGoal, equals(300));
      expect(goal.isSynced, isFalse);
    });

    test('serialization toMap and fromMap works correctly', () {
      final now = DateTime(2026, 9, 24, 8, 0);
      final goal = GoalModel(
        id: 'user_goal_1',
        dailyStepGoal: 8500,
        dailyDistanceGoalKm: 6.5,
        dailyCalorieGoal: 450,
        updatedAt: now,
        isSynced: true,
      );

      final map = goal.toMap();
      final reconstructed = GoalModel.fromMap(map);

      expect(reconstructed.id, equals('user_goal_1'));
      expect(reconstructed.dailyStepGoal, equals(8500));
      expect(reconstructed.dailyDistanceGoalKm, closeTo(6.5, 0.001));
      expect(reconstructed.dailyCalorieGoal, equals(450));
      expect(reconstructed.isSynced, isTrue);
    });

    test('GoalModel stores and retrieves from Hive box correctly', () async {
      final box = await Hive.openBox<GoalModel>('goals_test_box');
      final goal = GoalModel.defaultGoal();

      await box.put(goal.id, goal);
      final retrieved = box.get(goal.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(goal.id));
      expect(retrieved.dailyStepGoal, equals(goal.dailyStepGoal));
      expect(retrieved.dailyDistanceGoalKm, closeTo(goal.dailyDistanceGoalKm, 0.001));
      expect(retrieved.dailyCalorieGoal, equals(goal.dailyCalorieGoal));
      expect(retrieved.isSynced, equals(goal.isSynced));

      await box.close();
    });
  });

  group('DailyHistoryModel Tests', () {
    test('calculates dateKey, progressRatio, and isGoalReached properly', () {
      final date = DateTime(2026, 9, 24);
      final key = DailyHistoryModel.formatDateKey(date);
      expect(key, equals('2026-09-24'));

      final history = DailyHistoryModel(
        dateString: key,
        steps: 4500,
        goal: 6000,
        distanceKm: 3.2,
        calories: 210,
        activeMinutes: 45,
        isGoalReached: false,
      );

      expect(history.progressRatio, closeTo(0.75, 0.01));
      expect(history.progressPercentage, closeTo(75.0, 0.1));
      expect(history.isGoalReached, isFalse);

      final reachedHistory = history.copyWith(steps: 6500);
      expect(reachedHistory.isGoalReached, isTrue);
      expect(reachedHistory.progressRatio, equals(1.0));
    });

    test('DailyHistoryModel stores and retrieves from Hive box correctly', () async {
      final box = await Hive.openBox<DailyHistoryModel>('history_test_box');
      final model = DailyHistoryModel(
        dateString: '2026-09-24',
        steps: 7200,
        goal: 6000,
        distanceKm: 5.1,
        calories: 320,
        activeMinutes: 65,
        isGoalReached: true,
        isSynced: true,
      );

      await box.put(model.dateString, model);
      final retrieved = box.get(model.dateString);

      expect(retrieved, isNotNull);
      expect(retrieved!.dateString, equals(model.dateString));
      expect(retrieved.steps, equals(model.steps));
      expect(retrieved.goal, equals(model.goal));
      expect(retrieved.distanceKm, closeTo(model.distanceKm, 0.001));
      expect(retrieved.calories, equals(model.calories));
      expect(retrieved.activeMinutes, equals(model.activeMinutes));
      expect(retrieved.isGoalReached, isTrue);
      expect(retrieved.isSynced, isTrue);

      await box.close();
    });
  });

  group('StreakModel Tests', () {
    test('initial values and copyWith test', () {
      final streak = StreakModel.initial();
      expect(streak.currentStreak, equals(0));
      expect(streak.bestStreak, equals(0));
      expect(streak.completedDates, isEmpty);

      final updated = streak.copyWith(
        currentStreak: 5,
        bestStreak: 7,
        completedDates: ['2026-09-20', '2026-09-21', '2026-09-22', '2026-09-23', '2026-09-24'],
      );

      expect(updated.currentStreak, equals(5));
      expect(updated.bestStreak, equals(7));
      expect(updated.completedDates.length, equals(5));
    });

    test('StreakModel stores and retrieves from Hive box correctly', () async {
      final box = await Hive.openBox<StreakModel>('streak_test_box');
      final now = DateTime(2026, 9, 24);
      final model = StreakModel(
        id: 'streak_test',
        currentStreak: 3,
        bestStreak: 12,
        lastActiveDate: now,
        completedDates: ['2026-09-22', '2026-09-23', '2026-09-24'],
        isSynced: false,
      );

      await box.put(model.id, model);
      final retrieved = box.get(model.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(model.id));
      expect(retrieved.currentStreak, equals(3));
      expect(retrieved.bestStreak, equals(12));
      expect(retrieved.completedDates, equals(['2026-09-22', '2026-09-23', '2026-09-24']));
      expect(retrieved.isSynced, isFalse);

      await box.close();
    });
  });
}

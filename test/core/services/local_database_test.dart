import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/core/services/local_database.dart';
import 'package:step_counter/features/goals/data/models/goal_model.dart';
import 'package:step_counter/features/history/data/models/daily_history_model.dart';
import 'package:step_counter/features/home/data/models/step_record_model.dart';
import 'package:step_counter/features/streak/data/models/streak_model.dart';

void main() {
  late Directory tempDir;
  final db = LocalDatabase.instance;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('local_database_test_');
    await db.init(tempDir.path);
  });

  tearDown(() async {
    await db.closeAll();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('LocalDatabase initializes and opens all four boxes', () {
    expect(db.isInitialized, isTrue);
    expect(db.stepRecordsBox.isOpen, isTrue);
    expect(db.goalsBox.isOpen, isTrue);
    expect(db.historyBox.isOpen, isTrue);
    expect(db.streakBox.isOpen, isTrue);
  });

  test('Can perform CRUD on all typed boxes through LocalDatabase', () async {
    // 1. Step Records Box
    final record = StepRecordModel(
      id: 'step_1',
      timestamp: DateTime(2026, 9, 24, 10),
      steps: 1200,
      distanceKm: 0.9,
      calories: 60,
      activeMinutes: 15,
    );
    await db.stepRecordsBox.put(record.id, record);
    expect(db.stepRecordsBox.get('step_1')?.steps, equals(1200));

    // 2. Goals Box
    final goal = GoalModel.defaultGoal(id: 'active_goal');
    await db.goalsBox.put(goal.id, goal);
    expect(db.goalsBox.get('active_goal')?.dailyStepGoal, equals(6000));

    // 3. History Box
    final history = DailyHistoryModel(
      dateString: '2026-09-24',
      steps: 6050,
      goal: 6000,
      distanceKm: 4.5,
      calories: 280,
      activeMinutes: 50,
      isGoalReached: true,
    );
    await db.historyBox.put(history.dateString, history);
    expect(db.historyBox.get('2026-09-24')?.isGoalReached, isTrue);

    // 4. Streak Box
    final streak = StreakModel.initial(id: 'active_streak').copyWith(currentStreak: 4);
    await db.streakBox.put(streak.id, streak);
    expect(db.streakBox.get('active_streak')?.currentStreak, equals(4));
  });

  test('clearAll clears all data from boxes', () async {
    await db.goalsBox.put('temp', GoalModel.defaultGoal());
    expect(db.goalsBox.isNotEmpty, isTrue);

    await db.clearAll();
    expect(db.goalsBox.isEmpty, isTrue);
    expect(db.stepRecordsBox.isEmpty, isTrue);
    expect(db.historyBox.isEmpty, isTrue);
    expect(db.streakBox.isEmpty, isTrue);
  });
}

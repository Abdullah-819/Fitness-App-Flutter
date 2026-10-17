import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/domain/models/user_model.dart';
import 'package:step_counter/features/settings/data/app_preferences.dart';
import 'package:step_counter/features/settings/presentation/screens/preferences_screen.dart';

import '../../helpers/memory_hive.dart';

const _user = UserModel(
  id: 'u1',
  email: 'a@b.com',
  name: 'Test',
  gender: 'Man',
  age: 28,
  heightCm: 185,
  weightKg: 76,
  dailyStepGoal: 6000,
);

Future<void> pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(home: PreferencesScreen(user: _user)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async => openMemoryBoxes());

  group('UnitFormat', () {
    test('converts metric values for imperial display', () {
      expect(UnitFormat.weight(76, UnitSystem.imperial), '168 lbs');
      expect(UnitFormat.height(185, UnitSystem.imperial), '6\'1"');
      expect(UnitFormat.length(74, UnitSystem.imperial), '29 in');
      expect(UnitFormat.time(420), '07:00');
    });

    test('preferences round-trip through a map', () {
      const prefs = AppPreferences(
        unitSystem: UnitSystem.imperial,
        sensitivity: 'High',
        reminderEnabled: false,
        reminderMinutes: 18 * 60 + 30,
      );
      final copy = AppPreferences.fromMap(prefs.toMap());
      expect(copy.unitSystem, UnitSystem.imperial);
      expect(copy.sensitivity, 'High');
      expect(copy.reminderEnabled, false);
      expect(copy.reminderMinutes, 1110);
    });
  });

  group('Preferences screen', () {
    testWidgets('shows every row from the design', (tester) async {
      await pumpScreen(tester);

      for (final t in [
        'Gender', 'Male', 'Age', '28 years', 'Height', '185 cm', 'Weight',
        '76 kg', 'Unit', 'kg / cm / km', 'Step Goal', '6000 steps',
        'Sensitivity', 'Medium', 'Step Length', '74 cm', 'First Day of Week',
        'Sunday', 'Daily Step Reminder', 'Reminder Time', '07:00',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('changing sensitivity updates and persists', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Sensitivity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);
      expect((await PreferencesStore.instance.load()).sensitivity, 'High');
    });

    testWidgets('switching unit converts weight and height', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Unit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('lbs / ft / mi'));
      await tester.pumpAndSettle();

      expect(find.text('168 lbs'), findsOneWidget);
      expect(find.text('6\'1"'), findsOneWidget);
    });

    testWidgets('reminder switch toggles', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect((await PreferencesStore.instance.load()).reminderEnabled, false);
    });
  });
}

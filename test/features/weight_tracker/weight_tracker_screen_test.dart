import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/weight_tracker/data/weight_models.dart';
import 'package:step_counter/features/weight_tracker/presentation/screens/weight_tracker_screen.dart';
import 'package:step_counter/features/weight_tracker/presentation/widgets/bmi_gauge.dart';
import 'package:step_counter/features/weight_tracker/presentation/widgets/weight_line_chart.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const WeightTrackerScreen(initialWeightKg: 76, heightCm: 185),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('BMI helpers', () {
    test('calculates BMI from kg and cm', () {
      expect(calculateBmi(76, 185), closeTo(22.2, 0.05));
    });

    test('maps BMI to WHO categories', () {
      expect(bmiCategoryFor(17).label, 'Underweight');
      expect(bmiCategoryFor(22.2).label, 'Normal');
      expect(bmiCategoryFor(27).label, 'Overweight');
      expect(bmiCategoryFor(35).label, 'Obese');
      expect(bmiCategoryFor(45).label, 'Morbidly Obese');
    });

    test('needle fraction stays inside the arc and rises with BMI', () {
      expect(BmiGauge.fractionFor(0), 0);
      expect(BmiGauge.fractionFor(200), 1);
      expect(BmiGauge.fractionFor(22.2), inInclusiveRange(0.2, 0.4));
      expect(BmiGauge.fractionFor(30), greaterThan(BmiGauge.fractionFor(22)));
    });
  });

  group('Weight Tracker Screen', () {
    testWidgets('shows chart card, BMI card and range pill', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Weight Tracker'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Last 6 Months'), findsOneWidget);
      expect(find.byType(WeightLineChart), findsOneWidget);
      expect(find.byType(BmiGauge), findsOneWidget);
      expect(find.text('BMI (kg/m2): 22.2'), findsOneWidget);
    });

    testWidgets('renders in dark theme without errors', (tester) async {
      await pumpScreen(tester, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('range sheet changes the selected range', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Last 6 Months'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 3 Months'));
      await tester.pumpAndSettle();

      expect(find.text('Last 3 Months'), findsOneWidget);
    });

    testWidgets('add sheet opens from the plus button', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('Add weight'));
      await tester.pumpAndSettle();

      expect(find.text('Log Your Weight'), findsOneWidget);
      await tester.tap(find.text('Save Weight'));
      await tester.pumpAndSettle();
      expect(find.text('Log Your Weight'), findsNothing);
    });

    testWidgets('edit height sheet updates the BMI', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('Edit height'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Your Height'), findsOneWidget);

      await tester.tap(find.text('Save Height'));
      await tester.pumpAndSettle();
      expect(find.text('BMI (kg/m2): 22.2'), findsOneWidget);
    });
  });
}

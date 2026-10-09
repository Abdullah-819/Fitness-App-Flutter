import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/water_tracker/presentation/screens/water_tracker_screen.dart';
import 'package:step_counter/features/water_tracker/presentation/widgets/water_droplet_indicator.dart';
import 'package:step_counter/features/water_tracker/presentation/widgets/water_history_chart.dart';

/// The droplet waves loop forever, so `pumpAndSettle` would never finish.
/// Advance time explicitly instead.
Future<void> advance(WidgetTester tester, [int ms = 2200]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: ms));
}

Future<void> pumpScreen(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
  bool disableAnimations = false,
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: const WaterTrackerScreen(),
    ),
  );
}

void main() {
  group('Water Tracker Screen', () {
    testWidgets('Renders all design components with complete accuracy',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);

      // 1. App Bar
      expect(find.text('Water Tracker'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // 2. Water Droplet Gauge
      expect(find.byType(WaterDropletIndicator), findsOneWidget);
      expect(find.text('44%'), findsOneWidget);
      expect(find.text('1,750 / 4,000 ml'), findsOneWidget);

      // 3. Drink Button
      expect(find.widgetWithText(ElevatedButton, 'Drink'), findsOneWidget);

      // 4. History Section
      expect(find.text('History'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // 5. Bar Chart Y-Axis
      for (final label in ['4k', '3k', '2k', '1k']) {
        expect(find.text(label), findsOneWidget);
      }

      // 6. Bar Chart X-Axis Days (16 to 22)
      for (int day = 16; day <= 22; day++) {
        expect(find.text(day.toString()), findsOneWidget);
      }

      // 7. Floating Tooltip on Selected Day (20)
      expect(find.text('2,750'), findsOneWidget);
      expect(find.text('ml'), findsOneWidget);
      expect(find.byType(WaterHistoryChart), findsOneWidget);
    });

    testWidgets('Numbers count up from zero when the screen opens',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Mid-animation: not at the final value yet.
      expect(find.text('44%'), findsNothing);
      expect(find.text('1,750 / 4,000 ml'), findsNothing);

      await advance(tester);
      expect(find.text('44%'), findsOneWidget);
      expect(find.text('1,750 / 4,000 ml'), findsOneWidget);
    });

    testWidgets('Tapping "Drink" adds water and shows the Drinking state',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Drink'));
      await advance(tester, 400);

      // Bottom sheet with portions appears
      expect(find.text('Add Water Intake'), findsOneWidget);
      expect(find.text('250 ml'), findsOneWidget);
      expect(find.text('500 ml'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Quick Add +250 ml'));
      await advance(tester, 500);

      // Button morphs into the outlined "Drinking..." state (design 48) and
      // a "+250 ml" label floats up from the droplet.
      expect(find.text('Drinking...'), findsOneWidget);
      expect(find.text('+250 ml'), findsOneWidget);

      await advance(tester);
      // Let the button finish morphing back to "Drink".
      await advance(tester, 500);

      // Level finished rising: 1,750 -> 2,000 ml (50%) and Drink is back.
      expect(find.text('2,000 / 4,000 ml'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Drinking...'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Drink'), findsOneWidget);
    });

    testWidgets('Choosing a portion tile logs that amount',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Drink'));
      await advance(tester, 400);
      await tester.tap(find.text('500 ml'));
      await advance(tester);

      expect(find.text('2,250 / 4,000 ml'), findsOneWidget);
      expect(find.text('56%'), findsOneWidget);
    });

    testWidgets('Tapping Settings opens water goal adjustment dialog',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await advance(tester, 400);

      expect(find.text('Water Goal Settings'), findsOneWidget);
      expect(find.text('4,000 ml'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await advance(tester, 400);
      expect(find.text('4,250 ml'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await advance(tester);

      expect(find.text('1,750 / 4,250 ml'), findsOneWidget);
    });

    testWidgets('Reaching the goal shows the "Daily goal reached" chip',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);
      expect(find.text('Daily goal reached!'), findsNothing);

      // Lower the goal to 1,000 ml (12 x 250 ml steps) so 1,750 ml is enough.
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await advance(tester, 400);
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump(const Duration(milliseconds: 260));
      }
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await advance(tester);

      expect(find.text('Daily goal reached!'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('Selecting another day in the chart updates selection and tooltip',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);

      // Day 19 has 3,850 ml
      await tester.tap(find.text('19'));
      await advance(tester, 500);

      expect(find.text('3,850'), findsOneWidget);
      expect(find.text('2,750'), findsNothing);
    });

    testWidgets('Changing the history range updates the label',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await advance(tester);

      await tester.tap(find.text('This Week'));
      await advance(tester, 400);
      await tester.tap(find.text('Last Week'));
      await advance(tester, 500);

      expect(find.text('Last Week'), findsOneWidget);
      expect(find.text('This Week'), findsNothing);
    });

    testWidgets('Respects reduce-motion: values appear without animating',
        (WidgetTester tester) async {
      await pumpScreen(tester, disableAnimations: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('44%'), findsOneWidget);
      expect(find.text('1,750 / 4,000 ml'), findsOneWidget);
    });

    testWidgets('Renders in dark theme without errors',
        (WidgetTester tester) async {
      await pumpScreen(tester, themeMode: ThemeMode.dark);
      await advance(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Water Tracker'), findsOneWidget);
      expect(find.text('44%'), findsOneWidget);
    });
  });
}

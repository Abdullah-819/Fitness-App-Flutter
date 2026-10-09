import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/water_tracker/presentation/screens/water_tracker_screen.dart';
import 'package:step_counter/features/water_tracker/presentation/widgets/water_droplet_indicator.dart';
import 'package:step_counter/features/water_tracker/presentation/widgets/water_history_chart.dart';

void main() {
  group('Water Tracker Screen Verification (47_Dark_water tracker.png in White Theme)', () {
    testWidgets('Renders all design components with complete accuracy',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WaterTrackerScreen(),
        ),
      );
      // Pump initial frame
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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
      expect(find.text('4k'), findsOneWidget);
      expect(find.text('3k'), findsOneWidget);
      expect(find.text('2k'), findsOneWidget);
      expect(find.text('1k'), findsOneWidget);

      // 6. Bar Chart X-Axis Days (16 to 22)
      for (int day = 16; day <= 22; day++) {
        expect(find.text(day.toString()), findsOneWidget);
      }

      // 7. Floating Tooltip on Selected Day (20)
      expect(find.text('2,750'), findsOneWidget);
      expect(find.text('ml'), findsOneWidget);
      expect(find.byType(WaterHistoryChart), findsOneWidget);
    });

    testWidgets('Tapping "Drink" opens portion selector and adds water intake',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WaterTrackerScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap "Drink"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Drink'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Bottom sheet with portions appears
      expect(find.text('Add Water Intake'), findsOneWidget);
      expect(find.text('250 ml'), findsOneWidget);
      expect(find.text('500 ml'), findsOneWidget);

      // Tap +250 ml button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Quick Add +250 ml'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Total increased from 1,750 to 2,000 ml (50%)
      expect(find.text('2,000 / 4,000 ml'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('Tapping Settings opens water goal adjustment dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WaterTrackerScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Settings gear
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Water Goal Settings'), findsOneWidget);
      expect(find.text('4,000 ml'), findsOneWidget);

      // Increase goal by 250
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      expect(find.text('4,250 ml'), findsOneWidget);

      // Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('1,750 / 4,250 ml'), findsOneWidget);
    });

    testWidgets('Selecting another day in the chart updates selection and tooltip',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WaterTrackerScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Day 19 has 3,850 ml
      await tester.tap(find.text('19'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('3,850'), findsOneWidget);
    });
  });
}

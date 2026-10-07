import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:step_counter/features/auth/domain/models/user_model.dart';
import 'package:step_counter/features/dashboard/dashboard.dart';
import 'package:step_counter/features/history/history.dart';

import '../../helpers/memory_hive.dart';

void main() {
  setUp(openMemoryBoxes);

  const testUser = UserModel(
    id: 'test_user_id',
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
  );

  group('Report & History Screen Tests (matching design/History/32_Light_report.png)', () {
    testWidgets('ReportScreen renders with high accuracy matching Screen 32',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
          child: const MaterialApp(
            home: ReportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify App Bar
      expect(find.text('Report'), findsOneWidget);

      // 2. Verify Overview Summary Card
      expect(find.text('256,480'), findsOneWidget);
      expect(find.text('Total steps all the time'), findsOneWidget);
      expect(find.text('85h 24m'), findsOneWidget);
      expect(find.text('time'), findsOneWidget);
      expect(find.text('20,492'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
      expect(find.text('294.35'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);

      // 3. Verify Statistics Card
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('This Week'), findsWidgets);
      // Tooltip on highlighted bar (Day 20)
      expect(find.text('5,289'), findsOneWidget);
      expect(find.text('steps'), findsWidgets);
      // Bar chart X-Axis Day labels (16 to 22)
      expect(find.text('16'), findsWidgets);
      expect(find.text('17'), findsWidgets);
      expect(find.text('18'), findsWidgets);
      expect(find.text('19'), findsWidgets);
      expect(find.text('20'), findsWidgets);
      expect(find.text('21'), findsWidgets);
      expect(find.text('22'), findsWidgets);

      // Metric switcher pills
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Calorie'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);

      // 4. Verify "Your Progress" Month Calendar Card
      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('December 2024'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('Metric switcher pills toggle chart units in Statistics card',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
          child: const MaterialApp(
            home: ReportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Calorie
      await tester.tap(find.text('Calorie'));
      await tester.pumpAndSettle();
      expect(find.text('kcal'), findsWidgets);

      // Switch to Distance
      await tester.tap(find.text('Distance'));
      await tester.pumpAndSettle();
      expect(find.text('km'), findsWidgets);

      // Switch back to Steps
      await tester.tap(find.text('Steps'));
      await tester.pumpAndSettle();
      expect(find.text('steps'), findsWidgets);
    });

    testWidgets('Date Range selector opens modal sheet matching Screen 33',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
          child: const MaterialApp(
            home: ReportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the "This Week" dropdown button in the Statistics card
      await tester.tap(find.text('This Week').first);
      await tester.pumpAndSettle();

      // Verify the modal options from design Screen 33
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('Last 6 Months'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('Last Year'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('Custom Range'), findsOneWidget);

      // Select "All Time"
      await tester.tap(find.text('All Time'));
      await tester.pumpAndSettle();
      expect(find.text('All Time'), findsWidgets);
    });

    testWidgets('HistoryScreen renders list and supports delete and undo',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = HistoryProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Saturday, Dec 21 2024'), findsOneWidget);
      expect(find.text('6,496'), findsOneWidget);

      // Delete the first item
      final firstRecord = provider.historyRecords.first;
      provider.deleteRecord(firstRecord);
      await tester.pumpAndSettle();

      // Verify deletion banner appeared
      expect(find.text('History has been deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Verify item restored
      expect(find.text('6,496'), findsOneWidget);
    });

    testWidgets('DashboardScreen switches to Report tab and displays ReportScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(user: testUser),
        ),
      );
      await tester.pump();

      // Tap Report tab in Dashboard bottom navigation
      await tester.tap(find.bySemanticsLabel('Report'));
      await tester.pumpAndSettle();

      // Title should now be Report
      expect(find.text('Report'), findsOneWidget);
      // Report card content should be visible
      expect(find.text('256,480'), findsOneWidget);
      expect(find.text('Total steps all the time'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Your Progress'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/domain/models/user_model.dart';
import 'package:step_counter/features/dashboard/dashboard.dart';
import 'package:step_counter/features/home/presentation/screens/home_screen.dart';
import '../../helpers/memory_hive.dart';

void main() {
  setUp(openMemoryBoxes);

  const testUser = UserModel(
    id: 'test_user_id',
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
  );

  group('Dashboard Screens & Widgets (matching design/DashBoard)', () {
    testWidgets('DashboardScreen renders default layout matching Screen 25',
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

      // Verify AppBar
      expect(find.text('Home'), findsOneWidget);

      // Verify Steps Gauge Card elements
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.text('/6,000'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Verify Activity stats
      expect(find.text('time'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);

      // Verify "Your Progress" section
      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Verify Bottom Nav
      expect(find.text('Track'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('PhysicalActivityPermissionDialog renders matching Screen 23',
        (WidgetTester tester) async {
      bool granted = false;
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhysicalActivityPermissionDialog(
              onGrant: () => granted = true,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Physical Activity\nPermission Request'), findsOneWidget);
      expect(
        find.textContaining('TrackFit needs permission to access your physical activity data'),
        findsOneWidget,
      );
      expect(find.text('Grant Permission'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Grant Permission'));
      expect(granted, isTrue);

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });

    testWidgets('LocationPermissionDialog renders matching Screen 24',
        (WidgetTester tester) async {
      bool granted = false;
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationPermissionDialog(
              onGrant: () => granted = true,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Location Access\nPermission Request'), findsOneWidget);
      expect(
        find.textContaining('TrackFit requires access to your location'),
        findsOneWidget,
      );
      expect(find.text('Grant Permission'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Grant Permission'));
      expect(granted, isTrue);

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });

    testWidgets('GoalCompletionDialog renders trophy celebration matching Screen 27',
        (WidgetTester tester) async {
      bool stopped = false;
      bool continued = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCompletionDialog(
              stepGoal: 6000,
              durationString: '1h 30m',
              caloriesString: '432',
              distanceKmString: '6.90',
              onStopStep: () => stopped = true,
              onContinueSteps: () => continued = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('6,000 Steps!'), findsOneWidget);
      expect(find.text("Congratulations!\nYou've completed the step goal."), findsOneWidget);
      expect(find.text('1h 30m'), findsOneWidget);
      expect(find.text('432'), findsOneWidget);
      expect(find.text('6.90'), findsOneWidget);
      expect(find.text('Stop Step'), findsOneWidget);
      expect(find.text('Continue Steps'), findsOneWidget);

      await tester.tap(find.text('Stop Step'));
      expect(stopped, isTrue);

      await tester.tap(find.text('Continue Steps'));
      expect(continued, isTrue);
    });

    testWidgets('HomeScreen delegates seamlessly to DashboardScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(user: testUser),
        ),
      );
      await tester.pump();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Your Progress'), findsOneWidget);
    });
  });
}

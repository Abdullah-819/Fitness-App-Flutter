import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:step_counter/features/auth/domain/models/user_model.dart';
import 'package:step_counter/features/dashboard/dashboard.dart';
import 'package:step_counter/features/track/data/location_tracking_service.dart';
import 'package:step_counter/features/track/domain/track_session.dart';
import 'package:step_counter/features/track/presentation/providers/track_provider.dart';
import 'package:step_counter/features/track/presentation/screens/track_screen.dart';
import 'package:step_counter/features/track/presentation/widgets/track_active_stats_sheet.dart';
import 'package:step_counter/features/track/presentation/widgets/track_locate_button.dart';
import 'package:step_counter/features/track/presentation/widgets/track_start_button.dart';
import 'package:step_counter/features/track/presentation/widgets/track_summary_dialog.dart';

import '../../helpers/memory_hive.dart';

import 'package:geolocator/geolocator.dart';

/// Test location service that does not call platform channels during widget tests.
class FakeLocationTrackingService extends LocationTrackingService {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<Position?> getCurrentPosition() async => Position(
        longitude: 69.3451,
        latitude: 30.3753,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 100.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 1.0,
        speedAccuracy: 1.0,
      );

  @override
  void startTracking({TrackPoint? initialPoint}) {
    // No-op for tests
  }
}

void main() {
  setUp(openMemoryBoxes);

  Widget createTestWidget(TrackProvider trackProvider) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TrackProvider>.value(
          value: trackProvider,
          child: const TrackScreen(),
        ),
      ),
    );
  }

  group('TrackScreen Widget Tests (Designs 30 and 31)', () {
    testWidgets('Idle state renders map, locate button, and START button (Design 30)',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = TrackProvider(
        locationService: FakeLocationTrackingService(),
      );
      addTearDown(provider.dispose);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();

      // Verify START button is visible
      expect(find.byType(TrackStartButton), findsOneWidget);
      expect(find.text('START'), findsOneWidget);

      // Verify Locate button is visible
      expect(find.byType(TrackLocateButton), findsOneWidget);
      expect(find.byIcon(LucideIcons.locateFixed), findsOneWidget);

      // Active stats sheet should NOT be visible when idle
      expect(find.byType(TrackActiveStatsSheet), findsNothing);
      expect(find.text('Stop'), findsNothing);
    });

    testWidgets(
        'Active tracking state displays stats sheet with steps/time/kcal/km and Stop button (Design 31)',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = TrackProvider(
        locationService: FakeLocationTrackingService(),
      );
      addTearDown(provider.dispose);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();

      // Start tracking
      await provider.startTracking(simulateInStaging: false);
      await tester.pump(const Duration(milliseconds: 50));

      // START button should now be gone
      expect(find.byType(TrackStartButton), findsNothing);

      // Active stats sheet should be displayed
      expect(find.byType(TrackActiveStatsSheet), findsOneWidget);
      expect(find.text('steps'), findsOneWidget);
      expect(find.text('time'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);

      // Locate button remains visible during tracking
      expect(find.byType(TrackLocateButton), findsOneWidget);

      // Clean up timer
      await provider.stopTracking();
      await tester.pump();
    });

    testWidgets('Tapping Stop stops tracking and presents TrackSummaryDialog',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = TrackProvider(
        locationService: FakeLocationTrackingService(),
      );
      addTearDown(provider.dispose);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pump();

      await provider.startTracking(simulateInStaging: false);
      await tester.pump(const Duration(milliseconds: 50));

      // Tap Stop button
      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();

      // Summary dialog should appear
      expect(find.byType(TrackSummaryDialog), findsOneWidget);
      expect(find.text('Workout Saved!'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byType(TrackSummaryDialog), findsNothing);
      // Returned to idle state
      expect(find.byType(TrackStartButton), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
    });

    testWidgets('Switching tabs survives and keeps active tracking session alive',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const testUser = UserModel(
        id: 'test_u1',
        name: 'Test Walker',
        email: 'walker@example.com',
      );

      final trackProvider = TrackProvider(
        locationService: FakeLocationTrackingService(),
      );
      addTearDown(trackProvider.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(
            user: testUser,
            trackProvider: trackProvider,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Starts at Home (index 0)
      expect(find.text('Home'), findsOneWidget);

      // Switch to Track tab (index 1) via bottom nav callback
      final bottomNav =
          tester.widget<DashboardBottomNav>(find.byType(DashboardBottomNav));
      bottomNav.onTabSelected(1);
      await tester.pump(const Duration(milliseconds: 500));

      // AppBar title should now be Track
      expect(find.text('Track'), findsOneWidget);
      expect(find.byType(TrackStartButton), findsOneWidget);

      // Start active tracking
      await trackProvider.startTracking(simulateInStaging: false);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(TrackActiveStatsSheet), findsOneWidget);
      expect(trackProvider.isTracking, isTrue);

      // Switch to Home tab (index 0) while tracking is active
      bottomNav.onTabSelected(0);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Home'), findsOneWidget);

      // Verify tracking continues in background
      expect(trackProvider.isTracking, isTrue);

      // Switch back to Track tab (index 1)
      bottomNav.onTabSelected(1);
      await tester.pump(const Duration(milliseconds: 500));

      // Track screen is still preserved and active stats sheet remains
      expect(find.byType(TrackScreen), findsOneWidget);
      expect(find.byType(TrackActiveStatsSheet), findsOneWidget);

      // Stop tracking and clean up timer
      await trackProvider.stopTracking();
      await tester.pump();
    });
  });
}

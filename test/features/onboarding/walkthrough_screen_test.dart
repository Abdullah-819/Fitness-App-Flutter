import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/onboarding/presentation/screens/walkthrough_one_screen.dart';
import 'package:step_counter/features/onboarding/presentation/screens/walkthrough_screen.dart';
import 'package:step_counter/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:step_counter/features/splash/presentation/screens/splash_screen.dart';
import 'package:step_counter/main.dart';

void main() {
  testWidgets(
    'WalkthroughScreen renders Walkthrough 1 content matching 2_Light_walkthrough 1.png',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WalkthroughScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Walkthrough 1 Header and Subtitle
      expect(
        find.text('TrackFit - Your Ultimate\nStep Counter & Tracker'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Track your steps, monitor your progress'),
        findsOneWidget,
      );

      // Verify Skip and Continue buttons
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    },
  );

  testWidgets(
    'WalkthroughOneScreen alias correctly loads Walkthrough 1',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalkthroughOneScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('TrackFit - Your Ultimate\nStep Counter & Tracker'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Tapping Continue cycles through Walkthrough 2 and 3 sequentially',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WalkthroughScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Page 1
      expect(
        find.text('TrackFit - Your Ultimate\nStep Counter & Tracker'),
        findsOneWidget,
      );

      // Tap Continue -> Page 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Discover Your Route with\nLive Maps'),
        findsOneWidget,
      );

      // Tap Continue -> Page 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Gain Step Insights with\nDetailed Reports'),
        findsOneWidget,
      );
      expect(find.text("Let's Get Started"), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Skip navigates directly to WelcomeScreen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: WalkthroughScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Should be on WelcomeScreen
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text("Let's Get Started!"), findsOneWidget);
    },
  );

  testWidgets(
    'End-to-End Onboarding Sequence: Splash -> Walkthrough 1, 2, 3 -> Welcome -> Sign In',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Launch root StepCounterApp
      await tester.pumpWidget(const StepCounterApp());
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Splash Screen is active
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.bySemanticsLabel('TrackFit'), findsOneWidget);

      // Finish splash duration (2500ms)
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      // 2. Walkthrough 1 is active
      expect(find.byType(WalkthroughScreen), findsOneWidget);
      expect(
        find.text('TrackFit - Your Ultimate\nStep Counter & Tracker'),
        findsOneWidget,
      );

      // 3. Move to Walkthrough 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Discover Your Route with\nLive Maps'), findsOneWidget);

      // 4. Move to Walkthrough 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.text('Gain Step Insights with\nDetailed Reports'),
        findsOneWidget,
      );
      expect(find.text("Let's Get Started"), findsOneWidget);

      // 5. Tap Let's Get Started -> Navigates to Welcome Screen
      await tester.tap(find.text("Let's Get Started"));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text("Let's Get Started!"), findsOneWidget);

      // 6. Scroll and Tap Sign in -> Navigates to Sign In Screen
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back! \u{1F44B}'), findsOneWidget);
    },
  );
}

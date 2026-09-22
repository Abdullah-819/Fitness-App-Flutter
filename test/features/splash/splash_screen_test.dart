import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/splash/presentation/screens/splash_screen.dart';
import 'package:step_counter/features/splash/presentation/widgets/fading_spinner.dart';

void main() {
  testWidgets(
    'SplashScreen renders title, logo, and spinner and triggers callback',
    (WidgetTester tester) async {
      bool initialized = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(milliseconds: 500),
            onInitialized: () {
              initialized = true;
            },
          ),
        ),
      );

      // Verify title text exists
      expect(find.text('Step Counter &\nWalking Goals'), findsOneWidget);

      // Verify Logo Image exists
      expect(find.byType(Image), findsOneWidget);

      // Verify FadingSpinner exists
      expect(find.byType(FadingSpinner), findsOneWidget);

      // Advance animation past entrance and splash duration
      await tester.pump(const Duration(milliseconds: 600));

      // Verify callback was invoked
      expect(initialized, isTrue);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/splash/presentation/screens/splash_screen.dart';
import 'package:step_counter/features/splash/presentation/widgets/fading_spinner.dart';
import 'package:step_counter/features/splash/presentation/widgets/footprints_icon.dart';

void main() {
  testWidgets('SplashScreen renders title, footprints icon, and spinner', (
    WidgetTester tester,
  ) async {
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

    // Verify FootprintsIcon exists
    expect(find.byType(FootprintsIcon), findsOneWidget);

    // Verify FadingSpinner exists
    expect(find.byType(FadingSpinner), findsOneWidget);

    // Advance time past the splash duration
    await tester.pump(const Duration(milliseconds: 600));

    // Verify callback was invoked
    expect(initialized, isTrue);
  });
}

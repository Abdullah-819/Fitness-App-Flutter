import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/presentation/widgets/social_logos.dart';
import 'package:step_counter/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:step_counter/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen renders all 4 social buttons with equal sizings and identical alignment', (tester) async {
    // Set a phone screen resolution
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Verify button texts
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Continue with Facebook'), findsOneWidget);
    expect(find.text('Continue with Twitter'), findsOneWidget);

    // Verify social logos
    expect(find.byType(GoogleLogo), findsOneWidget);
    expect(find.byType(AppleLogo), findsOneWidget);
    expect(find.byType(FacebookLogo), findsOneWidget);
    expect(find.byType(TwitterLogo), findsOneWidget);

    // Verify all 4 logos have equal size (24x24)
    final googleSize = tester.getSize(find.byType(GoogleLogo));
    final appleSize = tester.getSize(find.byType(AppleLogo));
    final facebookSize = tester.getSize(find.byType(FacebookLogo));
    final twitterSize = tester.getSize(find.byType(TwitterLogo));

    expect(googleSize, const Size(24, 24));
    expect(appleSize, const Size(24, 24));
    expect(facebookSize, const Size(24, 24));
    expect(twitterSize, const Size(24, 24));

    // Verify all 4 logos are perfectly aligned at the exact same horizontal position
    final googleTopLeft = tester.getTopLeft(find.byType(GoogleLogo));
    final appleTopLeft = tester.getTopLeft(find.byType(AppleLogo));
    final facebookTopLeft = tester.getTopLeft(find.byType(FacebookLogo));
    final twitterTopLeft = tester.getTopLeft(find.byType(TwitterLogo));

    expect(googleTopLeft.dx, equals(appleTopLeft.dx));
    expect(appleTopLeft.dx, equals(facebookTopLeft.dx));
    expect(facebookTopLeft.dx, equals(twitterTopLeft.dx));

    // Verify buttons are full width and equal height (56)
    final buttons = find.byType(SocialSignInButton);
    expect(buttons, findsNWidgets(4));
    for (int i = 0; i < 4; i++) {
      final btnSize = tester.getSize(buttons.at(i));
      expect(btnSize.height, equals(56));
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/presentation/widgets/social_logos.dart';

void main() {
  testWidgets('Social logos render with expected size and no errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              GoogleLogo(size: 24),
              AppleLogo(size: 24),
              FacebookLogo(size: 24),
              TwitterLogo(size: 24),
            ],
          ),
          
        ),
      ),
    );

    expect(find.byType(GoogleLogo), findsOneWidget);
    expect(find.byType(AppleLogo), findsOneWidget);
    expect(find.byType(FacebookLogo), findsOneWidget);
    expect(find.byType(TwitterLogo), findsOneWidget);

    final googleBox = tester.getSize(find.byType(GoogleLogo));
    final appleBox = tester.getSize(find.byType(AppleLogo));
    final facebookBox = tester.getSize(find.byType(FacebookLogo));
    final twitterBox = tester.getSize(find.byType(TwitterLogo));

    expect(googleBox, const Size(24, 24));
    expect(appleBox, const Size(24, 24));
    expect(facebookBox, const Size(24, 24));
    expect(twitterBox, const Size(24, 24));
  });
}

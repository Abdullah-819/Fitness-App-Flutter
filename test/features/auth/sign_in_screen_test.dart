import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/data/auth_service.dart';
import 'package:step_counter/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:step_counter/features/auth/presentation/widgets/auth_form_icons.dart';

void main() {
  group('AuthService Tests', () {
    test('Default user logs in successfully', () async {
      final user = await AuthService.instance.signIn(
        email: AuthService.defaultEmail,
        password: AuthService.defaultPassword,
      );
      expect(user.email, AuthService.defaultEmail);
      expect(user.name, AuthService.defaultName);
    });

    test('Invalid password throws AuthException', () async {
      expect(
        () => AuthService.instance.signIn(
          email: AuthService.defaultEmail,
          password: 'wrong_password',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('SignInScreen Widget Tests', () {
    testWidgets('Renders all UI components and side icons correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Verify header texts
      expect(find.textContaining('Welcome Back!'), findsOneWidget);
      expect(
        find.text('Sign in to continue your fitness journey.'),
        findsOneWidget,
      );

      // Verify labels
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Verify side icons
      expect(find.byType(AuthMailIcon), findsOneWidget);
      expect(find.byType(AuthLockIcon), findsOneWidget);
      expect(find.byType(AuthEyeIcon), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Verify social buttons
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);

      // Verify Sign in button
      expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
    });

    testWidgets('Tapping auto-fill banner populates credentials and shows clear side icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Tap auto-fill
      final fillBanner = find.textContaining('Tap to fill default credentials');
      expect(fillBanner, findsOneWidget);
      await tester.tap(fillBanner);
      await tester.pumpAndSettle();

      // Check fields are populated
      expect(find.text(AuthService.defaultEmail), findsOneWidget);
      expect(find.text(AuthService.defaultPassword), findsOneWidget);

      // Email clear side icon appears when text is present
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('Remember me checkbox toggles state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      final rememberMeText = find.text('Remember me');
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap Remember me
      await tester.tap(rememberMeText);
      await tester.pumpAndSettle();

      // Should show check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Toggling eye icon updates obscureText state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      final eyeFinder = find.byType(AuthEyeIcon);
      expect(eyeFinder, findsOneWidget);

      AuthEyeIcon eyeWidget = tester.widget<AuthEyeIcon>(eyeFinder);
      expect(eyeWidget.isObscured, isTrue);

      // Tap eye toggle side icon
      await tester.tap(eyeFinder);
      await tester.pumpAndSettle();

      eyeWidget = tester.widget<AuthEyeIcon>(eyeFinder);
      expect(eyeWidget.isObscured, isFalse);
    });
  });
}

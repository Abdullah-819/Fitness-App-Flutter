import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

    test('Team members log in successfully with password 696969', () async {
      for (final member in AuthService.teamMembers) {
        final user = await AuthService.instance.signIn(
          email: member.email,
          password: '696969',
        );
        expect(user.name, equals(member.name));
        expect(user.email, equals(member.email));
      }
    });

    test('Invalid password throws AuthException', () async {
      expect(
        () => AuthService.instance.signIn(
          email: 'abdullah.rana@trackfit.com',
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

    testWidgets('Tapping auto-fill banner shows 3 team options and selecting one auto-fills', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Tap auto-fill banner
      final fillBanner = find.textContaining('Tap to auto-fill team credentials');
      expect(fillBanner, findsOneWidget);
      await tester.tap(fillBanner);
      await tester.pumpAndSettle();

      // Bottom sheet should display all 3 team members
      expect(find.text('Select Team Account'), findsOneWidget);
      expect(find.text('Abdullah Rana'), findsOneWidget);
      expect(find.text('Ahmad Ali'), findsOneWidget);
      expect(find.text('Abdullah Qureshi'), findsOneWidget);

      // Tap on Abdullah Rana
      await tester.tap(find.text('Abdullah Rana'));
      await tester.pump();

      // Check fields are populated with Abdullah Rana's credentials
      expect(find.text('abdullah.rana@trackfit.com'), findsOneWidget);
      expect(find.text('696969'), findsOneWidget);

      // Settle loading dialog and navigation
      await tester.pumpAndSettle();
    });

    testWidgets('Remember me checkbox toggles state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      final rememberMeText = find.text('Remember me');
      expect(find.byIcon(LucideIcons.check), findsNothing);

      // Tap Remember me
      await tester.tap(rememberMeText);
      await tester.pumpAndSettle();

      // Should show check icon
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
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

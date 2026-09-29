import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:step_counter/features/auth/data/auth_service.dart';
import 'package:step_counter/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:step_counter/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:step_counter/features/auth/presentation/widgets/auth_form_icons.dart';
import 'package:step_counter/features/onboarding/presentation/screens/sign_up_steps_screen.dart';

void main() {
  group('AuthService SignUp Tests', () {
    test('signUp creates new user with valid email and password', () async {
      final user = await AuthService.instance.signUp(
        email: 'newuser@example.com',
        password: 'password123',
      );
      expect(user.email, 'newuser@example.com');
      expect(user.name, 'Newuser');
      expect(user.id, startsWith('user_'));
    });

    test('signUp derives multi-word formatted name from email prefix', () async {
      final user = await AuthService.instance.signUp(
        email: 'john.smith@domain.com',
        password: 'password123',
      );
      expect(user.name, 'John Smith');
    });

    test('signUp throws AuthException on invalid email format', () async {
      expect(
        () => AuthService.instance.signUp(
          email: 'invalid-email',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('signUp throws AuthException on short password', () async {
      expect(
        () => AuthService.instance.signUp(
          email: 'test@example.com',
          password: '123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('SignUpScreen Widget Tests', () {
    void setupScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets(
      'Renders all UI components and icons matching design 6_Light_sign up blank form.png',
      (tester) async {
        setupScreenSize(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: SignUpScreen(),
          ),
        );

        // Verify Header & Subtitle
        expect(find.text('Join TrackFit Today'), findsOneWidget);
        expect(
          find.text('Create your account and start tracking your steps.'),
          findsOneWidget,
        );

        // Verify Icons
        expect(find.byType(AuthUserIcon), findsOneWidget);
        expect(find.byType(AuthMailIcon), findsOneWidget);
        expect(find.byType(AuthLockIcon), findsOneWidget);
        expect(find.byType(AuthEyeIcon), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Verify Field Labels
        expect(find.text('Email'), findsWidgets);
        expect(find.text('Password'), findsWidgets);

        // Verify Terms Checkbox & Text
        expect(find.textContaining('I agree to TrackFit'), findsOneWidget);
        expect(find.textContaining('Terms & Conditions.'), findsOneWidget);

        // Verify Already have an account? Sign in
        expect(find.text('Already have an account? '), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);

        // Verify Divider
        expect(find.text('or'), findsOneWidget);

        // Verify Social Buttons (Google and Apple matching design 6)
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Apple'), findsOneWidget);

        // Verify Sign up Button
        expect(find.byKey(const Key('sign_up_button')), findsOneWidget);
      },
    );

    testWidgets('Terms & Conditions checkbox toggles state', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      // Initially unchecked
      expect(find.byIcon(LucideIcons.check), findsNothing);

      // Tap on Terms checkbox via key
      final checkboxFinder = find.byKey(const Key('terms_checkbox'));
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Checkmark icon should appear
      expect(find.byIcon(LucideIcons.check), findsOneWidget);

      // Tap again to uncheck
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.check), findsNothing);
    });

    testWidgets('Toggling eye icon updates password obscurity', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      final eyeFinder = find.byType(AuthEyeIcon);
      expect(eyeFinder, findsOneWidget);

      AuthEyeIcon eyeWidget = tester.widget<AuthEyeIcon>(eyeFinder);
      expect(eyeWidget.isObscured, isTrue);

      // Tap eye toggle
      await tester.tap(eyeFinder);
      await tester.pumpAndSettle();

      eyeWidget = tester.widget<AuthEyeIcon>(eyeFinder);
      expect(eyeWidget.isObscured, isFalse);
    });

    testWidgets('Clear button clears email text when typed', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      // Enter text in email field
      final emailField = find.widgetWithText(TextFormField, '');
      await tester.enterText(emailField.first, 'test@example.com');
      await tester.pumpAndSettle();

      // CircleX clear icon should be visible
      expect(find.byIcon(LucideIcons.circleX), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byIcon(LucideIcons.circleX));
      await tester.pumpAndSettle();

      // Email field should now be empty and clear icon removed
      expect(find.text('test@example.com'), findsNothing);
      expect(find.byIcon(LucideIcons.circleX), findsNothing);
    });

    testWidgets(
      'Tapping auto-fill banner fills credentials and marks terms agreed',
      (tester) async {
        setupScreenSize(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: SignUpScreen(),
          ),
        );

        final bannerFinder = find.textContaining(
          'Tap to auto-fill demo or team account credentials',
        );
        expect(bannerFinder, findsOneWidget);
        await tester.tap(bannerFinder);
        await tester.pumpAndSettle();

        // Bottom sheet should display options
        expect(find.text('Select Demo Account'), findsOneWidget);
        expect(find.text('Andrew Ainsley'), findsOneWidget);
        expect(find.text('Abdullah Rana'), findsOneWidget);

        // Select Andrew Ainsley
        await tester.tap(find.text('Andrew Ainsley'));
        await tester.pumpAndSettle();

        // Fields should be filled and terms checked
        expect(find.text(AuthService.defaultEmail), findsOneWidget);
        expect(find.text(AuthService.defaultPassword), findsOneWidget);
        expect(find.byIcon(LucideIcons.check), findsOneWidget);
      },
    );

    testWidgets('Submitting without agreeing to terms shows snackbar alert', (
      tester,
    ) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      // Fill in valid email and password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'alex@domain.com');
      await tester.enterText(textFields.at(1), 'securepassword');
      await tester.pumpAndSettle();

      // Tap Sign up without checking terms
      final signUpBtn = find.byKey(const Key('sign_up_button'));
      await tester.ensureVisible(signUpBtn);
      await tester.tap(signUpBtn);
      await tester.pumpAndSettle();

      // Alert snackbar should be displayed
      expect(
        find.text('Please agree to TrackFit Terms & Conditions to sign up.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Submitting with valid form and agreed terms logs in user to HomeScreen',
      (tester) async {
        setupScreenSize(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: SignUpScreen(),
          ),
        );

        // Fill valid credentials
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'alex@domain.com');
        await tester.enterText(textFields.at(1), 'securepassword');

        // Agree to terms via checkbox key
        await tester.tap(find.byKey(const Key('terms_checkbox')));
        await tester.pumpAndSettle();

        // Tap Sign up
        final signUpBtn = find.byKey(const Key('sign_up_button'));
        await tester.ensureVisible(signUpBtn);
        await tester.tap(signUpBtn);
        await tester.pump(); // Show loading dialog

        // Verify loading dialog with 'Sign up...'
        expect(find.text('Sign up...'), findsOneWidget);

        // Fast-forward delayed timer
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();

        // Should have navigated to SignUpStepsScreen (Onboarding steps 1 to 6)
        expect(find.byType(SignUpStepsScreen), findsOneWidget);
      },
    );

    testWidgets('Tapping "Sign in" navigates to SignInScreen', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      final signInLink = find.text('Sign in');
      expect(signInLink, findsOneWidget);

      await tester.tap(signInLink);
      await tester.pumpAndSettle();

      // Should now be on SignInScreen
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });
}

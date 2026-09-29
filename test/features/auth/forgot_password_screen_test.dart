import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/data/auth_service.dart';
import 'package:step_counter/features/auth/presentation/screens/create_new_password_screen.dart';
import 'package:step_counter/features/auth/presentation/screens/enter_otp_screen.dart';
import 'package:step_counter/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:step_counter/features/auth/presentation/screens/reset_password_success_screen.dart';
import 'package:step_counter/features/auth/presentation/screens/sign_in_screen.dart';

void main() {
  group('ForgotPassword AuthService Tests', () {
    test('isEmailRegistered returns true for default and team emails', () {
      expect(
        AuthService.instance.isEmailRegistered(AuthService.defaultEmail),
        isTrue,
      );
      expect(
        AuthService.instance.isEmailRegistered('abdullah.rana@trackfit.com'),
        isTrue,
      );
      expect(
        AuthService.instance.isEmailRegistered('unknown@fitness.com'),
        isFalse,
      );
    });

    test('sendPasswordResetOtp succeeds for registered user', () async {
      await expectLater(
        AuthService.instance.sendPasswordResetOtp(AuthService.defaultEmail),
        completes,
      );
    });

    test('sendPasswordResetOtp throws for unregistered user', () async {
      expect(
        () => AuthService.instance.sendPasswordResetOtp('nonexistent@user.com'),
        throwsA(isA<AuthException>()),
      );
    });

    test('verifyOtp returns true for 1234 and false for other codes', () {
      expect(
        AuthService.instance.verifyOtp(email: 'user@fitness.com', otp: '1234'),
        isTrue,
      );
      expect(
        AuthService.instance.verifyOtp(email: 'user@fitness.com', otp: '9999'),
        isFalse,
      );
    });

    test(
      'updatePassword updates password and allows login with new password',
      () async {
        const testEmail = 'abdullah.rana@trackfit.com';
        const newPass = 'BrandNewPassword123';

        AuthService.instance.updatePassword(
          email: testEmail,
          newPassword: newPass,
        );

        // Sign in with new password succeeds
        final user = await AuthService.instance.signIn(
          email: testEmail,
          password: newPass,
        );
        expect(user.email, equals(testEmail));

        // Sign in with old password fails
        expect(
          () =>
              AuthService.instance.signIn(email: testEmail, password: '696969'),
          throwsA(isA<AuthException>()),
        );
      },
    );
  });

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets(
      'Renders all UI components matching design 19_Light_forgot password.png',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ForgotPasswordScreen()),
        );

        // Verify title & subtitle
        expect(find.textContaining('Forgot Your Password?'), findsOneWidget);
        expect(
          find.textContaining(
            "Enter the email associated with your TrackFit account below.",
          ),
          findsOneWidget,
        );

        // Verify label
        expect(find.text('Your Registered Email'), findsOneWidget);

        // Verify input and button
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Send OTP Code'), findsOneWidget);
      },
    );

    testWidgets('Pre-populates initialEmail when passed from SignInScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(initialEmail: 'test@domain.com'),
        ),
      );

      expect(find.text('test@domain.com'), findsOneWidget);
    });

    testWidgets('Navigating from SignInScreen to ForgotPasswordScreen works', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

      // Tap Forgot Password?
      final forgotBtn = find.byKey(const Key('forgot_password_button'));
      expect(forgotBtn, findsOneWidget);
      await tester.tap(forgotBtn);
      await tester.pumpAndSettle();

      // Verify ForgotPasswordScreen is displayed
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.textContaining('Forgot Your Password?'), findsOneWidget);
    });
  });

  group('EnterOtpScreen Widget Tests', () {
    testWidgets('Renders title, 4 boxes, countdown, and resend button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: EnterOtpScreen(email: 'test@fitness.com')),
      );

      expect(find.textContaining('Enter OTP Code'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.text('Resend code'), findsOneWidget);
      expect(find.text('Verify OTP'), findsOneWidget);
    });
  });

  group('CreateNewPasswordScreen Widget Tests', () {
    testWidgets('Renders fields and validates matching password', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateNewPasswordScreen(email: 'test@fitness.com'),
        ),
      );

      expect(find.textContaining('Secure Your Account'), findsOneWidget);
      expect(find.text('New Password'), findsWidgets);
      expect(find.text('Confirm New Password'), findsWidgets);
      expect(find.text('Save New Password'), findsOneWidget);
    });
  });

  group('ResetPasswordSuccessScreen Widget Tests', () {
    testWidgets('Renders You are all set and Go to Homepage button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordSuccessScreen(email: 'test@fitness.com'),
        ),
      );

      expect(find.text("You're All Set!"), findsOneWidget);
      expect(
        find.text('Your password has been successfully updated.'),
        findsOneWidget,
      );
      expect(find.text('Go to Homepage'), findsOneWidget);
    });
  });
}

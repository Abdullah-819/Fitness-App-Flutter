import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/core/config/app_config.dart';
import 'package:step_counter/features/auth/data/auth_service.dart';

import '../../helpers/memory_hive.dart';

/// Run the production half with:
///   flutter test --flavor production test/features/auth/flavor_auth_test.dart
void main() {
  setUp(() async {
    await openMemoryBoxes();
    AuthService.instance.signOut();
  });

  group('Staging build', () {
    test('keeps demo accounts and the demo OTP', () async {
      expect(AppConfig.isStaging, isTrue);
      final user = await AuthService.instance.signIn(
        email: AuthService.defaultEmail,
        password: AuthService.defaultPassword,
      );
      expect(user.name, AuthService.defaultName);
      expect(AuthService.instance.verifyOtp(email: 'a@b.c', otp: '1234'), isTrue);
    });
  }, skip: AppConfig.isProduction);

  group('Production build', () {
    test('rejects demo accounts and the demo OTP', () async {
      expect(AppConfig.isProduction, isTrue);
      await expectLater(
        AuthService.instance.signIn(
          email: AuthService.defaultEmail,
          password: AuthService.defaultPassword,
        ),
        throwsA(isA<AuthException>()),
      );
      expect(AuthService.instance.verifyOtp(email: 'a@b.c', otp: '1234'), isFalse);
    });

    test('real sign up works, then sign in, and duplicates are blocked', () async {
      await AuthService.instance.signUp(
        email: 'real.user@example.com',
        password: 'Secret@123',
      );
      AuthService.instance.signOut();

      final user = await AuthService.instance.signIn(
        email: 'real.user@example.com',
        password: 'Secret@123',
      );
      expect(user.email, 'real.user@example.com');

      await expectLater(
        AuthService.instance.signIn(
          email: 'real.user@example.com',
          password: 'wrong',
        ),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        AuthService.instance.signUp(
          email: 'real.user@example.com',
          password: 'Secret@123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  }, skip: !AppConfig.isProduction);

  group('Staying signed in', () {
    test('a signed-in user is restored until they sign out', () async {
      final user = await AuthService.instance.signUpWithPhone(
        phone: '+923061848755',
        password: 'Secret@123',
      );
      await AuthService.instance.updateCurrentUser(
        user.copyWith(gender: 'Man', dailyStepGoal: 8000, age: 30),
      );

      // Simulate a fresh app start: forget the in-memory user.
      final restored = await AuthService.instance.restoreSession();
      expect(restored?.phone, '+923061848755');
      expect(restored?.dailyStepGoal, 8000);
      expect(restored?.isProfileComplete, isTrue);

      AuthService.instance.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(await AuthService.instance.restoreSession(), isNull);
    });

    test('signing back in restores the saved profile', () async {
      final user = await AuthService.instance.signUpWithPhone(
        phone: '+923061848755',
        password: 'Secret@123',
      );
      await AuthService.instance.updateCurrentUser(
        user.copyWith(gender: 'Woman', dailyStepGoal: 9500),
      );
      AuthService.instance.signOut();

      final again = await AuthService.instance.signInWithPhone(
        phone: '+923061848755',
        password: 'Secret@123',
      );
      expect(again.gender, 'Woman');
      expect(again.dailyStepGoal, 9500);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/presentation/widgets/password_rules_checklist.dart';
import 'package:step_counter/features/auth/presentation/widgets/phone_number_field.dart';

void main() {
  group('PkPhone', () {
    test('normalises common Pakistani number formats', () {
      expect(PkPhone.e164('0306 1848755'), '+923061848755');
      expect(PkPhone.e164('306 1848755'), '+923061848755');
      expect(PkPhone.e164('+92 306 1848755'), '+923061848755');
      expect(PkPhone.e164('923061848755'), '+923061848755');
    });

    test('accepts only 10-digit mobile numbers starting with 3', () {
      expect(PkPhone.isValid('0306 1848755'), isTrue);
      expect(PkPhone.isValid('0206 1848755'), isFalse);
      expect(PkPhone.isValid('0306 184875'), isFalse);
      expect(PkPhone.isValid(''), isFalse);
    });
  });

  group('PasswordRules', () {
    test('requires 8 chars, a number, a special char and an uppercase', () {
      expect(PasswordRules.allPassed('Abcdef1@'), isTrue);
      expect(PasswordRules.allPassed('abcdef1@'), isFalse); // no uppercase
      expect(PasswordRules.allPassed('Abcdefg@'), isFalse); // no number
      expect(PasswordRules.allPassed('Abcdefg1'), isFalse); // no special
      expect(PasswordRules.allPassed('Ab1@'), isFalse); // too short
    });
  });

  testWidgets('PhoneNumberField formats as 0306 1848755', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PhoneNumberField(controller: controller)),
      ),
    );

    await tester.enterText(find.byKey(const Key('phone_field')), '03061848755');
    expect(controller.text, '0306 1848755');

    // Extra digits are ignored (max 11 digits with the leading 0).
    await tester.enterText(
      find.byKey(const Key('phone_field')),
      '030618487559999',
    );
    expect(controller.text, '0306 1848755');

    // Partial input groups after the first 4 digits only.
    await tester.enterText(find.byKey(const Key('phone_field')), '03061');
    expect(controller.text, '0306 1');
  });
}

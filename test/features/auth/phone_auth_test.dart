import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/presentation/widgets/password_rules_checklist.dart';
import 'package:step_counter/features/auth/presentation/widgets/phone_number_field.dart';

void main() {
  group('PkPhone', () {
    test('normalises common Pakistani number formats', () {
      expect(PkPhone.e164('0300 678 9089'), '+923006789089');
      expect(PkPhone.e164('300 678 9089'), '+923006789089');
      expect(PkPhone.e164('+92 300 6789089'), '+923006789089');
      expect(PkPhone.e164('923006789089'), '+923006789089');
    });

    test('accepts only 10-digit mobile numbers starting with 3', () {
      expect(PkPhone.isValid('0300 678 9089'), isTrue);
      expect(PkPhone.isValid('0200 678 9089'), isFalse);
      expect(PkPhone.isValid('0300 678 908'), isFalse);
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
}

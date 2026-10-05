import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:step_counter/features/auth/data/auth_service.dart';
import 'package:step_counter/features/auth/domain/models/user_model.dart';
import 'package:step_counter/features/dashboard/presentation/screens/account_view.dart';
import 'package:step_counter/features/settings/presentation/screens/personal_info_screen.dart';

import '../../helpers/memory_hive.dart';

void main() {
  setUp(openMemoryBoxes);

  const initialUser = UserModel(
    id: 'user_test_01',
    name: 'Jane Doe',
    email: 'jane.doe@example.com',
    phone: '+923001234567',
    gender: 'Woman',
    age: 26,
    heightCm: 170.0,
    weightKg: 65.0,
    dailyStepGoal: 8000,
    isSedentary: false,
  );

  group('PersonalInfoScreen CRUD Widget Tests', () {
    testWidgets('Read Mode: Displays user information and metrics properly',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(user: initialUser),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header details
      expect(find.text('Personal Info'), findsOneWidget);
      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('jane.doe@example.com'), findsWidgets);
      expect(find.text('Profile Complete'), findsOneWidget);

      // Verify Metrics summary
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('22.5'), findsOneWidget); // 65 / (1.7 * 1.7) = 22.49 -> 22.5
      expect(find.text('Normal Weight'), findsOneWidget);
      expect(find.text('Daily Goal'), findsOneWidget);
      expect(find.text('8000'), findsOneWidget);
      expect(find.text('Lifestyle'), findsWidgets);
      expect(find.text('Active'), findsWidgets);

      // Verify Info Rows
      expect(find.text('+923001234567'), findsOneWidget);
      expect(find.text('Woman'), findsOneWidget);
      expect(find.text('26 yrs'), findsOneWidget);
      expect(find.text('170 cm'), findsOneWidget);
      expect(find.text('65 kg'), findsOneWidget);
      expect(find.text('8000 steps/day'), findsOneWidget);

      // Verify Buttons
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Reset Personal Information'), findsOneWidget);
    });

    testWidgets('Edit Mode: Tapping Edit Profile switches to edit form',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(user: initialUser),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Edit Profile button
      await tester.tap(find.byTooltip('Edit Profile'));
      await tester.pumpAndSettle();

      // Form should now be visible
      expect(find.text('Update your personal information and fitness preferences below.'),
          findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel to switch back to View Mode
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Account Information'), findsOneWidget);
    });

    testWidgets('Update Mode: Modifying fields and saving updates profile',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await AuthService.instance.updateCurrentUser(initialUser);

      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(user: initialUser),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Edit Mode
      await tester.tap(find.byTooltip('Edit Profile'));
      await tester.pumpAndSettle();

      // Change Name
      final nameField = find.widgetWithText(TextFormField, 'Jane Doe');
      await tester.enterText(nameField, 'Jane Smith');

      // Change Daily Goal
      final goalField = find.widgetWithText(TextFormField, '8000');
      await tester.enterText(goalField, '10000');

      // Save Changes
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Should return to View Mode with updated name and goal
      expect(find.text('Jane Smith'), findsWidgets);
      expect(find.text('10000'), findsOneWidget);
      expect(find.text('10000 steps/day'), findsOneWidget);
    });

    testWidgets('Validation: Empty name prevents saving', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(user: initialUser),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Edit Profile'));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Jane Doe');
      await tester.enterText(nameField, '');

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Name cannot be empty'), findsOneWidget);
    });

    testWidgets('Delete / Reset: Resetting personal information clears metrics',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await AuthService.instance.updateCurrentUser(initialUser);

      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalInfoScreen(user: initialUser),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to Reset Personal Information
      final resetButton = find.text('Reset Personal Information');
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Reset Personal Info'), findsOneWidget);
      expect(find.text('Reset Info'), findsOneWidget);

      // Confirm Reset
      await tester.tap(find.text('Reset Info'));
      await tester.pumpAndSettle();

      // Metrics should be cleared
      expect(find.text('--'), findsOneWidget);
      expect(find.text('Not set'), findsWidgets);
      expect(find.text('+ Add'), findsWidgets);
    });

    testWidgets('AccountView: Clicking Personal Info navigates to PersonalInfoScreen',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountView(
              user: initialUser,
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal Info'), findsOneWidget);

      // Tap Personal Info tile
      await tester.tap(find.text('Personal Info'));
      await tester.pumpAndSettle();

      // Verify that PersonalInfoScreen is opened (not the bottom sheet!)
      expect(find.byType(PersonalInfoScreen), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pumpAndSettle();

      // Back on AccountView
      expect(find.byType(PersonalInfoScreen), findsNothing);
    });
  });
}

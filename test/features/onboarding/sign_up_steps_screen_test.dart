import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/auth/domain/models/user_model.dart';
import 'package:step_counter/features/home/presentation/screens/home_screen.dart';
import 'package:step_counter/features/onboarding/presentation/screens/sign_up_steps_screen.dart';
import 'package:step_counter/features/onboarding/presentation/widgets/vertical_number_picker.dart';

void main() {
  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('SignUpStepsScreen Multi-Step Onboarding Tests', () {
    testWidgets('Step 1 renders gender selection and allows selecting Woman', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(initialStep: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and step counter
      expect(find.textContaining('Select Your'), findsOneWidget);
      expect(find.textContaining('Gender'), findsWidgets);
      expect(find.text("Let's start by understanding you."), findsOneWidget);
      expect(find.text('1 / 6'), findsOneWidget);

      // Verify Man and Woman options
      expect(find.text('Man'), findsOneWidget);
      expect(find.text('Woman'), findsOneWidget);

      // Verify buttons
      expect(find.byKey(const Key('step_skip_button')), findsOneWidget);
      expect(find.byKey(const Key('step_continue_button')), findsOneWidget);

      // Tap Woman
      await tester.tap(find.text('Woman'));
      await tester.pumpAndSettle();

      // Advance to Step 2
      await tester.tap(find.byKey(const Key('step_continue_button')));
      await tester.pumpAndSettle();

      // Should now be on Step 2
      expect(find.text('2 / 6'), findsOneWidget);
      expect(find.textContaining('Sedentary'), findsWidgets);
    });

    testWidgets('Step 2 renders sedentary lifestyle question and allows toggling No/Yes', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(initialStep: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and step counter
      expect(find.textContaining('Sedentary'), findsWidgets);
      expect(find.text('Tell us about your daily routine.'), findsOneWidget);
      expect(find.text('2 / 6'), findsOneWidget);

      // Verify circular No / Yes buttons
      expect(find.byKey(const Key('sedentary_no')), findsOneWidget);
      expect(find.byKey(const Key('sedentary_yes')), findsOneWidget);

      // Tap Yes
      await tester.tap(find.byKey(const Key('sedentary_yes')));
      await tester.pumpAndSettle();

      // Tap Skip -> advances to Step 3
      await tester.tap(find.byKey(const Key('step_skip_button')));
      await tester.pumpAndSettle();

      expect(find.text('3 / 6'), findsOneWidget);
      expect(find.textContaining('Old'), findsWidgets);
    });

    testWidgets('Step 3 renders age number wheel picker', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(initialStep: 2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Old'), findsWidgets);
      expect(find.text('Share your age with us.'), findsOneWidget);
      expect(find.text('3 / 6'), findsOneWidget);
      expect(find.byType(VerticalNumberPicker), findsOneWidget);
      expect(find.text('years'), findsOneWidget);

      // Advance to Step 4
      await tester.tap(find.byKey(const Key('step_continue_button')));
      await tester.pumpAndSettle();

      expect(find.text('4 / 6'), findsOneWidget);
    });

    testWidgets('Step 4 renders height picker with cm/ft unit toggle', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(initialStep: 3),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Height'), findsWidgets);
      expect(find.text('How tall are you?'), findsOneWidget);
      expect(find.text('4 / 6'), findsOneWidget);
      expect(find.text('cm'), findsWidgets);
      expect(find.text('ft'), findsOneWidget);

      // Tap ft toggle
      await tester.tap(find.text('ft'));
      await tester.pumpAndSettle();

      // Advance to Step 5
      await tester.tap(find.byKey(const Key('step_continue_button')));
      await tester.pumpAndSettle();

      expect(find.text('5 / 6'), findsOneWidget);
    });

    testWidgets('Step 5 renders weight picker with kg/lbs unit toggle', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(initialStep: 4),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Weight'), findsWidgets);
      expect(find.text('Share your weight with us.'), findsOneWidget);
      expect(find.text('5 / 6'), findsOneWidget);
      expect(find.text('kg'), findsWidgets);
      expect(find.text('lbs'), findsOneWidget);

      // Tap lbs toggle
      await tester.tap(find.text('lbs'));
      await tester.pumpAndSettle();

      // Advance to Step 6
      await tester.tap(find.byKey(const Key('step_continue_button')));
      await tester.pumpAndSettle();

      expect(find.text('6 / 6'), findsOneWidget);
    });

    testWidgets('Step 6 renders step goal picker and finishes into HomeScreen', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(
            initialStep: 5,
            user: UserModel(
              id: 'test_user',
              email: 'test@trackfit.com',
              name: 'Test Athlete',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Step 6 header matching 15_Light_sign up step 6 - set your step goal.png
      expect(find.textContaining('Step Goal'), findsWidgets);
      expect(
        find.text('Choose your daily step goal to stay motivated!'),
        findsOneWidget,
      );
      expect(find.text('6 / 6'), findsOneWidget);

      // Verify default 6000 steps
      expect(find.text('6000'), findsOneWidget);
      expect(find.text('steps'), findsOneWidget);

      // Verify Finish button
      final finishBtn = find.byKey(const Key('step_finish_button'));
      expect(finishBtn, findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);

      // Tap Finish -> Navigates to HomeScreen
      await tester.tap(finishBtn);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('SignUpStepSixScreen loads Step 6 directly matching design 15', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepSixScreen(
            user: UserModel(
              id: 'step6_user',
              email: 'athlete@trackfit.com',
              name: 'Pro Runner',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('6 / 6'), findsOneWidget);
      expect(find.textContaining('Step Goal'), findsWidgets);
      expect(find.text('Finish'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Tapping back on Step 2 returns to Step 1', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpStepsScreen(initialStep: 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 / 6'), findsOneWidget);

      // Tap back arrow
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on Step 1
      expect(find.text('1 / 6'), findsOneWidget);
      expect(find.text('Man'), findsOneWidget);
      expect(find.text('Woman'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/services/local_database.dart';
import '../../../../core/services/step_session_store.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../widgets/vertical_number_picker.dart';

/// Full interactive Sign Up Step Flow covering:
/// - Step 1: 9_Light_sign up step 1 / 10_Light_sign up step 1 (Select Your Gender)
/// - Step 2: 11_Light_sign up step 2 (Do You Live a Sedentary Lifestyle?)
/// - Step 3: 12_Light_sign up step 3 (How Old Are You?)
/// - Step 4: 13_Light_sign up step 4 (What's Your Height?)
/// - Step 5: 14_Light_sign up step 5 (What's Your Weight?)
/// - Step 6: 15_Light_sign up step 6 (Set Your Step Goal)
class SignUpStepsScreen extends StatefulWidget {
  final UserModel? user;
  final int initialStep;

  const SignUpStepsScreen({super.key, this.user, this.initialStep = 0});

  @override
  State<SignUpStepsScreen> createState() => _SignUpStepsScreenState();
}

class _SignUpStepsScreenState extends State<SignUpStepsScreen> {
  // Realistic input ranges.
  static const int _minAge = 13;
  static const int _maxAge = 100;
  static const int _minHeightCm = 120;
  static const int _maxHeightCm = 230;
  static const int _minHeightIn = 48; // 4'0"
  static const int _maxHeightIn = 90; // 7'6"
  static const int _minWeightKg = 30;
  static const int _maxWeightKg = 200;
  static const int _minWeightLbs = 66;
  static const int _maxWeightLbs = 440;
  static const int _minStepGoal = 2000;
  static const int _maxStepGoal = 30000;
  static const int _stepGoalIncrement = 500;

  late int _currentStep;

  // Step 1: Gender (Man / Woman)
  String _selectedGender = 'Man';

  // Step 2: Sedentary lifestyle (false = "No", true = "Yes")
  bool _isSedentary = false;

  // Step 3: Age
  int _selectedAge = 28;

  // Step 4: Height
  String _heightUnit = 'cm';
  int _selectedHeight = 185;

  // Step 5: Weight
  String _weightUnit = 'kg';
  int _selectedWeight = 76;

  // Step 6: Daily step goal
  int _selectedStepGoal = 6000;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, 5);
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleSkip() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      _handleFinish();
    }
  }

  void _handleContinue() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      _handleFinish();
    }
  }

  Future<void> _handleFinish() async {
    // 1. Create or update user model with onboarding choices
    final baseUser =
        widget.user ??
        AuthService.instance.currentUser ??
        UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: AuthService.defaultEmail,
          name: AuthService.defaultName,
        );

    final updatedUser = baseUser.copyWith(
      gender: _selectedGender,
      isSedentary: _isSedentary,
      age: _selectedAge,
      heightCm: _heightUnit == 'cm'
          ? _selectedHeight.toDouble()
          : (_selectedHeight * 2.54),
      weightKg: _weightUnit == 'kg'
          ? _selectedWeight.toDouble()
          : (_selectedWeight * 0.453592),
      dailyStepGoal: _selectedStepGoal,
    );

    // 2. Persist daily step goal so the dashboard shows the same target
    await StepSessionStore.instance.saveGoal(_selectedStepGoal);
    try {
      if (LocalDatabase.instance.isInitialized) {
        final existingGoal = LocalDatabase.instance.goalsBox.get(
          'current_goal',
        );
        final newGoal = (existingGoal ?? GoalModel.defaultGoal()).copyWith(
          dailyStepGoal: _selectedStepGoal,
          updatedAt: DateTime.now(),
        );
        await LocalDatabase.instance.goalsBox.put('current_goal', newGoal);
      }
    } catch (_) {
      // Gracefully continue even if database box is not yet opened
    }

    if (!mounted) return;

    // Green success toast message at the bottom
    AppToast.success("Profile setup complete! Let's crush those goals!");

    // 3. Smooth transition to HomeScreen
    Navigator.of(
      context,
    ).pushReplacement(AppPageRoute.fade(page: HomeScreen(user: updatedUser)));
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / 6.0;
    final isLastStep = _currentStep == 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: _handleBack,
        ),
        title: Center(
          child: Container(
            width: 170,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${_currentStep + 1} / 6',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentStep),
                  child: _buildCurrentStepContent(),
                ),
              ),
            ),

            // Bottom Navigation Buttons: "Skip" and "Continue" / "Finish"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // Skip button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        key: const Key('step_skip_button'),
                        onPressed: _handleSkip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5EEFF),
                          foregroundColor: AppColors.primaryPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Continue or Finish button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        key: Key(
                          isLastStep
                              ? 'step_finish_button'
                              : 'step_continue_button',
                        ),
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isLastStep ? 'Finish' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<int> _range(int min, int max) =>
      List<int>.generate(max - min + 1, (i) => min + i);

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildGenderStep();
      case 1:
        return _buildSedentaryStep();
      case 2:
        return _buildAgeStep();
      case 3:
        return _buildHeightStep();
      case 4:
        return _buildWeightStep();
      case 5:
      default:
        return _buildStepGoalStep();
    }
  }

  // -------------------------------------------------------------
  // STEP 1: Select Your Gender (9_Light & 10_Light)
  // -------------------------------------------------------------
  Widget _buildGenderStep() {
    final isMan = _selectedGender == 'Man';
    final isWoman = _selectedGender == 'Woman';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeader(
            prefix: 'Select Your ',
            highlight: 'Gender',
            subtitle: "Let's start by understanding you.",
          ),
          const SizedBox(height: 24),

          // Two side-by-side figures: Man & Woman with interactive scaling animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Man option
              Expanded(
                child: _buildGenderFigure(
                  label: 'Man',
                  assetPath: AppAssets.genderMan,
                  isSelected: isMan,
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Man';
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Woman option
              Expanded(
                child: _buildGenderFigure(
                  label: 'Woman',
                  assetPath: AppAssets.genderWoman,
                  isSelected: isWoman,
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Woman';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderFigure({
    required String label,
    required String assetPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 470,
            child: AnimatedScale(
              scale: isSelected ? 1.06 : 0.92,
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.65,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Glowing purple circle behind selected figure
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isSelected ? 1.0 : 0.0,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 250),
                            scale: isSelected ? 1.0 : 0.6,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Oval shadow base under feet
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isSelected ? 180 : 150,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : const Color(0xFFE9ECF0),
                            borderRadius: const BorderRadius.all(
                              Radius.elliptical(180, 36),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Figure illustration image
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        assetPath,
                        height: 440,
                        cacheHeight: AppAssets.genderImageCacheHeight,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          label == 'Man' ? Icons.man : Icons.woman,
                          size: 240,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: isSelected ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 2: Sedentary Lifestyle (11_Light)
  // -------------------------------------------------------------
  Widget _buildSedentaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeader(
            prefix: 'Do You Live a ',
            highlight: 'Sedentary',
            suffix: '\nLifestyle?',
            subtitle: 'Tell us about your daily routine.',
          ),
          const SizedBox(height: 24),

          // Illustration of couch/bed with pizza
          Image.asset(
            AppAssets.sedentaryLifestyle,
            height: 240,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.weekend,
              size: 160,
              color: AppColors.primaryPurple,
            ),
          ),

          const SizedBox(height: 36),

          // Large circular No / Yes buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "No" button
              GestureDetector(
                key: const Key('sedentary_no'),
                onTap: () {
                  setState(() {
                    _isSedentary = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !_isSedentary
                        ? AppColors.primaryPurple
                        : const Color(0xFFF3F4F6),
                    boxShadow: !_isSedentary
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: !_isSedentary
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),

              // "Yes" button
              GestureDetector(
                key: const Key('sedentary_yes'),
                onTap: () {
                  setState(() {
                    _isSedentary = true;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isSedentary
                        ? AppColors.primaryPurple
                        : const Color(0xFFF3F4F6),
                    boxShadow: _isSedentary
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _isSedentary
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 3: How Old Are You? (12_Light)
  // -------------------------------------------------------------
  Widget _buildAgeStep() {
    final ageList = _range(_minAge, _maxAge);

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildHeader(
          prefix: 'How ',
          highlight: 'Old',
          suffix: ' Are You?',
          subtitle: 'Share your age with us.',
        ),
        const Spacer(),

        // Vertical number picker with 28 years selected
        VerticalNumberPicker(
          key: const Key('age_picker'),
          values: ageList,
          initialValue: _selectedAge,
          unit: 'years',
          onChanged: (age) {
            setState(() {
              _selectedAge = age;
            });
          },
        ),
        const Spacer(),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 4: What's Your Height? (13_Light)
  // -------------------------------------------------------------
  Widget _buildHeightStep() {
    final isCm = _heightUnit == 'cm';
    final heightList = isCm
        ? _range(_minHeightCm, _maxHeightCm)
        : _range(_minHeightIn, _maxHeightIn); // inches, shown as feet'inches"

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildHeader(
          prefix: "What's Your ",
          highlight: 'Height',
          suffix: '?',
          subtitle: 'How tall are you?',
        ),
        const SizedBox(height: 16),

        // Unit Toggle (cm / ft)
        _buildUnitToggle(
          leftLabel: 'cm',
          rightLabel: 'ft',
          activeUnit: _heightUnit,
          onUnitChanged: (unit) {
            setState(() {
              if (unit == _heightUnit) return;
              // Convert the current height instead of resetting it.
              _selectedHeight = unit == 'cm'
                  ? (_selectedHeight * 2.54)
                      .round()
                      .clamp(_minHeightCm, _maxHeightCm)
                  : (_selectedHeight / 2.54)
                      .round()
                      .clamp(_minHeightIn, _maxHeightIn);
              _heightUnit = unit;
            });
          },
        ),

        const Spacer(),

        // Height Vertical Number Picker
        VerticalNumberPicker(
          key: ValueKey<String>('height_picker_$_heightUnit'),
          values: heightList,
          initialValue: _selectedHeight,
          unit: _heightUnit,
          labelBuilder: isCm ? null : (inches) => "${inches ~/ 12}'${inches % 12}\"",
          onChanged: (val) {
            setState(() {
              _selectedHeight = val;
            });
          },
        ),
        const Spacer(),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 5: What's Your Weight? (14_Light)
  // -------------------------------------------------------------
  Widget _buildWeightStep() {
    final weightList = _weightUnit == 'kg'
        ? _range(_minWeightKg, _maxWeightKg)
        : _range(_minWeightLbs, _maxWeightLbs);

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildHeader(
          prefix: "What's Your ",
          highlight: 'Weight',
          suffix: '?',
          subtitle: 'Share your weight with us.',
        ),
        const SizedBox(height: 16),

        // Unit Toggle (kg / lbs)
        _buildUnitToggle(
          leftLabel: 'kg',
          rightLabel: 'lbs',
          activeUnit: _weightUnit,
          onUnitChanged: (unit) {
            setState(() {
              if (unit == _weightUnit) return;
              // Convert the current weight instead of resetting it.
              _selectedWeight = unit == 'kg'
                  ? (_selectedWeight * 0.453592)
                      .round()
                      .clamp(_minWeightKg, _maxWeightKg)
                  : (_selectedWeight / 0.453592)
                      .round()
                      .clamp(_minWeightLbs, _maxWeightLbs);
              _weightUnit = unit;
            });
          },
        ),

        const Spacer(),

        // Weight Vertical Number Picker
        VerticalNumberPicker(
          key: ValueKey<String>('weight_picker_$_weightUnit'),
          values: weightList,
          initialValue: _selectedWeight,
          unit: _weightUnit,
          onChanged: (val) {
            setState(() {
              _selectedWeight = val;
            });
          },
        ),
        const Spacer(),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 6: Set Your Step Goal (15_Light)
  // -------------------------------------------------------------
  Widget _buildStepGoalStep() {
    // Increments of 500 from 2,000 to 30,000 steps
    final goalList = List.generate(
      (_maxStepGoal - _minStepGoal) ~/ _stepGoalIncrement + 1,
      (index) => _minStepGoal + index * _stepGoalIncrement,
    );

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildHeader(
          prefix: 'Set Your ',
          highlight: 'Step Goal',
          subtitle: 'Choose your daily step goal to stay motivated!',
        ),
        const Spacer(),

        // Step Goal Vertical Number Picker (default: 6000 steps)
        VerticalNumberPicker(
          key: const Key('step_goal_picker'),
          values: goalList,
          initialValue: _selectedStepGoal,
          unit: 'steps',
          onChanged: (val) {
            setState(() {
              _selectedStepGoal = val;
            });
          },
        ),
        const Spacer(),
      ],
    );
  }

  // -------------------------------------------------------------
  // Helper Widgets: Header & Unit Toggle
  // -------------------------------------------------------------
  Widget _buildHeader({
    required String prefix,
    required String highlight,
    String? suffix,
    required String subtitle,
  }) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            TextSpan(
              text: prefix,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: highlight,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPurple,
                    letterSpacing: -0.5,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitToggle({
    required String leftLabel,
    required String rightLabel,
    required String activeUnit,
    required ValueChanged<String> onUnitChanged,
  }) {
    final isLeft = activeUnit == leftLabel;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onUnitChanged(leftLabel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 66,
            height: 38,
            decoration: BoxDecoration(
              color: isLeft ? AppColors.primaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: isLeft
                    ? AppColors.primaryPurple
                    : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                leftLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isLeft ? FontWeight.w700 : FontWeight.w600,
                  color: isLeft ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onUnitChanged(rightLabel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 66,
            height: 38,
            decoration: BoxDecoration(
              color: !isLeft ? AppColors.primaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: !isLeft
                    ? AppColors.primaryPurple
                    : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                rightLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: !isLeft ? FontWeight.w700 : FontWeight.w600,
                  color: !isLeft ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Standalone Screen for Step 6 matching 15_Light_sign up step 6 - set your step goal.png.
class SignUpStepSixScreen extends StatelessWidget {
  final UserModel? user;

  const SignUpStepSixScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return SignUpStepsScreen(user: user, initialStep: 5);
  }
}

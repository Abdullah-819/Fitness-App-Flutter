/// Centralized registry of all asset paths in the application.
class AppAssets {
  AppAssets._();

  // Images
  static const String splashScreenImage = 'assets/images/splash_screen.png';
  static const String walkthrough1 = 'assets/images/walkthrough_1.png';
  static const String walkthrough2 = 'assets/images/walkthrough_2.png';
  static const String walkthrough3 = 'assets/images/walkthrough_3.png';
  static const String genderMan = 'assets/images/gender_man.png';
  static const String genderWoman = 'assets/images/gender_woman.png';
  static const String genderManSelected = 'assets/images/gender_man_selected.png';
  static const String sedentaryLifestyle = 'assets/images/sedentary_lifestyle.png';
  static const String goalCompletionTrophy = 'assets/images/goal_completion_trophy.png';

  /// Decode height for the large gender illustrations (about 2x display).
  static const int genderImageCacheHeight = 880;

  // Icons
  static const String logoWhite = 'assets/icons/app_logo_white.png';
  static const String logoPurple = 'assets/icons/app_logo_purple.png';
}

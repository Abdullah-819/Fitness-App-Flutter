import 'package:flutter/services.dart' show appFlavor;

/// Which build of the app is running.
enum AppFlavor { staging, production }

/// Build-time configuration, driven by the Android/iOS flavor:
///
///     flutter run --flavor staging
///     flutter run --flavor production
///     flutter build apk --flavor production --release
///
/// Anything that is not explicitly the `production` flavor (including unit
/// and widget tests) behaves like staging, so test data stays available there.
class AppConfig {
  AppConfig._();

  static AppFlavor get flavor =>
      appFlavor == 'production' ? AppFlavor.production : AppFlavor.staging;

  static bool get isProduction => flavor == AppFlavor.production;

  /// True for the staging build: shows the STAGING label, demo/team accounts,
  /// auto-fill helpers, state simulators and mock dashboard data.
  static bool get isStaging => !isProduction;

  /// Text of the ribbon shown on staging builds.
  static const String stagingLabel = 'STAGING';
}

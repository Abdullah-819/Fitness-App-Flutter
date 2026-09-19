import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/fading_spinner.dart';
import '../widgets/footprints_icon.dart';

/// Minimalist splash screen for Step Counter & Walking Goals.
///
/// Features:
/// - Flat vibrant purple background (#7C3AED)
/// - Centered overlapping shoe-prints silhouette
/// - Bold, rounded sans-serif title typography
/// - Smooth animated gradient circular loading spinner
/// - Configurable initialization duration and transition callback
class SplashScreen extends StatefulWidget {
  /// The time the splash screen displays before triggering [onInitialized].
  final Duration duration;

  /// Callback executed when the splash delay finishes.
  final VoidCallback? onInitialized;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2500),
    this.onInitialized,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.onInitialized != null) {
      _timer = Timer(widget.duration, () {
        if (mounted) {
          widget.onInitialized!();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryPurple,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryPurple,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Overlapping shoeprints silhouette icon
                const FootprintsIcon(
                  size: 110,
                  color: AppColors.white,
                ),
                const SizedBox(height: 24),
                // App Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Step Counter &\nWalking Goals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                // Bottom loading spinner
                const FadingSpinner(
                  size: 50,
                  strokeWidth: 4.5,
                  color: AppColors.white,
                ),
                const SizedBox(height: 52),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

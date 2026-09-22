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
                const Spacer(flex: 5),
                // Overlapping shoeprints silhouette icon
                const FootprintsIcon(
                  size: 108,
                ),
                const SizedBox(height: 28),
                // TrackFit Brand Title
                Semantics(
                  header: true,
                  label: 'TrackFit',
                  child: Image.asset(
                    'assets/images/trackfit_text_transparent.png',
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'TrackFit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(flex: 6),
                // Bottom animated loading spinner
                const FadingSpinner(
                  size: 58,
                  strokeWidth: 7.0,
                  color: AppColors.white,
                ),
                const SizedBox(height: 58),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

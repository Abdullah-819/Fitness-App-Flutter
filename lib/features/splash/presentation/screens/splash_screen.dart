import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/fading_spinner.dart';
import '../widgets/footprints_icon.dart';

/// Minimalist, high-performance splash screen for Step Counter & Walking Goals.
///
/// Features:
/// - Full-bleed vibrant purple background (#7C3AED)
/// - Authentic design asset logo with smooth fade & scale entrance animation
/// - Bold, rounded typography
/// - Rotating circular sweep-gradient loading spinner
/// - Configurable initialization duration and completion callback
class SplashScreen extends StatefulWidget {
  /// The duration the splash screen displays before triggering [onInitialized].
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Entrance animation for logo and title
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Timer to trigger navigation/callback
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
    _animController.dispose();
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
                // Animated logo & typography block
                Semantics(
                  header: true,
                  label: 'TrackFit',
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Overlapping shoeprints silhouette icon
                          const FootprintsIcon(
                            size: 108,
                          ),
                          const SizedBox(height: 28),
                          // TrackFit Brand Title
                          Image.asset(
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
                        ],
                      ),
                    ),
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

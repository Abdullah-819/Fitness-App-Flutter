import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import 'welcome_screen.dart';

/// Data model representing an onboarding walkthrough slide.
class WalkthroughItem {
  final String image;
  final String title;
  final String description;

  const WalkthroughItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Walkthrough / Onboarding screen corresponding to designs:
/// - Screen 2: 2_Light_walkthrough 1.png
/// - Screen 3: 3_Light_walkthrough 2.png
/// - Screen 4: 4_Light_walkthrough 3.png
class WalkthroughScreen extends StatefulWidget {
  /// The starting slide index (0 for Walkthrough 1).
  final int initialPage;

  const WalkthroughScreen({
    super.key,
    this.initialPage = 0,
  });

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  late final PageController _pageController;
  late int _currentPage;

  static const List<WalkthroughItem> _items = [
    WalkthroughItem(
      image: AppAssets.walkthrough1,
      title: 'TrackFit - Your Ultimate\nStep Counter & Tracker',
      description:
          'Track your steps, monitor your progress, live route tracking, '
          'insightful reports, and detailed history, and achieve your fitness goals.',
    ),
    WalkthroughItem(
      image: AppAssets.walkthrough2,
      title: 'Discover Your Route with\nLive Maps',
      description:
          "Experience the thrill of tracking your steps in real-time with "
          "TrackFit's live maps. TrackFit keeps you connected to your journey.",
    ),
    WalkthroughItem(
      image: AppAssets.walkthrough3,
      title: 'Gain Step Insights with\nDetailed Reports',
      description:
          "Stay informed about your step count, distance traveled, and calories "
          "burned with TrackFit's comprehensive reports.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isTall = constraints.maxHeight > 750;
            final isVeryCompact = constraints.maxHeight < 620;

            return Column(
              children: [
                // Top Section with Purple Background & Phone Mockup
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: AppColors.primaryPurple,
                    child: SafeArea(
                      bottom: false,
                      child: ClipRect(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                item.image,
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.bottomCenter,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Section with Content, Indicators & Buttons
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isTall ? 28 : (isVeryCompact ? 10 : 16)),

                        // Title Text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _items[_currentPage].title,
                            key: ValueKey<String>(_items[_currentPage].title),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTall ? 25 : (isVeryCompact ? 20 : 22),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.3,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),

                        SizedBox(height: isTall ? 14 : (isVeryCompact ? 6 : 10)),

                        // Description Text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _items[_currentPage].description,
                            key: ValueKey<String>(
                              _items[_currentPage].description,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTall ? 15 : 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),

                        SizedBox(height: isTall ? 26 : (isVeryCompact ? 12 : 18)),

                        // Page Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_items.length, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              width: isActive ? 32 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primaryPurple
                                    : AppColors.indicatorInactive,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        SizedBox(height: isTall ? 34 : (isVeryCompact ? 14 : 22)),

                        // Action Buttons: Skip & Continue (pages 0 & 1) or Let's Get Started (page 2)
                        if (_currentPage < _items.length - 1)
                          Row(
                            children: [
                              // Skip Button
                              Expanded(
                                child: SizedBox(
                                  height: isVeryCompact ? 48 : 56,
                                  child: ElevatedButton(
                                    onPressed: _navigateToWelcome,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightPurpleBg,
                                      foregroundColor: AppColors.primaryPurple,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
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
                              // Continue Button
                              Expanded(
                                child: SizedBox(
                                  height: isVeryCompact ? 48 : 56,
                                  child: ElevatedButton(
                                    onPressed: _onNext,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          // Let's Get Started Button (Page 3)
                          SizedBox(
                            width: double.infinity,
                            height: isVeryCompact ? 48 : 56,
                            child: ElevatedButton(
                              onPressed: _navigateToWelcome,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Let's Get Started",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: isTall ? 20 : 12),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Reusable page route with smooth custom entrance and exit transitions.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AppPageRoute({
    required this.page,
    Duration duration = const Duration(milliseconds: 350),
    Duration reverseDuration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Smooth curved progression
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           // Subtle slide from right (shared-axis feel)
           final slideAnimation = Tween<Offset>(
             begin: const Offset(0.06, 0.0),
             end: Offset.zero,
           ).animate(curved);

           // Smooth opacity fade
           final fadeAnimation = Tween<double>(
             begin: 0.0,
             end: 1.0,
           ).animate(curved);

           return SlideTransition(
             position: slideAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );

  /// Smooth pure fade transition route
  static PageRouteBuilder<T> fade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 350),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        );
      },
    );
  }
}

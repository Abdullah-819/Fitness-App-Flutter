import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StepCounterApp());
}

class StepCounterApp extends StatelessWidget {
  const StepCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPurple,
          primary: AppColors.primaryPurple,
        ),
        scaffoldBackgroundColor: AppColors.primaryPurple,
      ),
      home: Builder(
        builder: (context) {
          return SplashScreen(
            duration: const Duration(milliseconds: 2500),
            onInitialized: () {
              // Smooth fade transition to SignInScreen
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SignInScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

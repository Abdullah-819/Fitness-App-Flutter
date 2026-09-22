import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
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
      home: SplashScreen(
        onInitialized: () {
          // Placeholder callback when onboarding or dashboard is wired up
          debugPrint('Splash initialization complete.');
        },
      ),
    );
  }
}

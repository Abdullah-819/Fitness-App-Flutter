import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/theme_controller.dart';
import 'features/onboarding/presentation/screens/walkthrough_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController()..load(); // non-blocking
  runApp(
    ChangeNotifierProvider<ThemeController>.value(
      value: themeController,
      child: const StepCounterApp(),
    ),
  );
}

class StepCounterApp extends StatelessWidget {
  const StepCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData buildTheme(Brightness brightness) => ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryPurple,
            primary: AppColors.primaryPurple,
            brightness: brightness,
          ),
          scaffoldBackgroundColor: AppColors.primaryPurple,
        );

    return MaterialApp(
      title: 'TrackFit',
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ThemeController>().mode,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Builder(
        builder: (context) {
          return SplashScreen(
            duration: const Duration(milliseconds: 2500),
            onInitialized: () {
              // Smooth fade transition to WalkthroughScreen (Screen 2)
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const WalkthroughScreen(),
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

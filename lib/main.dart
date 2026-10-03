import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/data/auth_service.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/onboarding/presentation/screens/sign_up_steps_screen.dart';
import 'features/onboarding/presentation/screens/walkthrough_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _enterImmersiveMode();
  final themeController = ThemeController()..load(); // non-blocking
  runApp(
    ChangeNotifierProvider<ThemeController>.value(
      value: themeController,
      child: const StepCounterApp(),
    ),
  );
}

/// Hides the system navigation buttons (back / home / recents) so the app
/// uses the whole screen, while keeping the status bar (time, battery,
/// signal) visible at the top.
void _enterImmersiveMode() {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
}

class StepCounterApp extends StatefulWidget {
  const StepCounterApp({super.key});

  @override
  State<StepCounterApp> createState() => _StepCounterAppState();
}

class _StepCounterAppState extends State<StepCounterApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android can bring the bars back after the app was in the background
    // or a system dialog (e.g. permission prompt) was shown.
    if (state == AppLifecycleState.resumed) _enterImmersiveMode();
  }

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
      builder: (context, child) {
        if (AppConfig.isProduction) return child!;
        return Stack(
          textDirection: TextDirection.ltr,
          children: [child!, const _StagingLabel()],
        );
      },
      home: Builder(
        builder: (context) {
          return SplashScreen(
            duration: const Duration(milliseconds: 2500),
            onInitialized: () async {
              // Already signed in on this device? Skip straight to the app.
              final user = await AuthService.instance.restoreSession();
              if (!context.mounted) return;

              final Widget next = user == null
                  ? const WalkthroughScreen()
                  : user.isProfileComplete
                  ? HomeScreen(user: user)
                  : SignUpStepsScreen(user: user);

              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => next,
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

/// Small "STAGING" tag shown just below the status bar on staging builds.
class _StagingLabel extends StatelessWidget {
  const _StagingLabel();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top,
      left: 0,
      right: 0,
      child: const IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFFF9500),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              child: Text(
                AppConfig.stagingLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

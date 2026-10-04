import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/services/local_database.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/step_sensor_service.dart';
import '../../../../core/services/step_session_store.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../splash/presentation/widgets/footprints_icon.dart';
import '../../../track/track.dart';
import '../../../../widgets/fade_slide_in.dart';
import '../widgets/daily_stats_row.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/goal_completion_dialog.dart';
import '../widgets/location_permission_dialog.dart';
import '../widgets/physical_activity_permission_dialog.dart';
import '../widgets/speedometer_gauge.dart';
import '../widgets/weekly_progress_card.dart';
import 'account_view.dart';

/// Complete Dashboard screen implementing all designs from `design/DashBoard/`:
/// - Screen 23: Physical Activity Permission Request
/// - Screen 24: Location Access Permission Request
/// - Screen 25: Home - Default (Speedometer arc gauge, stats, weekly progress, bottom nav)
/// - Screen 26: Home - Steps counter active (Live simulation, pause button)
/// - Screen 27: Home - Step goal passed celebration modal (Trophy illustration)
/// - Screen 28: Home - Steps counter active - Goal exceeded
/// - Screen 29: Home - Steps counter stopped - Step goal passed
class DashboardScreen extends StatefulWidget {
  final UserModel? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  // Step & Fitness metrics state
  int _currentSteps = 0;
  int _stepGoal = 6000;
  int _elapsedSeconds = 0;
  double _distanceKm = 0.0;
  int _calories = 0;

  // Active counting state
  bool _isActive = false;
  bool _hasPassedGoal = false;
  Timer? _stepTimer;
  final StepSensorService _stepSensor = StepSensorService();
  int? _sensorBaseline; // raw sensor value matching _stepsAtBaseline
  int _stepsAtBaseline = 0;
  bool _sensorUnavailable = false;

  // Navigation & UI state
  int _currentNavIndex = 0;
  String _selectedWeekPeriod = 'This Week';
  bool _hasPromptedPermissions = false;

  /// Saved step totals per day (yyyy-mm-dd), used for weekly progress.
  Map<String, int> _history = {};
  UserModel? _currentUser;
  late final TrackProvider _trackProvider;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user ?? AuthService.instance.currentUser;
    _trackProvider = TrackProvider();
    WidgetsBinding.instance.addObserver(this);
    // Resolve the goal first so restored steps are compared against it.
    _loadUserGoal().then((_) => _restoreSession());
    StepSessionStore.instance.loadHistory().then((history) {
      if (mounted) setState(() => _history = history);
    });

    // Check permissions after first frame
    // Let the dashboard animate in before showing a dialog on top of it.
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _checkInitialPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepTimer?.cancel();
    _stepSensor.stop();
    _trackProvider.dispose();
    super.dispose();
  }

  /// Daily goal priority: the signed-in user's goal (set during onboarding),
  /// then the saved goal, then the goals database, then 6,000.
  Future<void> _loadUserGoal() async {
    int? goal =
        _currentUser?.dailyStepGoal ??
        widget.user?.dailyStepGoal ??
        AuthService.instance.currentUser?.dailyStepGoal;

    goal ??= await StepSessionStore.instance.loadGoal();

    if (goal == null) {
      try {
        if (LocalDatabase.instance.isInitialized) {
          goal = LocalDatabase.instance.goalsBox
              .get('current_goal')
              ?.dailyStepGoal;
        }
      } catch (_) {
        // Fall through to the default goal.
      }
    }

    if (!mounted) return;
    final resolved = (goal != null && goal > 0) ? goal : 6000;
    setState(() => _stepGoal = resolved);
    // Keep the saved goal in sync with what the dashboard shows.
    await StepSessionStore.instance.saveGoal(resolved);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the background: pick up steps counted while we were away.
    if (state == AppLifecycleState.resumed) {
      _restoreSession();
    } else if (state == AppLifecycleState.paused) {
      _persistSession();
    }
  }

  /// Loads today's saved session. If counting was on, the phone's hardware
  /// counter kept running while the app was closed, so the first sensor
  /// reading adds those steps back in.
  Future<void> _restoreSession() async {
    if (_isActive) return; // already counting live
    final saved = await StepSessionStore.instance.load();
    if (!mounted || saved == null) return;
    if (saved.day != StepSession.dayKey(DateTime.now())) return; // new day

    final away = saved.active
        ? ((DateTime.now().millisecondsSinceEpoch - saved.savedAtMs) ~/ 1000)
              .clamp(0, 86400)
        : 0;

    setState(() {
      _currentSteps = saved.steps;
      _elapsedSeconds = saved.elapsedSeconds + away;
      _hasPassedGoal = saved.steps >= _stepGoal;
      _recalculateMetrics();
    });

    if (saved.active &&
        !_isActive &&
        await PermissionService.instance.hasActivity()) {
      _sensorBaseline = saved.sensorBaseline;
      _stepsAtBaseline = saved.steps;
      _beginTracking();
    }
  }

  void _persistSession() {
    final today = StepSession.dayKey(DateTime.now());
    _history[today] = _currentSteps;
    StepSessionStore.instance.saveDayTotal(today, _currentSteps);
    StepSessionStore.instance.save(
      StepSession(
        day: StepSession.dayKey(DateTime.now()),
        steps: _currentSteps,
        elapsedSeconds: _elapsedSeconds,
        active: _isActive,
        sensorBaseline: _sensorBaseline,
        savedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _checkInitialPermissions() async {
    if (_hasPromptedPermissions) return;
    _hasPromptedPermissions = true;

    final permissions = PermissionService.instance;

    // Physical Activity Permission (Screen 23)
    var activityGranted = await permissions.hasActivity();
    if (!activityGranted) {
      if (!mounted) return;
      activityGranted =
          await PhysicalActivityPermissionDialog.show(context) == true;
    }
    if (!mounted || !activityGranted) return;

    // Location Permission (Screen 24)
    if (!await permissions.hasLocation()) {
      if (!mounted) return;
      await LocationPermissionDialog.show(context);
    }
  }

  void _toggleStepCounting() {
    if (_isActive) {
      _pauseCounting();
    } else {
      _startCounting();
    }
  }

  Future<void> _startCounting() async {
    // Real step counting needs the physical activity permission.
    if (!await PermissionService.instance.hasActivity()) {
      if (!mounted) return;
      final granted = await PhysicalActivityPermissionDialog.show(context);
      if (granted != true) {
        AppToast.info('Physical activity permission is needed to count steps');
        return;
      }
    }
    if (!mounted) return;

    _sensorBaseline = null; // first sensor reading becomes the new baseline
    _stepsAtBaseline = _currentSteps;
    _beginTracking();
  }

  /// Starts the sensor listener and the elapsed-time timer.
  void _beginTracking() {
    setState(() {
      _isActive = true;
      _sensorUnavailable = false;
    });

    _stepSensor.start(
      onRawSteps: (raw) {
        if (!mounted || !_isActive) return;
        final baseline = _sensorBaseline;
        if (baseline == null || raw < baseline) {
          // First reading (or the phone rebooted and reset its counter).
          _sensorBaseline = raw;
          _stepsAtBaseline = _currentSteps;
        }
        _updateSteps(_stepsAtBaseline + raw - _sensorBaseline!);
      },
      onError: (_) {
        // No step sensor (e.g. emulator): fall back to one step per second.
        if (!mounted) return;
        setState(() => _sensorUnavailable = true);
        AppToast.info('Step sensor unavailable, using simulated steps');
      },
    );

    // Timer drives elapsed time (and the fallback when there is no sensor).
    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _elapsedSeconds += 1);
      if (_sensorUnavailable) _updateSteps(_currentSteps + 1);
    });
    _persistSession();
  }

  void _updateSteps(int steps) {
    setState(() {
      _currentSteps = steps;
      _recalculateMetrics();

      // Check if goal was just passed
      if (_currentSteps >= _stepGoal && !_hasPassedGoal) {
        _hasPassedGoal = true;
        _showGoalCompletedCelebration();
      }
    });
    _persistSession();
  }

  void _pauseCounting() {
    _stepTimer?.cancel();
    _stepSensor.stop();
    setState(() {
      _isActive = false;
    });
    _persistSession();
  }

  void _recalculateMetrics() {
    // Standard stride estimation: ~0.00078 km per step
    _distanceKm = double.parse((_currentSteps * 0.00078).toStringAsFixed(2));
    // Standard calorie burn: ~0.042 kcal per step
    _calories = (_currentSteps * 0.042).round();
  }

  void _showGoalCompletedCelebration() {
    GoalCompletionDialog.show(
      context: context,
      stepGoal: _stepGoal,
      durationString: _formatDuration(_elapsedSeconds),
      caloriesString: '$_calories',
      distanceKmString: _distanceKm.toStringAsFixed(2),
    ).then((continueSteps) {
      if (!mounted) return;
      if (continueSteps == true) {
        // User tapped "Continue Steps" (Screen 28 state)
        if (!_isActive) {
          _startCounting();
        }
      } else {
        // User tapped "Stop Step" (Screen 29 state)
        _pauseCounting();
      }
    });
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Preset state simulators to easily test screens 25-29
  void _simulateDefaultState() {
    _pauseCounting();
    setState(() {
      _currentSteps = 0;
      _elapsedSeconds = 0;
      _distanceKm = 0.0;
      _calories = 0;
      _hasPassedGoal = false;
    });
  }

  void _simulateActiveState() {
    setState(() {
      _currentSteps = 4805;
      _elapsedSeconds = 74 * 60; // 1h 14m
      _calories = 360;
      _distanceKm = 5.46;
      _hasPassedGoal = false;
      _isActive = true;
    });
  }

  void _simulateGoalCompletedModal() {
    _pauseCounting();
    setState(() {
      _currentSteps = 6000;
      _elapsedSeconds = 90 * 60; // 1h 30m
      _calories = 432;
      _distanceKm = 6.90;
      _hasPassedGoal = true;
    });
    _showGoalCompletedCelebration();
  }

  void _simulateExceededState() {
    setState(() {
      _currentSteps = 6496;
      _elapsedSeconds = 94 * 60; // 1h 34m
      _calories = 525;
      _distanceKm = 7.23;
      _hasPassedGoal = true;
      _isActive = true;
    });
  }

  void _simulateStoppedPassedState() {
    _pauseCounting();
    setState(() {
      _currentSteps = 6000;
      _elapsedSeconds = 90 * 60; // 1h 30m
      _calories = 432;
      _distanceKm = 6.90;
      _hasPassedGoal = true;
      _isActive = false;
    });
  }

  void _handleSignOut() {
    AuthService.instance.signOut();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Lifetime level: one level per 50,000 steps (staging shows a fixed 9).
  int get _level {
    if (AppConfig.isStaging) return 9;
    final todayKey = StepSession.dayKey(DateTime.now());
    var total = _currentSteps;
    _history.forEach((day, steps) {
      if (day != todayKey) total += steps;
    });
    return 1 + total ~/ 50000;
  }

  /// Real last-7-days progress from saved totals (production).
  List<DayProgressData> _buildWeeklyProgress() {
    if (AppConfig.isStaging) return _mockWeeklyProgress();

    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      for (var i = 6; i >= 0; i--)
        () {
          final date = today.subtract(Duration(days: i));
          final steps = i == 0
              ? _currentSteps
              : (_history[StepSession.dayKey(date)] ?? 0);
          return DayProgressData(
            dayName: names[date.weekday - 1],
            dayNumber: date.day,
            progress: _stepGoal > 0 ? (steps / _stepGoal).clamp(0.0, 1.0) : 0.0,
            isToday: i == 0,
          );
        }(),
    ];
  }

  /// Fixed sample week used by the staging build.
  List<DayProgressData> _mockWeeklyProgress() {
    final todayProgress = _stepGoal > 0
        ? (_currentSteps / _stepGoal).clamp(0.0, 1.0)
        : 0.0;

    return [
      const DayProgressData(dayName: 'Mon', dayNumber: 16, progress: 1.0),
      const DayProgressData(dayName: 'Tue', dayNumber: 17, progress: 1.0),
      const DayProgressData(dayName: 'Wed', dayNumber: 18, progress: 0.45),
      const DayProgressData(dayName: 'Thu', dayNumber: 19, progress: 0.75),
      const DayProgressData(dayName: 'Fri', dayNumber: 20, progress: 0.85),
      const DayProgressData(dayName: 'Sat', dayNumber: 21, progress: 1.0),
      DayProgressData(
        dayName: 'Sun',
        dayNumber: 22,
        progress: todayProgress,
        isToday: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final foreground = palette.textPrimary;
    final surface = palette.background;

    final String titleText;
    switch (_currentNavIndex) {
      case 1:
        titleText = 'Track';
        break;
      case 2:
        titleText = 'Report';
        break;
      case 3:
        titleText = 'History';
        break;
      case 4:
        titleText = 'Account';
        break;
      default:
        titleText = 'Home';
    }

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(
            child: FootprintsIcon(size: 28, color: AppColors.primaryPurple),
          ),
        ),
        title: Text(
          titleText,
          style: TextStyle(
            color: foreground,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.ellipsisVertical, color: foreground),
            color: palette.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              switch (value) {
                case 'perm_activity':
                  PhysicalActivityPermissionDialog.show(context);
                  break;
                case 'perm_location':
                  LocationPermissionDialog.show(context);
                  break;
                case 'sim_default':
                  _simulateDefaultState();
                  break;
                case 'sim_active':
                  _simulateActiveState();
                  break;
                case 'sim_modal':
                  _simulateGoalCompletedModal();
                  break;
                case 'sim_exceeded':
                  _simulateExceededState();
                  break;
                case 'sim_stopped':
                  _simulateStoppedPassedState();
                  break;
                case 'sim_track_walk':
                  _trackProvider.startTracking(simulateInStaging: true);
                  break;
                case 'sign_out':
                  _handleSignOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              // Test helpers: staging build only
              if (AppConfig.isStaging) ...[
                if (_currentNavIndex == 1)
                  const PopupMenuItem(
                    value: 'sim_track_walk',
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.route,
                          size: 20,
                          color: AppColors.primaryPurple,
                        ),
                        SizedBox(width: 12),
                        Text('Simulate GPS Walk (30/31)'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'perm_activity',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.footprints,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                      SizedBox(width: 12),
                      Text('Physical Activity Permission (23)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'perm_location',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                      SizedBox(width: 12),
                      Text('Location Permission (24)'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'sim_default',
                  child: Text('State 25: Home Default (0 Steps)'),
                ),
                const PopupMenuItem(
                  value: 'sim_active',
                  child: Text('State 26: Active (4,805 Steps)'),
                ),
                const PopupMenuItem(
                  value: 'sim_modal',
                  child: Text('State 27: Goal Passed Celebration (6,000)'),
                ),
                const PopupMenuItem(
                  value: 'sim_exceeded',
                  child: Text('State 28: Goal Exceeded (6,496 Steps)'),
                ),
                const PopupMenuItem(
                  value: 'sim_stopped',
                  child: Text('State 29: Stopped Goal Passed (6,000)'),
                ),
                const PopupMenuDivider(),
              ],
              const PopupMenuItem(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 20, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: _currentNavIndex != 1,
        bottom: false,
        child: ChangeNotifierProvider<TrackProvider>.value(
          value: _trackProvider,
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              _buildHomeTab(),
              const TrackScreen(),
              _buildPlaceholderTab('Report'),
              _buildPlaceholderTab('History'),
              AccountView(
                user: _currentUser ?? widget.user ?? AuthService.instance.currentUser,
                level: _level,
                onLogout: _handleSignOut,
                onUserUpdated: (updated) {
                  setState(() {
                    _currentUser = updated;
                    if (updated.dailyStepGoal != null && updated.dailyStepGoal! > 0) {
                      _stepGoal = updated.dailyStepGoal!;
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _currentNavIndex,
        onTabSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 2 || index == 3) {
            final tabNames = ['Home', 'Track', 'Report', 'History', 'Account'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Switched to ${tabNames[index]} tab'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speedometer Circular Arc Step Gauge (Screens 25, 26, 28, 29)
          FadeSlideIn(
            child: SpeedometerGauge(
              currentSteps: _currentSteps,
              stepGoal: _stepGoal,
              isActive: _isActive,
              onToggle: _toggleStepCounting,
            ),
          ),

          const SizedBox(height: 16),

          // Activity Stats Row: Time, Calories, Distance
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: DailyStatsRow(
              timeString: _formatDuration(_elapsedSeconds),
              caloriesString: '$_calories',
              distanceKmString: _distanceKm.toStringAsFixed(2),
            ),
          ),

          const SizedBox(height: 16),

          // "Your Progress" Weekly Progress Card
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: WeeklyProgressCard(
              days: _buildWeeklyProgress(),
              selectedPeriod: _selectedWeekPeriod,
              onPeriodChanged: (newPeriod) {
                setState(() {
                  _selectedWeekPeriod = newPeriod;
                });
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String name) {
    final p = AppPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 48, color: p.textSecondary),
          const SizedBox(height: 12),
          Text(
            '$name coming soon',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

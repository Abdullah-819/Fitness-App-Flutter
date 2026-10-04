import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/step_sensor_service.dart';
import '../../data/location_tracking_service.dart';
import '../../data/track_config.dart';
import '../../data/track_session_store.dart';
import '../../domain/track_session.dart';

/// State management for the live GPS tracking feature.
/// Survives dashboard tab switching so sessions continue uninterrupted.
class TrackProvider extends ChangeNotifier {
  final LocationTrackingService _locationService;
  final StepSensorService _stepSensor;
  final TrackSessionStore _sessionStore;

  TrackProvider({
    LocationTrackingService? locationService,
    StepSensorService? stepSensor,
    TrackSessionStore? sessionStore,
  })  : _locationService = locationService ?? LocationTrackingService(),
        _stepSensor = stepSensor ?? StepSensorService(),
        _sessionStore = sessionStore ?? TrackSessionStore.instance;

  // Tracking state
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  bool _isAutoFollow = true;
  bool get isAutoFollow => _isAutoFollow;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  LatLng? _startPosition;
  LatLng? get startPosition => _startPosition;

  final List<TrackPoint> _points = [];
  List<TrackPoint> get points => List.unmodifiable(_points);

  List<LatLng> get polylinePoints =>
      _points.map((p) => LatLng(p.latitude, p.longitude)).toList();

  int _steps = 0;
  int get steps => _steps;

  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  double _distanceKm = 0.0;
  double get distanceKm => _distanceKm;

  int _kcal = 0;
  int get kcal => _kcal;

  TrackSession? _lastSavedSession;
  TrackSession? get lastSavedSession => _lastSavedSession;

  // Stream & timer subscriptions
  StreamSubscription<TrackPoint>? _pointSubscription;
  Timer? _timer;
  int? _sensorBaseline;
  int _stepsAtBaseline = 0;
  bool _sensorUnavailable = false;
  DateTime? _sessionStartTime;

  /// Initializes location state and acquires current user coordinate.
  Future<void> initLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      notifyListeners();
    }
  }

  /// Sets current position explicitly (used by locate button or initial acquisition).
  void setCurrentPosition(LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  /// Enables or disables auto-following the user on the map.
  void setAutoFollow(bool autoFollow) {
    if (_isAutoFollow != autoFollow) {
      _isAutoFollow = autoFollow;
      notifyListeners();
    }
  }

  /// Starts live tracking. If [simulateInStaging] is true and staging flavor
  /// is active, uses mock GPS coordinates.
  Future<void> startTracking({bool simulateInStaging = false}) async {
    if (_isTracking) return;

    _isTracking = true;
    _isAutoFollow = true;
    _steps = 0;
    _elapsedSeconds = 0;
    _distanceKm = 0.0;
    _kcal = 0;
    _points.clear();
    _sensorBaseline = null;
    _stepsAtBaseline = 0;
    _sensorUnavailable = false;
    _sessionStartTime = DateTime.now();

    // Determine initial anchor point
    final pos = await _locationService.getCurrentPosition();
    final startLatLng = pos != null
        ? LatLng(pos.latitude, pos.longitude)
        : (_currentPosition ??
            (AppConfig.isStaging
                ? TrackConfig.stagingMockCenter
                : TrackConfig.defaultCenter));

    _currentPosition = startLatLng;
    _startPosition = startLatLng;

    final initialTrackPoint = TrackPoint(
      latitude: startLatLng.latitude,
      longitude: startLatLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      speed: 1.2,
    );
    _points.add(initialTrackPoint);

    // Listen to accepted GPS points from service
    _pointSubscription?.cancel();
    _pointSubscription = _locationService.onPointAccepted.listen((point) {
      _points.add(point);
      _currentPosition = LatLng(point.latitude, point.longitude);
      _distanceKm = LocationTrackingService.calculateTotalDistanceKm(_points);
      notifyListeners();
    });

    if (simulateInStaging && AppConfig.isStaging) {
      _locationService.startStagingSimulation(
        startLat: startLatLng.latitude,
        startLng: startLatLng.longitude,
      );
    } else {
      _locationService.startTracking(initialPoint: initialTrackPoint);
    }

    // Step detector
    _stepSensor.start(
      onRawSteps: (raw) {
        if (!_isTracking) return;
        final baseline = _sensorBaseline;
        if (baseline == null || raw < baseline) {
          _sensorBaseline = raw;
          _stepsAtBaseline = _steps;
        }
        _updateSteps(_stepsAtBaseline + (raw - _sensorBaseline!));
      },
      onError: (_) {
        _sensorUnavailable = true;
      },
    );

    // 1-second elapsed timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }
      _elapsedSeconds += 1;
      if (_sensorUnavailable) {
        // Fallback: 1 simulated step per second when sensor is absent
        _updateSteps(_steps + 1);
      } else {
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void _updateSteps(int newSteps) {
    _steps = newSteps;
    _kcal = (_steps * 0.042).round();
    // If GPS points are few, fallback distance from steps
    if (_points.length < 2 && _distanceKm == 0.0) {
      _distanceKm = double.parse((_steps * 0.00078).toStringAsFixed(2));
    }
    notifyListeners();
  }

  /// Stops tracking, compiles the [TrackSession], and saves to Hive store.
  Future<TrackSession?> stopTracking() async {
    if (!_isTracking && _points.isEmpty) return null;

    _isTracking = false;
    _timer?.cancel();
    _timer = null;
    _pointSubscription?.cancel();
    _pointSubscription = null;
    _locationService.stopTracking();
    _stepSensor.stop();

    final endedAt = DateTime.now();
    final startedAt = _sessionStartTime ?? endedAt.subtract(Duration(seconds: _elapsedSeconds));

    final session = TrackSession(
      id: 'track_${startedAt.millisecondsSinceEpoch}',
      startedAt: startedAt,
      endedAt: endedAt,
      points: List.of(_points),
      steps: _steps,
      distanceKm: _distanceKm,
      durationSeconds: _elapsedSeconds,
      kcal: _kcal,
    );

    _lastSavedSession = session;
    await _sessionStore.saveSession(session);

    notifyListeners();
    return session;
  }

  /// Formatted duration string e.g. "1h 14m" or "14m" or "0s".
  String get formattedDuration {
    if (_elapsedSeconds <= 0) return '0s';
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${seconds}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pointSubscription?.cancel();
    _locationService.dispose();
    _stepSensor.stop();
    super.dispose();
  }
}

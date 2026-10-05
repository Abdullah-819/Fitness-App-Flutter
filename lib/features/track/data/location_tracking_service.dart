import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/config/app_config.dart';
import '../domain/track_session.dart';

/// Service managing GPS location streams, point filtering, distance
/// calculations, and mock route simulation for staging.
///
/// TODO: Background / foreground service tracking (e.g. flutter_foreground_task)
/// can be added as a follow-up to support continuous tracking when the app is
/// minimized or the screen is locked.
class LocationTrackingService {
  LocationTrackingService();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;

  final _pointController = StreamController<TrackPoint>.broadcast();
  Stream<TrackPoint> get onPointAccepted => _pointController.stream;

  TrackPoint? _lastAcceptedPoint;
  TrackPoint? get lastAcceptedPoint => _lastAcceptedPoint;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Default fallback coordinate (Pakistan center) when GPS is not yet acquired.
  static const double fallbackLat = 30.3753;
  static const double fallbackLng = 69.3451;
  static const double fallbackZoom = 5.0;

  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current location permission status.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission from the operating system.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Opens the device's location service settings.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Opens the application settings.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Retrieves the current device position, or null if unavailable.
  Future<Position?> getCurrentPosition() async {
    try {
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) return null;

      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('LocationTrackingService.getCurrentPosition error: $e');
      return null;
    }
  }

  /// Evaluates whether a new GPS point passes filtering rules:
  /// 1. Accuracy must be <= [maxAccuracyMeters] (default 20 m).
  /// 2. Distance from previous point must be >= [minDistanceMeters] (default 5 m).
  /// 3. Speed between points must not exceed [maxSpeedMps] (default 12 m/s ~ 43 km/h).
  static bool shouldAcceptPoint({
    required TrackPoint newPoint,
    TrackPoint? lastPoint,
    double maxAccuracyMeters = 20.0,
    double minDistanceMeters = 5.0,
    double maxSpeedMps = 12.0,
  }) {
    // 1. Accuracy filter
    if (newPoint.accuracy != null && newPoint.accuracy! > maxAccuracyMeters) {
      return false;
    }

    if (lastPoint == null) {
      return true;
    }

    // 2. Minimum distance threshold
    final distance = Geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      newPoint.latitude,
      newPoint.longitude,
    );

    if (distance < minDistanceMeters) {
      return false;
    }

    // 3. Physically impossible jump / speed check
    final timeDiffSeconds =
        newPoint.timestamp.difference(lastPoint.timestamp).inMilliseconds / 1000.0;
    if (timeDiffSeconds > 0) {
      final speedMps = distance / timeDiffSeconds;
      if (speedMps > maxSpeedMps) {
        return false;
      }
    }

    return true;
  }

  /// Sum of geodesic distances between adjacent points in kilometers.
  static double calculateTotalDistanceKm(List<TrackPoint> points) {
    if (points.length < 2) return 0.0;
    double totalMeters = 0.0;
    for (int i = 1; i < points.length; i++) {
      totalMeters += Geolocator.distanceBetween(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return double.parse((totalMeters / 1000.0).toStringAsFixed(3));
  }

  /// Starts listening to real device GPS position stream.
  void startTracking({TrackPoint? initialPoint}) {
    stopTracking();
    _isTracking = true;
    _lastAcceptedPoint = initialPoint;

    if (initialPoint != null) {
      _pointController.add(initialPoint);
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        final point = TrackPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: position.timestamp,
          altitude: position.altitude,
          accuracy: position.accuracy,
          speed: position.speed,
        );

        if (shouldAcceptPoint(newPoint: point, lastPoint: _lastAcceptedPoint)) {
          _lastAcceptedPoint = point;
          _pointController.add(point);
        }
      },
      onError: (err) {
        debugPrint('LocationTrackingService stream error: $err');
      },
    );
  }

  /// Staging only: simulates a realistic walking route for emulators or testing.
  /// Generates points moving in a gentle loop at ~1.3 m/s (brisk walk).
  void startStagingSimulation({required double startLat, required double startLng}) {
    if (!AppConfig.isStaging) return;

    stopTracking();
    _isTracking = true;

    final initial = TrackPoint(
      latitude: startLat,
      longitude: startLng,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      speed: 1.3,
    );
    _lastAcceptedPoint = initial;
    _pointController.add(initial);

    // Simulation step counter
    int stepIndex = 0;
    const double stepDistanceDeg = 0.00008; // ~8.8 meters per step

    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }
      stepIndex++;
      // Move in a box/oval pattern
      double dLat = 0.0;
      double dLng = 0.0;
      final phase = (stepIndex ~/ 8) % 4;
      switch (phase) {
        case 0:
          dLat = stepDistanceDeg;
          break;
        case 1:
          dLng = stepDistanceDeg;
          break;
        case 2:
          dLat = -stepDistanceDeg;
          break;
        case 3:
          dLng = -stepDistanceDeg;
          break;
      }

      final prev = _lastAcceptedPoint!;
      final simPoint = TrackPoint(
        latitude: prev.latitude + dLat,
        longitude: prev.longitude + dLng,
        timestamp: DateTime.now(),
        accuracy: 4.0,
        speed: 1.3,
      );

      if (shouldAcceptPoint(newPoint: simPoint, lastPoint: _lastAcceptedPoint)) {
        _lastAcceptedPoint = simPoint;
        _pointController.add(simPoint);
      }
    });
  }

  /// Stops tracking, cancels active streams and simulation timers.
  void stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Disposes resources and closes broadcast streams.
  void dispose() {
    stopTracking();
    _pointController.close();
  }
}

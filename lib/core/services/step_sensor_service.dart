import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

/// Reads the phone's hardware step counter.
///
/// The sensor reports a cumulative count since the phone booted and keeps
/// counting while the app is closed, so callers compare raw readings with a
/// saved baseline to work out steps taken in between.
class StepSensorService {
  StreamSubscription<StepCount>? _subscription;

  bool get isRunning => _subscription != null;

  /// Starts listening. [onRawSteps] receives the cumulative sensor value;
  /// [onError] fires if the sensor is missing or unavailable.
  void start({
    required void Function(int rawSteps) onRawSteps,
    required void Function(Object error) onError,
  }) {
    stop();
    _subscription = Pedometer.stepCountStream.listen(
      (event) => onRawSteps(event.steps),
      onError: (Object error) {
        debugPrint('StepSensorService: $error');
        onError(error);
      },
      cancelOnError: true,
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}

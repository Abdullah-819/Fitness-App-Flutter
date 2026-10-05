import 'package:latlong2/latlong.dart';

/// Single geographic point captured along a live tracking route.
class TrackPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? accuracy;
  final double? speed;

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.accuracy,
    this.speed,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        if (altitude != null) 'altitude': altitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null) 'speed': speed,
      };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        altitude: (json['altitude'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackPoint &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(latitude, longitude, timestamp);
}

/// Represents an individual live GPS tracking workout/session.
class TrackSession {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<TrackPoint> points;
  final int steps;
  final double distanceKm;
  final int durationSeconds;
  final int kcal;

  const TrackSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.points = const [],
    this.steps = 0,
    this.distanceKm = 0.0,
    this.durationSeconds = 0,
    this.kcal = 0,
  });

  bool get isActive => endedAt == null;

  List<LatLng> get polylinePoints => points.map((p) => p.toLatLng()).toList();

  double get averageSpeedKmh {
    if (durationSeconds <= 0) return 0.0;
    final hours = durationSeconds / 3600.0;
    return double.parse((distanceKm / hours).toStringAsFixed(2));
  }

  TrackSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    List<TrackPoint>? points,
    int? steps,
    double? distanceKm,
    int? durationSeconds,
    int? kcal,
  }) {
    return TrackSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      points: points ?? this.points,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      kcal: kcal ?? this.kcal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
        'points': points.map((p) => p.toJson()).toList(),
        'steps': steps,
        'distanceKm': distanceKm,
        'durationSeconds': durationSeconds,
        'kcal': kcal,
      };

  factory TrackSession.fromJson(Map<String, dynamic> json) => TrackSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        points: (json['points'] as List<dynamic>?)
                ?.map((e) => TrackPoint.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        steps: (json['steps'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
      );

  @override
  String toString() =>
      'TrackSession(id: $id, steps: $steps, distanceKm: $distanceKm, duration: ${durationSeconds}s)';
}

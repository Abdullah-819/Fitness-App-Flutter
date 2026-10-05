import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/track/data/location_tracking_service.dart';
import 'package:step_counter/features/track/data/track_session_store.dart';
import 'package:step_counter/features/track/domain/track_session.dart';

import '../../helpers/memory_hive.dart';

void main() {
  setUp(openMemoryBoxes);

  group('TrackPoint & TrackSession Domain Tests', () {
    test('TrackPoint JSON round-trip preserves all fields', () {
      final now = DateTime.now();
      final point = TrackPoint(
        latitude: 31.5204,
        longitude: 74.3587,
        timestamp: now,
        altitude: 215.5,
        accuracy: 4.2,
        speed: 1.4,
      );

      final json = point.toJson();
      final restored = TrackPoint.fromJson(json);

      expect(restored.latitude, 31.5204);
      expect(restored.longitude, 74.3587);
      expect(restored.timestamp.toIso8601String(), now.toIso8601String());
      expect(restored.altitude, 215.5);
      expect(restored.accuracy, 4.2);
      expect(restored.speed, 1.4);
    });

    test('TrackSession JSON round-trip preserves all metrics and points', () {
      final start = DateTime.now().subtract(const Duration(minutes: 25));
      final end = DateTime.now();
      final points = [
        TrackPoint(latitude: 31.520, longitude: 74.358, timestamp: start),
        TrackPoint(latitude: 31.521, longitude: 74.359, timestamp: end),
      ];

      final session = TrackSession(
        id: 'track_12345',
        startedAt: start,
        endedAt: end,
        points: points,
        steps: 2450,
        distanceKm: 1.85,
        durationSeconds: 1500,
        kcal: 103,
      );

      final json = session.toJson();
      final restored = TrackSession.fromJson(json);

      expect(restored.id, 'track_12345');
      expect(restored.startedAt.toIso8601String(), start.toIso8601String());
      expect(restored.endedAt?.toIso8601String(), end.toIso8601String());
      expect(restored.points.length, 2);
      expect(restored.steps, 2450);
      expect(restored.distanceKm, 1.85);
      expect(restored.durationSeconds, 1500);
      expect(restored.kcal, 103);
      expect(restored.averageSpeedKmh, 4.44); // 1.85 / (1500 / 3600)
    });
  });

  group('LocationTrackingService Point Filtering & Math', () {
    test('Accepts initial point with good accuracy', () {
      final point = TrackPoint(
        latitude: 31.5204,
        longitude: 74.3587,
        timestamp: DateTime.now(),
        accuracy: 8.0,
      );

      final accepted = LocationTrackingService.shouldAcceptPoint(
        newPoint: point,
        lastPoint: null,
      );

      expect(accepted, isTrue);
    });

    test('Rejects point with accuracy > 20 meters', () {
      final point = TrackPoint(
        latitude: 31.5204,
        longitude: 74.3587,
        timestamp: DateTime.now(),
        accuracy: 25.0, // Inaccurate
      );

      final accepted = LocationTrackingService.shouldAcceptPoint(
        newPoint: point,
        lastPoint: null,
      );

      expect(accepted, isFalse);
    });

    test('Rejects point with distance < 5 meters from last accepted point', () {
      final now = DateTime.now();
      final p1 = TrackPoint(
        latitude: 31.520400,
        longitude: 74.358700,
        timestamp: now,
        accuracy: 4.0,
      );
      // Very tiny shift: ~1 meter
      final p2 = TrackPoint(
        latitude: 31.520405,
        longitude: 74.358705,
        timestamp: now.add(const Duration(seconds: 3)),
        accuracy: 4.0,
      );

      final accepted = LocationTrackingService.shouldAcceptPoint(
        newPoint: p2,
        lastPoint: p1,
      );

      expect(accepted, isFalse);
    });

    test('Accepts point with distance >= 5 meters and realistic speed', () {
      final now = DateTime.now();
      final p1 = TrackPoint(
        latitude: 31.5200,
        longitude: 74.3580,
        timestamp: now,
        accuracy: 4.0,
      );
      // ~15 meters shift over 10 seconds (~1.5 m/s)
      final p2 = TrackPoint(
        latitude: 31.5201,
        longitude: 74.3581,
        timestamp: now.add(const Duration(seconds: 10)),
        accuracy: 4.0,
      );

      final accepted = LocationTrackingService.shouldAcceptPoint(
        newPoint: p2,
        lastPoint: p1,
      );

      expect(accepted, isTrue);
    });

    test('Rejects physically impossible GPS jump (> 12 m/s)', () {
      final now = DateTime.now();
      final p1 = TrackPoint(
        latitude: 31.5200,
        longitude: 74.3580,
        timestamp: now,
        accuracy: 4.0,
      );
      // ~500 meters shift in 2 seconds (~250 m/s)
      final p2 = TrackPoint(
        latitude: 31.5250,
        longitude: 74.3620,
        timestamp: now.add(const Duration(seconds: 2)),
        accuracy: 4.0,
      );

      final accepted = LocationTrackingService.shouldAcceptPoint(
        newPoint: p2,
        lastPoint: p1,
      );

      expect(accepted, isFalse);
    });

    test('calculateTotalDistanceKm returns correct geodesic distance', () {
      final now = DateTime.now();
      // Distance between Lahore Mall Road and Anarkali (~1.5 km)
      final points = [
        TrackPoint(latitude: 31.5600, longitude: 74.3100, timestamp: now),
        TrackPoint(latitude: 31.5700, longitude: 74.3150, timestamp: now.add(const Duration(minutes: 5))),
        TrackPoint(latitude: 31.5800, longitude: 74.3200, timestamp: now.add(const Duration(minutes: 10))),
      ];

      final dist = LocationTrackingService.calculateTotalDistanceKm(points);
      expect(dist, greaterThan(2.0));
      expect(dist, lessThan(3.5));
    });
  });

  group('TrackSessionStore Persistence Tests', () {
    test('Saves, loads, retrieves all, and deletes sessions in Hive', () async {
      final store = TrackSessionStore.instance;
      await store.clear();

      final s1 = TrackSession(
        id: 'session_1',
        startedAt: DateTime(2026, 10, 1, 8, 0),
        endedAt: DateTime(2026, 10, 1, 8, 30),
        distanceKm: 2.5,
        steps: 3200,
      );

      final s2 = TrackSession(
        id: 'session_2',
        startedAt: DateTime(2026, 10, 2, 9, 0),
        endedAt: DateTime(2026, 10, 2, 9, 45),
        distanceKm: 4.1,
        steps: 5400,
      );

      await store.saveSession(s1);
      await store.saveSession(s2);

      // Load individual
      final loaded1 = await store.loadSession('session_1');
      expect(loaded1?.id, 'session_1');
      expect(loaded1?.distanceKm, 2.5);

      // Get all (should be sorted newest first)
      final all = await store.getAllSessions();
      expect(all.length, 2);
      expect(all.first.id, 'session_2'); // newer
      expect(all.last.id, 'session_1');

      // Delete
      await store.deleteSession('session_1');
      final afterDelete = await store.getAllSessions();
      expect(afterDelete.length, 1);
      expect(afterDelete.first.id, 'session_2');

      // Clear
      await store.clear();
      expect(await store.getAllSessions(), isEmpty);
    });
  });
}

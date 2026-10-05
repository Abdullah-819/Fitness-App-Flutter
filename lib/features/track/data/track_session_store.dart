import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/track_session.dart';

/// Local persistence store for live GPS tracking sessions using Hive.
class TrackSessionStore {
  TrackSessionStore._();

  static final TrackSessionStore instance = TrackSessionStore._();

  static const String boxName = 'track_sessions_box';

  Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<String>(boxName);
    }
    await Hive.initFlutter();
    return Hive.openBox<String>(boxName);
  }

  /// Persists a completed or updated [TrackSession] into local storage.
  Future<void> saveSession(TrackSession session) async {
    try {
      final box = await _box();
      await box.put(session.id, jsonEncode(session.toJson()));
    } catch (e) {
      debugPrint('TrackSessionStore: saveSession failed ($e)');
    }
  }

  /// Loads a single [TrackSession] by its unique [id].
  Future<TrackSession?> loadSession(String id) async {
    try {
      final box = await _box();
      final raw = box.get(id);
      if (raw == null) return null;
      return TrackSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('TrackSessionStore: loadSession failed ($e)');
      return null;
    }
  }

  /// Retrieves all saved tracking sessions sorted by start date (newest first).
  Future<List<TrackSession>> getAllSessions() async {
    try {
      final box = await _box();
      final sessions = <TrackSession>[];
      for (final raw in box.values) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          sessions.add(TrackSession.fromJson(decoded));
        } catch (_) {}
      }
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } catch (e) {
      debugPrint('TrackSessionStore: getAllSessions failed ($e)');
      return const [];
    }
  }

  /// Removes a session by its [id].
  Future<void> deleteSession(String id) async {
    try {
      final box = await _box();
      await box.delete(id);
    } catch (e) {
      debugPrint('TrackSessionStore: deleteSession failed ($e)');
    }
  }

  /// Clears all recorded tracking sessions (for testing/reset).
  Future<void> clear() async {
    try {
      final box = await _box();
      await box.clear();
    } catch (e) {
      debugPrint('TrackSessionStore: clear failed ($e)');
    }
  }
}

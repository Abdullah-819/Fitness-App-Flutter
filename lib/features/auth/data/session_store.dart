import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/models/user_model.dart';

/// Keeps the signed-in user on the device so the app opens straight to the
/// dashboard next time (no sign-in / sign-up again) until they log out.
///
/// Also remembers each account's profile (gender, age, height, weight, step
/// goal) so signing back in after a logout restores it.
class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  static const String _boxName = 'session_box';
  static const String _currentKey = 'current_user';

  Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    await Hive.initFlutter();
    return Hive.openBox<String>(_boxName);
  }

  Future<void> saveSession(UserModel user) async {
    try {
      await (await _box()).put(_currentKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('SessionStore: saveSession failed ($e)');
    }
  }

  Future<UserModel?> loadSession() async {
    try {
      final raw = (await _box()).get(_currentKey);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('SessionStore: loadSession failed ($e)');
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      await (await _box()).delete(_currentKey);
    } catch (e) {
      debugPrint('SessionStore: clearSession failed ($e)');
    }
  }

  Future<void> saveProfile(UserModel user) async {
    try {
      await (await _box()).put('profile_${user.id}', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('SessionStore: saveProfile failed ($e)');
    }
  }

  Future<UserModel?> loadProfile(String userId) async {
    try {
      final raw = (await _box()).get('profile_$userId');
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('SessionStore: loadProfile failed ($e)');
      return null;
    }
  }
}

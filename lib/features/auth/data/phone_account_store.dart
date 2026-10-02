import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Remembers phone-number accounts on this device so they can sign in later.
///
/// Only a salted SHA-256 hash of the password is stored, never the password.
/// (This is a local demo store; a real backend would replace it.)
class PhoneAccountStore {
  PhoneAccountStore._();

  static final PhoneAccountStore instance = PhoneAccountStore._();

  static const String _boxName = 'phone_accounts_box';

  Future<Box<String>> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    await Hive.initFlutter();
    return Hive.openBox<String>(_boxName);
  }

  String _hash(String phone, String password) =>
      sha256.convert(utf8.encode('trackfit:$phone:$password')).toString();

  Future<void> register(String phone, String password) async {
    try {
      final box = await _box();
      await box.put(phone, _hash(phone, password));
    } catch (e) {
      debugPrint('PhoneAccountStore: register failed ($e)');
    }
  }

  Future<bool> exists(String phone) async {
    try {
      return (await _box()).containsKey(phone);
    } catch (_) {
      return false;
    }
  }

  Future<bool> verify(String phone, String password) async {
    try {
      final stored = (await _box()).get(phone);
      return stored != null && stored == _hash(phone, password);
    } catch (_) {
      return false;
    }
  }
}

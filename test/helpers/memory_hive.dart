import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

/// Opens the app's local-storage boxes in memory so widget tests can sign
/// up, sign in and save steps without touching the file system.
Future<void> openMemoryBoxes() async {
  Future<void> open<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<T>(name).clear();
    } else {
      await Hive.openBox<T>(name, bytes: Uint8List(0));
    }
  }

  await open<String>('phone_accounts_box');
  await open<String>('session_box');
  await open<Map<dynamic, dynamic>>('step_session_box');
  await open<String>('track_sessions_box');
}

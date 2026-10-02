import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Holds the app-wide [ThemeMode] and persists the choice with Hive.
class ThemeController extends ChangeNotifier {
  static const String _boxName = 'settings_box';
  static const String _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  /// Loads the saved mode. Falls back to light if storage is unavailable.
  Future<void> load() async {
    try {
      await Hive.initFlutter();
      final box = await Hive.openBox<String>(_boxName);
      _mode = _decode(box.get(_key));
    } catch (e) {
      debugPrint('ThemeController: could not load saved theme ($e)');
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box<String>(_boxName)
          : await Hive.openBox<String>(_boxName);
      await box.put(_key, mode.name);
    } catch (e) {
      debugPrint('ThemeController: could not save theme ($e)');
    }
  }

  static ThemeMode _decode(String? value) {
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.light,
    );
  }
}

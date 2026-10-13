import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Выбранная тема; по умолчанию системная, ручной выбор сохраняется.
class ThemeService extends ChangeNotifier {
  new _();

  static final ThemeService instance = ThemeService._();

  static const String _key = 'srpski_padezi_theme';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  /// Переключает тему; при системной теме отсчёт идёт от текущей яркости,
  /// а не от [mode].
  Future<void> toggle(Brightness current) =>
      setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, mode.name);
    }
  }
}

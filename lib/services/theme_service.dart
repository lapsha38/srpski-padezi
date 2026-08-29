import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Выбранная тема оформления; сохраняется между запусками.
///
/// По умолчанию тема системная - приложение выглядит так же, как остальные
/// на устройстве. Как только тему переключили кнопкой, выбор запоминается,
/// в том числе в веб-версии.
class ThemeService extends ChangeNotifier {
  ThemeService._();

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

  /// Переключает тему на противоположную той, что видно сейчас.
  ///
  /// Пока выбор не сделан, тема системная, поэтому «противоположная»
  /// считается от текущей яркости экрана, а не от значения [mode].
  Future<void> toggle(Brightness current) => setMode(
    current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
  );

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

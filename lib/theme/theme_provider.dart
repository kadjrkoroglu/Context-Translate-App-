import 'package:flutter/material.dart';
import 'package:translate_app/data/services/settings_service.dart';

class ThemeProvider with ChangeNotifier {
  final SettingsService _settings;
  ThemeMode _mode = ThemeMode.system;

  ThemeProvider(this._settings) {
    _mode = ThemeMode.values.firstWhere(
      (e) => e.name == _settings.themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  ThemeMode get themeMode => _mode;

  bool get isDarkMode => _mode == ThemeMode.system
      ? WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
      : _mode == ThemeMode.dark;

  Future<void> toggleTheme(bool isOn) async {
    _mode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _settings.setThemeMode(_mode.name);
  }

  Future<void> useSystemTheme() async {
    _mode = ThemeMode.system;
    notifyListeners();
    await _settings.setThemeMode('system');
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _keyTheme = 'is_dark_mode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    // We assume the box is opened in main.dart
    var box = await Hive.openBox(_boxName);
    _isDarkMode = box.get(_keyTheme, defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    var box = await Hive.openBox(_boxName);
    await box.put(_keyTheme, _isDarkMode);
    notifyListeners();
  }
}

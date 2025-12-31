import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _keyTheme = 'is_dark_mode';
  static const _keyLocale = 'language_code';

  bool _isDarkMode = false;
  Locale _locale = const Locale('en');

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    // We assume the box is opened in main.dart
    var box = await Hive.openBox(_boxName);
    _isDarkMode = box.get(_keyTheme, defaultValue: false);
    
    String langCode = box.get(_keyLocale, defaultValue: 'en');
    _locale = Locale(langCode);
    
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    var box = await Hive.openBox(_boxName);
    await box.put(_keyTheme, _isDarkMode);
    notifyListeners();
  }

  void toggleLanguage() async {
    _locale = _locale.languageCode == 'en' ? const Locale('es') : const Locale('en');
    var box = await Hive.openBox(_boxName);
    await box.put(_keyLocale, _locale.languageCode);
    notifyListeners();
  }
}

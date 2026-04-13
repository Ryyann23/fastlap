import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({bool darkMode = false}) : _isDarkMode = darkMode;

  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  /// Seed color for both the example app and the logger overlay.
  Color seedColor = const Color(0xFF546E7A); // Blue Grey 600

  /// null = follow device locale
  Locale? locale;

  /// Use Android 12+ / Material You wallpaper-derived dynamic color scheme.
  /// When true, [seedColor] is ignored; color picker is disabled.
  bool isDynamicTheme = false;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setSeedColor(Color color) {
    seedColor = color;
    notifyListeners();
  }

  void setLocale(Locale? l) {
    locale = l;
    notifyListeners();
  }

  void setDynamicTheme(bool value) {
    isDynamicTheme = value;
    notifyListeners();
  }
}

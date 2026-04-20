import 'package:flutter/material.dart';

/// Global configuration for simple_logger_overlay appearance.
///
/// Call [SimpleLoggerOverlayConfig.configure] before launching the overlay
/// to customise colors. Example:
/// ```dart
/// SimpleLoggerOverlayConfig.configure(seedColor: Colors.indigo);
/// ```
class SimpleLoggerOverlayConfig {
  SimpleLoggerOverlayConfig._();

  static final SimpleLoggerOverlayConfig _instance =
      SimpleLoggerOverlayConfig._();
  static SimpleLoggerOverlayConfig get instance => _instance;

  /// Seed color used to generate the overlay's Material You color scheme.
  /// Defaults to a pastel sage-green tuned for developer tooling.
  Color seedColor = const Color(0xFF4CAF50);

  /// Configure overlay appearance. Call once at app startup.
  static void configure({Color? seedColor}) {
    if (seedColor != null) _instance.seedColor = seedColor;
  }

  /// Builds an overlay-specific [ThemeData] that inherits [brightness]
  /// from the host app so light/dark mode works automatically.
  ThemeData buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      textTheme: _textTheme,
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
        fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium:
        TextStyle(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0),
    displaySmall:
        TextStyle(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
    headlineLarge:
        TextStyle(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0),
    headlineMedium:
        TextStyle(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0),
    headlineSmall:
        TextStyle(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0),
    titleLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0),
    titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    labelSmall: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}

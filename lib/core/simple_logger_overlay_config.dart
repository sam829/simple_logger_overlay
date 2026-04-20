import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  /// Seed color for the overlay's Material You color scheme.
  /// Defaults to sage-mint green — neutral and easy on developer eyes.
  Color seedColor = const Color(0xFF52B788);

  /// Configure overlay appearance. Call once at app startup.
  static void configure({Color? seedColor}) {
    if (seedColor != null) _instance.seedColor = seedColor;
  }

  /// Builds an overlay-specific [ThemeData].
  /// Inherits [brightness] from the host app for automatic dark/light support.
  ThemeData buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final base = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: base.copyWith(
        displayLarge:
            base.displayLarge?.copyWith(letterSpacing: -0.5, height: 1.12),
        displayMedium:
            base.displayMedium?.copyWith(letterSpacing: -0.25, height: 1.14),
        headlineLarge:
            base.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
        headlineMedium:
            base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        titleLarge:
            base.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
        titleMedium: base.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        titleSmall: base.titleSmall
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge:
            base.bodyLarge?.copyWith(height: 1.5, letterSpacing: 0.15),
        bodyMedium:
            base.bodyMedium?.copyWith(height: 1.5, letterSpacing: 0.1),
        bodySmall:
            base.bodySmall?.copyWith(height: 1.4, letterSpacing: 0.2),
        labelLarge: base.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: base.labelMedium
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
        labelSmall: base.labelSmall
            ?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.5),
      ),
    );
  }

  /// Returns the font family name for monospace content (JSON, headers, etc.)
  static String get monospaceFontFamily =>
      GoogleFonts.jetBrainsMono().fontFamily!;
}

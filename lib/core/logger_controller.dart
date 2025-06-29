import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

import '../simple_logger_overlay.dart';

/// Controls the logger overlay, handles logging, and manages storage.
class SimpleOverlayLoggerShakeController {
  static final SimpleOverlayLoggerShakeController _instance =
      SimpleOverlayLoggerShakeController._internal();
  ShakeDetector? _shakeDetector;

  SimpleOverlayLoggerShakeController._internal();

  factory SimpleOverlayLoggerShakeController() => _instance;

  /// Initializes the overlay and logger options.
  ///
  /// [context] is required for launching the overlay UI.
  /// [enableShake] enables shake-to-open gesture in debug mode.
  /// [enableInRelease] allows logger in release mode (disabled by default).
  /// [performanceMode] disables file writes for high-FPS apps (e.g., games).
  void init(
      {required BuildContext context,
      bool enableShake = true,
      GlobalKey<NavigatorState>? navigatorKey}) {
    _shakeDetector?.stopListening(); // clean up old

    if (enableShake) {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: (event) =>
            SimpleLoggerOverlay.show(context, navigatorKey: navigatorKey),
        shakeThresholdGravity: 2.7,
      );
    }
  }

  void dispose() {
    _shakeDetector?.stopListening();
  }
}

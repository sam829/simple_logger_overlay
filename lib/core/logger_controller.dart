import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

import '../simple_logger_overlay.dart';

class LoggerController {
  static final LoggerController _instance = LoggerController._internal();
  ShakeDetector? _shakeDetector;

  LoggerController._internal();

  factory LoggerController() => _instance;

  void init({required BuildContext context, bool enableShake = true}) {
    _shakeDetector?.stopListening(); // clean up old

    if (enableShake) {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: (event) => SimpleLoggerOverlay.show(context),
        shakeThresholdGravity: 2.7,
      );
    }
  }

  void dispose() {
    _shakeDetector?.stopListening();
  }
}

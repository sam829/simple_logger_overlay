library simple_logger_overlay;

import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/ui/logger_overlay.dart';

class SimpleLoggerOverlay {
  static void show(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const LoggerOverlay(),
    ));
  }
}

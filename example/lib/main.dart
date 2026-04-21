import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

import 'app/simple_overlay_logger_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
  await _seedLogs();
  runApp(const SimpleOverlayLoggerApp());
}

Future<void> _seedLogs() async {
  await SimpleLoggerOverlay.log(
    'App launched',
    tag: 'main',
    level: LogLevel.info,
  );
  await SimpleLoggerOverlay.log(
    'WidgetsBinding initialized',
    tag: 'main',
    level: LogLevel.debug,
  );
  await SimpleLoggerOverlay.log(
    'AppLifecycleObserver registered',
    tag: 'main',
    level: LogLevel.debug,
  );
}

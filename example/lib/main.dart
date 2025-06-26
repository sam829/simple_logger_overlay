import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/core/app_lifecycle_logger.dart';

import 'app/simple_overlay_logger_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
  runApp(const SimpleOverlayLoggerApp());
}

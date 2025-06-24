library simple_logger_overlay;

import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/ui/logger_overlay.dart';

export 'core/bloc_logger_observer.dart';
export 'core/export_service.dart';
export 'core/getx_logger_patch.dart';
export 'core/logger_controller.dart';
export 'core/network_logger_interceptor.dart';
export 'core/riverpod_logger.dart';
export 'models/network_log.dart';
export 'models/simple_log.dart';
export 'ui/logger_overlay.dart';

/// A Material 3-powered, developer-friendly logger overlay for Flutter.
///
/// Displays logs in-app with tabs for:
/// - 📝 Simple logs (debug/info/error)
/// - 🌐 Network logs (via Dio)
///
/// Supports:
/// - BLoC (via `BlocObserver`)
/// - Riverpod (via `ProviderObserver`)
/// - GetX (`Get.config`)
/// - logger package
///
/// Also includes shake-to-open, JSON export, filtering, and search.
class SimpleLoggerOverlay {
  static void show(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const LoggerOverlay(),
    ));
  }
}

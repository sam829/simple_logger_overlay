library;

import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/ui/logger_overlay.dart';

import 'core/log_storage_service.dart';
import 'models/simple_log.dart';

export 'core/app_lifecycle_logger.dart';
export 'core/bloc_logger_observer.dart';
export 'core/export_service.dart';
export 'core/getx_logger_patch.dart';
export 'core/go_router_observer.dart';
export 'core/logger_controller.dart';
export 'core/network_logger_interceptor.dart';
export 'core/riverpod_logger.dart';
export 'models/network_log.dart';
export 'models/simple_log.dart';
export 'ui/logger_overlay.dart';
export 'ui/widgets/draggable_floating_overlay.dart';

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
/// Allows quick and easy logging without needing to create [SimpleOverlayLog] manually.
///
/// Example:
/// ```dart
/// SimpleLoggerOverlay.log('Button clicked', level: LogLevel.debug, tag: 'HomeScreen');
/// ```
class SimpleLoggerOverlay {
  static void show(BuildContext context,
      {GlobalKey<NavigatorState>? navigatorKey}) {
    final page = MaterialPageRoute(
      builder: (_) => const SimpleOverlayLoggerScreen(),
      settings: RouteSettings(name: 'LoggerOverlay'),
    );

    if (navigatorKey != null) {
      navigatorKey.currentState?.push(page);
      return;
    }

    Navigator.of(context).push(page);
  }

  /// Logs a simple message to the overlay logger.
  ///
  /// - [message]: Required log string
  /// - [tag]: Optional tag (defaults to `"App"`)
  /// - [level]: LogLevel (`debug`, `info`, `warn`, `error`) — defaults to `LogLevel.info`
  static Future<void> log(
    String message, {
    String tag = 'App',
    LogLevel level = LogLevel.info,
  }) async {
    final log = SimpleOverlayLog(
      timestamp: DateTime.now(),
      tag: tag,
      level: level,
      message: message,
    );
    await SimpleOverlayLogStorageService().addSimpleLog(log);
  }
}

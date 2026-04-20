library;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/ui/logger_overlay.dart';

import 'core/log_storage_service.dart';
import 'models/simple_log.dart';

export 'core/app_lifecycle_logger.dart';
export 'core/simple_logger_overlay_config.dart';
export 'core/simple_overlay_localizations.dart';
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

class SimpleLoggerOverlay {
  static void show(BuildContext context,
      {GlobalKey<NavigatorState>? navigatorKey}) {
    final page = PageRouteBuilder<void>(
      settings: const RouteSettings(name: 'LoggerOverlay'),
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SimpleOverlayLoggerScreen(),
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.vertical,
        child: child,
      ),
    );

    if (navigatorKey != null) {
      navigatorKey.currentState?.push(page);
      return;
    }

    Navigator.of(context).push(page);
  }

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

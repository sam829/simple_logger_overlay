import 'package:flutter/widgets.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

import 'log_storage_service.dart';

/// A [NavigatorObserver] for `go_router` that logs route transitions
/// (push/pop/replace/remove) into `simple_logger_overlay`.
///
/// Attach it to your `GoRouter`:
/// ```dart
/// GoRouter(
///   routes: [...],
///   observers: [SimpleOverlayGoRouterObserver()],
/// )
/// ```
class SimpleOverlayGoRouterObserver extends NavigatorObserver {
  final LogStorageService _storage = LogStorageService();

  void _log(String action, Route<dynamic>? route) {
    final routeName =
        route?.settings.name ?? route?.settings.arguments ?? route?.toString();

    // ignore internal routes
    if (routeName == 'LoggerOverlay') return;

    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: 'GoRouter',
      level: LogLevel.info,
      message: '$action → $routeName',
    ));
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _log('Push', route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _log('Pop', route);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _log('Remove', route);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _log('Replace', newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

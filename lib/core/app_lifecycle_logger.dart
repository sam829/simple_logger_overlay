import 'package:flutter/widgets.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

/// Logs Flutter app lifecycle changes to `simple_logger_overlay`.
///
/// A [WidgetsBindingObserver] that logs app lifecycle changes to the logger overlay.
///
/// States logged:
/// - `resumed`
/// - `inactive`
/// - `paused`
/// - `detached`
///
/// This is useful for debugging app suspend/resume behavior.
/// Attach this in your main app widget:
/// ```dart
/// WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
/// ```
class SimpleOverlayAppLifecycleObserver extends WidgetsBindingObserver {
  final LogStorageService _storage = LogStorageService();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: 'AppLifecycle',
      level: LogLevel.info,
      message: 'State changed: ${state.name}',
    ));
  }
}

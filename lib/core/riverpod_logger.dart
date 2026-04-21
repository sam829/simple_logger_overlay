import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

/// A custom [ProviderObserver] that logs Riverpod provider changes
/// to the `simple_logger_overlay` system.
///
/// This observer writes logs into persistent storage using [SimpleOverlayLogStorageService],
/// and formats them as [SimpleOverlayLog] entries for display in the overlay.
base class SimpleOverlayLoggerRiverpodObserver extends ProviderObserver {
  final SimpleOverlayLogStorageService _storage =
      SimpleOverlayLogStorageService();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    String valueStr;
    try {
      valueStr = newValue.toString();
      if (valueStr.length > 256) valueStr = '${valueStr.substring(0, 256)}...';
    } catch (_) {
      valueStr = newValue.runtimeType.toString();
    }

    unawaited(
      _storage.addSimpleLog(
        SimpleOverlayLog(
          timestamp: DateTime.now(),
          tag: context.provider.name ?? context.provider.runtimeType.toString(),
          level: LogLevel.debug,
          message: 'Updated: $valueStr',
        ),
      ),
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    unawaited(
      _storage.addSimpleLog(
        SimpleOverlayLog(
          timestamp: DateTime.now(),
          tag: context.provider.name ?? context.provider.runtimeType.toString(),
          level: LogLevel.info,
          message: 'Disposed',
        ),
      ),
    );
  }
}

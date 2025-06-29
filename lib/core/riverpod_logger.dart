import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

/// A custom [ProviderObserver] that logs Riverpod provider changes
/// to the `simple_logger_overlay` system.
///
/// This observer writes logs into persistent storage using [SimpleOverlayLogStorageService],
/// and formats them as [SimpleOverlayLog] entries for display in the overlay.
class SimpleOverlayLoggerRiverpodObserver extends ProviderObserver {
  final SimpleOverlayLogStorageService _storage =
      SimpleOverlayLogStorageService();

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    _storage.addSimpleLog(SimpleOverlayLog(
      timestamp: DateTime.now(),
      tag: provider.name ?? provider.runtimeType.toString(),
      level: LogLevel.debug,
      message: 'Updated: $newValue',
    ));
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    _storage.addSimpleLog(SimpleOverlayLog(
      timestamp: DateTime.now(),
      tag: provider.name ?? provider.runtimeType.toString(),
      level: LogLevel.info,
      message: 'Disposed',
    ));
  }
}

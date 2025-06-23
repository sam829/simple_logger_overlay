import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

class SimpleOverlayLoggerRiverpodObserver extends ProviderObserver {
  final LogStorageService _storage = LogStorageService();

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: provider.name ?? provider.runtimeType.toString(),
      level: LogLevel.debug,
      message: 'Updated: $newValue',
    ));
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: provider.name ?? provider.runtimeType.toString(),
      level: LogLevel.info,
      message: 'Disposed',
    ));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

/// A custom [BlocObserver] that logs BLoC events, state changes, and errors
/// to the `simple_logger_overlay` system.
///
/// This observer writes logs into persistent storage using [SimpleOverlayLogStorageService],
/// and formats them as [SimpleOverlayLog] entries for display in the overlay.
///
/// Usage:
/// ```dart
/// Bloc.observer = SimpleOverlayBlocObserverLogger();
/// ```
class SimpleOverlayBlocObserverLogger extends BlocObserver {
  final SimpleOverlayLogStorageService _storage =
      SimpleOverlayLogStorageService();

  /// Logs every dispatched BLoC [event] as a `debug`-level [SimpleOverlayLog].
  @override
  void onEvent(Bloc bloc, Object? event) {
    _storage.addSimpleLog(SimpleOverlayLog(
      timestamp: DateTime.now(),
      tag: bloc.runtimeType.toString(),
      level: LogLevel.debug,
      message: 'Event: $event',
    ));
    super.onEvent(bloc, event);
  }

  /// Logs every state [change] as an `info`-level [SimpleOverlayLog].
  @override
  void onChange(BlocBase bloc, Change change) {
    _storage.addSimpleLog(SimpleOverlayLog(
      timestamp: DateTime.now(),
      tag: bloc.runtimeType.toString(),
      level: LogLevel.info,
      message: 'Change: $change',
    ));
    super.onChange(bloc, change);
  }

  /// Logs all [error]s and [stackTrace]s as `error`-level [SimpleOverlayLog]s.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _storage.addSimpleLog(SimpleOverlayLog(
      timestamp: DateTime.now(),
      tag: bloc.runtimeType.toString(),
      level: LogLevel.error,
      message: 'Error: $error\n$stackTrace',
    ));
    super.onError(bloc, error, stackTrace);
  }
}

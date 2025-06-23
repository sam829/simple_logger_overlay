import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

class SimpleOverlayBlocObserverLogger extends BlocObserver {
  final LogStorageService _storage = LogStorageService();

  @override
  void onEvent(Bloc bloc, Object? event) {
    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: bloc.runtimeType.toString(),
      level: LogLevel.debug,
      message: 'Event: $event',
    ));
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: bloc.runtimeType.toString(),
      level: LogLevel.info,
      message: 'Change: $change',
    ));
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _storage.addSimpleLog(SimpleLog(
      timestamp: DateTime.now(),
      tag: bloc.runtimeType.toString(),
      level: LogLevel.error,
      message: 'Error: $error\n$stackTrace',
    ));
    super.onError(bloc, error, stackTrace);
  }
}

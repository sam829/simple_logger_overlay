import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';
import 'package:simple_logger_overlay/core/getx_logger_patch.dart';
import 'package:simple_logger_overlay/core/riverpod_logger.dart';

void main() {
  patchGetXLogger();
  Bloc.observer = LoggerBlocObserver();
  runApp(
    ProviderScope(
      observers: [LoggerRiverpodObserver()],
      child: const LoggerDemo(),
    ),
  );
}

class LoggerDemo extends StatelessWidget {
  const LoggerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

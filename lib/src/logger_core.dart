import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LogEntry {
  final String message;
  final DateTime timestamp;
  final LogLevel level;
  final String? tag;

  LogEntry(this.message, this.level, {this.tag}) : timestamp = DateTime.now();
}

class LoggerCore extends ChangeNotifier {
  static final LoggerCore _instance = LoggerCore._internal();
  LoggerCore._internal();

  factory LoggerCore() => _instance;

  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(String message, {LogLevel level = LogLevel.debug, String? tag}) {
    final entry = LogEntry(message, level, tag: tag);
    _logs.add(entry);
    if (kDebugMode) {
      debugPrint("[${entry.level.name.toUpperCase()}] ${entry.message}");
    }
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  // Shorthands
  void d(String msg, {String? tag}) =>
      log(msg, level: LogLevel.debug, tag: tag);
  void i(String msg, {String? tag}) => log(msg, level: LogLevel.info, tag: tag);
  void w(String msg, {String? tag}) =>
      log(msg, level: LogLevel.warning, tag: tag);
  void e(String msg, {String? tag}) =>
      log(msg, level: LogLevel.error, tag: tag);
}

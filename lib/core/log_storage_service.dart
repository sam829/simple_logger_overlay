import 'dart:isolate' show Isolate;

import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

import '../models/network_log.dart';
import '../models/simple_log.dart';
import 'isolate_log_writer.dart';

/// Service for storing logs to persistent storage.
///
/// This service uses an isolate to write logs to the application support
/// directory. The logs are written in JSON Lines format.
///
/// The logs are written to two files, `simple_logs.jsonl` and `network_logs.jsonl`.
/// The first file contains logs from the [LoggerController.log] method, while
/// the second file contains logs from the [NetworkLoggerInterceptor].
///
class LogStorageService {
  /// Enables styled logging to console. Defaults to true.
  static bool enableConsole = true;

  /// Writes a [SimpleLog] to the persistent log file.
  ///
  /// The log is written to a file named `simple_logs.jsonl` within the
  /// application support directory. The log is written in JSON Lines format.
  ///
  /// The log is written asynchronously in a separate isolate to avoid blocking
  /// the main isolate.
  ///
  /// The log is written as a single JSON object, with the following keys:
  ///
  /// * `timestamp`: The timestamp of the log event, in ISO 8601 format.
  /// * `tag`: The tag of the log event, a short string identifying the source
  ///   of the log.
  /// * `level`: The log level of the log event, one of "debug", "info", "warn",
  ///   or "error".
  /// * `message`: The log message itself, a string.
  Future<void> addSimpleLog(SimpleLog log) async {
    _printStyled(log.level.name, log.tag, log.message);

    final dir = await getApplicationSupportDirectory();
    final path = dir.path;
    final payload = {
      'path': path,
      'type': 'simple',
      ...log.toJson(),
    };
    await Isolate.run(() => IsolateLogWriter.writeLog(payload));
  }

  /// Writes a [NetworkLog] to the persistent log file.
  ///
  /// The log is written to a file named `network_logs.jsonl` within the
  /// application support directory. The log is written in JSON Lines format.
  ///
  /// The log is written asynchronously in a separate isolate to avoid blocking
  /// the main isolate.
  ///
  /// The log is written as a single JSON object, with the following keys:
  ///
  /// * `timestamp`: The timestamp of the log event, in ISO 8601 format.
  /// * `tag`: The tag of the log event, a short string identifying the source
  ///   of the log.
  /// * `method`: The HTTP method used in the network request, such as "GET" or "POST".
  /// * `url`: The URL of the network request.
  /// * `requestHeaders`: A map of the request headers.
  /// * `requestBody`: The body of the network request, if any.
  /// * `statusCode`: The HTTP status code of the response.
  /// * `responseHeaders`: A map of the response headers.
  /// * `responseBody`: The body of the response, if any.
  /// * `isSuccess`: A boolean indicating if the network request was successful.
  Future<void> addNetworkLog(NetworkLog log) async {
    final tag = '${log.method} ${log.url}';
    final msg =
        'Status: ${log.statusCode} | ${log.isSuccess ? 'Success' : 'Error'}';

    _printStyled(log.isSuccess ? 'info' : 'error', tag, msg);

    final dir = await getApplicationSupportDirectory();
    final path = dir.path;
    final payload = {
      'path': path,
      'type': 'network',
      ...log.toJson(),
    };
    await Isolate.run(() => IsolateLogWriter.writeLog(payload));
  }

  /// Reads all simple logs from persistent storage.
  ///
  /// The logs are read from a file named `simple_logs.jsonl` within the
  /// application support directory. The logs are read in JSON Lines format.
  ///
  /// The logs are read asynchronously in a separate isolate to avoid blocking
  /// the main isolate.
  ///
  /// The logs are returned as a list of [SimpleLog] objects.
  Future<List<SimpleLog>> getSimpleLogs() async {
    final dir = await getApplicationSupportDirectory();
    final rawLogs =
        await Isolate.run(() => IsolateLogWriter.readLogs(dir.path, 'simple'));
    return rawLogs.map((e) => SimpleLog.fromJson(e)).toList();
  }

  /// Reads all network logs from persistent storage.
  ///
  /// The logs are read from a file named `network_logs.jsonl` within the
  /// application support directory. The logs are read in JSON Lines format.
  ///
  /// The logs are read asynchronously in a separate isolate to avoid blocking
  /// the main isolate.
  ///
  /// The logs are returned as a list of [NetworkLog] objects.
  Future<List<NetworkLog>> getNetworkLogs() async {
    final dir = await getApplicationSupportDirectory();
    final rawLogs =
        await Isolate.run(() => IsolateLogWriter.readLogs(dir.path, 'network'));
    return rawLogs.map((e) => NetworkLog.fromJson(e)).toList();
  }

  /// Deletes all logs older than 2 days from persistent storage.
  ///
  /// The logs are deleted asynchronously in a separate isolate to avoid blocking
  /// the main isolate.
  ///
  /// This is useful for limiting the amount of disk space used by the log files.
  Future<void> purgeOldLogs() async {
    final dir = await getApplicationSupportDirectory();
    final path = dir.path;
    await Isolate.run(() => IsolateLogWriter.purgeOldLogs(path, 2));
  }

  void _printStyled(String level, String tag, String message) {
    if (!LogStorageService.enableConsole) return;

    final timestamp = DateTime.now().toIso8601String();

    // ANSI color codes
    const reset = '\x1B[0m';
    const gray = '\x1B[90m';
    const blue = '\x1B[34m';
    const yellow = '\x1B[33m';
    const red = '\x1B[31m';

    String color;
    String emoji;
    String label;

    switch (level.toLowerCase()) {
      case 'debug':
        color = gray;
        emoji = '🔍';
        label = 'DEBUG';
        break;
      case 'info':
        color = blue;
        emoji = 'ℹ️';
        label = 'INFO';
        break;
      case 'warn':
      case 'warning':
        color = yellow;
        emoji = '🟡';
        label = 'WARN';
        break;
      case 'error':
        color = red;
        emoji = '🔥';
        label = 'ERROR';
        break;
      default:
        color = reset;
        emoji = '📌';
        label = level.toUpperCase();
    }

    final formatted = '[$timestamp] $emoji [$label] [$tag] $message';
    print('$color$formatted$reset');
  }
}

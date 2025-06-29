import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show File, FileMode, Directory;

/// A utility class for writing log entries to files in JSON Lines format
/// from isolates.
///
/// This class provides a static method for writing log entries to files in
/// JSON Lines format. It is designed to be used from isolates, where the
/// `dart:io` library is not available, by being passed a `Map<String, dynamic>`
/// containing the log data and the path to write to.
///
/// The `writeLog` method writes the log entry to a file named
/// `{type}_logs.jsonl` within the specified directory path. If `type` is not
/// provided in the payload, it defaults to 'simple'. The payload may contain
/// any other keys, which are written to the log file in JSON format.
///
/// This class is not intended to be instantiated; use the static `writeLog`
/// method instead.
class SimpleOverlayIsolateLogWriter {
  /// Writes a log entry to a file in JSON Lines format.
  ///
  /// The log entry is appended to a file named `{type}_logs.jsonl` within the specified
  /// directory path. If `type` is not provided in the payload, it defaults to 'simple'.
  ///
  /// The `payload` parameter must contain a `path` key specifying the directory path
  /// and may contain a `type` key to determine the log file prefix. Other keys in the
  /// payload represent the log data and are written to the file in JSON format.
  ///
  /// This function ensures that the file is opened, the log is written, and the
  /// file is properly closed.
  static Future<void> writeLog(Map<String, dynamic> payload) async {
    final path = payload['path'] as String;
    final type = payload['type'] ?? 'simple';

    final file = File('$path/${type}_logs.jsonl');
    final sink = file.openWrite(mode: FileMode.append);

    final logCopy = Map.of(payload)
      ..remove('path')
      ..remove('type');
    sink.writeln(jsonEncode(logCopy));

    await sink.flush();
    await sink.close();
  }

  /// Deletes log files older than the specified number of days.
  ///
  /// [dirPath] - The directory path where the log files are stored.
  /// [daysToKeep] - The number of days to retain log files. Files older than this
  /// will be purged.
  ///
  /// This function iterates through the files in the specified directory,
  /// checks their modification date, and deletes those that are older than
  /// the specified number of days. Only files with a `.jsonl` extension are
  /// considered.
  // remove path/type from actual log
  static Future<void> purgeOldLogs(String dirPath, int daysToKeep) async {
    final dir = Directory(dirPath);
    final now = DateTime.now();

    final files = dir.listSync();
    for (final file in files) {
      if (file is File && file.path.endsWith('.jsonl')) {
        final stat = await file.stat();
        final diff = now.difference(stat.modified);
        if (diff.inDays > daysToKeep) {
          await file.delete();
        }
      }
    }
  }

  /// Reads log entries from a file in JSON Lines format.
  ///
  /// The [dirPath] parameter specifies the directory path where the log file is
  /// located, and the [type] parameter specifies the log file prefix (e.g., 'simple'
  /// or 'network'). The method returns a list of log entries, where each entry is
  /// a `Map<String, dynamic>` containing the log data.
  ///
  /// If the file does not exist, an empty list is returned.
  static Future<List<Map<String, dynamic>>> readLogs(
      String dirPath, String type) async {
    final file = File('$dirPath/${type}_logs.jsonl');
    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    return lines
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }
}

import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show File, FileMode, Directory;

class IsolateLogWriter {
  static Future<void> writeLog(Map<String, dynamic> payload) async {
    final path = payload['path'] as String;
    final type = payload['type'] ?? 'simple';

    final file = File('$path/${type}_logs.jsonl');
    final sink = file.openWrite(mode: FileMode.append);

    // remove path/type from actual log
    final logCopy = Map.of(payload)
      ..remove('path')
      ..remove('type');
    sink.writeln(jsonEncode(logCopy));

    await sink.flush();
    await sink.close();
  }

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

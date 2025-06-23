import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show File, FileMode;

import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

class IsolateLogWriter {
  static Future<void> writeLog(Map<String, dynamic> logMap) async {
    final dir = await getApplicationSupportDirectory();
    final logType = logMap['type'] ?? 'simple';
    final file = File('${dir.path}/${logType}_logs.jsonl');

    final sink = file.openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(logMap));
    await sink.flush();
    await sink.close();
  }

  static Future<void> purgeOldLogs(int daysToKeep) async {
    final dir = await getApplicationSupportDirectory();
    final now = DateTime.now();

    for (final file in dir.listSync()) {
      if (file is File && file.path.endsWith('.jsonl')) {
        final stat = await file.stat();
        final diff = now.difference(stat.modified);
        if (diff.inDays > daysToKeep) {
          await file.delete();
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> readLogs(String type) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${type}_logs.jsonl');
    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    return lines
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }
}

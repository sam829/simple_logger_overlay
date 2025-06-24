import 'dart:convert' show jsonEncode;
import 'dart:io' show File;

import 'package:path_provider/path_provider.dart';

import 'log_storage_service.dart';

/// Service that exports all logs (simple + network) as JSON
/// and opens a native share sheet using `share_plus`.
class ExportService {
  final _storage = LogStorageService();

  /// Exports both simple and network logs to JSON and triggers native share dialog.
  Future<String> exportLogsToFile() async {
    final simple = await _storage.getSimpleLogs();
    final network = await _storage.getNetworkLogs();

    final Map<String, dynamic> json = {
      "simple_logs": simple.map((e) => e.toJson()).toList(),
      "network_logs": network.map((e) => e.toJson()).toList(),
    };

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/exported_logs_${DateTime.now().millisecondsSinceEpoch}.json');

    await file.writeAsString(jsonEncode(json));
    return file.path;
  }
}

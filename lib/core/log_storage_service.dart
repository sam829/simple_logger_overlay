import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/network_log.dart';
import '../models/simple_log.dart';

class LogStorageService {
  static const _simpleLogFile = 'simple_logs.json';
  static const _networkLogFile = 'network_logs.json';

  Future<File> _getFile(String name) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$name');
  }

  Future<void> addSimpleLog(SimpleLog log) async {
    final logs = await getSimpleLogs();
    logs.add(log);
    await _write(_simpleLogFile, logs.map((e) => e.toJson()).toList());
  }

  Future<void> addNetworkLog(NetworkLog log) async {
    final logs = await getNetworkLogs();
    logs.add(log);
    await _write(_networkLogFile, logs.map((e) => e.toJson()).toList());
  }

  Future<List<SimpleLog>> getSimpleLogs() async {
    final file = await _getFile(_simpleLogFile);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    final jsonList = jsonDecode(content) as List;
    return jsonList
        .map((e) => SimpleLog.fromJson(e))
        .where((e) => DateTime.now().difference(e.timestamp).inDays < 2)
        .toList();
  }

  Future<List<NetworkLog>> getNetworkLogs() async {
    final file = await _getFile(_networkLogFile);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    final jsonList = jsonDecode(content) as List;
    return jsonList
        .map((e) => NetworkLog.fromJson(e))
        .where((e) => DateTime.now().difference(e.timestamp).inDays < 2)
        .toList();
  }

  Future<void> _write(String fileName, List<Map<String, dynamic>> data) async {
    final file = await _getFile(fileName);
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> clearOldLogs() async {
    final simpleLogs = await getSimpleLogs();
    await _write(_simpleLogFile, simpleLogs.map((e) => e.toJson()).toList());

    final networkLogs = await getNetworkLogs();
    await _write(_networkLogFile, networkLogs.map((e) => e.toJson()).toList());
  }
}

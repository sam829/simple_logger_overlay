import 'dart:isolate' show Isolate;

import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

import '../models/network_log.dart';
import '../models/simple_log.dart';
import 'isolate_log_writer.dart';

class LogStorageService {
  Future<void> addSimpleLog(SimpleLog log) async {
    final dir = await getApplicationSupportDirectory();
    final path = dir.path;
    final payload = {
      'path': path,
      'type': 'simple',
      ...log.toJson(),
    };
    await Isolate.run(() => IsolateLogWriter.writeLog(payload));
  }

  Future<void> addNetworkLog(NetworkLog log) async {
    final dir = await getApplicationSupportDirectory();
    final path = dir.path;
    final payload = {
      'path': path,
      'type': 'network',
      ...log.toJson(),
    };
    await Isolate.run(() => IsolateLogWriter.writeLog(payload));
  }

  Future<List<SimpleLog>> getSimpleLogs() async {
    final dir = await getApplicationSupportDirectory();
    final rawLogs =
        await Isolate.run(() => IsolateLogWriter.readLogs(dir.path, 'simple'));
    return rawLogs.map((e) => SimpleLog.fromJson(e)).toList();
  }

  Future<List<NetworkLog>> getNetworkLogs() async {
    final dir = await getApplicationSupportDirectory();
    final rawLogs =
        await Isolate.run(() => IsolateLogWriter.readLogs(dir.path, 'network'));
    return rawLogs.map((e) => NetworkLog.fromJson(e)).toList();
  }

  Future<void> purgeOldLogs() async {
    final dir = await getApplicationSupportDirectory();
    final path = dir.path;
    await Isolate.run(() => IsolateLogWriter.purgeOldLogs(path, 2));
  }
}

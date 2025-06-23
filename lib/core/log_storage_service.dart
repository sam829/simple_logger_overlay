import 'dart:isolate' show Isolate;

import '../models/network_log.dart';
import '../models/simple_log.dart';
import 'isolate_log_writer.dart';

class LogStorageService {
  Future<void> addSimpleLog(SimpleLog log) async {
    await _writeToIsolate({...log.toJson(), 'type': 'simple'});
  }

  Future<void> _writeToIsolate(Map<String, dynamic> data) async {
    await Isolate.run(() => IsolateLogWriter.writeLog(data));
  }

  Future<void> addNetworkLog(NetworkLog log) async {
    await _writeToIsolate({...log.toJson(), 'type': 'network'});
  }

  Future<List<SimpleLog>> getSimpleLogs() async {
    final rawLogs =
        await Isolate.run(() => IsolateLogWriter.readLogs('simple'));
    return rawLogs.map((e) => SimpleLog.fromJson(e)).toList();
  }

  Future<List<NetworkLog>> getNetworkLogs() async {
    final rawLogs =
        await Isolate.run(() => IsolateLogWriter.readLogs('network'));
    return rawLogs.map((e) => NetworkLog.fromJson(e)).toList();
  }

  Future<void> purgeOldLogs() async {
    await Isolate.run(() => IsolateLogWriter.purgeOldLogs(2));
  }
}

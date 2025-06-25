import 'package:get/get.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

/// Patch `Get` to use the `simple_logger_overlay` storage for logs.
///
/// This will forward all logs to the `simple_logger_overlay` storage, tagged
/// as 'GetX'. This is useful for debugging errors in your GetX app.
///
/// Call this once at app start.
///
/// Example:
///
void simpleOverlayGetXLogObserver() {
  final storage = LogStorageService();
  Get.config(
    logWriterCallback: (text, {bool isError = false}) {
      storage.addSimpleLog(SimpleLog(
        timestamp: DateTime.now(),
        tag: 'GetX',
        level: isError ? LogLevel.error : LogLevel.debug,
        message: text,
      ));
    },
  );
}

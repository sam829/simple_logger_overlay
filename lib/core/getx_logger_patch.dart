import 'package:get/get.dart';

import '../models/simple_log.dart';
import 'log_storage_service.dart';

void patchGetXLogger() {
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

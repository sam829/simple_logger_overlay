# Changelog

## 0.1.1

- 🧠 Major performance enhancements:
  - All log read/write/purge now happens in isolates to prevent UI jank
  - Log overlay is now safe for high-frequency logging in production-grade apps
- 🎯 UI update:
  - Replaced log level text (DEBUG, INFO, ERROR) with intuitive icons
- 🧾 Log detail page now pretty-prints JSON request/response bodies
- 🛑 Auto-purge logs older than 2 days in background

## 0.1.0

- Initial release of `simple_logger_overlay`
- 🌈 Material 3 overlay for logs and network traffic
- 🚀 Shake-to-open debug tool
- 🔍 Filter, sort, search support
- 📦 Integration with:
  - `logger` package
  - BLoC (`BlocObserver`)
  - Riverpod (`ProviderObserver`)
  - GetX (via `Get.config`)
- 🌐 Dio interceptor for capturing network logs
- 🧾 Log detail views
- 📤 Export logs as JSON via `share_plus`

## 1.0.0

- Initial release
- LoggerCore for log levels
- LoggerOverlay for UI
- Dio interceptor support
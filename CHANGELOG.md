# Changelog

## 0.1.8

- ✳️ Adjusted `intl` package version to `>=0.19.0 <0.21.0`, for backward compatibility

## 0.1.7

- 🐞 The `formatTimestampForUTC` function has been updated to correctly convert the input `DateTime` to UTC before formatting.
  This ensures that the output string accurately represents the timestamp in UTC, as intended.

## 0.1.6

- 🧠 Minor name refactorings for classes for uniformity.

- 🐞 Added navigator support to shake controller for better accessibility

## 0.1.5

- 🎨 Code style improvements:
  - Applied `dart format .` to ensure consistent code formatting across the codebase

## 0.1.4

- ✳️ Added pretty terminal logging with ANSI colors + emoji:
  - 🔍 DEBUG, ℹ️ INFO, 🟡 WARN, 🔥 ERROR
  - Implemented via internal `printStyled(...)` formatter

- ⚙️ Introduced global console logging toggle:
  - `LogStorageService.enableConsole = false;`

- 🧠 Refactored `LogStorageService` to singleton pattern for optimized reuse

- ✅ Added developer-friendly static logging API:
  ```dart
  SimpleLoggerOverlay.log('Something happened', level: LogLevel.info);

- 🌐 Added navigation + app lifecycle observers:

    - SimpleOverlayGoRouterObserver

    - SimpleOverlayAppLifecycleObserver

- 🐞 Added DraggableDebuggerFAB:

    - Floating debug-only access point to the overlay

    - Can be placed via Stack() and moved around freely

## 0.1.3

### ✨ New Features
- 📝 Added **"Copy to Clipboard"** button on log detail pages
  - Copies full log as formatted JSON
  - Available via AppBar action for both simple and network logs

### 🔧 Improvements
- ✨ Log detail now shows clean, shareable JSON
- 📋 SnackBar confirmation after copying log

## 0.1.2

### ⚡ Performance & Stability
- ✅ **Isolate-based logging**: Moved all file read/write/purge operations to background isolates
  - Prevents UI lag during high-frequency logging
  - Main thread stays unblocked
- ✅ **Safe platform channel usage**:
  - All `path_provider` calls now run on the main isolate
  - Eliminated `BackgroundIsolateBinaryMessenger` crash

### 🧼 Log Management
- 🧹 Auto-purges logs older than 2 days using isolates
- 🧾 Pretty-printed JSON body in network log detail page

### 🎨 UI Improvements
- 🔁 Replaced log level text (DEBUG / INFO / ERROR) with intuitive icons
  - 🐞 Debug → `bug_report`
  - ℹ️ Info → `info_outline`
  - ❗ Error → `error_outline`

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
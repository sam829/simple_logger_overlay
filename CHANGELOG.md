# Changelog

## 0.2.2

- 🧠 Minor documentation update.

## 0.2.1

### 🐛 Bug fixes

- **Riverpod 3.x compatibility** — `SimpleOverlayLoggerRiverpodObserver` migrated to `flutter_riverpod ^3.x` API:
  - Class declared `base` (required because `ProviderObserver` is now `base`)
  - `didUpdateProvider` / `didDisposeProvider` signatures updated to accept `ProviderObserverContext` instead of `ProviderBase` + `ProviderContainer`
  - Added `dart:async` import for `unawaited`; removed unused `meta` import

### 🔧 Internal

- Applied `dart format` across all core services and data models (no logic changes)
- Fixed unnecessary multi-underscore wildcard params (`__` / `___` → `_`) per `unnecessary_underscores` lint rule

---

## 0.2.0

- 🐛 Fix `OpenContainer` deactivated-context crash: pre-compute all `Theme.of` values before any closure — zero `Theme.of` calls inside `openBuilder` or `closedBuilder`
- 🔧 CI: pin Flutter version to `3.35.6` in publish workflow for reproducible builds
- 🔧 example: remove `build_verify` dev dependency to resolve `go_router_builder` / `analyzer` version conflict

### ✨ Material You Expressive UI

- **Container transform** — log card → detail page uses `OpenContainer` (fade, 450 ms) for a seamless surface expansion
- **M3 color system** — all hard-coded colors replaced with semantic tokens (`primaryContainer`, `errorContainer`, `surfaceContainerHighest`, etc.); adapts automatically to light / dark
- **M3 easing** — list entry animations use emphasized-decelerate curve `Cubic(0.05, 0.7, 0.1, 1.0)` at 350 ms
- **Shared-axis transition** — vertical slide for overlay open / close
- **FAB spring snap** — spring physics on drag release; scale press feedback; pulse on new logs

### 🎨 Theming

- **`SimpleLoggerOverlayConfig`** — new singleton with `configure(seedColor:)` API; overlay builds its own `ThemeData` via `ColorScheme.fromSeed`; default seed: sage-mint `0xFF52B788`
- **Dynamic Color** — `configure(lightScheme:, darkScheme:, clearSchemes:)` accepts a full `ColorScheme` for Android 12+ wallpaper-derived colors
- **Typography** — Inter (UI text) + JetBrains Mono (JSON / code) via `google_fonts`

### 🌐 Network logs

- HTML response bodies rendered inline via `flutter_html`
- Auto-detection: JSON (pretty-printed) · HTML (rendered) · plain text
- Per-field copy buttons on every section in the detail view
- `_bodyToString()` in interceptor uses `jsonEncode` to avoid Dart Map literal output

### 🔍 Search & filter

- M3 `SearchBar` with inline filter + sort icon buttons
- Filter sheet — level (Debug / Info / Error) and network status (Success / Error)
- Sort always applied (newest / oldest first) regardless of filter state

### 🌍 Localization

- `SimpleOverlayLocalizations` delegate — overlay picks up host app locale
- `shouldReload` fixed to `true` so strings update when locale changes

### 🐛 Bug fixes

- `OpenContainer` deactivated-context crash: pre-compute all `Theme.of` values before any closure; zero `Theme.of` calls inside `openBuilder` or `closedBuilder`
- `LateInitializationError` on second FAB drag: animation fields made nullable; listener de-registered before re-add
- `FormatException` on JSONL read: per-line `try/catch` skips malformed / partial lines
- Sort not applying without active filter: unified display getters always apply both filter and sort

## 0.1.9

- go_router causing issue on version `15.3.2`, retracted to `15.1.3`

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
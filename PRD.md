# Product Requirements Document — simple_logger_overlay

**Author:** Saumya Macwan  
**Current version:** 0.2.1  
**Repository:** https://github.com/sam829/simple_logger_overlay  
**pub.dev:** https://pub.dev/packages/simple_logger_overlay  
**License:** MIT

---

## 1. Product Overview

`simple_logger_overlay` is a Flutter package that embeds a full-featured debug logger directly inside a running app — accessible via a draggable FAB, no laptop required. It captures simple log events and Dio network requests, persists them to disk in a background isolate, and surfaces them in a Material You Expressive overlay UI with live streaming, search, filter, and export.

**Core value proposition:** QA engineers and developers can inspect logs and network traffic on-device, on physical hardware, without connecting to Xcode / Android Studio / a terminal.

---

## 2. Target Users

| User | Context |
|---|---|
| Flutter developer | Debugging own app during development — faster than console |
| QA engineer | Reproducing bugs on physical device, capturing logs to share |
| Developer on-call | Diagnosing production-style issues without a laptop nearby |

---

## 3. Goals & Non-Goals

### Goals
- Zero-config integration (3 lines of setup code)
- Non-blocking — zero main-thread overhead from log I/O
- Production-safe — FAB/UI can be gated behind `kDebugMode`; log writes are always safe
- Material You Expressive UI that adapts to the host app's color scheme
- Framework-agnostic — works with BLoC, Riverpod, GetX, GoRouter, or none of them

### Non-Goals
- Not a remote logging / crash-reporting service (no cloud, no backend)
- Not a replacement for production observability tools (Sentry, Datadog, Firebase Crashlytics)
- Not a general-purpose `print` replacement library (no log levels for release builds, no upload)

---

## 4. Public API Surface

### 4.1 Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleLoggerOverlay.init();   // purges logs older than 7 days
  runApp(const MyApp());
}
```

### 4.2 Logging

```dart
SimpleLoggerOverlay.log(
  'Payment failed: 402',
  level: LogLevel.error,   // debug | info | error
  tag: 'PaymentService',
);
```

| Level | Color token | Intent |
|---|---|---|
| `LogLevel.debug` | `tertiaryContainer` | Internal state, verbose |
| `LogLevel.info` | `primaryContainer` | Normal flow events |
| `LogLevel.error` | `errorContainer` | Failures, exceptions |

### 4.3 FAB (draggable entry point)

```dart
// Place inside a Stack at the root of your widget tree
SimpleOverlayDraggableDebuggerFAB(navigatorKey: navigatorKey)
```

- Drags freely; spring-snaps to nearest screen edge on release
- Scales down on press (`AnimatedScale`, 0.88, 120 ms)
- Pulses (scale 1.0 → 1.18 → 0.95 → 1.0, 800 ms) when a new log arrives while overlay is closed
- Shadow swells in sync with the pulse via `AnimatedBuilder` on elevation

### 4.4 Open programmatically

```dart
SimpleLoggerOverlay.show(context, navigatorKey: navigatorKey);
```

Opens with a `SharedAxisTransition` (vertical, 300 ms forward / 250 ms reverse).

### 4.5 Theming

```dart
// Seed-based (default: sage-mint 0xFF52B788)
SimpleLoggerOverlayConfig.configure(seedColor: Colors.deepPurple);

// Full scheme (Android 12+ Dynamic Color)
SimpleLoggerOverlayConfig.configure(
  lightScheme: lightDynamic,
  darkScheme: darkDynamic,
);

// Revert to seed
SimpleLoggerOverlayConfig.configure(seedColor: Colors.teal, clearSchemes: true);
```

The overlay builds its own `ThemeData` from `ColorScheme.fromSeed` (or the provided scheme), independent of the host app's theme. Brightness is inherited from the host app — dark/light switches automatically.

**Typography:** Inter (UI text) + JetBrains Mono (JSON / headers / code fields) via `google_fonts`.

### 4.6 Console logging

Logs also print to the terminal with ANSI color and emoji:

```
[2025-06-24T19:15:01Z] 🔥 [ERROR] [PaymentSvc]  Stripe returned 402
```

Disable:
```dart
SimpleOverlayLogStorageService.enableConsole = false;
```

### 4.7 Log export

```dart
await SimpleOverlayExportService().exportLogsToFile();
// Returns file path; pass to share_plus to share
```

Export button in the overlay AppBar triggers `share_plus` share sheet.

### 4.8 Storage management

```dart
// Manual clear
await SimpleOverlayLogStorageService().clearAllLogs();
```

Auto-purge on init: logs older than 7 days are deleted in a background isolate. Default retention configurable via `purgeOldLogs(path, days)`.

---

## 5. Feature Specifications

### 5.1 Log Storage (Core)

- **Format:** JSON Lines (`.jsonl`) — one JSON object per line
- **Files:** `simple_logs.jsonl` and `network_logs.jsonl` in `getApplicationSupportDirectory()`
- **Writes:** dispatched to a background `Isolate` via `Isolate.run()` — main thread never blocks
- **Reads:** also in background isolate; returned as `List<SimpleOverlayLog>` / `List<SimpleOverlayNetworkLog>`
- **Live stream:** `SimpleOverlayLogStorageService` exposes `simpleLogStream` and `networkLogStream` as `Stream.broadcast()` — new logs pushed to all listeners without a round-trip to disk
- **Robustness:** per-line `try/catch` on JSONL parse — corrupt / partial lines silently skipped

### 5.2 Overlay UI

#### Screen structure
```
SharedAxisTransition (vertical)
└── Scaffold
    ├── AppBar — title + log count + export button (IconButton.filledTonal)
    └── SimpleOverlayTabbedLogger
        ├── SearchBar (M3) + sort toggle + animated filter badge
        ├── TabBar.secondary — "Logs (n)" | "Network (n)"
        └── TabBarView
            ├── Log list (SimpleOverlayLogCard.simple)
            └── Network list (SimpleOverlayLogCard.network)
```

#### Log card
- Built with `OpenContainer` (container-transform, fade, 450 ms)
- Colors from M3 semantic tokens — adapts to any seed color or dynamic scheme
- Simple card: level icon + message (2-line ellipsis) + tag · timestamp
- Network card: method badge + URL + timestamp + status code badge

#### Log entry animation
- **Standard logs (debug/info, network success):** `Cubic(0.05, 0.7, 0.1, 1.0)` (M3 emphasized decelerate), 350 ms — slide up 20px + fade in
- **Error logs / failed requests:** `Cubic(0.34, 1.4, 0.64, 1.0)` (spring overshoot), 300 ms — slides 14px then bounces past target before settling; opacity clamped so no flicker

#### Detail page
- Opens via `OpenContainer` container-transform from the card
- Simple log: tag chip, level chip, UTC timestamp, full message — all fields individually copyable
- Network log: method + status code + URL, request headers + body, response headers + body
- Body auto-detected: JSON (pretty-printed with JetBrains Mono) · HTML (rendered inline via `flutter_html`) · plain text
- Copy entire log as JSON via AppBar action

### 5.3 Search & Filter

#### Search bar
- M3 `SearchBar` widget; elevation overridden to 0 (flat, blends with surface)
- Live filter on `onChanged` — no submit required
- Clear button appears when query is non-empty
- Searches: `message` + `tag` (simple); `url` + `method` (network)

#### Sort
- Toggle button (`IconButton.outlined`) with `AnimatedSwitcher` rotation on icon swap
- Newest-first / oldest-first — applied independently of filter state

#### Filter sheet
- Opened via `IconButton.outlined` with animated badge dot
  - Badge dot: custom 8px circle, `AnimatedScale` with `easeOutBack` spring (220 ms) — pops in when filters are active, shrinks out when cleared
- `showModalBottomSheet` with:
  - `barrierColor: Colors.black @ 0.32` — M3 standard modal scrim
  - `backgroundColor: Colors.transparent` + `Container` with `surfaceContainerLow` + `BorderRadius.vertical(top: 28)`
  - Drag handle (32×4 px, `onSurfaceVariant @ 0.3`)
- **Simple tab:** FilterChip for Debug / Info / Error (multi-select)
  - Selected chip: semantic container color (`tertiaryContainer` / `primaryContainer` / `errorContainer`)
  - Border: accent color @ 0.45 alpha when selected, `outlineVariant` when not
  - `showCheckmark: false` — icon in avatar serves as visual indicator
- **Network tab:** FilterChip for Success / Error (single-select toggle — selecting same value clears filter)
  - Selected chip: `secondaryContainer` (success) / `errorContainer` (error)
- "Clear all" `TextButton` — visible only when filters active
- "Apply" `FilledButton` — full width

### 5.4 Empty States

| State | Icon | Title | Subtitle |
|---|---|---|---|
| No logs yet | `receipt_long_outlined` | Localizable | Localizable |
| No network logs | `wifi_off_outlined` | Localizable | Localizable |
| No search results | `filter_list_off` | Localizable | Shows query string |
| No filter results | `filter_list_off` | Localizable | Filter-specific message |

### 5.5 Network Inspector (Dio Interceptor)

Add one line:
```dart
dio.interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
```

Captures per-request:

| Field | Type |
|---|---|
| `timestamp` | `DateTime` (UTC) |
| `method` | `String` (GET / POST / …) |
| `url` | `String` |
| `requestHeaders` | `Map<String, dynamic>` |
| `requestBody` | `String?` |
| `statusCode` | `int?` |
| `responseHeaders` | `Map<String, dynamic>` |
| `responseBody` | `String?` — JSON encoded if Map/List, raw string otherwise |
| `isSuccess` | `bool` — `statusCode` in 200–299 |

### 5.6 Framework Integrations

All integrations are optional imports — no runtime cost if unused.

#### BLoC
```dart
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';
Bloc.observer = SimpleOverlayBlocObserverLogger();
```
Logs every `Event`, `Transition`, and `Error` from every BLoC.

#### Riverpod
```dart
import 'package:simple_logger_overlay/core/riverpod_logger.dart';
ProviderScope(observers: [SimpleOverlayLoggerRiverpodObserver()])
```

#### GetX
```dart
import 'package:simple_logger_overlay/core/getx_logger_patch.dart';
simpleOverlayGetXLogObserver();
```

#### GoRouter
```dart
import 'package:simple_logger_overlay/core/go_router_observer.dart';
GoRouter(observers: [SimpleOverlayGoRouterObserver()])
```
Logs every push, pop, and replace with full route path.

#### App Lifecycle
```dart
import 'package:simple_logger_overlay/core/app_lifecycle_observer.dart';
WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
```
Logs `resumed`, `paused`, `detached`.

#### Shake-to-open
Built-in via the `shake` package — shaking the device opens the overlay. Debug builds only (no-op in release).

### 5.7 Localization

```dart
MaterialApp(
  localizationsDelegates: [
    SimpleOverlayLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

25 localizable strings. Extend `SimpleOverlayLocalizations` to translate:

```dart
class MyL10n extends SimpleOverlayLocalizations {
  @override String get title => 'Registros';
  @override String logsTab(int n) => 'Registros ($n)';
  // ...
}
```

`shouldReload` returns `true` — strings update live when app locale changes.

---

## 6. Architecture

```
Host App
   │
   ├─▶ SimpleLoggerOverlay.log(...)
   │       │
   │       ▼
   │   SimpleOverlayLogStorageService   ← singleton
   │       │
   │       ├─▶ Isolate.run(writeLog)   ← disk write (non-blocking)
   │       │
   │       └─▶ StreamController.broadcast.add(log)
   │                   │
   │                   ▼
   │       SimpleOverlayTabbedLogger   ← StreamSubscription
   │           └─▶ setState → card animates in
   │
   ├─▶ SimpleOverlayDraggableDebuggerFAB
   │       ├─▶ StreamSubscription → pulse on new log
   │       └─▶ onTap → SimpleLoggerOverlay.show(...)
   │
   └─▶ SimpleOverlayNetworkLoggerInterceptor (Dio)
           └─▶ SimpleOverlayLogStorageService().addNetworkLog(...)
```

### Key design decisions

| Decision | Rationale |
|---|---|
| `Isolate.run` for all disk I/O | Zero main-thread overhead at any log frequency |
| `StreamController.broadcast` | Multiple listeners (FAB + list) without duplication |
| Overlay builds own `ThemeData` | Decoupled from host app theme; seed color API works regardless of host |
| `OpenContainer` for card→detail | Container-transform is the most expressive M3 pattern for this use case |
| JSONL (not SQLite) | Simple, no schema migrations, grep-friendly, trivially exportable |

---

## 7. Platform Support

| Platform | Status | Notes |
|---|---|---|
| Android | ✅ Full | Dynamic Color (Android 12+) supported |
| iOS | ✅ Full | Dynamic Color not available (graceful fallback to seed) |
| macOS | ✅ Full | FAB renders in overlay Stack |
| Linux | ✅ Full | Same as macOS |
| Windows | ✅ Full | Same as macOS |
| Web | ⚠️ Partial | Simple logging works; file export triggers browser download |

**Minimum SDK:** Dart ≥ 3.3.0 · Flutter ≥ 3.19

---

## 8. Dependencies

| Package | Purpose | Optionality |
|---|---|---|
| `animations ^2.0.11` | `OpenContainer`, `SharedAxisTransition` | Required |
| `google_fonts ^8.0.2` | Inter + JetBrains Mono typography | Required |
| `flutter_html ^3.0.0` | Inline HTML response body rendering | Required |
| `path_provider ^2.1.5` | JSONL file storage path | Required |
| `share_plus ^11.0.0` | Log export share sheet | Required |
| `dio ^5.8.0+1` | Network interceptor | Required (peer dep) |
| `shake ^3.0.0` | Shake-to-open trigger | Required |
| `flutter_bloc ^9.1.1` | BLoC observer | Optional integration |
| `flutter_riverpod ^2.6.1` | Riverpod observer | Optional integration |
| `get ^4.7.2` | GetX log patch | Optional integration |
| `go_router ^15.1.3` | GoRouter observer | Optional integration |
| `intl >=0.19.0 <0.21.0` | Date formatting | Required |

---

## 9. Data Models

### SimpleOverlayLog
```dart
class SimpleOverlayLog {
  final DateTime timestamp;   // UTC
  final String tag;
  final LogLevel level;       // debug | info | error
  final String message;
}
```

### SimpleOverlayNetworkLog
```dart
class SimpleOverlayNetworkLog {
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, dynamic>? requestHeaders;
  final String? requestBody;
  final int? statusCode;
  final Map<String, dynamic>? responseHeaders;
  final String? responseBody;
  final bool isSuccess;        // statusCode in 200–299
}
```

---

## 10. Non-Functional Requirements

| Requirement | Specification |
|---|---|
| Main-thread blocking | Zero — all disk I/O in `Isolate.run` |
| Log write latency (perceived) | Immediate (stream fires before isolate completes write) |
| Storage format | JSONL — one UTF-8 JSON object per line |
| Auto-purge | Logs older than 7 days deleted on next `init()` |
| Crash safety | Corrupt/partial JSONL lines silently skipped (per-line try/catch) |
| Production safety | `SimpleLoggerOverlay.log()` is always safe; gate FAB with `kDebugMode` |
| Theme isolation | Overlay has its own `ThemeData` — host theme changes don't break overlay |

---

## 11. Version History

| Version | Highlights |
|---|---|
| **0.2.1** | Fix `OpenContainer` deactivated-context crash; CI Flutter pin; example dep fix |
| **0.2.0** | Material You Expressive UI — M3 colors, container-transform, FAB spring, `SimpleLoggerOverlayConfig`, Dynamic Color, `SearchBar`, localization fix, JSONL robustness |
| **0.1.9** | go_router version rollback to 15.1.3 |
| **0.1.8** | `intl` version range broadened for backward compatibility |
| **0.1.7** | UTC timestamp formatting fix |
| **0.1.6** | Class name refactoring; shake navigator support |
| **0.1.5** | `dart format` code style pass |
| **0.1.4** | ANSI console logging; `enableConsole` toggle; singleton `LogStorageService`; GoRouter + lifecycle observers; draggable FAB |
| **0.1.3** | Copy-to-clipboard on detail page |
| **0.1.2** | Isolate-based I/O; auto-purge; network log pretty-print |
| **0.1.0** | Initial release — overlay, BLoC/Riverpod/GetX, Dio interceptor, export |

---

## 12. Roadmap (Potential)

| Item | Notes |
|---|---|
| `AnimatedList` for per-item exit animations | Currently `ListView.builder` — exit needs refactor |
| Log retention setting (configurable days) | Currently hardcoded 7 days in `purgeOldLogs` |
| Pin / star important logs | Persisted flag in JSONL |
| Multiple tag filters simultaneously | Currently level-only multi-select |
| Timeline / waterfall view for network | Ordered by time with duration bars |
| Web: IndexedDB storage | `path_provider` not ideal on web |

---

*MIT © 2025 Saumya Macwan*

# simple_logger_overlay

[![Pub Version](https://img.shields.io/pub/v/simple_logger_overlay)](https://pub.dev/packages/simple_logger_overlay)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/sam829/simple_logger_overlay)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/saumya-macwan-b650b91a1)

A lightweight, Dart 3-compatible Flutter logging package with a **Material You Expressive** in-app overlay — draggable FAB, live log streaming, container-transform transitions, and full M3 theming.

Built with 💙 by [Saumya Macwan](https://github.com/sam829).

---

## ✨ Features

| Category | Highlights |
|---|---|
| **UI** | Material You color tokens · Container transform card→detail · M3 emphasized easing · Inter + JetBrains Mono fonts |
| **Logging** | Simple logs (debug / info / error) · Network logs via Dio interceptor · Live list updates via broadcast stream |
| **Overlay** | Draggable FAB with spring-physics snap · Shared-axis transition open/close · Per-tab log counts |
| **Detail view** | Pretty-printed JSON · HTML response rendering · Per-field copy buttons |
| **Filtering** | Full-text search · Level / status filter sheet · Newest-first / oldest-first sort |
| **Customization** | `SimpleLoggerOverlayConfig` seed-color API · Auto dark/light theme · Host app font inheritance |
| **I/O** | Background-isolate JSONL writes · Export logs as `.json` · Copy log to clipboard |
| **Integrations** | BLoC · Riverpod · GetX · GoRouter · App lifecycle observer |
| **DX** | Emoji + color console logging · Shake-to-open (debug) · Zero public API changes |

---

## 📱 Screenshots

<div align="center">
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_list.jpeg?raw=true" alt="Network list" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_detail.jpeg?raw=true" alt="Network detail" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_list.png?raw=true" alt="Simple log list" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_detail.png?raw=true" alt="Simple log detail" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/search.png?raw=true" alt="Search" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/export.png?raw=true" alt="Export" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/console.png?raw=true" alt="Console" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/debug_overlay.png?raw=true" alt="Debug overlay" width="200"/>
</div>

---

## 🚀 Getting Started

### 1. Add dependency

```yaml
dependencies:
  simple_logger_overlay: ^0.1.9
```

### 2. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleLoggerOverlay.init();
  runApp(const MyApp());
}
```

### 3. Add the FAB

Drop the draggable FAB into your root `Stack`. It snaps to screen edges with spring physics and pulses when new logs arrive.

```dart
final navigatorKey = GlobalKey<NavigatorState>();

MaterialApp(
  navigatorKey: navigatorKey,
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        SimpleOverlayDraggableDebuggerFAB(navigatorKey: navigatorKey),
      ],
    );
  },
);
```

### 4. Log from anywhere

```dart
SimpleLoggerOverlay.log(
  'Payment completed',
  level: LogLevel.info,
  tag: 'CheckoutScreen',
);
```

Available levels: `LogLevel.debug`, `LogLevel.info`, `LogLevel.error`.

---

## 🎨 Customization

### Seed color

Configure the overlay's Material You color scheme before `runApp`:

```dart
SimpleLoggerOverlayConfig.configure(
  seedColor: Colors.indigo, // any Color
);
```

The overlay uses `ColorScheme.fromSeed` internally so all M3 color tokens
(containers, on-containers, surface variants) derive from your seed automatically.
Both light and dark themes are generated — the overlay inherits brightness from
the host app.

Default seed: `Color(0xFF52B788)` (sage-mint green).

### Console logging

Logs are printed to the terminal with emoji and color by default:

```
[2025-06-24T19:15:01Z] 🔍 [DEBUG] [LoginBloc] Event dispatched
[2025-06-24T19:15:02Z] 🔥 [ERROR] [LoginBloc] Invalid credentials
```

Disable:

```dart
SimpleOverlayLogStorageService.enableConsole = false;
```

---

## 🌐 Network Logging (Dio)

Add the interceptor to any `Dio` instance:

```dart
import 'package:simple_logger_overlay/core/network_logger_interceptor.dart';

final dio = Dio()
  ..interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
```

The interceptor captures:
- Method, URL, status code
- Request headers + body
- Response headers + body
- Request start timestamp

Response bodies are auto-detected as **JSON** (pretty-printed), **HTML** (rendered), or **plain text** in the detail view.

---

## 🧩 Integrations

### BLoC

```dart
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';

void main() async {
  Bloc.observer = SimpleOverlayBlocObserverLogger();
  // ...
}
```

### Riverpod

```dart
import 'package:simple_logger_overlay/core/riverpod_logger.dart';

runApp(
  ProviderScope(
    observers: [SimpleOverlayLoggerRiverpodObserver()],
    child: const MyApp(),
  ),
);
```

### GetX

```dart
import 'package:simple_logger_overlay/core/getx_logger_patch.dart';

void main() {
  simpleOverlayGetXLogObserver();
}
```

### GoRouter

```dart
import 'package:simple_logger_overlay/core/go_router_observer.dart';

GoRouter(
  observers: [SimpleOverlayGoRouterObserver()],
  routes: [...],
);
```

### App Lifecycle

```dart
import 'package:simple_logger_overlay/core/app_lifecycle_observer.dart';

WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
```

---

## 🌍 Localization

Add `SimpleOverlayLocalizations.delegate` to your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: [
    SimpleOverlayLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [Locale('en')],
);
```

The overlay picks up the active locale from the host app's `Localizations` system.
Override `SimpleOverlayLocalizations` to provide translated strings.

---

## 📤 Export Logs

Tap the export icon in the overlay's app bar to:

- Export all visible logs as a `.json` file
- Copy the current log entry to clipboard (also available per-field in detail view)

---

## 🔌 Open Overlay Programmatically

```dart
SimpleLoggerOverlay.show(context, navigatorKey: navigatorKey);
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `animations` | Container transform (card→detail) · Shared-axis transition |
| `google_fonts` | Inter UI font · JetBrains Mono for code/JSON |
| `flutter_html` | Render HTML response bodies in detail view |
| `path_provider` | JSONL log file storage |
| `dio` | Network interceptor |
| `share_plus` | Log export |

---

## 🛠️ License

MIT © 2025 Saumya Macwan

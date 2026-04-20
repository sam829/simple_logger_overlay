# simple_logger_overlay

[![Pub Version](https://img.shields.io/pub/v/simple_logger_overlay)](https://pub.dev/packages/simple_logger_overlay)
[![Pub Points](https://img.shields.io/pub/points/simple_logger_overlay)](https://pub.dev/packages/simple_logger_overlay/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-sam829-181717?logo=github)](https://github.com/sam829/simple_logger_overlay)

A lightweight, Dart 3-compatible Flutter logging package with a **Material You Expressive** in-app overlay.
Draggable FAB, live log streaming, container-transform card transitions, full M3 theming — zero changes to your public API.

Built with 💙 by [Saumya Macwan](https://github.com/sam829).

---

## ✨ Features

| Category | What you get |
|---|---|
| **UI** | Material You color tokens · Container-transform card→detail · M3 emphasized easing · Inter + JetBrains Mono fonts |
| **Logging** | `debug` / `info` / `error` levels · Live list updates via broadcast stream · Background-isolate JSONL writes |
| **Network** | Dio interceptor · Status-code coloring · Pretty JSON · HTML response rendering · Per-field copy |
| **Overlay** | Draggable FAB with spring-snap · Pulse on new logs · Shared-axis open/close transition |
| **Search & filter** | Full-text search · Level / status filter sheet · Newest-first / oldest-first sort |
| **Theming** | `SimpleLoggerOverlayConfig.configure(seedColor:)` · Auto dark/light · Dynamic Color (Android 12+) support |
| **Integrations** | BLoC · Riverpod · GetX · GoRouter · App lifecycle observer · Shake-to-open |
| **Export** | Export logs as `.json` · Copy single log / individual field to clipboard |
| **Localization** | Extend `SimpleOverlayLocalizations` to translate any string |

---

## 📱 Screenshots

<div align="center">
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_list.png?raw=true" alt="Simple log list" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_detail.png?raw=true" alt="Simple log detail" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_list.jpeg?raw=true" alt="Network list" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_detail.jpeg?raw=true" alt="Network detail" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/search.png?raw=true" alt="Search" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/export.png?raw=true" alt="Export" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/debug_overlay.png?raw=true" alt="Debug overlay FAB" width="200"/>
  <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/console.png?raw=true" alt="Console output" width="200"/>
</div>

---

## 🚀 Getting Started

### 1. Add dependency

```yaml
dependencies:
  simple_logger_overlay: ^0.2.0
```

### 2. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleLoggerOverlay.init();
  runApp(const MyApp());
}
```

### 3. Add the draggable FAB

Drop it into your root `Stack`. It snaps to screen edges with spring physics and pulses when new logs arrive.

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

Available levels: `LogLevel.debug` · `LogLevel.info` · `LogLevel.error`

---

## 🎨 Theming

### Seed color

```dart
// Call before runApp, or any time settings change.
SimpleLoggerOverlayConfig.configure(
  seedColor: Colors.indigo,
);
```

The overlay uses `ColorScheme.fromSeed` internally — all M3 tokens derive from your seed.
Both light and dark themes are generated automatically from the host app's brightness.

Default seed: `Color(0xFF52B788)` (sage-mint green).

### Dynamic Color (Android 12+)

Pass the system-derived color scheme from `dynamic_color` to keep the overlay in sync with the wallpaper:

```dart
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    if (lightDynamic != null) {
      SimpleLoggerOverlayConfig.configure(
        lightScheme: lightDynamic,
        darkScheme: darkDynamic,
      );
    }
    return MaterialApp(/* ... */);
  },
);
```

To revert to seed-based theming:

```dart
SimpleLoggerOverlayConfig.configure(
  seedColor: myColor,
  clearSchemes: true,
);
```

---

## 🌐 Network Logging (Dio)

```dart
import 'package:simple_logger_overlay/core/network_logger_interceptor.dart';

final dio = Dio()
  ..interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
```

Captured per request: method · URL · status code · request headers & body · response headers & body · timestamp.

Response bodies are auto-detected as **JSON** (pretty-printed), **HTML** (rendered), or **plain text**.

---

## 🧩 Integrations

### BLoC

```dart
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';

Bloc.observer = SimpleOverlayBlocObserverLogger();
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

simpleOverlayGetXLogObserver();
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

Register the delegate so the overlay picks up your app's locale:

```dart
MaterialApp(
  localizationsDelegates: [
    SimpleOverlayLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
);
```

To provide translated strings, extend `SimpleOverlayLocalizations` and register your subclass via a custom `LocalizationsDelegate`:

```dart
class MyOverlayL10n extends SimpleOverlayLocalizations {
  @override String get title => 'Registros';
  @override String get searchHint => 'Buscar registros...';
  // override any getter you need
}
```

See the [example app's `lib/l10n/overlay_l10n.dart`](example/lib/l10n/overlay_l10n.dart) for a complete implementation covering English, Spanish, French, Arabic, German, and Japanese.

---

## 💻 Console Logging

Terminal output with emoji and color, enabled by default:

```
[2025-06-24T19:15:01Z] 🔍 [DEBUG] [LoginBloc] Event dispatched
[2025-06-24T19:15:02Z] 🔥 [ERROR] [LoginBloc] Invalid credentials
```

Disable:

```dart
SimpleOverlayLogStorageService.enableConsole = false;
```

---

## 🔌 Open Overlay Programmatically

```dart
SimpleLoggerOverlay.show(context, navigatorKey: navigatorKey);
```

---

## 📤 Export Logs

Tap the export icon in the overlay's app bar to save all visible logs as a `.json` file, or use the copy button on any individual field in the detail view.

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `animations` | Container transform (card→detail) · Shared-axis transition |
| `google_fonts` | Inter (UI) · JetBrains Mono (code / JSON) |
| `flutter_html` | Render HTML response bodies |
| `path_provider` | JSONL log file storage |
| `share_plus` | Log export |
| `dio` | Network interceptor |
| `shake` | Shake-to-open (debug builds) |

---

## 🛠️ License

MIT © 2025 Saumya Macwan

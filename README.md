<div align="center">

<img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/debug_overlay.png?raw=true" width="80" alt="simple_logger_overlay logo"/>

# simple_logger_overlay

**A premium in-app debug logger for Flutter — Material You, zero config, production-safe.**

[![Pub Version](https://img.shields.io/pub/v/simple_logger_overlay?color=52B788&label=pub.dev&logo=dart)](https://pub.dev/packages/simple_logger_overlay)
[![Pub Points](https://img.shields.io/pub/points/simple_logger_overlay?color=52B788)](https://pub.dev/packages/simple_logger_overlay/score)
[![Dart 3](https://img.shields.io/badge/Dart-3%2B-0175C2?logo=dart)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-54C5F8?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-52B788)](LICENSE)

<br/>

*Stop `print`-debugging. Stop switching windows. Everything you need, right inside your app.*

<br/>

<img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_list.png?raw=true" width="180"/>
&nbsp;&nbsp;
<img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_detail.jpeg?raw=true" width="180"/>
&nbsp;&nbsp;
<img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/search.png?raw=true" width="180"/>
&nbsp;&nbsp;
<img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_detail.png?raw=true" width="180"/>

</div>

---

## The problem this solves

You're debugging a production-style Flutter app. You need to:

- See logs from a specific user flow — **without opening Xcode or Android Studio**
- Inspect network request headers and response bodies — **directly on device**
- Filter only errors from the last 30 seconds — **without grep**
- Hand your phone to a QA engineer — **without them needing a laptop**

`simple_logger_overlay` puts a draggable debug panel *inside* your app. Tap the FAB, see everything.

---

## Feature highlights

| | Feature | Details |
|---|---|---|
| 🪄 | **Material You UI** | Full M3 color tokens, container-transform card transitions, spring-physics FAB |
| ⚡ | **Live streaming** | New logs animate in as they arrive — no pull-to-refresh |
| 🌐 | **Network inspector** | Dio interceptor · pretty JSON · HTML renderer · per-field copy |
| 🎨 | **Themeable** | Seed color API · Dynamic Color (Android 12+) · auto dark/light |
| 🔍 | **Search & filter** | Full-text · level filter · status filter · sort order |
| 🔒 | **Non-blocking** | Log I/O runs in a background isolate — zero main-thread overhead |
| 🌍 | **Localizable** | Extend one class to translate every overlay string |
| 📤 | **Export** | Save logs as `.json` · copy any field to clipboard |
| 🤝 | **Framework agnostic** | BLoC · Riverpod · GetX · GoRouter · App lifecycle |
| 🐞 | **Shake-to-open** | Shake the device to open the overlay (debug builds) |

---

## 60-second setup

### 1 — Add dependency

```yaml
dependencies:
  simple_logger_overlay: ^0.2.2
```

### 2 — Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleLoggerOverlay.init();
  runApp(const MyApp());
}
```

### 3 — Add the FAB to your root widget

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

**That's it.** A draggable button now lives in your app. Drag it anywhere, tap to open the overlay.

---

## Logging

```dart
// Log from anywhere — no context needed
SimpleLoggerOverlay.log('User tapped checkout', level: LogLevel.info,  tag: 'CheckoutScreen');
SimpleLoggerOverlay.log('Cart is empty',        level: LogLevel.debug, tag: 'CartBloc');
SimpleLoggerOverlay.log('Payment failed: 402',  level: LogLevel.error, tag: 'PaymentService');
```

| Level | Color | Use for |
|---|---|---|
| `LogLevel.debug` | Teal/tertiary | Detailed internal state |
| `LogLevel.info` | Primary | Normal flow events |
| `LogLevel.error` | Error/red | Failures, exceptions |

---

## Network logging

Add one line to your `Dio` setup:

```dart
import 'package:simple_logger_overlay/core/network_logger_interceptor.dart';

final dio = Dio()
  ..interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
```

The network tab shows every request with:

- Method badge + URL
- Status code (green = success, red = error)
- Request headers & body
- Response headers & body — **auto-rendered as JSON, HTML, or plain text**
- Copy button on every single field

---

## Theming

<details>
<summary><b>🎨 Custom seed color</b></summary>

```dart
// Call before runApp — takes effect immediately.
SimpleLoggerOverlayConfig.configure(
  seedColor: Colors.deepPurple, // any Color
);
```

The overlay generates its entire color scheme from a single seed using M3 `ColorScheme.fromSeed`.
Both light and dark themes are produced automatically.

**Default:** `Color(0xFF52B788)` — sage-mint green.

</details>

<details>
<summary><b>🌈 Android 12+ Dynamic Color (wallpaper-derived)</b></summary>

Add [`dynamic_color`](https://pub.dev/packages/dynamic_color) to your app:

```yaml
dependencies:
  dynamic_color: ^1.7.0
```

```dart
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    // Pass the system schemes to the overlay
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

To revert to seed color:

```dart
SimpleLoggerOverlayConfig.configure(
  seedColor: Colors.teal,
  clearSchemes: true,
);
```

</details>

---

## Integrations

<details>
<summary><b>🧠 BLoC</b></summary>

```dart
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleOverlayBlocObserverLogger();
  await SimpleLoggerOverlay.init();
  runApp(const MyApp());
}
```

Every `Event`, `Transition`, and `Error` from every BLoC is automatically logged.

</details>

<details>
<summary><b>🌱 Riverpod</b></summary>

```dart
import 'package:simple_logger_overlay/core/riverpod_logger.dart';

runApp(
  ProviderScope(
    observers: [SimpleOverlayLoggerRiverpodObserver()],
    child: const MyApp(),
  ),
);
```

</details>

<details>
<summary><b>⚡ GetX</b></summary>

```dart
import 'package:simple_logger_overlay/core/getx_logger_patch.dart';

void main() {
  simpleOverlayGetXLogObserver();
  runApp(const MyApp());
}
```

</details>

<details>
<summary><b>🧭 GoRouter</b></summary>

```dart
import 'package:simple_logger_overlay/core/go_router_observer.dart';

final router = GoRouter(
  observers: [SimpleOverlayGoRouterObserver()],
  routes: [...],
);
```

Every push, pop, and replace is logged with the full route path.

</details>

<details>
<summary><b>📱 App Lifecycle</b></summary>

```dart
import 'package:simple_logger_overlay/core/app_lifecycle_observer.dart';

WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
```

Logs `resumed`, `paused`, `detached` — useful for debugging background/foreground bugs.

</details>

---

## Localization

Add the delegate so the overlay inherits your app's locale:

```dart
MaterialApp(
  localizationsDelegates: [
    SimpleOverlayLocalizations.delegate, // 👈 add this
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
);
```

<details>
<summary><b>Translate overlay strings into any language</b></summary>

Extend `SimpleOverlayLocalizations` and register your own delegate:

```dart
class MySpanishOverlayL10n extends SimpleOverlayLocalizations {
  @override String get title        => 'Registros';
  @override String get searchHint   => 'Buscar registros...';
  @override String get noLogsTitle  => 'Sin registros';
  @override String logsTab(int n)   => 'Registros ($n)';
  // override any of the 25 available getters
}

class MyDelegate extends LocalizationsDelegate<SimpleOverlayLocalizations> {
  @override bool isSupported(Locale l) => true;
  @override bool shouldReload(_)       => true;

  @override Future<SimpleOverlayLocalizations> load(Locale locale) {
    return Future.value(
      locale.languageCode == 'es' ? MySpanishOverlayL10n() : SimpleOverlayLocalizations(),
    );
  }
}
```

See the [example app](example/lib/l10n/overlay_l10n.dart) for a complete implementation covering **English, Spanish, French, Arabic, German, and Japanese**.

</details>

---

## Console logging

Logs also print to the terminal with ANSI color and emoji — useful when the device isn't in front of you:

```
[2025-06-24T19:15:01Z] 🔍 [DEBUG] [CartBloc]    Item added: product_id=42
[2025-06-24T19:15:02Z] ℹ️  [INFO]  [Checkout]    Payment intent created
[2025-06-24T19:15:03Z] 🔥 [ERROR] [PaymentSvc]  Stripe returned 402
```

Disable when not needed:

```dart
SimpleOverlayLogStorageService.enableConsole = false;
```

---

## Open programmatically

```dart
// From any button, gesture, or deep link:
SimpleLoggerOverlay.show(context, navigatorKey: navigatorKey);
```

---

## How it works

```
Your App
   │
   ├─▶ SimpleLoggerOverlay.log(...)
   │       │
   │       ▼
   │   LogStorageService          ← singleton, holds broadcast StreamController
   │       │
   │       ├─▶ Isolate (background)
   │       │       └─▶ writes JSONL to disk  (non-blocking)
   │       │
   │       └─▶ stream.add(log)
   │                   │
   │                   ▼
   │           TabbedLogger (StreamBuilder)
   │                   └─▶ new card slides in (M3 easing, 350ms)
   │
   └─▶ SimpleOverlayDraggableDebuggerFAB
           └─▶ spring-physics snap to edges
           └─▶ pulse animation on new log
           └─▶ opens LoggerOverlay (SharedAxisTransition)
                   └─▶ tap card → OpenContainer transform → LogDetailPage
```

---

## Screenshots

<div align="center">

| Log list | Network list |
|:---:|:---:|
| <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_list.png?raw=true" width="220"/> | <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_list.jpeg?raw=true" width="220"/> |

| Log detail | Network detail |
|:---:|:---:|
| <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/simple_detail.png?raw=true" width="220"/> | <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_detail.jpeg?raw=true" width="220"/> |

| Search & filter | Export |
|:---:|:---:|
| <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/search.png?raw=true" width="220"/> | <img src="https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/export.png?raw=true" width="220"/> |

</div>

---

## FAQ

<details>
<summary><b>Is this safe to ship in production?</b></summary>

Yes — with a guard. The recommended pattern:

```dart
if (kDebugMode) {
  SimpleOverlayDraggableDebuggerFAB(navigatorKey: navigatorKey)
}
```

`SimpleLoggerOverlay.log(...)` calls are always safe; they just write to a local file. Only the visible FAB and overlay UI need to be gated.

</details>

<details>
<summary><b>Does it affect app performance?</b></summary>

No. All file I/O is dispatched to a background `Isolate`. The main thread only receives a `StreamController.broadcast` event — the same as a state update. The FAB and overlay are rendered in a separate layer from your app's route stack.

</details>

<details>
<summary><b>How do I clear old logs?</b></summary>

Logs older than N days are purged automatically on next launch. The default is 7 days. To purge manually:

```dart
await SimpleOverlayLogStorageService().clearAllLogs();
```

</details>

<details>
<summary><b>Can I use it without Dio?</b></summary>

Yes. The Dio interceptor is entirely optional. All other features — simple logs, BLoC/Riverpod/GetX observers, GoRouter observer — work independently.

</details>

<details>
<summary><b>Does it work on iOS / web / desktop?</b></summary>

- **iOS** ✅ — all features except Dynamic Color (Android 12+ only)
- **macOS / Linux / Windows** ✅ — all features (FAB renders in the overlay Stack)
- **Web** ⚠️ — simple logging works; file export uses a browser download

</details>

---

## Dependencies

| Package | Why |
|---|---|
| `animations` | Container transform (card→detail) · SharedAxis overlay transition |
| `google_fonts` | Inter (UI text) · JetBrains Mono (JSON/headers/code) |
| `flutter_html` | Render HTML response bodies inline |
| `path_provider` | Persistent JSONL log storage |
| `share_plus` | Export logs to file |
| `dio` | Network interceptor |
| `shake` | Shake-to-open (debug builds) |

---

<div align="center">

MIT © 2025 [Saumya Macwan](https://github.com/sam829)

[![GitHub](https://img.shields.io/badge/GitHub-sam829-181717?logo=github&style=flat-square)](https://github.com/sam829/simple_logger_overlay)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Saumya%20Macwan-0A66C2?logo=linkedin&style=flat-square)](https://www.linkedin.com/in/saumya-macwan-b650b91a1)
[![pub.dev](https://img.shields.io/badge/pub.dev-simple__logger__overlay-0175C2?logo=dart&style=flat-square)](https://pub.dev/packages/simple_logger_overlay)

*If this saved you time, consider starring the repo ⭐*

</div>

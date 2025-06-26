# simple_logger_overlay [![Pub Version](https://img.shields.io/pub/v/simple_logger_overlay)](https://pub.dev/packages/simple_logger_overlay)

A lightweight, Dart 3-compatible Flutter logging package with a draggable in-app log viewer overlay — inspired by `let_log`, rebuilt for modern apps.  
Built with 💙 by [Saumya Macwan](https://github.com/sam829).

---

### ✨ Features

- 🧠 **Non-blocking:** Log I/O runs in a background isolate
- 🌈 **Material 3 overlay**, dark/light theme aware
- 📄 **Pretty-printed JSON views** for network logs
- 🌐 **Dio interceptor** for network logging with status coloring
- 💬 Integrates with BLoC, Riverpod, GetX, and `logger`
- 🔍 Filter, sort, search logs
- 📤 Export logs as `.json`, or copy to clipboard
- 🧾 Detailed log view on card tap
- 🚀 Shake-to-open overlay (debug-only)
- 🐞 **Draggable floating debug button**
- 🔌 Optional: `GoRouterObserver`, `AppLifecycleObserver`
- 🖥️ Emoji + color-coded **console logging** (with toggle)
- 🧰 Simple static API: `SimpleLoggerOverlay.log(...)`

---

### 📱 Screenshots

**Listing Page**  
![network_list](https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_list.jpeg?raw=true)

**Detail Page**  
![network_page](https://github.com/sam829/simple_logger_overlay/blob/develop/screenshot/network_detail.jpeg?raw=true)

---

## 🚀 Getting Started

```dart
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

@override
Widget build(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      SimpleLoggerOverlay.show(context);
    },
    child: const Icon(Icons.file_present),
  );
}
````

---

### 🪵 Log from Anywhere

Log directly with the static API:

```dart
SimpleLoggerOverlay.log("Something happened", level: LogLevel.info, tag: 'HomeScreen');
```

---

### 🧩 Integrations

#### 🧠 BLoC

```dart
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleOverlayBlocObserverLogger();
}
```

#### 🌱 Riverpod

```dart
import 'package:simple_logger_overlay/core/riverpod_logger.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [SimpleOverlayLoggerRiverpodObserver()],
      child: const MyApp(),
    ),
  );
}
```

#### ⚡ GetX

```dart
import 'package:simple_logger_overlay/core/getx_logger_patch.dart';

void main() {
  simpleOverlayGetXLogObserver();
}
```

#### 🌐 Dio Interceptor

```dart
import 'package:dio/dio.dart';
import 'package:simple_logger_overlay/core/network_logger_interceptor.dart';

final dio = Dio()
  ..interceptors.add(NetworkLoggerInterceptor());
```

#### 🧭 GoRouter

```dart
MaterialApp.router(
  routerDelegate: GoRouter(
    observers: [SimpleOverlayGoRouterObserver()],
    ...
  ).routerDelegate,
);
```

#### 📱 App Lifecycle

```dart
WidgetsBinding.instance.addObserver(SimpleOverlayAppLifecycleObserver());
```

---

### 🐞 Debug Floating Button

```dart
Stack(
  children: [
    child!,
    const DraggableDebuggerFAB(navigatorKey: rootNavigatorKey),
  ],
);
```

---

## 💻 Console Logging

Logs are also printed in your terminal with emojis and color by default.

```bash
[2025-06-24T19:15:01.000Z] 🔍 [DEBUG] [LoginBloc] Event dispatched
[2025-06-24T19:15:02.000Z] 🔥 [ERROR] [LoginBloc] Invalid password
```

Disable if needed:

```dart
LogStorageService.enableConsole = false;
```

---

## 📦 Export Logs

Use the export button in the top-right corner of the overlay to:

* 📤 Export logs as `.json`
* 📋 Copy current log to clipboard

---

## 🛠️ License

MIT © 2025 [Saumya Macwan](https://github.com/sam829)

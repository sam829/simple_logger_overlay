# simple_logger_overlay [![Pub Version](https://img.shields.io/pub/v/simple_logger_overlay)](https://pub.dev/packages/simple_logger_overlay)

A lightweight, Dart 3 compatible Flutter logging package with an in-app log viewer overlay — inspired by let_log, rebuilt for modern apps. Built with 💙 by Saumya Macwan.

- 🧠 Non-blocking: Log I/O now runs in a background isolate
- 🚀 Shake-to-open debug UI (configurable)
- 🌐 Dio network logging with status coloring
- 💬 BLoC, Riverpod, GetX, and `logger` package integration
- 🧾 Pretty-printed JSON body view
- 🎨 Dark/light theme-aware design with icon-based log cards
- 🔍 Filter, search, and export logs as `.json`

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

### Optional integrations:

#### BLoC

```dart
import 'package:simple_logger_overlay/core/bloc_logger_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleOverlayBlocObserverLogger();
}
```

#### Riverpod

```dart
import 'package:simple_logger_overlay/core/riverpod_logger.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [SimpleOverlayLoggerRiverpodObserver()],
      child: const LoggerDemo(),
    ),
  );
}
```

#### GetX

```dart
import 'package:simple_logger_overlay/core/getx_logger_patch.dart';

void main() {
  simpleOverlayGetXLogObserver();
}
```

#### Dio Interceptor

```dart
import 'package:dio/dio.dart';
import 'package:simple_logger_overlay/core/network_logger_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(NetworkLoggerInterceptor());
}

```

---

## 📦 Export logs

Use the export button in the overlay’s top-right corner to share a JSON file of your logs.

---

## 🛠️ License

MIT © 2025 [Saumya Macwan](https://github.com/sam829)

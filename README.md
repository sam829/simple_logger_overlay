# simple_logger_overlay

A lightweight, Dart 3 compatible Flutter logging package with an in-app log viewer overlay — inspired by let_log, rebuilt for modern apps. Built with 💙 by Saumya Macwan.

- 📄 UI for logs and network traffic
- 🚀 Supports BLoC, Riverpod, GetX, and `logger`
- 📂 Persistent log file system (auto-purges after 2 days)
- 📳 Shake-to-open for quick debug access
- 🔍 Search, filter, sort
- 📤 Export logs to JSON and share

[![Pub Version](https://img.shields.io/pub/v/simple_logger_overlay)](https://pub.dev/packages/simple_logger_overlay)

---

## 🚀 Getting Started

```dart
SimpleLoggerOverlay.show(context);
````

### Optional integrations:

#### BLoC

```dart
Bloc.observer = LoggerBlocObserver();
```

#### Riverpod

```dart
ProviderScope(observers: [LoggerRiverpodObserver()], child: MyApp());
```

#### GetX

```dart
patchGetXLogger();
```

#### Dio Interceptor

```dart
dio.interceptors.add(NetworkLoggerInterceptor());
```

---

## 📦 Export logs

Use the export button in the overlay’s top-right corner to share a JSON file of your logs.

---

## 🛠️ License

MIT © 2025 [Saumya Macwan](https://github.com/sam829)

```

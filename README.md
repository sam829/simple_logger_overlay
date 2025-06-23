# simple_logger_overlay

A lightweight, Dart 3 compatible Flutter logging package with an in-app log viewer overlay — inspired by let_log, rebuilt for modern apps.

![screenshot](https://raw.githubusercontent.com/YOUR_USERNAME/simple_logger_overlay/main/screenshot.png)

---

## ✨ Features

✅ Clean Dart 3+ codebase  
✅ Log levels (debug, info, warning, error)  
✅ In-app draggable log viewer  
✅ Custom tags  
✅ Dio interceptor support  
✅ No extra dependencies

---

## 🚀 Getting Started

### 1. Add to your `pubspec.yaml`

```yaml
dependencies:
  simple_logger_overlay: ^1.0.0
````

### 2. Use Logger in Your Code

```dart
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

LoggerCore().d("Debug log");
LoggerCore().e("Something went wrong", tag: "Auth");
```

### 3. Add UI Overlay (in debug mode)

```dart
return Stack(
  children: [
    MaterialApp(...),
    if (kDebugMode) const LoggerOverlay(),
  ],
);
```

---

## 🔌 Dio Integration (Optional)

```dart
void setupDioLogger(Dio dio) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        LoggerCore().i("➡️ ${o.method} ${o.uri}");
        return h.next(o);
      },
      onResponse: (r, h) {
        LoggerCore().d("✅ ${r.statusCode} ${r.requestOptions.uri}");
        return h.next(r);
      },
      onError: (e, h) {
        LoggerCore().e("❌ ${e.message}", tag: e.requestOptions.path);
        return h.next(e);
      },
    ),
  );
}
```

---

## 🧪 Example

See `/example/lib/main.dart` for a full integration example.

---

## 📃 License

MIT © 2025 \Sam

````

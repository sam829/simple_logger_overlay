# Stop `print`-Debugging Your Flutter App. There's a Better Way.

*You've been doing it wrong — and honestly, so have I.*

---

There's a particular kind of shame that every Flutter developer knows. You've just handed your phone to a QA engineer, they've found a bug you cannot reproduce on the simulator, and you — a professional, a craftsperson, someone who has opinions about clean architecture — mutter "just give me a second" and start sprinkling `print()` calls across your codebase like you're seasoning a salad.

You recompile. Hot restart. Ask them to tap through the flow again. Squint at the terminal. Miss the relevant line because a Riverpod provider decided to print forty state updates at the same moment. Sigh.

We've all been there. The good news is: you never have to be there again.

---

## The Real Problem Nobody Talks About

Flutter's debugging story is excellent — when you're at your desk, simulator open, IDE connected. But the moment you step away from that setup, you're flying blind.

Think about the scenarios that actually matter:

- A bug only happens on a specific device model you don't own
- Your client is experiencing a crash in a build you shipped three weeks ago
- QA is testing on a physical device in a different room
- You're building an app for a user who definitely cannot open a terminal
- You need to inspect a network request made by a flow you can't easily trigger from the simulator

In every one of these cases, the conventional answer is: connect a device, open Android Studio or Xcode, enable `debugPrint`, rebuild, and hope. That's four steps before you've even started debugging.

I got tired of it. So I built something different.

---

## Introducing `simple_logger_overlay`

`simple_logger_overlay` is a Flutter package that puts a fully-featured debug panel *inside your app*. It shows up as a small draggable button — a FAB that lives on top of whatever screen you're on. Tap it, and a Material You–styled overlay slides in with every log your app has produced, every network request it has made, and a full suite of filtering, searching, and exporting tools.

No laptop required. No terminal. Hand your phone to a QA engineer and they can inspect logs themselves.

Here's what it looks like in practice. You drop three lines into your app:

```yaml
# pubspec.yaml
dependencies:
  simple_logger_overlay: ^0.2.2
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

```dart
// Your root widget
MaterialApp(
  navigatorKey: navigatorKey,
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        if (kDebugMode)
          SimpleOverlayDraggableDebuggerFAB(navigatorKey: navigatorKey),
      ],
    );
  },
);
```

That's it. You now have a draggable debug panel in your app. Drag it to any corner, tap to open, shake the device to summon it hands-free.

---

## Logging Is Just One Line, From Anywhere

Once you're set up, logging is as simple as it gets:

```dart
SimpleLoggerOverlay.log('User tapped checkout', level: LogLevel.info,  tag: 'CheckoutScreen');
SimpleLoggerOverlay.log('Cart is empty',        level: LogLevel.debug, tag: 'CartBloc');
SimpleLoggerOverlay.log('Payment failed: 402',  level: LogLevel.error, tag: 'PaymentService');
```

No context. No `BuildContext`. No dependency injection. Call it from a repository, a service, a BLoC, a background isolate — it doesn't matter. The log shows up in the overlay in real time, with a smooth animated entry, color-coded by severity:

| Level | Color | What it means |
|---|---|---|
| `debug` | Teal | Internal state, fine-grained detail |
| `info` | Blue | Normal user-facing flow events |
| `error` | Red with spring-overshoot animation | Something broke |

That spring animation on error logs isn't just a gimmick — it's a deliberate design decision. When something goes wrong, it should *feel* wrong. The error card bounces past its final position before settling, using a `Cubic(0.34, 1.4, 0.64, 1.0)` curve that subtly draws the eye. Normal logs decelerate gently into place using the M3 emphasized-decelerate easing. Motion conveys meaning.

---

## Network Logging That Actually Works

This is where it gets genuinely useful. Add one line to your `Dio` setup:

```dart
final dio = Dio()
  ..interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
```

Every request your app makes is now captured automatically: method, URL, request headers, request body, response headers, response body, status code, and timestamp. The network tab in the overlay shows them in a clean list — green for success, red for failure.

Tap any request and you get a full detail page. The response body is auto-detected and rendered appropriately:

- **JSON** — pretty-printed with proper indentation
- **HTML** — rendered inline (via `flutter_html`), so you can actually read it
- **Plain text** — as-is

Every single field has a copy button. URL, headers, body — one tap to clipboard. When you're trying to reproduce a network bug by pasting a curl command into your terminal, this saves you an embarrassing amount of time.

---

## It Plays Well With Your Existing Architecture

The part that usually gets complicated with debug tools is making them fit into your app's state management. `simple_logger_overlay` has first-class support for the major Flutter frameworks, and each integration is — genuinely — one line.

**BLoC:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleOverlayBlocObserverLogger(); // 👈
  runApp(const MyApp());
}
```

Every event, transition, and error from every BLoC in your app is now automatically logged. You'll see exactly which event triggered which state change, with full `toString()` output. Debugging a subtle state machine bug — the kind where a specific sequence of five taps in a particular order causes a race condition — becomes a matter of looking at the log trail rather than reading tea leaves.

**Riverpod:**

```dart
runApp(
  ProviderScope(
    observers: [SimpleOverlayLoggerRiverpodObserver()], // 👈
    child: const MyApp(),
  ),
);
```

Provider updates and disposals are logged with the provider name (or runtime type as fallback) and a truncated value string. It's built against the Riverpod 3.x API — `ProviderObserverContext` and all — so it works with the current version of the package without any shims.

**GoRouter:**

```dart
final router = GoRouter(
  observers: [SimpleOverlayGoRouterObserver()], // 👈
  routes: [...],
);
```

Every push, pop, and replace is logged with the full route path. Combined with BLoC or Riverpod logging, you get a complete timeline of what the user did, what the app decided, and where it went.

**GetX** and **App Lifecycle** observers are both included too — adding two lines gives you full coverage of your app's runtime behaviour.

---

## The Overlay UI: Material You, Done Properly

Most debug tools look like debug tools. Monospaced text on a dark background, maybe a pastel colour scheme from 2016. `simple_logger_overlay` looks like it belongs in a polished consumer app — because it's built with the same design language.

The theming is driven by a singleton config:

```dart
// Call before runApp
SimpleLoggerOverlayConfig.configure(
  seedColor: Colors.deepPurple,
);
```

The entire overlay — cards, chips, sheets, icons, text styles — derives from a single `ColorScheme.fromSeed` call. Change the seed, everything updates. The default seed is `0xFF52B788`, a sage-mint green that sits comfortably in both light and dark contexts.

For Android 12+ users, Dynamic Color is fully supported:

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

Your wallpaper colours show up in the debug overlay. It's a small thing. It's also completely unnecessary. I included it anyway because it made me happy when it worked.

The log cards use `OpenContainer` from the `animations` package — tapping a card expands it into the detail page with a container-transform transition. The overlay itself slides in on a shared-axis vertical transition. These aren't placeholder animations waiting to be replaced; they're the final version.

---

## Search, Filter, Sort — The Full Suite

The search bar in the overlay is a proper M3 `SearchBar` with real-time filtering. Type anything and the list narrows to matching messages and tags instantly.

The filter sheet — accessible via the filter icon — lets you narrow by log level (Debug, Info, Error) or network status (Success, Error). Active filters trigger a small badge dot on the filter button that animates in with an `easeOutBack` spring curve. It's eight pixels of delight.

Sort order toggles between newest-first and oldest-first with an animated icon swap.

All three — search, filter, sort — compose correctly. Filtering by "Error" while searching for "Payment" while sorted oldest-first gives you exactly what you'd expect.

---

## The Architecture That Makes It Fast

The part most debug tools get wrong is performance. If your logging library is causing jank in your production-like build, it defeats the purpose.

`simple_logger_overlay` routes all file I/O through a background isolate:

```
SimpleLoggerOverlay.log(...)
    │
    ▼
LogStorageService          ← singleton, broadcast StreamController
    │
    ├─▶ Isolate (background)
    │       └─▶ writes JSONL to disk (non-blocking, zero main thread cost)
    │
    └─▶ stream.add(log)
                │
                ▼
        TabbedLogger widget   ← new card animates in via StreamSubscription
```

The main thread receives exactly one event per log — equivalent to a `ChangeNotifier` notify. The disk write happens in a spawned isolate, so even high-frequency logging (stress-tested with bursts of 50+ logs per second) produces no visible frame drops.

Logs are stored as JSONL (one JSON object per line), which means malformed or partial lines from a crash are skipped gracefully rather than corrupting the entire log file. Logs older than two days are purged automatically in the background on next app launch.

---

## Localization and Internationalization

If you're building for a global audience — and if you're reading a Flutter article in 2025, you probably are — the overlay inherits your app's locale automatically:

```dart
MaterialApp(
  localizationsDelegates: [
    SimpleOverlayLocalizations.delegate, // 👈
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
);
```

The package ships with English as default. Want Spanish, French, Arabic, German, Japanese? The example app includes a full reference implementation for all six. Extend `SimpleOverlayLocalizations`, override the ~25 string getters, register your delegate — every label in the overlay updates.

---

## Is It Safe in Production?

Yes, with the standard gate:

```dart
if (kDebugMode)
  SimpleOverlayDraggableDebuggerFAB(navigatorKey: navigatorKey)
```

`SimpleLoggerOverlay.log(...)` calls are always safe — they write to a local file that never leaves the device unless the user explicitly exports it. Only the visible FAB and overlay UI need gating behind `kDebugMode`.

The FAB renders in a `Stack` above your normal route hierarchy, completely decoupled from your navigation stack. It won't interfere with gestures, push routes, or back-button behaviour. It's not modifying your widget tree in any meaningful way.

---

## Getting Started Right Now

```bash
flutter pub add simple_logger_overlay
```

Then follow the three-step setup above. The full example app — with burst logging tests, BLoC integration, network request demo, live theme picker, and locale switcher — is in the [GitHub repo](https://github.com/sam829/simple_logger_overlay).

```dart
// The only API you need to remember
SimpleLoggerOverlay.log('your message', level: LogLevel.info, tag: 'YourTag');
```

---

## What's Next

The roadmap includes a few things I'm actively thinking about:

- **Log timeline view** — horizontal swimlane showing logs, network requests, and BLoC events on a shared time axis
- **Crash reporting hooks** — capture uncaught exceptions and `FlutterError` automatically
- **Remote log streaming** — WebSocket bridge so you can monitor a device's logs from your browser without a USB cable

The package is MIT licensed, pub.dev verified, and actively maintained. If you run into something broken or have a feature you'd actually use, [open an issue](https://github.com/sam829/simple_logger_overlay/issues).

---

*Print debugging had a good run. It's time to let it go.*

---

**pub.dev** → [simple_logger_overlay](https://pub.dev/packages/simple_logger_overlay)  
**GitHub** → [sam829/simple_logger_overlay](https://github.com/sam829/simple_logger_overlay)  
**Author** → [Saumya Macwan](https://www.linkedin.com/in/saumya-macwan-b650b91a1)

---

*If this saved you from a `print`-debugging session, the repo appreciates a ⭐*

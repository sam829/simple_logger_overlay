# simple_logger_overlay — Example App

Interactive showcase for the [`simple_logger_overlay`](https://pub.dev/packages/simple_logger_overlay) library.
Demonstrates every major feature: log levels, burst/drip firing, BLoC + Dio integration, and the full settings panel for live-testing the overlay's theming and localization.

---

## Running

```bash
cd example
fvm flutter run          # or: flutter run
```

Requires Flutter ≥ 3.19 (Material 3 `SearchBar`, `SegmentedButton`).

---

## Dashboard Sections

### Log Levels
Tap **Debug / Info / Error** cards to fire a single log at that level.
Open the overlay and watch the card slide in with M3 easing.

### Burst & Stress
| Tile | What it tests |
|---|---|
| **Fire 10 logs (mixed levels)** | Rapid live-insert into the log list |
| **Slow drip (1 log/sec × 5)** | FAB pulse animation · live append |

### Integrations — BLoC Example
Navigates to a screen that fetches a user list via Dio.
Logs both BLoC state transitions and the raw network request/response,
so you can see JSON pretty-printing and HTML response rendering in the overlay.

### Open Overlay
Direct button to open the logger overlay via `SimpleLoggerOverlay.show(...)`.

### Settings
Live controls that affect both the example app and the overlay simultaneously.

| Control | What it does |
|---|---|
| **Theme Mode** | `SegmentedButton` — System / Light / Dark |
| **Locale** | Bottom-sheet picker — English / Español / Français / العربية / Deutsch / 日本語 |
| **Seed Color** | Bottom-sheet grid of 12 preset swatches; tap to apply — overlay recolors immediately |

---

## How Settings Work

`AppSettings` is a `ChangeNotifier` held at app root (`appSettings` global in
`lib/app/simple_overlay_logger_app.dart`). When any value changes:

1. `SimpleLoggerOverlayConfig.configure(seedColor: ...)` is called, updating the
   overlay's Material You color scheme.
2. `MaterialApp` rebuilds with the new `themeMode`, `locale`, and seed-derived `ThemeData`.

Both the host app and the overlay always use the same seed — no separate
configuration step needed.

---

## Customizing the Seed in Your Own App

```dart
// Call once, before or after runApp — takes effect on next overlay open.
SimpleLoggerOverlayConfig.configure(seedColor: Colors.deepPurple);
```

---

## Project Structure

```
lib/
├── app/
│   ├── app_settings.dart               # ChangeNotifier: themeMode, seedColor, locale
│   └── simple_overlay_logger_app.dart  # Stateful root; syncs AppSettings → overlay config
├── router/
│   └── routes.dart                     # GoRouter config + typed routes
└── screens/
    ├── dashboard_screen.dart           # Main showcase screen
    └── bloc_user_list/                 # BLoC + Dio integration example
```

# simple_logger_overlay — Example App

Interactive showcase for the [`simple_logger_overlay`](https://pub.dev/packages/simple_logger_overlay) library.
Run it to test every feature: log firing, live streaming, BLoC + Dio integration, container-transform transitions, and the live settings panel for theming and localization.

---

## Running

```bash
cd example
fvm flutter run      # or: flutter run
```

Requires Flutter ≥ 3.19 (`SearchBar`, `SegmentedButton`, `SliverAppBar.large`).

---

## Dashboard Sections

### Log Levels
Tap **Debug / Info / Error** to fire a single log. Open the overlay and watch the card slide in with M3 emphasized-decelerate easing, then tap it to see the container-transform transition to the detail page.

### Burst & Stress
| Tile | Tests |
|---|---|
| Fire 10 logs (mixed levels) | Live list insert · entry animations |
| Slow drip (1 log/sec × 5) | FAB pulse · live append while overlay is open |

### Integrations — BLoC Example
Navigates to a screen that fetches users from `jsonplaceholder` via Dio.
Logs BLoC state transitions and the raw network request/response — shows JSON pretty-printing, per-field copy, and (if the response were HTML) the inline HTML renderer.

### Open Overlay
Direct `FilledButton` calling `SimpleLoggerOverlay.show(...)`.

### Settings
Live controls — both the example app and the overlay update immediately.

| Control | Details |
|---|---|
| **Theme Mode** | Full-width `SegmentedButton` — System / Light / Dark |
| **Dynamic Color** | Toggle on to use Android 12+ wallpaper-derived colors; disables seed picker |
| **Seed Color** | 12-swatch grid bottom sheet; tap any swatch — app and overlay recolor live |
| **Locale** | Bottom-sheet picker — English / Español / Français / العربية / Deutsch / 日本語 |

---

## How It Works

### Settings state

`AppSettings` (`lib/app/app_settings.dart`) is a `ChangeNotifier` stored in the global `appSettings` variable. When any value changes:

1. `SimpleLoggerOverlayConfig.configure(...)` is called to update the overlay's color scheme.
2. `_SimpleOverlayLoggerAppState` calls `setState`, rebuilding `MaterialApp.router` with the new `themeMode`, `locale`, and `ThemeData`.

### Dynamic color

`DynamicColorBuilder` wraps the `MaterialApp.router`. When `isDynamicTheme` is true and the device provides `lightDynamic`/`darkDynamic` schemes, those are passed directly to `SimpleLoggerOverlayConfig.configure(lightScheme:, darkScheme:)`. On devices/platforms without dynamic color, the toggle has no visible effect (graceful fallback to seed).

### Localization

`ExampleOverlayLocalizationsDelegate` (`lib/l10n/overlay_l10n.dart`) subclasses `SimpleOverlayLocalizations` for each supported locale and registers itself via `localizationsDelegates`. `shouldReload` returns `true` so the overlay reloads its strings when the locale picker changes the app locale.

---

## Customizing the Seed in Your Own App

```dart
// Anywhere — before or after runApp.
SimpleLoggerOverlayConfig.configure(seedColor: Colors.deepPurple);
```

---

## Project Structure

```
lib/
├── app/
│   ├── app_settings.dart               # ChangeNotifier — themeMode, seedColor, locale, isDynamicTheme
│   └── simple_overlay_logger_app.dart  # Stateful root; DynamicColorBuilder; syncs settings → overlay
├── l10n/
│   └── overlay_l10n.dart               # Translated SimpleOverlayLocalizations for es/fr/ar/de/ja
├── router/
│   └── routes.dart                     # GoRouter config + typed routes (build_runner generated)
└── screens/
    ├── dashboard_screen.dart           # Main showcase — log tiles, burst, integrations, settings
    └── bloc_user_list/                 # BLoC + Dio integration demo
```

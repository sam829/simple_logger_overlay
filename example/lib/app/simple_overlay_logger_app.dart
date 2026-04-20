import 'package:example/app/app_settings.dart';
import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

final appSettings = AppSettings();

class SimpleOverlayLoggerApp extends StatefulWidget {
  const SimpleOverlayLoggerApp({super.key});

  @override
  State<SimpleOverlayLoggerApp> createState() => _SimpleOverlayLoggerAppState();
}

class _SimpleOverlayLoggerAppState extends State<SimpleOverlayLoggerApp> {
  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    // Sync overlay seed color whenever settings change.
    SimpleLoggerOverlayConfig.configure(seedColor: appSettings.seedColor);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simple Overlay Logger Example',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light, appSettings.seedColor),
      darkTheme: _buildTheme(Brightness.dark, appSettings.seedColor),
      themeMode: appSettings.themeMode,
      locale: appSettings.locale,
      localizationsDelegates: const [
        SimpleOverlayLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
        Locale('de'),
        Locale('ja'),
      ],
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            SimpleOverlayDraggableDebuggerFAB(navigatorKey: rootNavigatorKey),
          ],
        );
      },
    );
  }
}

ThemeData _buildTheme(Brightness brightness, Color seed) {
  final base = GoogleFonts.interTextTheme(
    brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ),
    textTheme: base,
  );
}

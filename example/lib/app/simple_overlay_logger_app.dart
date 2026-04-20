import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';


class SimpleOverlayLoggerApp extends StatelessWidget {
  const SimpleOverlayLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simple Overlay Logger Example',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        // Overlay picks up this delegate; override SimpleOverlayLocalizations
        // in your own delegate to provide translated strings.
        SimpleOverlayLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
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

ThemeData _buildTheme(Brightness brightness) {
  // Blue-grey seed — neutral, IDE/terminal-friendly palette.
  // Works well in both light (clean surfaces) and dark (slate backgrounds).
  const seed = Color(0xFF546E7A); // Blue Grey 600

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ),
  );
}

import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';

class SimpleOverlayLoggerApp extends StatelessWidget {
  const SimpleOverlayLoggerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simple Overlay Logger Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routerConfig: router,
    );
  }
}

import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/ui/widgets/draggable_floating_overlay.dart';

class SimpleOverlayLoggerApp extends StatelessWidget {
  const SimpleOverlayLoggerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simple Overlay Logger Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
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

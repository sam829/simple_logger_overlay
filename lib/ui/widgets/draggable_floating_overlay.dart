import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

class SimpleOverlayDraggableDebuggerFAB extends StatefulWidget {
  const SimpleOverlayDraggableDebuggerFAB({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<SimpleOverlayDraggableDebuggerFAB> createState() =>
      _SimpleOverlayDraggableDebuggerFABState();
}

class _SimpleOverlayDraggableDebuggerFABState
    extends State<SimpleOverlayDraggableDebuggerFAB> {
  Offset offset = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            offset += details.delta;
          });
        },
        onTap: () {
          SimpleLoggerOverlay.show(context, navigatorKey: widget.navigatorKey);
        },
        child: Material(
          elevation: 8,
          shape: const CircleBorder(),
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Icon(Icons.bug_report, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

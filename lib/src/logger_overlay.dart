import 'package:flutter/material.dart';

import 'logger_core.dart';

class LoggerOverlay extends StatelessWidget {
  const LoggerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LoggerCore(),
      builder: (context, _) {
        final logs = LoggerCore().logs.reversed.toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.1,
          minChildSize: 0.05,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return Material(
              color: Colors.black.withOpacity(0.9),
              child: ListView.builder(
                controller: controller,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      "[${log.level.name.toUpperCase()}] ${log.message}",
                      style: TextStyle(
                        fontSize: 12,
                        color: _colorForLevel(log.level),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Color _colorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.white;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.redAccent;
    }
  }
}

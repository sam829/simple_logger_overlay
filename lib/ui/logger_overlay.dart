import 'package:flutter/material.dart';

import 'widgets/tabbed_logger.dart';

class LoggerOverlay extends StatelessWidget {
  const LoggerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Logger Overlay'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: const TabbedLogger(),
    );
  }
}

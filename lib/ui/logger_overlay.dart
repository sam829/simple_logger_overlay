import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/export_service.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                final path = await ExportService().exportLogsToFile();
                final result = await SharePlus.instance.share(
                    ShareParams(files: [XFile(path)], text: "Exported logs"));

                debugPrint(result.raw);
              } catch (error) {
                debugPrint(error.toString());
              }
            },
          ),
        ],
      ),
      body: const TabbedLogger(),
    );
  }
}

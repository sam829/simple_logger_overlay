import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/export_service.dart';
import '../core/log_storage_service.dart';
import '../core/simple_overlay_localizations.dart';
import 'widgets/tabbed_logger.dart';

class SimpleOverlayLoggerScreen extends StatefulWidget {
  const SimpleOverlayLoggerScreen({super.key});

  @override
  State<SimpleOverlayLoggerScreen> createState() =>
      _SimpleOverlayLoggerScreenState();
}

class _SimpleOverlayLoggerScreenState extends State<SimpleOverlayLoggerScreen> {
  int _logCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final storage = SimpleOverlayLogStorageService();
    final (simple, network) = await (
      storage.getSimpleLogs(),
      storage.getNetworkLogs(),
    ).wait;
    if (mounted) {
      setState(() => _logCount = simple.length + network.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SimpleOverlayLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.title),
            if (_logCount > 0)
              Text(
                l10n.entriesCount(_logCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.exportTooltip,
            onPressed: () => _exportAndShareLogs(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SimpleOverlayTabbedLogger(),
    );
  }

  Future<void> _exportAndShareLogs(BuildContext context) async {
    try {
      final path = await SimpleOverlayExportService().exportLogsToFile();
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: "Application Logs",
          subject: "Exported Logs",
        ),
      );
      debugPrint('Share result: ${result.raw}');
    } catch (error, stackTrace) {
      debugPrint('Error exporting logs: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

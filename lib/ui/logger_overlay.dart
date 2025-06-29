import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/export_service.dart';
import 'widgets/tabbed_logger.dart';

/// A full-screen overlay that displays application logs in a user-friendly interface.
///
/// This widget serves as the main entry point for viewing logs in the application.
/// It provides a tabbed interface for browsing different types of logs and includes
/// functionality to export logs for sharing or debugging purposes.
///
/// The overlay is designed to be displayed on top of the main application UI
/// and can be toggled using a gesture or button press (handled by the parent).
///
/// Example usage:
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     fullscreenDialog: true,
///     builder: (context) => const LoggerOverlay(),
///   ),
/// );
/// ```
class SimpleOverlayLoggerScreen extends StatelessWidget {
  /// Creates a new [SimpleOverlayLoggerScreen] instance.
  const SimpleOverlayLoggerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the current theme's surface color for consistent theming
    final theme = Theme.of(context);

    return Scaffold(
      // Match the app's surface color for a consistent look
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Logger Overlay'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // Share button to export logs
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export logs',
            onPressed: () => _exportAndShareLogs(context),
          ),
        ],
      ),
      // The main content is handled by the TabbedLogger widget
      body: const SimpleOverlayTabbedLogger(),
    );
  }

  /// Exports the current logs to a file and shares them using the platform's share dialog.
  ///
  /// This method:
  /// 1. Exports logs to a temporary file using [SimpleOverlayExportService]
  /// 2. Opens the platform's share dialog with the exported file
  /// 3. Handles any errors that occur during the process
  ///
  /// Errors are logged to the console but not shown to the user to avoid disrupting
  /// their workflow. In a production app, you might want to show a snackbar or dialog
  /// if the export fails.
  Future<void> _exportAndShareLogs(BuildContext context) async {
    try {
      // Export logs to a temporary file
      final path = await SimpleOverlayExportService().exportLogsToFile();

      // Share the exported file using the platform's share dialog
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: "Application Logs",
          subject: "Exported Logs",
        ),
      );

      // Log the result of the share operation (useful for debugging)
      debugPrint('Share result: ${result.raw}');
    } catch (error, stackTrace) {
      // Log any errors that occur during export or sharing
      debugPrint('Error exporting logs: $error');
      debugPrint('Stack trace: $stackTrace');

      // In a production app, you might want to show an error message to the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to export logs')),
      // );
    }
  }
}

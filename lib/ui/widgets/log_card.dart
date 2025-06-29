import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/core/utils/date_time_helper.dart';

import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import '../log_detail_page.dart';

/// A card widget that displays a log entry in a visually appealing way.
///
/// This widget can display either a [SimpleOverlayLog] or [SimpleOverlayNetworkLog] entry.
/// The appearance changes based on the log type and level/status:
/// - Simple logs show different colors based on their [LogLevel]
/// - Network logs show green for success and red for errors
///
/// Tapping on a card navigates to a detailed view of the log entry.
class SimpleOverlayLogCard extends StatelessWidget {
  /// The simple log entry to display, if any.
  ///
  /// Only one of [simple] or [network] should be non-null.
  final SimpleOverlayLog? simple;

  /// The network log entry to display, if any.
  ///
  /// Only one of [simple] or [network] should be non-null.
  final SimpleOverlayNetworkLog? network;

  /// Creates a [SimpleOverlayLogCard] that displays a [SimpleOverlayLog] entry.
  ///
  /// The [simple] parameter must not be null.
  const SimpleOverlayLogCard.simple({super.key, required this.simple})
      : network = null;

  /// Creates a [SimpleOverlayLogCard] that displays a [SimpleOverlayNetworkLog] entry.
  ///
  /// The [network] parameter must not be null.
  const SimpleOverlayLogCard.network({super.key, required this.network})
      : simple = null;

  @override
  Widget build(BuildContext context) {
    // Only one of simple or network should be non-null
    assert(
      (simple != null) ^ (network != null),
      'Exactly one of simple or network must be non-null',
    );
    if (simple != null) {
      final color = switch (simple!.level) {
        LogLevel.debug => Colors.blue,
        LogLevel.info => Colors.teal,
        LogLevel.error => Colors.red,
      };

      return Card(
        margin: const EdgeInsets.all(8),
        color: color.withValues(alpha: (255 * 0.2).roundToDouble()),
        child: ListTile(
          title: Text(simple!.message),
          subtitle: Text(
            formatTimestamp(simple!.timestamp),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Icon(
            _getLogLevelIcon(simple!.level),
            color: color,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SimpleOverlayLogDetailPage.simple(
                simple: simple,
              ),
            ),
          ),
        ),
      );
    } else if (network != null) {
      final color = network!.isSuccess ? Colors.green : Colors.red;

      return Card(
        margin: const EdgeInsets.all(8),
        color: color.withValues(alpha: (255 * 0.2).roundToDouble()),
        child: ListTile(
          title: Text('${network!.method} ${network!.url}'),
          subtitle: Text(
            formatTimestamp(network!.timestamp),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            '${network!.statusCode ?? 'ERR'}',
            style: TextStyle(color: color),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SimpleOverlayLogDetailPage.network(network: network!),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  /// Returns an appropriate icon for a given log level.
  ///
  /// Parameters:
  /// - [level]: The log level to get an icon for
  ///
  /// Returns:
  /// An [IconData] representing the log level:
  /// - debug: Bug report icon
  /// - info: Info icon
  /// - error: Error icon
  IconData _getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report_outlined;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }
}

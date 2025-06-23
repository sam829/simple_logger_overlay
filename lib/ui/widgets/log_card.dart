import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/core/utils/date_time_helper.dart';

import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import '../log_detail_page.dart';

class LogCard extends StatelessWidget {
  final SimpleLog? simple;
  final NetworkLog? network;

  const LogCard.simple({super.key, required this.simple}) : network = null;
  const LogCard.network({super.key, required this.network}) : simple = null;

  @override
  Widget build(BuildContext context) {
    if (simple != null) {
      final color = switch (simple!.level) {
        LogLevel.debug => Colors.blue,
        LogLevel.info => Colors.teal,
        LogLevel.error => Colors.red,
      };

      return Card(
        margin: const EdgeInsets.all(8),
        color: color.withValues(alpha: (255 * 0.4).roundToDouble()),
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
              builder: (_) => LogDetailPage.simple(
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
        color: color.withValues(alpha: (255 * 0.4).roundToDouble()),
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
              builder: (_) => LogDetailPage.network(network: network!),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

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

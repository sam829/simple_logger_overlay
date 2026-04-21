import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/core/simple_logger_overlay_config.dart';
import 'package:simple_logger_overlay/core/utils/date_time_helper.dart';

import '../../models/network_log.dart';
import '../../models/simple_log.dart';
import '../log_detail_page.dart';

class SimpleOverlayLogCard extends StatelessWidget {
  final SimpleOverlayLog? simple;
  final SimpleOverlayNetworkLog? network;

  const SimpleOverlayLogCard.simple({super.key, required this.simple})
    : network = null;

  const SimpleOverlayLogCard.network({super.key, required this.network})
    : simple = null;

  @override
  Widget build(BuildContext context) {
    assert(
      (simple != null) ^ (network != null),
      'Exactly one of simple or network must be non-null',
    );
    if (simple != null) return _buildSimpleCard(context);
    if (network != null) return _buildNetworkCard(context);
    return const SizedBox();
  }

  Widget _buildSimpleCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final textTheme = theme.textTheme;

    final (bg, fg, icon) = switch (simple!.level) {
      LogLevel.debug => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        Icons.bug_report_outlined,
      ),
      LogLevel.info => (
        cs.primaryContainer,
        cs.onPrimaryContainer,
        Icons.info_outline,
      ),
      LogLevel.error => (
        cs.errorContainer,
        cs.onErrorContainer,
        Icons.error_outline,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 450),
        closedColor: bg,
        openColor: cs.surface,
        closedElevation: 0,
        openElevation: 0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        openShape: const RoundedRectangleBorder(),
        openBuilder: (_, _) => Theme(
          data: SimpleLoggerOverlayConfig.instance.buildTheme(brightness),
          child: SimpleOverlayLogDetailPage.simple(simple: simple),
        ),
        closedBuilder: (_, openContainer) => InkWell(
          onTap: openContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        simple!.message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${simple!.tag} · ${formatTimestamp(simple!.timestamp)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: fg.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: fg.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brightness = theme.brightness;
    final textTheme = theme.textTheme;
    final isSuccess = network!.isSuccess;

    final bg = isSuccess ? cs.secondaryContainer : cs.errorContainer;
    final fg = isSuccess ? cs.onSecondaryContainer : cs.onErrorContainer;
    final statusCode = network!.statusCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 450),
        closedColor: bg,
        openColor: cs.surface,
        closedElevation: 0,
        openElevation: 0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        openShape: const RoundedRectangleBorder(),
        openBuilder: (_, _) => Theme(
          data: SimpleLoggerOverlayConfig.instance.buildTheme(brightness),
          child: SimpleOverlayLogDetailPage.network(network: network!),
        ),
        closedBuilder: (_, openContainer) => InkWell(
          onTap: openContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    network!.method,
                    style: textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network!.url,
                        style: textTheme.bodyMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatTimestamp(network!.timestamp),
                        style: textTheme.labelSmall?.copyWith(
                          color: fg.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${statusCode ?? 'ERR'}',
                    style: textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

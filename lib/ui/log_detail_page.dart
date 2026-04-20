import 'dart:convert' show json, JsonEncoder, jsonEncode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../core/simple_overlay_localizations.dart';
import '../core/utils/date_time_helper.dart';
import '../models/network_log.dart';
import '../models/simple_log.dart';

class SimpleOverlayLogDetailPage extends StatelessWidget {
  final SimpleOverlayLog? simple;
  final SimpleOverlayNetworkLog? network;

  const SimpleOverlayLogDetailPage.simple({super.key, required this.simple})
      : network = null;

  const SimpleOverlayLogDetailPage.network({super.key, required this.network})
      : simple = null;

  String _buildCopyableLogText() {
    if (simple != null) return jsonEncode(simple!.toJson());
    if (network != null) return jsonEncode(network!.toJson());
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSimpleLog = simple != null;

    final l10n = SimpleOverlayLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isSimpleLog ? l10n.logDetailTitle : l10n.networkLogDetailTitle),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l10n.copyTooltip,
            onPressed: () => _copyLog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isSimpleLog
            ? SimpleOverlayLogDetailContent.simple(simple: simple)
            : SimpleOverlayLogDetailContent.network(network: network!),
      ),
    );
  }

  void _copyLog(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _buildCopyableLogText()));
    final l10n = SimpleOverlayLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.copiedMessage)),
    );
  }
}

/// Embeddable content — used both in [SimpleOverlayLogDetailPage] and bottom sheets.
class SimpleOverlayLogDetailContent extends StatelessWidget {
  final SimpleOverlayLog? simple;
  final SimpleOverlayNetworkLog? network;
  final ScrollController? scrollController;

  const SimpleOverlayLogDetailContent.simple(
      {super.key, required this.simple, this.scrollController})
      : network = null;

  const SimpleOverlayLogDetailContent.network(
      {super.key, required this.network, this.scrollController})
      : simple = null;

  @override
  Widget build(BuildContext context) {
    if (simple != null) return _buildSimpleLogDetail(context);
    if (network != null) return _buildNetworkLogDetail(context);
    return const SizedBox();
  }

  Widget _buildSimpleLogDetail(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = SimpleOverlayLocalizations.of(context);
    final levelColor = switch (simple!.level) {
      LogLevel.debug => cs.tertiary,
      LogLevel.info => cs.primary,
      LogLevel.error => cs.error,
    };

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _levelBadge(context, simple!.level.name.toUpperCase(), levelColor),
        const SizedBox(height: 16),
        _section(context, l10n.labelTag, simple!.tag),
        _section(context, l10n.labelTimestamp, formatTimestamp(simple!.timestamp)),
        _section(context, l10n.labelMessage, simple!.message, monospace: true),
      ],
    );
  }

  Widget _buildNetworkLogDetail(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = SimpleOverlayLocalizations.of(context);
    final isSuccess = network!.isSuccess;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _statusChip(
              context,
              '${network!.statusCode ?? 'ERR'}',
              isSuccess ? cs.secondaryContainer : cs.errorContainer,
              isSuccess ? cs.onSecondaryContainer : cs.onErrorContainer,
            ),
            const SizedBox(width: 8),
            _methodChip(context, network!.method),
          ],
        ),
        const SizedBox(height: 16),
        _section(context, l10n.labelUrl, network!.url),
        _section(context, l10n.labelTimestamp, formatTimestamp(network!.timestamp)),
        _section(
          context,
          l10n.labelRequestHeaders,
          _prettyPrintJsonFromMap(network!.requestHeaders),
          monospace: true,
        ),
        _section(
          context,
          l10n.labelRequestBody,
          _prettyPrintJsonFromString(network!.requestBody),
          monospace: true,
        ),
        if (network!.responseHeaders != null)
          _section(
            context,
            l10n.labelResponseHeaders,
            _prettyPrintJsonFromMap(network!.responseHeaders ?? {}),
            monospace: true,
          ),
        if (network!.responseBody != null)
          _responseBodySection(context, l10n, network!.responseBody!),
      ],
    );
  }

  Widget _responseBodySection(
      BuildContext context, SimpleOverlayLocalizations l10n, String body) {
    final contentType = _detectContentType(body);
    switch (contentType) {
      case _ContentType.json:
        return _section(
          context,
          l10n.labelResponseBody,
          _prettyPrintJsonFromString(body),
          monospace: true,
        );
      case _ContentType.html:
        return _htmlSection(context, l10n, body);
      case _ContentType.plain:
        return _section(context, l10n.labelResponseBody, body);
    }
  }

  Widget _htmlSection(
      BuildContext context, SimpleOverlayLocalizations l10n, String html) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.labelResponseBody,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'HTML',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onTertiaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 18),
              tooltip: 'Copy',
              onPressed: () => _copyToClipboard(context, html),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            html,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _levelBadge(
      BuildContext context, String label, Color backgroundColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: backgroundColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: backgroundColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _statusChip(
      BuildContext context, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _methodChip(BuildContext context, String method) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        method,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String content,
      {bool monospace = false}) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 18),
              tooltip: 'Copy',
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: () => _copyToClipboard(context, content),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: monospace ? 'monospace' : null,
              color: cs.onSurface,
            ),
          ),
        )
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _prettyPrintJsonFromMap(Map<String, String> input) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(input);
    } catch (_) {
      return input.toString();
    }
  }

  String _prettyPrintJsonFromString(String input) {
    if (input.isEmpty) return input;
    try {
      final decoded = json.decode(input);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return input;
    }
  }

  _ContentType _detectContentType(String input) {
    if (input.isEmpty) return _ContentType.plain;
    final trimmed = input.trimLeft();
    // JSON detection
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        json.decode(input);
        return _ContentType.json;
      } catch (_) {}
    }
    // HTML detection
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('<!doctype html') ||
        lower.startsWith('<html') ||
        (lower.contains('<body') && lower.contains('<head'))) {
      return _ContentType.html;
    }
    return _ContentType.plain;
  }
}

enum _ContentType { json, html, plain }

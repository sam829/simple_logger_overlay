import 'package:flutter/material.dart';

import '../models/network_log.dart';
import '../models/simple_log.dart';

class LogDetailPage extends StatelessWidget {
  final SimpleLog? simple;
  final NetworkLog? network;

  const LogDetailPage.simple({super.key, required this.simple})
      : network = null;
  const LogDetailPage.network({super.key, required this.network})
      : simple = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(simple != null ? 'Log Detail' : 'Network Log Detail'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: simple != null
            ? _buildSimpleLogDetail(context)
            : _buildNetworkLogDetail(context),
      ),
    );
  }

  Widget _buildSimpleLogDetail(BuildContext context) {
    return ListView(
      children: [
        _section("Tag", simple!.tag),
        _section("Level", simple!.level.name),
        _section("Timestamp", simple!.timestamp.toIso8601String()),
        _section("Message", simple!.message, monospace: true),
      ],
    );
  }

  Widget _buildNetworkLogDetail(BuildContext context) {
    return ListView(
      children: [
        _section("Method", network!.method),
        _section("URL", network!.url),
        _section("Status Code", '${network!.statusCode ?? 'ERROR'}'),
        _section("Timestamp", network!.timestamp.toIso8601String()),
        _section("Request Headers", network!.requestHeaders.toString(),
            monospace: true),
        _section("Request Body", network!.requestBody, monospace: true),
        if (network!.responseHeaders != null)
          _section("Response Headers", network!.responseHeaders.toString(),
              monospace: true),
        if (network!.responseBody != null)
          _section("Response Body", network!.responseBody!, monospace: true),
      ],
    );
  }

  Widget _section(String title, String content, {bool monospace = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontFamily: monospace ? 'monospace' : null,
              fontSize: 14,
            ),
          ),
        )
      ],
    );
  }
}

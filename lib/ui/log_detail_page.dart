import 'dart:convert' show json, JsonEncoder, jsonEncode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../core/utils/date_time_helper.dart';
import '../models/network_log.dart';
import '../models/simple_log.dart';

class LogDetailPage extends StatelessWidget {
  final SimpleLog? simple;
  final NetworkLog? network;

  const LogDetailPage.simple({super.key, required this.simple})
      : network = null;
  const LogDetailPage.network({super.key, required this.network})
      : simple = null;

  String _buildCopyableLogText() {
    if (simple != null) {
      return jsonEncode(simple!.toJson());
    } else if (network != null) {
      return jsonEncode(network!.toJson());
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(simple != null ? 'Log Detail' : 'Network Log Detail'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            tooltip: "Copy Log to Clipboard",
            onPressed: () {
              final content = _buildCopyableLogText();
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Log copied to clipboard")),
              );
            },
          ),
        ],
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
        _section("Timestamp", formatTimestamp(simple!.timestamp)),
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
        _section("Timestamp", formatTimestamp(network!.timestamp)),
        _section(
            "Request Headers", _prettyPrintJsonFromMap(network!.requestHeaders),
            monospace: true),
        _section(
            "Request Body", _prettyPrintJsonFromString(network!.requestBody),
            monospace: true),
        if (network!.responseHeaders != null)
          _section("Response Headers",
              _prettyPrintJsonFromMap(network!.responseHeaders ?? {}),
              monospace: true),
        if (network!.responseBody != null)
          _section("Response Body",
              _prettyPrintJsonFromString(network!.responseBody!),
              monospace: true),
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

  String _prettyPrintJsonFromMap(Map<String, String> input) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(input);
    } catch (e) {
      return input.toString(); // fallback to raw if not JSON
    }
  }

  String _prettyPrintJsonFromString(String input) {
    try {
      final decoded = json.decode(input);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (e) {
      return input; // fallback to raw if not JSON
    }
  }
}

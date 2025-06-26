import 'dart:convert' show json, JsonEncoder, jsonEncode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../core/utils/date_time_helper.dart';
import '../models/network_log.dart';
import '../models/simple_log.dart';

/// A page that displays detailed information about a log entry.
///
/// This widget can display either a [SimpleLog] or [NetworkLog] in a user-friendly format.
/// It provides a detailed view of all log properties and allows copying the raw log data.
///
/// The page automatically adapts its layout based on the type of log being displayed.
/// For network logs, it shows request/response details including headers and bodies.
class LogDetailPage extends StatelessWidget {
  /// The simple log entry to display, if any.
  ///
  /// Only one of [simple] or [network] should be non-null.
  final SimpleLog? simple;

  /// The network log entry to display, if any.
  ///
  /// Only one of [simple] or [network] should be non-null.
  final NetworkLog? network;

  /// Creates a detail page for a [SimpleLog] entry.
  ///
  /// The [simple] parameter must not be null.
  const LogDetailPage.simple({super.key, required this.simple})
      : network = null;

  /// Creates a detail page for a [NetworkLog] entry.
  ///
  /// The [network] parameter must not be null.
  const LogDetailPage.network({super.key, required this.network})
      : simple = null;

  /// Creates a JSON string representation of the current log entry.
  ///
  /// This is used when copying the log to clipboard. The output is a pretty-printed
  /// JSON string that includes all log properties.
  ///
  /// Returns:
  /// A JSON string representation of the log, or an empty string if no log is available.
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
    final isSimpleLog = simple != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSimpleLog ? 'Log Detail' : 'Network Log Detail'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          // Copy button to copy the raw JSON of the log
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: "Copy Log to Clipboard",
            onPressed: () {
              final content = _buildCopyableLogText();
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Log copied to clipboard")),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isSimpleLog
            ? _buildSimpleLogDetail(context)
            : _buildNetworkLogDetail(context),
      ),
    );
  }

  /// Builds the detail view for a simple log entry.
  ///
  /// Displays the log's tag, level, timestamp, and message in a scrollable list.
  /// The message is shown in a monospace font for better readability of any
  /// code or structured data it might contain.
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

  /// Builds the detail view for a network log entry.
  ///
  /// Displays the network request/response details including:
  /// - Method, URL, and status code
  /// - Timestamp
  /// - Request headers and body (if available)
  /// - Response headers and body (if available)
  ///
  /// All JSON data is pretty-printed for better readability.
  Widget _buildNetworkLogDetail(BuildContext context) {
    return ListView(
      children: [
        _section("Method", network!.method),
        _section("URL", network!.url),
        _section("Status Code", '${network!.statusCode ?? 'ERROR'}'),
        _section("Timestamp", formatTimestamp(network!.timestamp)),

        // Request details
        _section(
          "Request Headers",
          _prettyPrintJsonFromMap(network!.requestHeaders),
          monospace: true,
        ),
        _section(
          "Request Body",
          _prettyPrintJsonFromString(network!.requestBody),
          monospace: true,
        ),

        // Response details (only if available)
        if (network!.responseHeaders != null)
          _section(
            "Response Headers",
            _prettyPrintJsonFromMap(network!.responseHeaders ?? {}),
            monospace: true,
          ),
        if (network!.responseBody != null)
          _section(
            "Response Body",
            _prettyPrintJsonFromString(network!.responseBody!),
            monospace: true,
          ),
      ],
    );
  }

  /// Creates a section widget with a title and content.
  ///
  /// Used to consistently format different sections of the log detail view.
  /// The content is displayed in a light gray container with rounded corners.
  ///
  /// Parameters:
  /// - [title]: The section heading
  /// - [content]: The content to display
  /// - [monospace]: Whether to use a monospace font (useful for code/JSON)
  Widget _section(String title, String content, {bool monospace = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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

  /// Converts a map to a pretty-printed JSON string.
  ///
  /// If the conversion fails, falls back to the default string representation.
  ///
  /// Parameters:
  /// - [input]: The map to convert to JSON
  ///
  /// Returns:
  /// A formatted JSON string, or the string representation of the input if conversion fails.
  String _prettyPrintJsonFromMap(Map<String, String> input) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(input);
    } catch (e) {
      return input.toString(); // fallback to raw if not JSON
    }
  }

  /// Converts a JSON string to a pretty-printed format.
  ///
  /// If the input is not valid JSON, returns it unchanged.
  ///
  /// Parameters:
  /// - [input]: The JSON string to format
  ///
  /// Returns:
  /// A formatted JSON string, or the original string if it's not valid JSON.
  String _prettyPrintJsonFromString(String input) {
    if (input.isEmpty) return input;

    try {
      final decoded = json.decode(input);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (e) {
      return input; // fallback to raw if not JSON
    }
  }
}

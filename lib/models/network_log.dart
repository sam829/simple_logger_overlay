import 'base_log.dart';

/// Represents a network request/response log entry
/// This class extends BaseLog and adds specific fields for network operations
///
/// Properties:
/// - method: HTTP method used (GET, POST, etc.)
/// - url: The request URL
/// - requestHeaders: Map of request headers
/// - requestBody: Request payload/body
/// - statusCode: Response status code (optional)
/// - responseHeaders: Map of response headers (optional)
/// - responseBody: Response payload/body (optional)
/// - isSuccess: Boolean indicating if the request was successful
/// - timestamp: When the log was created
/// - tag: Identifier for the log entry
///
/// Example usage:
/// ```dart
/// NetworkLog(
///   timestamp: DateTime.now(),
///   tag: 'API_CALL',
///   method: 'GET',
///   url: 'https://api.example.com/data',
///   requestHeaders: {'Content-Type': 'application/json'},
///   requestBody: '',
///   isSuccess: true
/// );
/// ```
class SimpleOverlayNetworkLog extends SimpleOverlayBaseLog {
  /// HTTP method used for the request (GET, POST, etc.)
  final String method;

  /// The URL that was requested
  final String url;

  /// Map of headers sent with the request
  final Map<String, String> requestHeaders;

  /// Request body/payload sent to the server
  final String requestBody;

  /// Response status code from the server (optional)
  final int? statusCode;

  /// Map of headers received in the response (optional)
  final Map<String, String>? responseHeaders;

  /// Response body/payload received from the server (optional)
  final String? responseBody;

  /// Indicates if the network request was successful
  final bool isSuccess;

  /// Creates a new NetworkLog instance
  ///
  /// All required parameters must be provided. Optional parameters
  /// (statusCode, responseHeaders, responseBody) can be null if not available.
  SimpleOverlayNetworkLog({
    required super.timestamp,
    required super.tag,
    required this.method,
    required this.url,
    required this.requestHeaders,
    required this.requestBody,
    this.statusCode,
    this.responseHeaders,
    this.responseBody,
    required this.isSuccess,
  });

  /// Converts the NetworkLog instance to a JSON Map
  ///
  /// Returns a Map containing all the log information in a format
  /// that can be easily serialized to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'tag': tag,
        'method': method,
        'url': url,
        'requestHeaders': requestHeaders,
        'requestBody': requestBody,
        'statusCode': statusCode,
        'responseHeaders': responseHeaders,
        'responseBody': responseBody,
        'isSuccess': isSuccess,
        'type': 'network',
      };

  /// Creates a NetworkLog instance from a JSON Map
  ///
  /// This is the inverse operation of toJson(). It takes a Map containing
  /// serialized log information and creates a NetworkLog instance from it.
  ///
  /// Parameters:
  /// - json: Map containing the serialized log data
  ///
  /// Returns:
  /// A new NetworkLog instance populated with the deserialized data
  static SimpleOverlayNetworkLog fromJson(Map<String, dynamic> json) =>
      SimpleOverlayNetworkLog(
        timestamp: DateTime.parse(json['timestamp']),
        tag: json['tag'],
        method: json['method'],
        url: json['url'],
        requestHeaders: Map<String, String>.from(json['requestHeaders']),
        requestBody: json['requestBody'],
        statusCode: json['statusCode'],
        responseHeaders: json['responseHeaders'] != null
            ? Map<String, String>.from(json['responseHeaders'])
            : null,
        responseBody: json['responseBody'],
        isSuccess: json['isSuccess'],
      );
}

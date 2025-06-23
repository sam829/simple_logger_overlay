import 'base_log.dart';

class NetworkLog extends BaseLog {
  final String method;
  final String url;
  final Map<String, String> requestHeaders;
  final String requestBody;
  final int? statusCode;
  final Map<String, String>? responseHeaders;
  final String? responseBody;
  final bool isSuccess;

  NetworkLog({
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

  static NetworkLog fromJson(Map<String, dynamic> json) => NetworkLog(
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

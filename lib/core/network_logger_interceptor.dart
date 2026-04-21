import 'dart:convert' show jsonEncode;

import 'package:dio/dio.dart';

import '../models/network_log.dart';
import 'log_storage_service.dart';

/// Dio interceptor that captures and stores network requests/responses.
///
/// Attach to your Dio instance:
/// ```dart
/// dio.interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
/// ```
class SimpleOverlayNetworkLoggerInterceptor extends Interceptor {
  final SimpleOverlayLogStorageService _storageService =
      SimpleOverlayLogStorageService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.extra['startTime'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final request = response.requestOptions;
    final startTime = request.extra['startTime'] as DateTime?;
    final timestamp = startTime ?? DateTime.now();

    final log = SimpleOverlayNetworkLog(
      timestamp: timestamp,
      tag: request.path,
      method: request.method,
      url: request.uri.toString(),
      requestHeaders: Map<String, String>.from(
        request.headers.map((k, v) => MapEntry(k, v.toString())),
      ),
      requestBody: _bodyToString(request.data),
      statusCode: response.statusCode,
      responseHeaders: response.headers.map.map(
        (k, v) => MapEntry(k, v.join(',')),
      ),
      responseBody: _bodyToString(response.data),
      isSuccess: response.statusCode != null && response.statusCode! < 400,
    );

    await _storageService.addNetworkLog(log);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final startTime = request.extra['startTime'] as DateTime?;
    final timestamp = startTime ?? DateTime.now();

    final log = SimpleOverlayNetworkLog(
      timestamp: timestamp,
      tag: request.path,
      method: request.method,
      url: request.uri.toString(),
      requestHeaders: Map<String, String>.from(
        request.headers.map((k, v) => MapEntry(k, v.toString())),
      ),
      requestBody: _bodyToString(request.data),
      statusCode: err.response?.statusCode,
      responseHeaders: err.response?.headers.map.map(
        (k, v) => MapEntry(k, v.join(',')),
      ),
      responseBody: _bodyToString(err.response?.data),
      isSuccess: false,
    );

    await _storageService.addNetworkLog(log);
    handler.next(err);
  }

  /// Dio auto-decodes JSON responses to Map/List. Storing as .toString() produces
  /// Dart Map literals (not valid JSON). Re-encode to proper JSON string.
  static String _bodyToString(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}

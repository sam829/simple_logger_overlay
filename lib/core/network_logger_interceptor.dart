import 'package:dio/dio.dart';

import '../models/network_log.dart';
import 'log_storage_service.dart';

/// Dio interceptor that captures and stores network requests/responses.
///
/// Automatically logs:
/// - request headers/body
/// - response headers/body
/// - success/failure color
///
/// Attach to your Dio instance:
/// ```dart
/// dio.interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
/// ```
class SimpleOverlayNetworkLoggerInterceptor extends Interceptor {
  final LogStorageService _storageService = LogStorageService();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.extra['startTime'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final request = response.requestOptions;
    final startTime = request.extra['startTime'] as DateTime?;
    final timestamp = startTime ?? DateTime.now();

    final log = NetworkLog(
      timestamp: timestamp,
      tag: request.path,
      method: request.method,
      url: request.uri.toString(),
      requestHeaders: Map<String, String>.from(
          request.headers.map((k, v) => MapEntry(k, v.toString()))),
      requestBody: request.data.toString(),
      statusCode: response.statusCode,
      responseHeaders:
          response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
      responseBody: response.data.toString(),
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

    final log = NetworkLog(
      timestamp: timestamp,
      tag: request.path,
      method: request.method,
      url: request.uri.toString(),
      requestHeaders: Map<String, String>.from(
          request.headers.map((k, v) => MapEntry(k, v.toString()))),
      requestBody: request.data.toString(),
      statusCode: err.response?.statusCode,
      responseHeaders:
          err.response?.headers.map.map((k, v) => MapEntry(k, v.join(','))),
      responseBody: err.response?.data.toString(),
      isSuccess: false,
    );

    await _storageService.addNetworkLog(log);
    handler.next(err);
  }
}

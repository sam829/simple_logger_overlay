import 'package:dio/dio.dart';
import 'package:simple_logger_overlay/core/network_logger_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com/',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    )..interceptors.add(SimpleOverlayNetworkLoggerInterceptor());
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'browser_http_adapter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'auth_interceptor.dart';
import 'endpoints.dart';

class DioProvider {
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    if (kIsWeb) {
      final adapter = createBrowserAdapter();
      if (adapter != null) {
        dio.httpClientAdapter = adapter as dynamic;
      }
    }

    dio.interceptors.addAll([
      AuthInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
      ),
    ]);

    return dio;
  }

  static Dio get dio => _dio;
}

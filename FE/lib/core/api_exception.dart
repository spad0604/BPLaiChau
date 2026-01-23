import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';

  static ApiException fromDioError(DioError err) {
    if (err.type == DioErrorType.badResponse && err.response != null) {
      final data = err.response!.data;
      if (data is Map && data['message'] != null)
        return ApiException(data['message'].toString());
      return ApiException('HTTP ${err.response!.statusCode}');
    }
    if (err.type == DioErrorType.connectionTimeout ||
        err.type == DioErrorType.receiveTimeout) {
      return ApiException('Connection timed out');
    }
    return ApiException(err.message ?? 'Unknown network error');
  }
}

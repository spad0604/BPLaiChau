import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';

  static ApiException fromDioException(DioException err) {
    if (err.type == DioExceptionType.badResponse && err.response != null) {
      final data = err.response!.data;
      if (data is Map && data['message'] != null) {
        return ApiException(data['message'].toString());
      }
      return ApiException('HTTP ${err.response!.statusCode}');
    }
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return ApiException('Connection timed out');
    }
    return ApiException(err.message ?? 'Unknown network error');
  }
}

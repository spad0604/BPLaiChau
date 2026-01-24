import 'package:dio/dio.dart';
import '../core/dio_provider.dart';
import '../core/api_exception.dart';

class ApiService {
  final Dio _dio;

  ApiService([Dio? dio]) : _dio = dio ?? DioProvider.dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final r = await _dio.get(path, queryParameters: query);
      return r.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> post(String path, dynamic data) async {
    try {
      final r = await _dio.post(path, data: data);
      return r.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> postFormUrlEncoded(String path, Map<String, dynamic> data) async {
    try {
      final r = await _dio.post(
        path,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return r.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> put(String path, dynamic data) async {
    try {
      final r = await _dio.put(path, data: data);
      return r.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final r = await _dio.delete(path);
      return r.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> postMultipart(String path, FormData formData) async {
    try {
      final r = await _dio.post(path, data: formData);
      return r.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

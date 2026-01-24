import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../core/endpoints.dart';

class BannerRepository {
  final ApiService api;
  BannerRepository(this.api);

  Future<List<Map<String, dynamic>>> list() async {
    final res = await api.get(Endpoints.banners);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final items = (payload is Map) ? (payload['items'] ?? []) : [];
    return (items as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> upload({required PlatformFile file, String bannerTitle = ''}) async {
    final parts = <MultipartFile>[];
    if (file.bytes != null) {
      parts.add(MultipartFile.fromBytes(file.bytes!, filename: file.name));
    } else if (file.path != null) {
      parts.add(await MultipartFile.fromFile(file.path!, filename: file.name));
    }
    if (parts.isEmpty) return null;

    // Backend expects single file field name: "file" (not "files")
    final form = FormData.fromMap({
      'file': parts.first,
      'banner_title': bannerTitle,
    });

    final res = await api.postMultipart(Endpoints.banners, form);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    if (payload is Map && payload['banner'] is Map) {
      return Map<String, dynamic>.from(payload['banner']);
    }
    return null;
  }

  Future<bool> delete(String bannerId) async {
    final path = Endpoints.bannerById.replaceFirst('{id}', bannerId);
    final res = await api.delete(path);
    if (res is Map && res['status'] != null) {
      return res['status'] == 200 || res['status'] == '200';
    }
    return true;
  }
}

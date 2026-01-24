import '../services/api_service.dart';
import '../core/endpoints.dart';

class AdminRepository {
  final ApiService api;
  AdminRepository(this.api);

  Future<List<Map<String, dynamic>>> listPublicAdmins() async {
    final res = await api.get(Endpoints.adminListPublic);
    // BE returns a plain list of dicts for this endpoint
    if (res is List) return List<Map<String, dynamic>>.from(res);
    // fallback: check inside data
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final items = payload is List ? payload : (payload['items'] ?? []);
    return List<Map<String, dynamic>>.from(items);
  }

  Future<Map<String, dynamic>?> createAdmin(
    Map<String, dynamic> userCreate,
  ) async {
    final res = await api.post(Endpoints.adminCreate, userCreate);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    return (data is Map) ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> updateAdmin(
    String username,
    Map<String, dynamic> updates,
  ) async {
    final path = Endpoints.adminByUsername.replaceFirst(
      '{username}',
      username,
    );
    final res = await api.put(path, updates);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    return (data is Map) ? Map<String, dynamic>.from(data) : null;
  }

  Future<bool> deleteAdmin(String username) async {
    final path = Endpoints.adminByUsername.replaceFirst(
      '{username}',
      username,
    );
    final res = await api.delete(path);
    if (res is Map && res['status'] != null) {
      return res['status'] == 200 || res['status'] == '200';
    }
    return true;
  }
}

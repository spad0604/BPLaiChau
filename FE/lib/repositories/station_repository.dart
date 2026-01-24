import '../core/endpoints.dart';
import '../models/station_model.dart';
import '../services/api_service.dart';

class StationRepository {
  final ApiService api;
  StationRepository(this.api);

  Future<List<StationModel>> list() async {
    final res = await api.get(Endpoints.stationList);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final items = (payload is Map ? (payload['items'] ?? []) : []) as List;
    return items.map((e) => StationModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<StationModel?> create(Map<String, dynamic> payload) async {
    final res = await api.post(Endpoints.stationList, payload);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    final station = (data is Map) ? data['station'] : null;
    if (station == null) return null;
    return StationModel.fromJson(Map<String, dynamic>.from(station));
  }

  Future<StationModel?> update(String id, Map<String, dynamic> updates) async {
    final path = Endpoints.stationById.replaceFirst('{id}', id);
    final res = await api.put(path, updates);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    final station = (data is Map) ? data['station'] : null;
    if (station == null) return null;
    return StationModel.fromJson(Map<String, dynamic>.from(station));
  }

  Future<bool> delete(String id) async {
    final path = Endpoints.stationById.replaceFirst('{id}', id);
    final res = await api.delete(path);
    if (res is Map && res['status'] != null) {
      return res['status'] == 200 || res['status'] == '200';
    }
    return true;
  }
}

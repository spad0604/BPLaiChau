import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../core/endpoints.dart';
import '../models/incident_model.dart';

class IncidentRepository {
  final ApiService api;
  IncidentRepository(this.api);

  Future<List<IncidentModel>> list({String stationId = '', int year = 0, String status = '', String title = ''}) async {
    final query = <String, dynamic>{};
    if (stationId.isNotEmpty) query['station_id'] = stationId;
    if (year > 0) query['year'] = year;
    if (status.isNotEmpty) query['status'] = status;
    if (title.trim().isNotEmpty) query['title'] = title.trim();

    final res = await api.get(Endpoints.incidentList, query: query.isEmpty ? null : query);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final items = payload['items'] ?? [];
    return (items as List)
        .map((e) => IncidentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> stats({String stationId = '', int year = 0, String title = ''}) async {
    final query = <String, dynamic>{};
    if (stationId.isNotEmpty) query['station_id'] = stationId;
    if (year > 0) query['year'] = year;
    if (title.trim().isNotEmpty) query['title'] = title.trim();

    final res = await api.get(Endpoints.incidentStats, query: query.isEmpty ? null : query);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return {};
  }

  Future<IncidentModel?> get(String id) async {
    final path = Endpoints.incidentById.replaceFirst('{id}', id);
    final res = await api.get(path);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final incident = payload['incident'];
    if (incident == null) return null;
    return IncidentModel.fromJson(Map<String, dynamic>.from(incident));
  }

  Future<IncidentModel?> create(Map<String, dynamic> payload) async {
    final res = await api.post(Endpoints.incidentReport, payload);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    final incident = data['incident'];
    if (incident == null) return null;
    return IncidentModel.fromJson(Map<String, dynamic>.from(incident));
  }

  Future<IncidentModel?> update(String id, Map<String, dynamic> updates) async {
    final path = Endpoints.incidentById.replaceFirst('{id}', id);
    final res = await api.put(path, updates);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    final incident = data['incident'];
    if (incident == null) return null;
    return IncidentModel.fromJson(Map<String, dynamic>.from(incident));
  }

  Future<bool> delete(String id) async {
    final path = Endpoints.incidentById.replaceFirst('{id}', id);
    final res = await api.delete(path);
    if (res is Map && res['status'] != null) {
      return res['status'] == 200 || res['status'] == '200';
    }
    return true;
  }

  /// Upload multiple files to an incident. `filePaths` are absolute paths.
  Future<List<String>> uploadEvidence(String id, List<String> filePaths) async {
    final path = Endpoints.incidentEvidence.replaceFirst('{id}', id);
    final files = <MultipartFile>[];
    for (final p in filePaths) {
      files.add(await MultipartFile.fromFile(p));
    }

    final form = FormData.fromMap({'files': files});
    final res = await api.postMultipart(path, form);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    // backend returns BaseResponse with data possibly containing incident
    if (data == null) return [];
    if (data is Map && data['incident'] != null) {
      final incident = data['incident'];
      return (incident['evidence'] is List)
          ? List<String>.from(incident['evidence'])
          : [];
    }
    return [];
  }

  /// Upload multiple picked files (web/desktop compatible).
  Future<List<String>> uploadEvidenceFiles(String id, List<PlatformFile> files) async {
    final path = Endpoints.incidentEvidence.replaceFirst('{id}', id);
    final parts = <MultipartFile>[];

    for (final f in files) {
      if (f.bytes != null) {
        parts.add(MultipartFile.fromBytes(f.bytes!, filename: f.name));
      } else if (f.path != null) {
        parts.add(await MultipartFile.fromFile(f.path!, filename: f.name));
      }
    }

    if (parts.isEmpty) return [];

    final form = FormData.fromMap({'files': parts});
    final res = await api.postMultipart(path, form);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    if (data == null) return [];
    if (data is Map && data['incident'] != null) {
      final incident = data['incident'];
      return (incident['evidence'] is List) ? List<String>.from(incident['evidence']) : [];
    }
    return [];
  }
}

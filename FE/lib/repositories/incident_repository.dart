import 'dart:io';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../core/endpoints.dart';
import '../models/incident_model.dart';

class IncidentRepository {
  final ApiService api;
  IncidentRepository(this.api);

  Future<List<IncidentModel>> list() async {
    final res = await api.get(Endpoints.INCIDENT_LIST);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final items = payload['items'] ?? [];
    return (items as List)
        .map((e) => IncidentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<IncidentModel?> get(String id) async {
    final path = Endpoints.INCIDENT_BY_ID.replaceFirst('{id}', id);
    final res = await api.get(path);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final incident = payload['incident'];
    if (incident == null) return null;
    return IncidentModel.fromJson(Map<String, dynamic>.from(incident));
  }

  Future<IncidentModel?> create(Map<String, dynamic> payload) async {
    final res = await api.post(Endpoints.INCIDENT_REPORT, payload);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    final incident = data['incident'];
    if (incident == null) return null;
    return IncidentModel.fromJson(Map<String, dynamic>.from(incident));
  }

  Future<IncidentModel?> update(String id, Map<String, dynamic> updates) async {
    final path = Endpoints.INCIDENT_BY_ID.replaceFirst('{id}', id);
    final res = await api.put(path, updates);
    final data = (res is Map && res['data'] != null) ? res['data'] : res;
    final incident = data['incident'];
    if (incident == null) return null;
    return IncidentModel.fromJson(Map<String, dynamic>.from(incident));
  }

  Future<bool> delete(String id) async {
    final path = Endpoints.INCIDENT_BY_ID.replaceFirst('{id}', id);
    final res = await api.delete(path);
    if (res is Map && res['status'] != null)
      return res['status'] == 200 || res['status'] == '200';
    return true;
  }

  /// Upload multiple files to an incident. `filePaths` are absolute paths.
  Future<List<String>> uploadEvidence(String id, List<String> filePaths) async {
    final path = Endpoints.INCIDENT_EVIDENCE.replaceFirst('{id}', id);
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
}

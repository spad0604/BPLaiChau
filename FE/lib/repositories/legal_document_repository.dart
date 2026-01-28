import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/endpoints.dart';
import '../core/token_storage.dart';
import '../models/legal_document_model.dart';

class LegalDocumentRepository {
  Future<List<LegalDocumentModel>> getAll() async {
    final token = TokenStorage.instance.token;
    final response = await http.get(
      Uri.parse('${Endpoints.baseUrl}${Endpoints.legalDocuments}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = (data['data']?['items'] as List?) ?? [];
      return items.map((e) => LegalDocumentModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load legal documents');
  }

  Future<LegalDocumentModel> getById(String id) async {
    final token = TokenStorage.instance.token;
    final url = Endpoints.legalDocumentById.replaceAll('{id}', id);
    final response = await http.get(
      Uri.parse('${Endpoints.baseUrl}$url'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LegalDocumentModel.fromJson(data['data']['document']);
    }
    throw Exception('Failed to load document');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final token = TokenStorage.instance.token;
    final response = await http.post(
      Uri.parse('${Endpoints.baseUrl}${Endpoints.legalDocuments}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create document');
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final token = TokenStorage.instance.token;
    final url = Endpoints.legalDocumentById.replaceAll('{id}', id);
    final response = await http.put(
      Uri.parse('${Endpoints.baseUrl}$url'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update document');
  }

  Future<void> delete(String id) async {
    final token = TokenStorage.instance.token;
    final url = Endpoints.legalDocumentById.replaceAll('{id}', id);
    final response = await http.delete(
      Uri.parse('${Endpoints.baseUrl}$url'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete document');
    }
  }

  Future<String> uploadFile(List<int> bytes, String filename) async {
    print('🚀 Repository uploadFile called');
    print('   File: $filename');
    print('   Size: ${bytes.length} bytes');
    print('   Endpoint: ${Endpoints.baseUrl}${Endpoints.legalDocumentUpload}');

    final token = TokenStorage.instance.token;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Endpoints.baseUrl}${Endpoints.legalDocumentUpload}'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      print('   ✅ Token attached');
    } else {
      print('   ⚠️ No token found');
    }

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    print('   📤 Sending request...');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('   📥 Response status: ${response.statusCode}');
    print('   📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fileUrl = data['data']['file_url'];
      print('   ✅ Upload successful: $fileUrl');
      return fileUrl;
    }
    print('   ❌ Upload failed');
    throw Exception('Failed to upload file: ${response.body}');
  }
}

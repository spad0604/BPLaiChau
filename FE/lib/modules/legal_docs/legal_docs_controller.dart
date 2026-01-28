import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/legal_document_model.dart';
import '../../repositories/legal_document_repository.dart';

class LegalDocsController extends GetxController {
  final LegalDocumentRepository _repository = LegalDocumentRepository();

  final items = <LegalDocumentModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;
      final docs = await _repository.getAll();
      items.value = docs;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách văn bản: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _repository.delete(id);
      await loadDocuments();
      Get.snackbar(
        'Thành công',
        'Đã xóa văn bản',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa văn bản: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<String?> uploadFile(List<int> bytes, String filename) async {
    try {
      final url = await _repository.uploadFile(bytes, filename);
      return url;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể upload file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return null;
    }
  }

  Future<void> createDocument(Map<String, dynamic> payload) async {
    try {
      await _repository.create(payload);
      await loadDocuments();
      Get.snackbar(
        'Thành công',
        'Đã thêm văn bản',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể thêm văn bản: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> updateDocument(String id, Map<String, dynamic> updates) async {
    try {
      await _repository.update(id, updates);
      await loadDocuments();
      Get.snackbar(
        'Thành công',
        'Đã cập nhật văn bản',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật văn bản: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}

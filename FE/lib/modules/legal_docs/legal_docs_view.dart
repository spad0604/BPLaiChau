import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/token_storage.dart';
import '../../core/url_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/dashboard/dashboard_layout.dart';
import '../../widgets/dashboard/sidebar.dart';
import '../../widgets/dashboard/top_bar.dart';
import '../../models/legal_document_model.dart';
import 'legal_docs_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalDocsView extends GetView<LegalDocsController> {
  final bool embedded;
  const LegalDocsView({super.key, this.embedded = false});

  bool get _isSuperAdmin => (TokenStorage.instance.role ?? '') == 'super_admin';

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Văn bản quy phạm pháp luật và hướng dẫn nội bộ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (_isSuperAdmin)
                AppButton(
                  text: 'Thêm văn bản',
                  onPressed: () => _showUploadDialog(context),
                  icon: Icons.add,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quản lý các văn bản về công tác điều tra hình sự, xử lý vi phạm hành chính',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.items.toList();
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có văn bản nào',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final doc = list[i];
                  return _DocumentCard(
                    document: doc,
                    isSuperAdmin: _isSuperAdmin,
                    onDelete: () async {
                      final ok = await _confirmDelete(context, doc.title);
                      if (ok == true) {
                        await controller.deleteDocument(doc.documentId);
                      }
                    },
                    onEdit: () => _showEditDialog(context, doc),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );

    if (embedded) return body;

    return DashboardLayout(
      active: SidebarItemKey.legalDocs,
      child: Column(
        children: [
          const DashboardTopBar(
            breadcrumb: 'Hệ thống  /  Văn bản quy phạm',
            title: 'Quản lý văn bản pháp luật',
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final fileUrl = RxnString();
    final fileName = RxnString();
    final isUploading = false.obs;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thêm văn bản mới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Tiêu đề *',
                  controller: titleController,
                  hint: 'Nhập tiêu đề văn bản',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Chú thích',
                  controller: descController,
                  hint: 'Nhập mô tả ngắn gọn',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File văn bản (Word, PDF) *',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (fileName.value != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fileName.value!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  fileName.value = null;
                                  fileUrl.value = null;
                                },
                                tooltip: 'Xóa file',
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isUploading.value
                                ? null
                                : () async {
                                    isUploading.value = true;
                                    try {
                                      final result = await FilePicker.platform
                                          .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: [
                                              'pdf',
                                              'doc',
                                              'docx',
                                            ],
                                            withData: true, // CRITICAL for web!
                                          );
                                      print(
                                        '📦 FilePicker result: ${result != null}',
                                      );
                                      if (result != null &&
                                          result.files.single.bytes != null) {
                                        final bytes =
                                            result.files.single.bytes!;
                                        final name = result.files.single.name;
                                        print(
                                          '📁 Uploading file: $name, size: ${bytes.length}',
                                        );
                                        final url = await controller.uploadFile(
                                          bytes,
                                          name,
                                        );
                                        print('✅ Upload result: $url');
                                        if (url != null) {
                                          fileUrl.value = url;
                                          fileName.value = name;
                                          print(
                                            '✅ Set state - URL: $url, Name: $name',
                                          );
                                        } else {
                                          print('❌ Upload returned null');
                                        }
                                      } else {
                                        print('❌ No file selected or no bytes');
                                      }
                                    } catch (e, stack) {
                                      print('❌ Error during upload: $e');
                                      print('Stack: $stack');
                                    } finally {
                                      isUploading.value = false;
                                    }
                                  },
                            icon: isUploading.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(
                              isUploading.value ? 'Đang tải...' : 'Chọn file',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4D3E),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        print('📝 Submit clicked');
                        print('Title: ${titleController.text.trim()}');
                        print('FileURL: ${fileUrl.value}');
                        print('FileName: ${fileName.value}');

                        if (titleController.text.trim().isEmpty ||
                            fileUrl.value == null) {
                          print('❌ Validation failed');
                          Get.snackbar(
                            'Lỗi',
                            'Vui lòng nhập đủ thông tin',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }

                        print('✅ Creating document...');
                        await controller.createDocument({
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                          'file_url': fileUrl.value!,
                          'file_type': fileName.value!.split('.').last,
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Thêm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    LegalDocumentModel doc,
  ) async {
    final titleController = TextEditingController(text: doc.title);
    final descController = TextEditingController(text: doc.description);

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sửa văn bản',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Tiêu đề',
                  controller: titleController,
                  hint: 'Nhập tiêu đề văn bản',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Chú thích',
                  controller: descController,
                  hint: 'Nhập mô tả ngắn gọn',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4D3E),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await controller.updateDocument(doc.documentId, {
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Xóa văn bản'),
          content: Text('Bạn chắc chắn muốn xóa văn bản "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final LegalDocumentModel document;
  final bool isSuperAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _DocumentCard({
    required this.document,
    required this.isSuperAdmin,
    required this.onDelete,
    required this.onEdit,
  });

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final absoluteUrl = UrlHelper.toAbsoluteUrl(document.fileUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getFileColor(document.fileType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getFileIcon(document.fileType),
              color: _getFileColor(document.fileType),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (document.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    document.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Định dạng: ${document.fileType.toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(absoluteUrl);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                Get.snackbar(
                  'Lỗi',
                  'Không thể mở file: $e',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Tải'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          if (isSuperAdmin) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Sửa',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Xóa',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}

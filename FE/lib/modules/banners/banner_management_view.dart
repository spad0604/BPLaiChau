import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/token_storage.dart';
import '../../widgets/app_button.dart';
import '../../widgets/dashboard/dashboard_layout.dart';
import '../../widgets/dashboard/sidebar.dart';
import '../../widgets/dashboard/top_bar.dart';
import 'banner_management_controller.dart';

class BannerManagementView extends GetView<BannerManagementController> {
  final bool embedded;
  const BannerManagementView({super.key, this.embedded = false});

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
                child: Text('Banner màn hình đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (_isSuperAdmin)
                Obx(() => AppButton(
                      text: 'Tải banner',
                      onPressed: controller.uploadOne,
                      isLoading: controller.isLoadingRx.value,
                    )),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final list = controller.items.toList();
              if (list.isEmpty) {
                return Center(child: Text('Chưa có banner', style: TextStyle(color: Colors.grey.shade600)));
              }
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final b = list[i];
                  final id = (b['banner_id'] ?? '').toString();
                  final url = (b['image_url'] ?? '').toString();
                  final title = (b['banner_title'] ?? '').toString();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 180,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, st) => const Icon(Icons.broken_image)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title.isEmpty ? 'Không có tiêu đề' : title, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(id, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(height: 6),
                              SelectableText(url, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        if (_isSuperAdmin)
                          IconButton(
                            tooltip: 'Xoá',
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Xoá banner'),
                                  content: const Text('Bạn chắc chắn muốn xoá banner này?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Xoá'),
                                    )
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await controller.deleteBanner(id);
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                      ],
                    ),
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
      active: SidebarItemKey.banners,
      child: Column(
        children: [
          const DashboardTopBar(breadcrumb: 'Hệ thống  /  Banner', title: 'Quản lý banner'),
          Expanded(child: body),
        ],
      ),
    );
  }
}

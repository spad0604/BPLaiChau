import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/dashboard/dashboard_layout.dart';
import '../../../widgets/dashboard/sidebar.dart';
import '../../../widgets/dashboard/top_bar.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_rich_editor.dart';
import 'case_create_controller.dart';
import '../../../widgets/app_dropdown.dart';
import '../../dashboard/dashboard_nav_controller.dart';

class CaseCreateView extends GetView<CaseCreateController> {
  final bool embedded;
  const CaseCreateView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final nav = Get.isRegistered<DashboardNavController>()
        ? Get.find<DashboardNavController>()
        : null;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập thông tin chi tiết vụ việc, tang chứng và kết quả xử lý ban đầu.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Thông tin chung',
            icon: Icons.info_outline,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Ngày xảy ra',
                        hint: '',
                        controller: controller.dateTextCtrl,
                        readOnly: true,
                        onTap: () => controller.pickDate(context),
                        prefixIcon: Icons.calendar_month_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'Địa bàn',
                        hint: '',
                        controller: controller.locationCtrl,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => AppDropdown<String>(
                          label: 'Loại vụ việc',
                          value: controller.incidentType.value,
                          items: const [
                            AppDropdownItem(
                              value: 'criminal',
                              label: 'Vụ án hình sự',
                            ),
                            AppDropdownItem(
                              value: 'administrative',
                              label: 'Xử lý hành chính',
                            ),
                          ],
                          onChanged: (v) => controller.incidentType.value = v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => AppDropdown<String>(
                          label: "Nhóm 'tội phạm'",
                          value: controller.severity.value,
                          items: const [
                            AppDropdownItem(
                              value: 'low',
                              label: 'Ít nghiêm trọng',
                            ),
                            AppDropdownItem(
                              value: 'medium',
                              label: 'Nghiêm trọng',
                            ),
                            AppDropdownItem(
                              value: 'high',
                              label: 'Rất nghiêm trọng',
                            ),
                            AppDropdownItem(
                              value: 'critical',
                              label: 'Đặc biệt nghiêm trọng',
                            ),
                          ],
                          onChanged: (v) => controller.severity.value = v,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final list = controller.stations;
                  final selected = controller.stationId.value;
                  final items = <AppDropdownItem<String>>[
                    const AppDropdownItem(
                      value: '',
                      label: 'Chọn đồn biên phòng (không bắt buộc)',
                    ),
                    ...list.map(
                      (s) => AppDropdownItem(value: s.stationId, label: s.name),
                    ),
                  ];
                  return AppDropdown<String>(
                    label: 'Đồn biên phòng',
                    value: selected,
                    items: items,
                    onChanged: (v) => controller.stationId.value = v,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Chi tiết vụ việc',
            icon: Icons.description_outlined,
            child: Column(
              children: [
                AppTextField(
                  label: 'Mã hồ sơ',
                  hint: 'VD: HS-001/2026',
                  controller: controller.caseCodeCtrl,
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Tiêu đề vụ việc',
                  hint: '',
                  controller: controller.titleCtrl,
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 16),
                AppRichEditor(
                  label: 'Nội dung sự việc',
                  controller: controller.descriptionCtrl,
                  height: 250,
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final isCriminal =
                      controller.incidentType.value == 'criminal';
                  if (isCriminal) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppRichEditor(
                                label: 'Biện pháp giải quyết',
                                controller: controller.handlingMeasureCtrl,
                                height: 150,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppRichEditor(
                                label: 'Khởi tố về hành vi',
                                controller: controller.prosecutedBehaviorCtrl,
                                height: 150,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Tang chứng / vật chứng',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: controller.addSeizedItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm tang chứng'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final rows = controller.seizedItems;
                          return Column(
                            children: List.generate(rows.length, (i) {
                              final item = rows[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: AppTextField(
                                        label: i == 0 ? 'Tên tang chứng' : '',
                                        hint: '',
                                        controller: item.nameCtrl,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: AppTextField(
                                        label: i == 0 ? 'Số lượng' : '',
                                        hint: '',
                                        controller: item.qtyCtrl,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: AppTextField(
                                        label: i == 0 ? 'Đơn vị' : '',
                                        hint: '',
                                        controller: item.unitCtrl,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: AppTextField(
                                        label: i == 0 ? 'Ghi chú' : '',
                                        hint: '',
                                        controller: item.noteCtrl,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Xóa',
                                      onPressed: () =>
                                          controller.removeSeizedItem(i),
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        }),
                      ],
                    );
                  }

                  // administrative
                  return Column(
                    children: [
                      AppTextField(
                        label: 'Kết quả giải quyết',
                        hint: '',
                        controller: controller.resultsCtrl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Hình thức xử phạt',
                              hint: '',
                              controller: controller.punishmentCtrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Mức phạt (VND)',
                              hint: '',
                              controller: controller.penaltyCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Ghi chú',
                        hint: '',
                        controller: controller.noteCtrl,
                        maxLines: 2,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title:
                'Tang vật, phương tiện vi phạm hành chính, giấy phép chứng chỉ hành nghề bị tạm giữ theo thủ tục hành chính',
            icon: Icons.upload_file,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tải lên tài liệu, hình ảnh minh chứng.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.pickEvidenceFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Chọn tệp...'),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.pickedFiles.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: List.generate(controller.pickedFiles.length, (i) {
                      final f = controller.pickedFiles[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.insert_drive_file_outlined,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Bỏ tệp',
                              onPressed: () => controller.removePickedFile(i),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                }),
                const SizedBox(height: 6),
                const Text(
                  'Hỗ trợ: jpg, png, pdf, doc, docx.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (embedded && nav != null) {
                    nav.select(SidebarItemKey.cases);
                    return;
                  }
                  Get.back();
                },
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 12),
              Obx(
                () => AppButton(
                  text: 'Lưu vụ việc',
                  onPressed: controller.submit,
                  isLoading: controller.isLoadingRx.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (embedded) return body;

    return DashboardLayout(
      active: SidebarItemKey.createCase,
      child: Column(
        children: [
          const DashboardTopBar(
            breadcrumb: 'Hệ thống  /  Quản lý vụ việc  /  Thêm mới',
            title: 'Thêm vụ việc mới',
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1B4D3E)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

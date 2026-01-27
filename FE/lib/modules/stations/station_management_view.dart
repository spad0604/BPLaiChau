import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/dashboard/sidebar.dart';
import '../dashboard/dashboard_nav_controller.dart';
import 'station_management_controller.dart';

class StationManagementView extends GetView<StationManagementController> {
  final bool embedded;
  const StationManagementView({super.key, this.embedded = false});

  ButtonStyle _outlinedStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1B4D3E),
      side: BorderSide(color: Colors.grey.shade200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = Get.isRegistered<DashboardNavController>() ? Get.find<DashboardNavController>() : null;

    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Container(
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
                      const Expanded(
                        child: Text(
                          'Danh sách đồn biên phòng (chỉ Super Admin có quyền thêm/sửa/xóa).',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: controller.fetch,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tải lại'),
                        style: _outlinedStyle(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      final list = controller.items.toList();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columnSpacing: 24,
                                  horizontalMargin: 12,
                                  dataRowMinHeight: 64,
                                  dataRowMaxHeight: 110,
                                  columns: const [
                                    DataColumn(label: Text('MÃ')),
                                    DataColumn(label: Text('TÊN ĐỒN')),
                                    DataColumn(label: Text('ĐỊA CHỈ')),
                                    DataColumn(label: Text('SĐT')),
                                    DataColumn(label: Text('')),
                                  ],
                                  rows: list.map((s) {
                                    return DataRow(cells: [
                                      DataCell(Text(s.code.isEmpty ? '-' : s.code)),
                                      DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(s.address.isEmpty ? '-' : s.address)),
                                      DataCell(Text(s.phone.isEmpty ? '-' : s.phone)),
                                      DataCell(
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_horiz),
                                          color: Colors.white,
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          onSelected: (v) async {
                                            if (v == 'edit') {
                                              await _openEditDialog(context, s);
                                            } else if (v == 'delete') {
                                              final ok = await _confirmDelete(context, s.name);
                                              if (ok == true) {
                                                await controller.deleteStation(s.stationId);
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(value: 'edit', child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Text('Sửa', style: TextStyle(color: Colors.black87)),
                                            )),
                                            PopupMenuItem(value: 'delete', child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Text('Xoá', style: TextStyle(color: Colors.red.shade700)),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thêm đồn biên phòng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    AppTextField(label: 'Tên đồn', hint: 'Ví dụ: Đồn Vàng Ma Chải', controller: controller.nameCtrl, prefixIcon: Icons.home_work_outlined),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Mã đồn', hint: 'VD: VMC', controller: controller.codeCtrl, prefixIcon: Icons.tag),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Địa chỉ', hint: '...', controller: controller.addressCtrl, prefixIcon: Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Số điện thoại', hint: '...', controller: controller.phoneCtrl, prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 18),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: 'Tạo đồn',
                            onPressed: controller.create,
                            isLoading: controller.isLoadingRx.value,
                          ),
                        )),
                    const SizedBox(height: 8),
                    const Text('Lưu ý: API sẽ trả 403 nếu không phải Super Admin.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    if (embedded && nav != null) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => nav.select(SidebarItemKey.cases),
                        child: const Text('Quay về danh sách chuyên án'),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return body;
  }

  Future<void> _openEditDialog(BuildContext context, dynamic station) async {
    final nameCtrl = TextEditingController(text: station.name);
    final codeCtrl = TextEditingController(text: station.code);
    final addressCtrl = TextEditingController(text: station.address);
    final phoneCtrl = TextEditingController(text: station.phone);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 12,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 520,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cập nhật đồn biên phòng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Tên đồn', hint: '', controller: nameCtrl),
                  const SizedBox(height: 10),
                  AppTextField(label: 'Mã đồn', hint: '', controller: codeCtrl),
                  const SizedBox(height: 10),
                  AppTextField(label: 'Địa chỉ', hint: '', controller: addressCtrl),
                  const SizedBox(height: 10),
                  AppTextField(label: 'SĐT', hint: '', controller: phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final ok = await controller.updateStation(station.stationId, {
                            'name': nameCtrl.text.trim(),
                            'code': codeCtrl.text.trim(),
                            'address': addressCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                          });
                          if (ok && ctx.mounted) Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), foregroundColor: Colors.white),
                        child: const Text('Lưu'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xoá đồn'),
          content: Text('Bạn chắc chắn muốn xoá "$name"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
              child: const Text('Xoá'),
            ),
          ],
        );
      },
    );
  }
}

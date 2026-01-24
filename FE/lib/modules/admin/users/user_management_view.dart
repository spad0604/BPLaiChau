import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/dashboard/dashboard_layout.dart';
import '../../../widgets/dashboard/sidebar.dart';
import '../../../widgets/dashboard/top_bar.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';
import 'user_management_controller.dart';
import '../../../widgets/app_dropdown.dart';

class UserManagementView extends GetView<UserManagementController> {
  final bool embedded;
  const UserManagementView({super.key, this.embedded = false});

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
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search by name, rank, or service number...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.filter_alt_outlined),
                                label: const Text('Filter'),
                                style: _outlinedStyle(),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.file_download_outlined),
                                label: const Text('Export'),
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
                                            DataColumn(label: Text('OFFICER')),
                                            DataColumn(label: Text('UNIT / STATION')),
                                            DataColumn(label: Text('ROLE')),
                                            DataColumn(label: Text('STATUS')),
                                            DataColumn(label: Text('')),
                                          ],
                                          rows: list.map((u) {
                                            final username = (u['username'] ?? '').toString();
                                            final fullName = (u['full_name'] ?? '').toString();
                                            final role = (u['role'] ?? '').toString();
                                            return DataRow(cells: [
                                              DataCell(Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(fullName.isEmpty ? username : fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 2),
                                                  Text(username, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                                ],
                                              )),
                                              const DataCell(Text('-')),
                                              DataCell(Text(role.isEmpty ? 'Admin' : role)),
                                              DataCell(Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                                                child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                              )),
                                          DataCell(
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_horiz),
                                              color: Colors.white,
                                              elevation: 8,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              onSelected: (v) async {
                                                if (v == 'edit') {
                                                  await _openEditDialog(context, controller, u);
                                                } else if (v == 'delete') {
                                                  final ok = await _confirmDelete(context, username);
                                                  if (ok == true) {
                                                    await controller.deleteUser(username);
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Register New Officer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AppTextField(label: 'Full Name', hint: 'e.g., Nguyễn Văn A', controller: controller.fullNameCtrl, prefixIcon: Icons.badge_outlined),
                            const SizedBox(height: 12),
                            Obx(() => AppDropdown<String>(
                                  label: 'System Role',
                                  value: controller.role.value,
                                  items: const [
                                    AppDropdownItem(value: 'admin', label: 'Admin'),
                                    AppDropdownItem(value: 'super_admin', label: 'Super Admin'),
                                  ],
                                  onChanged: (v) => controller.role.value = v,
                                )),
                            const SizedBox(height: 12),
                            AppTextField(label: 'Username', hint: 'username', controller: controller.usernameCtrl, prefixIcon: Icons.person_outline),
                            const SizedBox(height: 12),
                            AppTextField(label: 'Password', hint: '••••••••', controller: controller.passwordCtrl, isPassword: true, prefixIcon: Icons.lock_outline),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Phone Number',
                                    hint: 'e.g., 098xxxxxxx',
                                    controller: controller.phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icons.phone_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Date of Birth',
                                    hint: 'YYYY-MM-DD',
                                    controller: controller.dobCtrl,
                                    prefixIcon: Icons.cake_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Identity Card Number',
                                    hint: 'CCCD/CMND',
                                    controller: controller.idCardCtrl,
                                    prefixIcon: Icons.credit_card_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() => AppDropdown<int>(
                                        label: 'Gender',
                                        value: controller.gender.value,
                                        items: const [
                                          AppDropdownItem(value: 0, label: 'Female'),
                                          AppDropdownItem(value: 1, label: 'Male'),
                                        ],
                                        onChanged: (v) => controller.gender.value = v,
                                      )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Obx(() => SizedBox(
                                  width: double.infinity,
                                  child: AppButton(
                                    text: 'Create Account',
                                    onPressed: controller.createAccount,
                                    isLoading: controller.isLoadingRx.value,
                                  ),
                                )),
                            const SizedBox(height: 8),
                            const Text('Lưu ý: Chỉ Super Admin có quyền tạo/sửa/xóa tài khoản.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
        ],
      ),
    );

    if (embedded) return body;

    return DashboardLayout(
      active: SidebarItemKey.userManagement,
      child: Column(
        children: [
          const DashboardTopBar(breadcrumb: 'Home  /  Administration  /  Users', title: 'Personnel Access Control'),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, UserManagementController controller, Map<String, dynamic> user) async {
    final originalUsername = (user['username'] ?? '').toString();
    final usernameCtrl = TextEditingController(text: originalUsername);
    final fullNameCtrl = TextEditingController(text: (user['full_name'] ?? '').toString());
    final roleRx = ((user['role'] ?? 'admin').toString()).obs;
    final passwordCtrl = TextEditingController();

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cập nhật admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Tài khoản', hint: '', controller: usernameCtrl),
                  const SizedBox(height: 10),
                  AppTextField(label: 'Họ tên', hint: '', controller: fullNameCtrl),
                  const SizedBox(height: 10),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: roleRx.value,
                      items: const [
                        DropdownMenuItem(value: 'super_admin', child: Text('super_admin')),
                        DropdownMenuItem(value: 'admin', child: Text('admin')),
                        DropdownMenuItem(value: 'user', child: Text('user')),
                      ],
                      onChanged: (v) => roleRx.value = v ?? roleRx.value,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(label: 'Mật khẩu mới (tuỳ chọn)', hint: '', controller: passwordCtrl, isPassword: true),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final payload = <String, dynamic>{
                            'username': usernameCtrl.text.trim(),
                            'role': roleRx.value,
                            'full_name': fullNameCtrl.text.trim().isEmpty ? null : fullNameCtrl.text.trim(),
                          };
                          if (passwordCtrl.text.trim().isNotEmpty) {
                            payload['password'] = passwordCtrl.text.trim();
                          }
                          await controller.updateUser(originalUsername, payload);
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

  Future<bool?> _confirmDelete(BuildContext context, String username) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xoá admin'),
          content: Text('Bạn chắc chắn muốn xoá "$username"?'),
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

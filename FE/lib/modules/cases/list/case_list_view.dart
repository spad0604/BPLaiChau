import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/dashboard/dashboard_layout.dart';
import '../../../widgets/dashboard/sidebar.dart';
import '../../../widgets/dashboard/top_bar.dart';
import 'case_list_controller.dart';
import '../../../widgets/app_dropdown.dart';
import '../../dashboard/dashboard_nav_controller.dart';
import '../../../models/incident_model.dart';
import '../../../core/token_storage.dart';
import '../../../widgets/app_text_field.dart';

class CaseListView extends GetView<CaseListController> {
  final bool embedded;
  const CaseListView({super.key, this.embedded = false});

  String _formatDate(String? iso) {
    final s = (iso ?? '').trim();
    if (s.isEmpty) return '-';
    final dt = DateTime.tryParse(s);
    if (dt == null) {
      // Fallback: try to extract yyyy-mm-dd
      if (s.length >= 10) {
        final d = DateTime.tryParse(s.substring(0, 10));
        if (d != null) {
          final x = d.toLocal();
          return '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
        }
      }
      return s;
    }
    final x = dt.toLocal();
    return '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
  }

  String _incidentTypeLabel(String? v) {
    switch ((v ?? '').toLowerCase()) {
      case 'criminal':
        return 'Vụ án hình sự';
      case 'administrative':
        return 'Xử lý hành chính';
      default:
        return (v == null || v.isEmpty) ? '-' : v;
    }
  }

  String _severityLabel(String? v) {
    switch ((v ?? '').toLowerCase()) {
      case 'low':
        return 'Thấp';
      case 'medium':
        return 'Trung bình';
      case 'high':
        return 'Cao';
      case 'critical':
        return 'Rất nghiêm trọng';
      default:
        return (v == null || v.isEmpty) ? '-' : v;
    }
  }

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
    final isSuperAdmin = (TokenStorage.instance.role ?? '') == 'super_admin';

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Theo dõi, cập nhật và quản lý hồ sơ các chuyên án trên địa bàn tỉnh Lai Châu.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Xuất báo cáo'),
                        style: _outlinedStyle(),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (embedded && nav != null) {
                            nav.select(SidebarItemKey.createCase);
                            return;
                          }
                          Get.offAllNamed(Routes.caseCreate);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm chuyên án mới'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final total = controller.total.value;
                    final inProgress = controller.inProgress.value;
                    final urgent = controller.urgent.value;
                    final completedThisMonth = controller.completedThisMonth.value;
                    return Row(
                      children: [
                        Expanded(child: StatCard(title: 'Tổng chuyên án', value: total.toString(), icon: Icons.folder)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(title: 'Đang thụ lý', value: inProgress.toString(), icon: Icons.work_outline, iconColor: Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(title: 'Khẩn cấp', value: urgent.toString(), icon: Icons.warning_amber, iconColor: Colors.red)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(title: 'Hoàn thành (tháng)', value: completedThisMonth.toString(), icon: Icons.check_circle_outline, iconColor: Colors.blue)),
                      ],
                    );
                  }),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) => controller.query.value = v,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: 'Tìm kiếm theo tiêu đề',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 160,
                              child: Obx(() {
                                final items = <AppDropdownItem<String>>[
                                  const AppDropdownItem(value: '', label: 'Tất cả đơn vị'),
                                  ...controller.stations.map((s) => AppDropdownItem(value: s.stationId, label: s.name)),
                                ];
                                return AppDropdown<String>(
                                  value: controller.stationIdFilter.value,
                                  items: items,
                                  onChanged: (v) => controller.stationIdFilter.value = v,
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 160,
                              child: Obx(() => AppDropdown<String>(
                                    value: controller.statusFilter.value,
                                    items: const [
                                      AppDropdownItem(value: '', label: 'Tất cả trạng thái'),
                                      AppDropdownItem(value: 'Đang thụ lý', label: 'Đang thụ lý'),
                                      AppDropdownItem(value: 'Hoàn thành', label: 'Hoàn thành'),
                                    ],
                                    onChanged: (v) => controller.statusFilter.value = v,
                                  )),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 130,
                              child: Obx(() {
                                final years = controller.yearOptions;
                                final items = <AppDropdownItem<int>>[
                                  const AppDropdownItem(value: 0, label: 'Tất cả năm'),
                                  ...years.map((y) => AppDropdownItem(value: y, label: y.toString())),
                                ];
                                return AppDropdown<int>(
                                  value: controller.yearFilter.value,
                                  items: items,
                                  onChanged: (v) => controller.yearFilter.value = v,
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.tune),
                              label: const Text('Lọc nâng cao'),
                              style: _outlinedStyle(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Obx(() {
                          final chips = <Widget>[];

                          if (controller.yearFilter.value != 0) {
                            chips.add(_FilterChip(label: 'Năm: ${controller.yearFilter.value}', onClear: () => controller.yearFilter.value = 0));
                          }
                          if (controller.stationIdFilter.value.isNotEmpty) {
                            final st = controller.stations.firstWhereOrNull((s) => s.stationId == controller.stationIdFilter.value);
                            chips.add(_FilterChip(label: 'Đơn vị: ${st?.name ?? controller.stationIdFilter.value}', onClear: () => controller.stationIdFilter.value = ''));
                          }
                          if (controller.statusFilter.value.isNotEmpty) {
                            chips.add(_FilterChip(label: 'Trạng thái: ${controller.statusFilter.value}', onClear: () => controller.statusFilter.value = ''));
                          }
                          if (controller.query.value.trim().isNotEmpty) {
                            chips.add(_FilterChip(label: 'Từ khóa: ${controller.query.value.trim()}', onClear: () => controller.query.value = ''));
                          }

                          if (chips.isEmpty) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Không có bộ lọc', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            );
                          }

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(spacing: 8, runSpacing: 8, children: chips),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final list = controller.items.toList();
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    columnSpacing: 24,
                                    horizontalMargin: 12,
                                    dataRowMinHeight: 68,
                                    dataRowMaxHeight: 120,
                                    columns: const [
                                      DataColumn(label: Text('MÃ HỒ SƠ')),
                                      DataColumn(label: Text('TÊN CHUYÊN ÁN / NỘI DUNG')),
                                      DataColumn(label: Text('ĐỒN BIÊN PHÒNG')),
                                      DataColumn(label: Text('ĐỊA BÀN')),
                                      DataColumn(label: Text('NGÀY LẬP')),
                                      DataColumn(label: Text('TRẠNG THÁI')),
                                      DataColumn(label: Text('TÁC VỤ')),
                                    ],
                                    rows: list.map((e) {
                                      final status = (e.status?.isNotEmpty ?? false) ? e.status! : 'Đang thụ lý';
                                      final station = (e.stationName?.isNotEmpty ?? false) ? e.stationName! : '-';
                                      return DataRow(cells: [
                                        DataCell(Text(e.incidentId.isEmpty ? '-' : e.incidentId.substring(0, 6))),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(minWidth: 360, maxWidth: 520),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  e.description ?? '',
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(station)),
                                        DataCell(Text(e.location)),
                                        DataCell(Text(_formatDate(e.createdAt))),
                                        DataCell(StatusBadge(status: status)),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Xem chi tiết',
                                                onPressed: () => _openDetailDialog(context, e),
                                                icon: const Icon(Icons.visibility_outlined),
                                              ),
                                              if (isSuperAdmin)
                                                PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_horiz),
                                                  color: Colors.white,
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  onSelected: (v) async {
                                                    if (v == 'edit') {
                                                      await _openEditDialog(context, e);
                                                    } else if (v == 'delete') {
                                                      final ok = await _confirmDelete(context, e.title);
                                                      if (ok == true) {
                                                        await controller.deleteCase(e.incidentId);
                                                      }
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                                        child: Text('Sửa', style: TextStyle(color: Colors.black87)),
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                        child: Text('Xoá', style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
        ],
      ),
    );

    if (embedded) {
      return body;
    }

    return DashboardLayout(
      active: SidebarItemKey.cases,
      child: Column(
        children: [
          const DashboardTopBar(
            breadcrumb: 'Trang chủ  /  Quản lý chuyên án',
            title: 'Danh sách chuyên án',
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Xoá chuyên án', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Bạn chắc chắn muốn xoá: "$title"?', style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xoá'),
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

  Future<void> _openEditDialog(BuildContext context, dynamic incident) async {
    final titleCtrl = TextEditingController(text: incident.title?.toString() ?? '');
    final locationCtrl = TextEditingController(text: incident.location?.toString() ?? '');
    final descriptionCtrl = TextEditingController(text: incident.description?.toString() ?? '');
    String status = (incident.status?.toString().isNotEmpty ?? false) ? incident.status.toString() : 'Đang thụ lý';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sửa chuyên án', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  AppTextField(label: 'Tiêu đề', hint: '', controller: titleCtrl, prefixIcon: Icons.title),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Địa bàn', hint: '', controller: locationCtrl, prefixIcon: Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Nội dung', hint: '', controller: descriptionCtrl, maxLines: 4),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return AppDropdown<String>(
                        label: 'Trạng thái',
                        value: status,
                        items: const [
                          AppDropdownItem(value: 'Đang thụ lý', label: 'Đang thụ lý'),
                          AppDropdownItem(value: 'Hoàn thành', label: 'Hoàn thành'),
                        ],
                        onChanged: (v) => setState(() => status = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), foregroundColor: Colors.white),
                        onPressed: () async {
                          final updates = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'location': locationCtrl.text.trim(),
                            'description': descriptionCtrl.text.trim(),
                            'status': status,
                          };
                          Navigator.pop(context);
                          await controller.updateCase(incident.incidentId.toString(), updates);
                        },
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        );
      },
    );
  }

  Future<void> _openDetailDialog(BuildContext context, dynamic incident) async {
    final status = (incident.status?.toString().isNotEmpty ?? false) ? incident.status.toString() : 'Đang thụ lý';
    final station = (incident.stationName?.toString().isNotEmpty ?? false) ? incident.stationName.toString() : '-';
    final title = incident.title?.toString() ?? '';
    final location = incident.location?.toString() ?? '';
    final description = incident.description?.toString() ?? '';
    final createdAt = _formatDate(incident.createdAt?.toString());
    final occurredAt = _formatDate(incident.occurredAt?.toString());
    final typeLabel = _incidentTypeLabel(incident.incidentType?.toString());
    final severityLabel = _severityLabel(incident.severity?.toString());
    final evidence = (incident.evidence is List) ? List<String>.from(incident.evidence as List) : <String>[];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Chi tiết chuyên án', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          StatusBadge(status: status),
                          const SizedBox(width: 6),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Đồn biên phòng: $station', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Địa bàn: $location', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _kv('Ngày lập', createdAt)),
                            Expanded(child: _kv('Ngày xảy ra', occurredAt)),
                            Expanded(child: _kv('Loại', typeLabel)),
                            Expanded(child: _kv('Cấp độ', severityLabel)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Nội dung', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: SingleChildScrollView(
                          child: Text(description.isEmpty ? '-' : description, style: const TextStyle(color: Colors.black87)),
                        ),
                      ),

                      // Additional fields if present
                      const SizedBox(height: 12),
                      Builder(builder: (ctx) {
                        String handling = '';
                        String prosecuted = '';
                        String results = '';
                        String punishment = '';
                        String penalty = '';
                        String note = '';
                        List<dynamic> seized = <dynamic>[];

                        if (incident is Map) {
                          handling = incident['handling_measure']?.toString() ?? '';
                          prosecuted = incident['prosecuted_behavior']?.toString() ?? '';
                          results = incident['results']?.toString() ?? '';
                          punishment = incident['form_of_punishment']?.toString() ?? '';
                          penalty = incident['penalty_amount']?.toString() ?? '';
                          note = incident['note']?.toString() ?? '';
                          seized = (incident['seized_items'] is List) ? List.from(incident['seized_items']) : <dynamic>[];
                        } else if (incident is IncidentModel) {
                          // IncidentModel doesn't expose these fields; leave as defaults (empty)
                        }

                        final widgets = <Widget>[];
                        if (seized.isNotEmpty) {
                          widgets.add(const Text('Tang chứng', style: TextStyle(fontWeight: FontWeight.w700)));
                          widgets.add(const SizedBox(height: 6));
                          widgets.addAll(seized.map((s) {
                            try {
                              final name = s['name']?.toString() ?? s.toString();
                              final qty = s['quantity']?.toString() ?? '';
                              final unit = s['unit']?.toString() ?? '';
                              final noteS = s['note']?.toString() ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('- $name ${qty.isNotEmpty ? 'x $qty' : ''} ${unit.isNotEmpty ? unit : ''} ${noteS.isNotEmpty ? '($noteS)' : ''}'),
                              );
                            } catch (_) {
                              return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('- ${s.toString()}'));
                            }
                          }).toList());
                        }

                        if (handling.isNotEmpty) {
                          widgets.add(const SizedBox(height: 8));
                          widgets.add(const Text('Biện pháp giải quyết', style: TextStyle(fontWeight: FontWeight.w700)));
                          widgets.add(const SizedBox(height: 6));
                          widgets.add(Text(handling));
                        }
                        if (prosecuted.isNotEmpty) {
                          widgets.add(const SizedBox(height: 8));
                          widgets.add(const Text('Khởi tố', style: TextStyle(fontWeight: FontWeight.w700)));
                          widgets.add(const SizedBox(height: 6));
                          widgets.add(Text(prosecuted));
                        }
                        if (results.isNotEmpty) {
                          widgets.add(const SizedBox(height: 8));
                          widgets.add(const Text('Kết quả', style: TextStyle(fontWeight: FontWeight.w700)));
                          widgets.add(const SizedBox(height: 6));
                          widgets.add(Text(results));
                        }
                        if (punishment.isNotEmpty || penalty.isNotEmpty) {
                          widgets.add(const SizedBox(height: 8));
                          widgets.add(const Text('Xử phạt', style: TextStyle(fontWeight: FontWeight.w700)));
                          widgets.add(const SizedBox(height: 6));
                          widgets.add(Text('${punishment.isNotEmpty ? punishment : ''} ${penalty.isNotEmpty ? ' - $penalty VND' : ''}'));
                        }
                        if (note.isNotEmpty) {
                          widgets.add(const SizedBox(height: 8));
                          widgets.add(const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.w700)));
                          widgets.add(const SizedBox(height: 6));
                          widgets.add(Text(note));
                        }

                        if (widgets.isEmpty) return const SizedBox.shrink();
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
                      }),

                      const SizedBox(height: 12),
                      const Text('Tài liệu / Tang chứng', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      if (evidence.isEmpty)
                        Text('Không có', style: TextStyle(color: Colors.grey.shade600))
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 280),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: evidence.map((u) {
                                final s = u.toString();
                                final lower = s.toLowerCase();
                                final isImage = lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp') || lower.endsWith('.gif');
                                if (isImage) {
                                  return Container(
                                    width: 160,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        s,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, st) => Center(child: Icon(Icons.broken_image, color: Colors.grey.shade400)),
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: SelectableText(s, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _FilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1B4D3E), fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF1B4D3E)),
          )
        ],
      ),
    );
  }
}

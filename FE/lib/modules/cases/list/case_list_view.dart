import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../services/export/export_service.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../../widgets/app_rich_editor.dart';

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
    final nav = Get.isRegistered<DashboardNavController>()
        ? Get.find<DashboardNavController>()
        : null;
    final isSuperAdmin = (TokenStorage.instance.role ?? '') == 'super_admin';

    final dragDevices = <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
    };

    Widget tableWidget() {
      return Obx(() {
        final list = controller.items.toList();
        return LayoutBuilder(
          builder: (context, constraints) {
            final behavior = ScrollConfiguration.of(
              context,
            ).copyWith(dragDevices: dragDevices);

            return ScrollConfiguration(
              behavior: behavior,
              child: Scrollbar(
                controller: controller.tableHorizontalController,
                thumbVisibility: true,
                trackVisibility: true,
                notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: controller.tableHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 120,
                        columns: [
                          DataColumn(label: Text('cases.table.code'.tr)),
                          DataColumn(label: Text('cases.table.title'.tr)),
                          DataColumn(label: Text('cases.table.station'.tr)),
                          DataColumn(label: Text('cases.table.area'.tr)),
                          DataColumn(label: Text('cases.table.createdAt'.tr)),
                          DataColumn(label: Text('cases.table.status'.tr)),
                          DataColumn(label: Text('cases.table.actions'.tr)),
                        ],
                        rows: list.map((e) {
                          final rawStatus = (e.status?.isNotEmpty ?? false)
                              ? e.status!
                              : 'Đang thụ lý';
                          final status = switch (rawStatus) {
                            'Đang thụ lý' => 'cases.status.inProgress'.tr,
                            'Hoàn thành' => 'cases.status.completed'.tr,
                            _ => rawStatus,
                          };
                          final station = (e.stationName?.isNotEmpty ?? false)
                              ? e.stationName!
                              : '-';
                          final code = e.incidentId.isEmpty
                              ? '-'
                              : (e.incidentId.length >= 6
                                    ? e.incidentId.substring(0, 6)
                                    : e.incidentId);

                          return DataRow(
                            cells: [
                              DataCell(Text(code)),
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 360,
                                    maxWidth: 520,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SizedBox(
                                        height: 40,
                                        child: ClipRect(
                                          child: HtmlWidget(
                                            e.description ?? '',
                                            textStyle: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
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
                                      onPressed: () =>
                                          _openDetailDialog(context, e),
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                      ),
                                    ),
                                    if (isSuperAdmin)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz),
                                        color: Colors.white,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        onSelected: (v) async {
                                          if (v == 'edit') {
                                            await _openEditDialog(context, e);
                                          } else if (v == 'delete') {
                                            final ok = await _confirmDelete(
                                              context,
                                              e.title,
                                            );
                                            if (ok == true) {
                                              await controller.deleteCase(
                                                e.incidentId,
                                              );
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                'Sửa',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                'Xoá',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      });
    }

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'cases.headerDesc'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await ExportService.exportIncidentsCsv(
                  controller.items.toList(),
                );
                controller.showSuccess('export.incidentsDone'.tr);
              },
              icon: const Icon(Icons.file_download_outlined),
              label: Text('common.exportReport'.tr),
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
              label: Text('cases.addNew'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4D3E),
                foregroundColor: Colors.white,
              ),
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
              Expanded(
                child: StatCard(
                  title: 'Tổng chuyên án',
                  value: total.toString(),
                  icon: Icons.folder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Đang thụ lý',
                  value: inProgress.toString(),
                  icon: Icons.work_outline,
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Khẩn cấp',
                  value: urgent.toString(),
                  icon: Icons.warning_amber,
                  iconColor: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Hoàn thành (tháng)',
                  value: completedThisMonth.toString(),
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.blue,
                ),
              ),
            ],
          );
        }),
      ],
    );

    Widget listPanel({required bool expandedTable}) {
      return Container(
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
                      hintText: 'cases.searchHintTitle'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: Obx(() {
                    final items = <AppDropdownItem<String>>[
                      AppDropdownItem(
                        value: '',
                        label: 'cases.filter.allStations'.tr,
                      ),
                      ...controller.stations.map(
                        (s) =>
                            AppDropdownItem(value: s.stationId, label: s.name),
                      ),
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
                  child: Obx(
                    () => AppDropdown<String>(
                      value: controller.statusFilter.value,
                      items: [
                        AppDropdownItem(
                          value: '',
                          label: 'cases.filter.allStatuses'.tr,
                        ),
                        AppDropdownItem(
                          value: 'Đang thụ lý',
                          label: 'cases.status.inProgress'.tr,
                        ),
                        AppDropdownItem(
                          value: 'Hoàn thành',
                          label: 'cases.status.completed'.tr,
                        ),
                      ],
                      onChanged: (v) => controller.statusFilter.value = v,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: Obx(
                    () => AppDropdown<String>(
                      value: controller.incidentTypeFilter.value,
                      items: const [
                        AppDropdownItem(value: '', label: 'Tất cả loại'),
                        AppDropdownItem(
                          value: 'criminal',
                          label: 'Vụ án hình sự',
                        ),
                        AppDropdownItem(
                          value: 'administrative',
                          label: 'Xử lý hành chính',
                        ),
                      ],
                      onChanged: (v) => controller.incidentTypeFilter.value = v,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: Obx(() {
                    final years = controller.yearOptions;
                    final items = <AppDropdownItem<int>>[
                      AppDropdownItem(
                        value: 0,
                        label: 'cases.filter.allYears'.tr,
                      ),
                      ...years.map(
                        (y) => AppDropdownItem(value: y, label: y.toString()),
                      ),
                    ];
                    return AppDropdown<int>(
                      value: controller.yearFilter.value,
                      items: items,
                      onChanged: (v) => controller.yearFilter.value = v,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final chips = <Widget>[];

              if (controller.yearFilter.value != 0) {
                chips.add(
                  _FilterChip(
                    label: 'cases.filter.yearChip'.trParams({
                      'year': controller.yearFilter.value.toString(),
                    }),
                    onClear: () => controller.yearFilter.value = 0,
                  ),
                );
              }
              if (controller.stationIdFilter.value.isNotEmpty) {
                final st = controller.stations.firstWhereOrNull(
                  (s) => s.stationId == controller.stationIdFilter.value,
                );
                chips.add(
                  _FilterChip(
                    label: 'cases.filter.stationChip'.trParams({
                      'station': st?.name ?? controller.stationIdFilter.value,
                    }),
                    onClear: () => controller.stationIdFilter.value = '',
                  ),
                );
              }
              if (controller.statusFilter.value.isNotEmpty) {
                chips.add(
                  _FilterChip(
                    label: 'cases.filter.statusChip'.trParams({
                      'status': controller.statusFilter.value,
                    }),
                    onClear: () => controller.statusFilter.value = '',
                  ),
                );
              }
              if (controller.incidentTypeFilter.value.isNotEmpty) {
                final incidentTypeLabel =
                    switch (controller.incidentTypeFilter.value) {
                      'criminal' => 'Vụ án hình sự',
                      'administrative' => 'Xử lý hành chính',
                      _ => controller.incidentTypeFilter.value,
                    };
                chips.add(
                  _FilterChip(
                    label: 'Loại: $incidentTypeLabel',
                    onClear: () => controller.incidentTypeFilter.value = '',
                  ),
                );
              }
              if (controller.query.value.trim().isNotEmpty) {
                chips.add(
                  _FilterChip(
                    label: 'cases.filter.keywordChip'.trParams({
                      'keyword': controller.query.value.trim(),
                    }),
                    onClear: () => controller.query.value = '',
                  ),
                );
              }

              if (chips.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'cases.filter.none'.tr,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                );
              }

              return Align(
                alignment: Alignment.centerLeft,
                child: Wrap(spacing: 8, runSpacing: 8, children: chips),
              );
            }),
            const SizedBox(height: 12),
            if (expandedTable)
              Expanded(child: tableWidget())
            else
              tableWidget(),
          ],
        ),
      );
    }

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 18),
          Expanded(child: listPanel(expandedTable: true)),
        ],
      ),
    );

    if (embedded) {
      return content;
    }

    return DashboardLayout(
      active: SidebarItemKey.cases,
      child: Column(
        children: [
          const DashboardTopBar(
            breadcrumb: 'Trang chủ  /  Quản lý chuyên án',
            title: 'Danh sách chuyên án',
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            color: Colors.white,
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Xoá chuyên án',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Bạn có chắc chắn muốn xoá chuyên án này không?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hành động này không thể hoàn tác. Tất cả dữ liệu liên quan sẽ bị xoá vĩnh viễn.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Hủy', style: TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Xác nhận xoá',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    final row = (incident is IncidentModel) ? incident : null;
    final id = (row != null)
        ? row.incidentId
        : (incident is Map
              ? (incident['incident_id']?.toString() ??
                    incident['id']?.toString() ??
                    '')
              : '');

    await showDialog<void>(
      context: context,
      builder: (_) => _CaseEditDialog(
        controller: controller,
        incidentId: id,
        stations: controller.stations.toList(),
        row: row,
      ),
    );
  }

  Future<void> _openDetailDialog(BuildContext context, dynamic incident) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        final row = (incident is IncidentModel) ? incident : null;
        final id = (row != null)
            ? row.incidentId
            : (incident is Map
                  ? (incident['incident_id']?.toString() ??
                        incident['id']?.toString() ??
                        '')
                  : '');
        return _CaseDetailDialog(
          controller: controller,
          incidentId: id,
          row: row,
        );
      },
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1B4D3E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF1B4D3E)),
          ),
        ],
      ),
    );
  }
}

class _CaseDetailDialog extends StatelessWidget {
  final CaseListController controller;
  final String incidentId;
  final IncidentModel? row;

  const _CaseDetailDialog({
    required this.controller,
    required this.incidentId,
    required this.row,
  });

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: controller.fetchCaseDetail(incidentId),
              builder: (context, snap) {
                final isLoading = snap.connectionState != ConnectionState.done;
                final data = snap.data ?? <String, dynamic>{};

                // fallback to row fields if fetch fails
                final title = (data['title']?.toString().isNotEmpty ?? false)
                    ? data['title'].toString()
                    : (row?.title ?? '');
                final station =
                    (data['station_name']?.toString().isNotEmpty ?? false)
                    ? data['station_name'].toString()
                    : (row?.stationName ?? '-');
                final location =
                    (data['location']?.toString().isNotEmpty ?? false)
                    ? data['location'].toString()
                    : (row?.location ?? '');
                final description =
                    (data['description']?.toString().isNotEmpty ?? false)
                    ? data['description'].toString()
                    : (row?.description ?? '');
                final status = (data['status']?.toString().isNotEmpty ?? false)
                    ? data['status'].toString()
                    : ((row?.status?.isNotEmpty ?? false)
                          ? row!.status!
                          : 'Đang thụ lý');

                // Note: Access helper via static formatting below to avoid reaching view instance.
                final createdStr = _formatDateStatic(
                  data['created_at']?.toString() ?? row?.createdAt,
                );
                final occurredStr = _formatDateStatic(
                  data['occurred_at']?.toString() ?? row?.occurredAt,
                );

                final typeLabel = _incidentTypeLabelStatic(
                  data['incident_type']?.toString() ?? row?.incidentType,
                );
                final severityLabel = _severityLabelStatic(
                  data['severity']?.toString() ?? row?.severity,
                );

                final seized = (data['seized_items'] is List)
                    ? List.from(data['seized_items'])
                    : <dynamic>[];
                final handling = data['handling_measure']?.toString() ?? '';
                final prosecuted =
                    data['prosecuted_behavior']?.toString() ?? '';
                final results = data['results']?.toString() ?? '';
                final punishment = data['form_of_punishment']?.toString() ?? '';
                final penalty = (data['penalty_amount'] == null)
                    ? ''
                    : data['penalty_amount'].toString();
                final note = data['note']?.toString() ?? '';
                final evidence = (data['evidence'] is List)
                    ? List<String>.from(data['evidence'])
                    : (row?.evidence ?? <String>[]);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Chi tiết chuyên án',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          StatusBadge(status: status),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đồn biên phòng: $station',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Địa bàn: $location',
                        style: const TextStyle(color: Colors.black87),
                      ),
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
                            Expanded(child: _kvStatic('Ngày lập', createdStr)),
                            Expanded(
                              child: _kvStatic('Ngày xảy ra', occurredStr),
                            ),
                            Expanded(child: _kvStatic('Loại', typeLabel)),
                            Expanded(child: _kvStatic('Cấp độ', severityLabel)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nội dung',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      HtmlWidget(description.isEmpty ? '-' : description),

                      if (seized.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Tang chứng',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        ...seized.map((s) {
                          try {
                            final name = s['name']?.toString() ?? s.toString();
                            final qty = s['quantity']?.toString() ?? '';
                            final unit = s['unit']?.toString() ?? '';
                            final noteS = s['note']?.toString() ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '- $name ${qty.isNotEmpty ? 'x $qty' : ''} ${unit.isNotEmpty ? unit : ''} ${noteS.isNotEmpty ? '($noteS)' : ''}',
                              ),
                            );
                          } catch (_) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('- ${s.toString()}'),
                            );
                          }
                        }),
                      ],

                      if (handling.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Biện pháp giải quyết',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        HtmlWidget(handling),
                      ],
                      if (prosecuted.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Khởi tố về hành vi',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        HtmlWidget(prosecuted),
                      ],
                      if (results.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Kết quả giải quyết',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        HtmlWidget(results),
                      ],
                      if (punishment.isNotEmpty || penalty.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Xử phạt',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${punishment.isNotEmpty ? punishment : '-'}${penalty.isNotEmpty ? ' - $penalty VND' : ''}',
                        ),
                      ],
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Ghi chú',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(note),
                      ],

                      const SizedBox(height: 12),
                      const Text(
                        'Tài liệu / Tang chứng',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      if (evidence.isEmpty)
                        Text(
                          'Không có',
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: evidence.map((u) {
                            final url = u.toString();
                            if (_isImageUrl(url)) {
                              return Container(
                                width: 170,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, st) => Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: SelectableText(
                                url,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4D3E),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDateStatic(String? iso) {
    final s = (iso ?? '').trim();
    if (s.isEmpty) return '-';
    final dt = DateTime.tryParse(s);
    if (dt == null) {
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

  static String _incidentTypeLabelStatic(String? v) {
    switch ((v ?? '').toLowerCase()) {
      case 'criminal':
        return 'Vụ án hình sự';
      case 'administrative':
        return 'Xử lý hành chính';
      default:
        return (v == null || v.isEmpty) ? '-' : v;
    }
  }

  static String _severityLabelStatic(String? v) {
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

  static Widget _kvStatic(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CaseEditDialog extends StatefulWidget {
  final CaseListController controller;
  final String incidentId;
  final List<dynamic> stations;
  final IncidentModel? row;

  const _CaseEditDialog({
    required this.controller,
    required this.incidentId,
    required this.stations,
    required this.row,
  });

  @override
  State<_CaseEditDialog> createState() => _CaseEditDialogState();
}

class _CaseEditDialogState extends State<_CaseEditDialog> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Rich editors
  QuillController _descriptionCtrl = QuillController.basic();
  QuillController _handlingCtrl = QuillController.basic();
  QuillController _prosecutedCtrl = QuillController.basic();

  final _resultsCtrl = TextEditingController();
  final _punishmentCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _status = 'Đang thụ lý';
  String _incidentType = 'criminal';
  String _severity = 'medium';
  String _stationId = '';
  DateTime? _occurredAt;

  List<_SeizedItemRow> _seized = [];
  List<String> _evidenceUrls = [];
  List<PlatformFile> _newEvidenceFiles = [];

  bool _initialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _handlingCtrl.dispose();
    _prosecutedCtrl.dispose();
    _resultsCtrl.dispose();
    _punishmentCtrl.dispose();
    _penaltyCtrl.dispose();
    _noteCtrl.dispose();
    for (final r in _seized) {
      r.dispose();
    }
    super.dispose();
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  String _quillToHtml(QuillController controller) {
    if (controller.document.isEmpty()) return '';
    final delta = controller.document.toDelta().toJson();
    final converter = QuillDeltaToHtmlConverter(
      delta,
      ConverterOptions.forEmail(),
    );
    return converter.convert();
  }

  List<PlatformFile> _mergePickedFiles(
    List<PlatformFile> existing,
    List<PlatformFile> incoming,
  ) {
    final out = <PlatformFile>[...existing];

    bool exists(PlatformFile f) {
      return out.any((e) {
        final sameName = e.name == f.name;
        final sameSize = e.size == f.size;
        final sameId =
            (e.identifier != null &&
            f.identifier != null &&
            e.identifier == f.identifier);
        final samePath = (e.path != null && f.path != null && e.path == f.path);
        return (sameId || samePath) || (sameName && sameSize);
      });
    }

    for (final f in incoming) {
      if (!exists(f)) out.add(f);
    }
    return out;
  }

  Future<void> _pickEvidence() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      _newEvidenceFiles = _mergePickedFiles(_newEvidenceFiles, result.files);
    });
  }

  Future<void> _pickOccurredAt() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _occurredAt = picked);
    }
  }

  Future<void> _save(Map<String, dynamic> detail) async {
    final effectiveStationId = _stationId.isNotEmpty
        ? _stationId
        : (detail['station_id']?.toString() ?? (widget.row?.stationId ?? ''));

    final stationName = () {
      try {
        final st = widget.controller.stations.firstWhereOrNull(
          (s) => s.stationId == effectiveStationId,
        );
        return st?.name ??
            (detail['station_name']?.toString() ??
                (widget.row?.stationName ?? ''));
      } catch (_) {
        return detail['station_name']?.toString() ??
            (widget.row?.stationName ?? '');
      }
    }();

    final occurredIso = _occurredAt?.toIso8601String();
    final existingOccurred = (detail['occurred_at']?.toString() ?? '').trim();

    final updates = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'description': _quillToHtml(_descriptionCtrl),
      'status': _status,
      'incident_type': _incidentType,
      'severity': _severity,
      if (occurredIso != null) 'occurred_at': occurredIso,
      if (occurredIso == null && existingOccurred.isNotEmpty)
        'occurred_at': existingOccurred,
      'station_id': effectiveStationId,
      'station_name': stationName,
      'evidence': _evidenceUrls,
    };

    if (_incidentType == 'criminal') {
      updates.addAll({
        'handling_measure': _quillToHtml(_handlingCtrl),
        'prosecuted_behavior': _quillToHtml(_prosecutedCtrl),
        'seized_items': _seized
            .map((r) => r.toJson())
            .where((m) => (m['name'] as String).trim().isNotEmpty)
            .toList(),
        'results': '',
        'form_of_punishment': '',
        'penalty_amount': 0.0,
        'note': '',
      });
    } else {
      updates.addAll({
        'results': _resultsCtrl.text.trim(),
        'form_of_punishment': _punishmentCtrl.text.trim(),
        'penalty_amount': double.tryParse(_penaltyCtrl.text.trim()) ?? 0.0,
        'note': _noteCtrl.text.trim(),
        'handling_measure': '',
        'prosecuted_behavior': '',
        'seized_items': [],
      });
    }

    await widget.controller.updateCase(widget.incidentId, updates);

    if (_newEvidenceFiles.isNotEmpty) {
      final merged = await widget.controller.appendEvidence(
        widget.incidentId,
        _newEvidenceFiles,
      );
      if (merged.isNotEmpty) {
        setState(() {
          _evidenceUrls = merged;
          _newEvidenceFiles = [];
        });
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: widget.controller.fetchCaseDetail(widget.incidentId),
              builder: (context, snap) {
                final isLoading = snap.connectionState != ConnectionState.done;
                final detail = snap.data ?? <String, dynamic>{};

                if (!_initialized && !isLoading) {
                  _titleCtrl.text =
                      (detail['title']?.toString().isNotEmpty ?? false)
                      ? detail['title'].toString()
                      : (widget.row?.title ?? '');
                  _locationCtrl.text =
                      (detail['location']?.toString().isNotEmpty ?? false)
                      ? detail['location'].toString()
                      : (widget.row?.location ?? '');

                  final descHtml =
                      (detail['description']?.toString().isNotEmpty ?? false)
                      ? detail['description'].toString()
                      : (widget.row?.description ?? '');
                  _descriptionCtrl = QuillController(
                    document: Document.fromDelta(
                      HtmlToDelta().convert(descHtml),
                    ),
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                  _status = (detail['status']?.toString().isNotEmpty ?? false)
                      ? detail['status'].toString()
                      : ((widget.row?.status?.isNotEmpty ?? false)
                            ? widget.row!.status!
                            : 'Đang thụ lý');
                  _incidentType =
                      (detail['incident_type']?.toString().isNotEmpty ?? false)
                      ? detail['incident_type'].toString()
                      : (widget.row?.incidentType ?? 'criminal');
                  _severity =
                      (detail['severity']?.toString().isNotEmpty ?? false)
                      ? detail['severity'].toString()
                      : (widget.row?.severity ?? 'medium');
                  _stationId =
                      (detail['station_id']?.toString().isNotEmpty ?? false)
                      ? detail['station_id'].toString()
                      : (widget.row?.stationId ?? '');
                  final occ = detail['occurred_at']?.toString();
                  _occurredAt = (occ == null || occ.isEmpty)
                      ? null
                      : DateTime.tryParse(occ);

                  final handlingHtml =
                      detail['handling_measure']?.toString() ?? '';
                  _handlingCtrl = QuillController(
                    document: Document.fromDelta(
                      HtmlToDelta().convert(handlingHtml),
                    ),
                    selection: const TextSelection.collapsed(offset: 0),
                  );

                  final prosecutedHtml =
                      detail['prosecuted_behavior']?.toString() ?? '';
                  _prosecutedCtrl = QuillController(
                    document: Document.fromDelta(
                      HtmlToDelta().convert(prosecutedHtml),
                    ),
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                  _resultsCtrl.text = detail['results']?.toString() ?? '';
                  _punishmentCtrl.text =
                      detail['form_of_punishment']?.toString() ?? '';
                  _penaltyCtrl.text = (detail['penalty_amount'] == null)
                      ? ''
                      : detail['penalty_amount'].toString();
                  _noteCtrl.text = detail['note']?.toString() ?? '';

                  _evidenceUrls = (detail['evidence'] is List)
                      ? List<String>.from(detail['evidence'])
                      : (widget.row?.evidence ?? <String>[]);

                  for (final r in _seized) {
                    r.dispose();
                  }
                  _seized = [];
                  final seized = (detail['seized_items'] is List)
                      ? List.from(detail['seized_items'])
                      : <dynamic>[];
                  if (seized.isNotEmpty) {
                    for (final s in seized) {
                      try {
                        _seized.add(
                          _SeizedItemRow.fromJson(Map<String, dynamic>.from(s)),
                        );
                      } catch (_) {
                        _seized.add(_SeizedItemRow());
                      }
                    }
                  }
                  if (_seized.isEmpty) _seized.add(_SeizedItemRow());

                  _initialized = true;
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Sửa chuyên án',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Basic
                      AppTextField(
                        label: 'Tiêu đề',
                        hint: '',
                        controller: _titleCtrl,
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Địa bàn',
                        hint: '',
                        controller: _locationCtrl,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppRichEditor(
                        label: 'Nội dung',
                        controller: _descriptionCtrl,
                        height: 200,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Loại vụ việc',
                              value: _incidentType,
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
                              onChanged: (v) =>
                                  setState(() => _incidentType = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Cấp độ',
                              value: _severity,
                              items: const [
                                AppDropdownItem(value: 'low', label: 'Thấp'),
                                AppDropdownItem(
                                  value: 'medium',
                                  label: 'Trung bình',
                                ),
                                AppDropdownItem(value: 'high', label: 'Cao'),
                                AppDropdownItem(
                                  value: 'critical',
                                  label: 'Rất nghiêm trọng',
                                ),
                              ],
                              onChanged: (v) => setState(() => _severity = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickOccurredAt,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Ngày xảy ra',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _occurredAt == null
                                      ? '-'
                                      : '${_occurredAt!.day.toString().padLeft(2, '0')}/${_occurredAt!.month.toString().padLeft(2, '0')}/${_occurredAt!.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Đồn biên phòng',
                              value: _stationId,
                              items: [
                                const AppDropdownItem(
                                  value: '',
                                  label: 'Không chọn',
                                ),
                                ...widget.controller.stations.map(
                                  (s) => AppDropdownItem(
                                    value: s.stationId,
                                    label: s.name,
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _stationId = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      AppDropdown<String>(
                        label: 'Trạng thái',
                        value: _status,
                        items: const [
                          AppDropdownItem(
                            value: 'Đang thụ lý',
                            label: 'Đang thụ lý',
                          ),
                          AppDropdownItem(
                            value: 'Hoàn thành',
                            label: 'Hoàn thành',
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v),
                      ),

                      const SizedBox(height: 16),
                      if (_incidentType == 'criminal') ...[
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Tang chứng / vật chứng',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _seized.add(_SeizedItemRow())),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm tang chứng'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_seized.length, (i) {
                          final r = _seized[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: AppTextField(
                                    label: i == 0 ? 'Tên tang chứng' : '',
                                    hint: '',
                                    controller: r.nameCtrl,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: AppTextField(
                                    label: i == 0 ? 'Số lượng' : '',
                                    hint: '',
                                    controller: r.qtyCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: AppTextField(
                                    label: i == 0 ? 'Đơn vị' : '',
                                    hint: '',
                                    controller: r.unitCtrl,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: AppTextField(
                                    label: i == 0 ? 'Ghi chú' : '',
                                    hint: '',
                                    controller: r.noteCtrl,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  tooltip: 'Xoá',
                                  onPressed: () {
                                    if (_seized.length == 1) return;
                                    setState(() {
                                      r.dispose();
                                      _seized.removeAt(i);
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        AppRichEditor(
                          label: 'Biện pháp giải quyết',
                          controller: _handlingCtrl,
                          height: 120,
                        ),
                        const SizedBox(height: 12),
                        AppRichEditor(
                          label: 'Khởi tố về hành vi',
                          controller: _prosecutedCtrl,
                          height: 120,
                        ),
                      ] else ...[
                        AppTextField(
                          label: 'Kết quả giải quyết',
                          hint: '',
                          controller: _resultsCtrl,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Hình thức xử phạt',
                                hint: '',
                                controller: _punishmentCtrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Mức phạt (VND)',
                                hint: '',
                                controller: _penaltyCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Ghi chú',
                          hint: '',
                          controller: _noteCtrl,
                          maxLines: 2,
                        ),
                      ],

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tài liệu / Tang chứng',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _pickEvidence,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Thêm tệp'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_evidenceUrls.isEmpty)
                        Text(
                          'Không có',
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _evidenceUrls.map((u) {
                            final url = u.toString();
                            return Stack(
                              children: [
                                Container(
                                  width: 170,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _isImageUrl(url)
                                        ? Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, st) => Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                url,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _evidenceUrls.remove(url),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      if (_newEvidenceFiles.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Tệp mới: ${_newEvidenceFiles.length}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _newEvidenceFiles
                              .map(
                                (f) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    f.name,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4D3E),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: isLoading ? null : () => _save(detail),
                            child: const Text('Lưu'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SeizedItemRow {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  _SeizedItemRow();

  factory _SeizedItemRow.fromJson(Map<String, dynamic> json) {
    final r = _SeizedItemRow();
    r.nameCtrl.text = json['name']?.toString() ?? '';
    r.qtyCtrl.text = (json['quantity'] == null)
        ? ''
        : json['quantity'].toString();
    r.unitCtrl.text = json['unit']?.toString() ?? '';
    r.noteCtrl.text = json['note']?.toString() ?? '';
    return r;
  }

  Map<String, dynamic> toJson() {
    final qty = double.tryParse(qtyCtrl.text.trim());
    return {
      'name': nameCtrl.text.trim(),
      'quantity': qty,
      'unit': unitCtrl.text.trim(),
      'note': noteCtrl.text.trim(),
    };
  }

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    unitCtrl.dispose();
    noteCtrl.dispose();
  }
}

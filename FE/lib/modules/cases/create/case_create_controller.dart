import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:starter/widgets/dashboard/sidebar.dart';
import '../../../core/base_controller.dart';
import '../../../repositories/incident_repository.dart';
import '../../../repositories/station_repository.dart';
import '../../../models/station_model.dart';
import '../../../routes/app_pages.dart';
import '../../dashboard/dashboard_nav_controller.dart';
import '../list/case_list_controller.dart';

class CaseCreateController extends BaseController {
  final IncidentRepository _repo;
  final StationRepository _stationRepo;
  CaseCreateController(this._repo, this._stationRepo);

  String _fileKey(PlatformFile f) {
    final p = f.path ?? '';
    return '${f.name}|${f.size}|$p';
  }

  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // Classification
  final RxString incidentType = 'criminal'.obs; // criminal | administrative
  final RxString severity = 'medium'.obs; // low | medium | high | critical

  // Station
  final RxList<StationModel> stations = <StationModel>[].obs;
  final RxString stationId = ''.obs; // '' = none

  // Administrative
  final resultsCtrl = TextEditingController();
  final punishmentCtrl = TextEditingController();
  final penaltyCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  // Criminal
  final handlingMeasureCtrl = TextEditingController();
  final prosecutedBehaviorCtrl = TextEditingController();

  final RxList<SeizedItemForm> seizedItems = <SeizedItemForm>[].obs;

  final RxList<PlatformFile> pickedFiles = <PlatformFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadStations();
    if (seizedItems.isEmpty) addSeizedItem();
  }

  Future<void> pickEvidenceFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      final existingKeys = pickedFiles.map(_fileKey).toSet();
      final merged = <PlatformFile>[...pickedFiles];
      for (final f in result.files) {
        final k = _fileKey(f);
        if (existingKeys.contains(k)) continue;
        existingKeys.add(k);
        merged.add(f);
      }
      pickedFiles.assignAll(merged);
    } catch (e) {
      showError(e.toString());
    }
  }

  void removePickedFile(int index) {
    if (index < 0 || index >= pickedFiles.length) return;
    pickedFiles.removeAt(index);
  }

  Future<void> _loadStations() async {
    try {
      stations.assignAll(await _stationRepo.list());
    } catch (_) {
      // ignore: station selection is optional
    }
  }

  Future<void> reloadStations() async {
    await _loadStations();
  }

  void addSeizedItem() {
    seizedItems.add(SeizedItemForm());
  }

  void removeSeizedItem(int index) {
    if (index < 0 || index >= seizedItems.length) return;
    seizedItems[index].dispose();
    seizedItems.removeAt(index);
    if (seizedItems.isEmpty) addSeizedItem();
  }

  final Rx<DateTime?> date = Rx<DateTime?>(null);

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date.value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) date.value = picked;
  }

  Future<void> submit() async {
    if (titleCtrl.text.trim().isEmpty || locationCtrl.text.trim().isEmpty || descriptionCtrl.text.trim().isEmpty) {
      showError('Vui lòng nhập đủ: tiêu đề, địa bàn, nội dung');
      return;
    }

    setLoading(true);
    try {
      final selectedStation = stations.firstWhereOrNull((s) => s.stationId == stationId.value);
      final payload = <String, dynamic>{
        'incident_type': incidentType.value,
        'severity': severity.value,
        'occurred_at': date.value?.toIso8601String() ?? '',
        'title': titleCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'station_id': stationId.value,
        'station_name': selectedStation?.name ?? '',
      };

      if (incidentType.value == 'criminal') {
        final items = seizedItems
            .map((f) => f.toJson())
            .where((m) => (m['name'] as String).trim().isNotEmpty)
            .toList();
        payload.addAll({
          'handling_measure': handlingMeasureCtrl.text.trim(),
          'prosecuted_behavior': prosecutedBehaviorCtrl.text.trim(),
          'seized_items': items,
        });
      } else {
        payload.addAll({
          'results': resultsCtrl.text.trim(),
          'form_of_punishment': punishmentCtrl.text.trim(),
          'penalty_amount': double.tryParse(penaltyCtrl.text.trim()) ?? 0.0,
          'note': noteCtrl.text.trim(),
        });
      }

      final created = await _repo.create(payload);
      if (created == null) {
        throw Exception('Tạo chuyên án thất bại');
      }

      if (pickedFiles.isNotEmpty) {
        await _repo.uploadEvidenceFiles(created.incidentId, pickedFiles.toList());
      }

      // If running inside DashboardShell, refresh list and switch tab.
      if (Get.isRegistered<DashboardNavController>()) {
        final nav = Get.find<DashboardNavController>();
        if (Get.isRegistered<CaseListController>()) {
          await Get.find<CaseListController>().fetch();
        }
        nav.select(SidebarItemKey.cases);
        return;
      }

      Get.offAllNamed(Routes.caseList);
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    locationCtrl.dispose();
    descriptionCtrl.dispose();
    resultsCtrl.dispose();
    punishmentCtrl.dispose();
    penaltyCtrl.dispose();
    noteCtrl.dispose();
    handlingMeasureCtrl.dispose();
    prosecutedBehaviorCtrl.dispose();
    for (final f in seizedItems) {
      f.dispose();
    }
    super.onClose();
  }
}

class SeizedItemForm {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

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

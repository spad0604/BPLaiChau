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
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

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
  final descriptionCtrl = QuillController.basic();

  final dateTextCtrl = TextEditingController();
  Worker? _dateWorker;

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
  final handlingMeasureCtrl = QuillController.basic();
  final prosecutedBehaviorCtrl = QuillController.basic();

  final RxList<SeizedItemForm> seizedItems = <SeizedItemForm>[].obs;

  final RxList<PlatformFile> pickedFiles = <PlatformFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadStations();
    if (seizedItems.isEmpty) addSeizedItem();

    _dateWorker?.dispose();
    _dateWorker = ever<DateTime?>(date, (d) {
      if (d == null) {
        dateTextCtrl.text = '';
      } else {
        dateTextCtrl.text =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      }
    });

    // Disable adding new lines on Enter for single-line inputs if we wanted to enforce it,
    // but these are multi-line fields so defaults are fine.
  }

  Future<void> pickEvidenceFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
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

  String _quillToHtml(QuillController controller) {
    if (controller.document.isEmpty()) return '';
    final delta = controller.document.toDelta().toJson();
    final converter = QuillDeltaToHtmlConverter(
      delta,
      ConverterOptions.forEmail(),
    );
    return converter.convert();
  }

  Future<void> submit() async {
    // Validate Quill content manually since we can't use Form validator easily
    final descHtml = _quillToHtml(descriptionCtrl);
    final descPlainText = descriptionCtrl.document.toPlainText().trim();

    if (titleCtrl.text.trim().isEmpty ||
        locationCtrl.text.trim().isEmpty ||
        descPlainText.isEmpty) {
      showError('Vui lòng nhập đủ: tiêu đề, địa bàn, nội dung');
      return;
    }

    setLoading(true);
    try {
      final selectedStation = stations.firstWhereOrNull(
        (s) => s.stationId == stationId.value,
      );
      final payload = <String, dynamic>{
        'incident_type': incidentType.value,
        'severity': severity.value,
        'occurred_at': date.value?.toIso8601String() ?? '',
        'title': titleCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'description': descHtml,
        'station_id': stationId.value,
        'station_name': selectedStation?.name ?? '',
      };

      if (incidentType.value == 'criminal') {
        final items = seizedItems
            .map((f) => f.toJson())
            .where((m) => (m['name'] as String).trim().isNotEmpty)
            .toList();

        final handlingHtml = _quillToHtml(handlingMeasureCtrl);
        final prosecutedHtml = _quillToHtml(prosecutedBehaviorCtrl);

        payload.addAll({
          'handling_measure': handlingHtml,
          'prosecuted_behavior': prosecutedHtml,
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
        await _repo.uploadEvidenceFiles(
          created.incidentId,
          pickedFiles.toList(),
        );
      }

      // Clear all form fields after successful creation
      _clearForm();

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

  void _clearForm() {
    titleCtrl.clear();
    locationCtrl.clear();
    descriptionCtrl.clear();
    dateTextCtrl.clear();
    date.value = null;

    resultsCtrl.clear();
    punishmentCtrl.clear();
    penaltyCtrl.clear();
    noteCtrl.clear();

    handlingMeasureCtrl.clear();
    prosecutedBehaviorCtrl.clear();

    pickedFiles.clear();

    for (final item in seizedItems) {
      item.dispose();
    }
    seizedItems.clear();
    addSeizedItem();

    incidentType.value = 'criminal';
    severity.value = 'medium';
    stationId.value = '';
  }

  @override
  void onClose() {
    _dateWorker?.dispose();
    dateTextCtrl.dispose();
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

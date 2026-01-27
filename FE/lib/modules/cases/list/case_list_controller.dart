import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/base_controller.dart';
import '../../../models/incident_model.dart';
import '../../../repositories/incident_repository.dart';
import '../../../repositories/station_repository.dart';
import '../../../models/station_model.dart';

class CaseListController extends BaseController {
  final IncidentRepository _repo;
  final StationRepository _stationRepo;
  CaseListController(this._repo, this._stationRepo);

  final RxList<IncidentModel> items = <IncidentModel>[].obs;
  final RxString query = ''.obs;

  final RxList<StationModel> stations = <StationModel>[].obs;
  final RxString stationIdFilter = ''.obs; // '' = all
  final RxString statusFilter = ''.obs; // '' = all
  final RxString incidentTypeFilter = ''.obs; // '' = all, 'criminal', 'administrative'
  final RxInt yearFilter = 0.obs; // 0 = all

  final RxInt total = 0.obs;
  final RxInt inProgress = 0.obs;
  final RxInt urgent = 0.obs;
  final RxInt completedThisMonth = 0.obs;

  Worker? _queryWorker;
  Worker? _filtersWorker;

  @override
  void onInit() {
    super.onInit();
    _loadStations();

    _queryWorker = debounce(
      query,
      (_) => fetch(),
      time: const Duration(milliseconds: 350),
    );
    _filtersWorker = everAll([stationIdFilter, statusFilter, incidentTypeFilter, yearFilter], (_) => fetch());

    fetch();
  }

  Future<void> _loadStations() async {
    try {
      stations.assignAll(await _stationRepo.list());
    } catch (_) {
      // ignore: stations filter is optional
    }
  }

  Future<void> reloadStations() async {
    await _loadStations();
  }

  Future<void> fetch() async {
    setLoading(true);
    try {
      final stationId = stationIdFilter.value;
      final status = statusFilter.value;
      final incidentType = incidentTypeFilter.value;
      final year = yearFilter.value;
      final title = query.value.trim();

      final results = await Future.wait([
        _repo.list(stationId: stationId, year: year, status: status, incidentType: incidentType, title: title),
        _repo.stats(stationId: stationId, year: year, title: title),
      ]);

      final list = results[0] as List<IncidentModel>;
      final stats = results[1] as Map<String, dynamic>;

      items.assignAll(list);
      total.value = (stats['total'] as int?) ?? int.tryParse('${stats['total'] ?? 0}') ?? 0;
      inProgress.value = (stats['in_progress'] as int?) ?? int.tryParse('${stats['in_progress'] ?? 0}') ?? 0;
      urgent.value = (stats['urgent'] as int?) ?? int.tryParse('${stats['urgent'] ?? 0}') ?? 0;
      completedThisMonth.value =
          (stats['completed_this_month'] as int?) ?? int.tryParse('${stats['completed_this_month'] ?? 0}') ?? 0;
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  List<int> get yearOptions {
    final now = DateTime.now().year;
    return List<int>.generate(8, (i) => now - i);
  }

  Future<void> deleteCase(String id) async {
    setLoading(true);
    try {
      await _repo.delete(id);
      await fetch();
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateCase(String id, Map<String, dynamic> updates) async {
    setLoading(true);
    try {
      await _repo.update(id, updates);
      await fetch();
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> fetchCaseDetail(String id) async {
    try {
      return await _repo.getDetailMap(id);
    } catch (e) {
      showError(e.toString());
      return null;
    }
  }

  Future<List<String>> appendEvidence(String id, List<PlatformFile> files) async {
    try {
      return await _repo.uploadEvidenceFiles(id, files);
    } catch (e) {
      showError(e.toString());
      return [];
    }
  }

  @override
  void onClose() {
    _queryWorker?.dispose();
    _filtersWorker?.dispose();
    super.onClose();
  }
}

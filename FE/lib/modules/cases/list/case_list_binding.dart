import 'package:get/get.dart';
import '../../../repositories/incident_repository.dart';
import '../../../repositories/station_repository.dart';
import 'case_list_controller.dart';

class CaseListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaseListController>(() => CaseListController(Get.find<IncidentRepository>(), Get.find<StationRepository>()));
  }
}

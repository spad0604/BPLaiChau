import 'package:get/get.dart';
import '../../../repositories/incident_repository.dart';
import '../../../repositories/station_repository.dart';
import 'case_create_controller.dart';

class CaseCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaseCreateController>(() => CaseCreateController(Get.find<IncidentRepository>(), Get.find<StationRepository>()));
  }
}

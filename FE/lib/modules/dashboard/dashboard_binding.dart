import 'package:get/get.dart';

import '../../repositories/admin_repository.dart';
import '../../repositories/incident_repository.dart';
import '../../repositories/station_repository.dart';
import '../admin/users/user_management_controller.dart';
import '../cases/create/case_create_controller.dart';
import '../cases/list/case_list_controller.dart';
import '../stations/station_management_controller.dart';
import 'dashboard_nav_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardNavController(), permanent: true);

    // Controllers used inside the dashboard tabs
    Get.lazyPut<CaseListController>(() => CaseListController(Get.find<IncidentRepository>(), Get.find<StationRepository>()), fenix: true);
    Get.lazyPut<CaseCreateController>(() => CaseCreateController(Get.find<IncidentRepository>(), Get.find<StationRepository>()), fenix: true);
    Get.lazyPut<StationManagementController>(() => StationManagementController(Get.find<StationRepository>()), fenix: true);
    Get.lazyPut<UserManagementController>(() => UserManagementController(Get.find<AdminRepository>()), fenix: true);
  }
}

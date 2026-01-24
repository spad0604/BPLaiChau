import 'package:get/get.dart';
import '../core/dio_provider.dart';
import '../services/api_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/incident_repository.dart';
import '../repositories/admin_repository.dart';
import '../repositories/station_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(DioProvider.dio), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut<IncidentRepository>(() => IncidentRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut<AdminRepository>(() => AdminRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut<StationRepository>(() => StationRepository(Get.find<ApiService>()), fenix: true);
  }
}

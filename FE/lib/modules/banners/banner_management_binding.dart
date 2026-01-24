import 'package:get/get.dart';

import '../../repositories/banner_repository.dart';
import 'banner_management_controller.dart';

class BannerManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BannerManagementController>(() => BannerManagementController(Get.find<BannerRepository>()), fenix: true);
  }
}

import 'package:get/get.dart';
import '../../widgets/dashboard/sidebar.dart';
import '../cases/create/case_create_controller.dart';
import '../cases/list/case_list_controller.dart';

class DashboardNavController extends GetxController {
  final Rx<SidebarItemKey> active = SidebarItemKey.cases.obs;

  void select(SidebarItemKey key) {
    active.value = key;

    // Ensure station dropdowns reflect newest data after station CRUD.
    if (key == SidebarItemKey.createCase &&
        Get.isRegistered<CaseCreateController>()) {
      Get.find<CaseCreateController>().reloadStations();
    }
    if (key == SidebarItemKey.cases && Get.isRegistered<CaseListController>()) {
      Get.find<CaseListController>().reloadStations();
    }
  }

  String get breadcrumb {
    switch (active.value) {
      case SidebarItemKey.cases:
        return 'nav.breadcrumb.cases'.tr;
      case SidebarItemKey.createCase:
        return 'nav.breadcrumb.createCase'.tr;
      case SidebarItemKey.stations:
        return 'nav.breadcrumb.stations'.tr;
      case SidebarItemKey.userManagement:
        return 'nav.breadcrumb.users'.tr;
      case SidebarItemKey.banners:
        return 'nav.breadcrumb.banners'.tr;
      case SidebarItemKey.legalDocs:
        return 'nav.breadcrumb.legalDocs'.tr;
    }
  }

  String get title {
    switch (active.value) {
      case SidebarItemKey.cases:
        return 'nav.title.cases'.tr;
      case SidebarItemKey.createCase:
        return 'nav.title.createCase'.tr;
      case SidebarItemKey.stations:
        return 'nav.title.stations'.tr;
      case SidebarItemKey.userManagement:
        return 'nav.title.users'.tr;
      case SidebarItemKey.banners:
        return 'nav.title.banners'.tr;
      case SidebarItemKey.legalDocs:
        return 'nav.title.legalDocs'.tr;
    }
  }
}

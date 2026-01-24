import 'package:get/get.dart';
import '../../widgets/dashboard/sidebar.dart';
import '../cases/create/case_create_controller.dart';
import '../cases/list/case_list_controller.dart';

class DashboardNavController extends GetxController {
  final Rx<SidebarItemKey> active = SidebarItemKey.cases.obs;

  void select(SidebarItemKey key) {
    active.value = key;

    // Ensure station dropdowns reflect newest data after station CRUD.
    if (key == SidebarItemKey.createCase && Get.isRegistered<CaseCreateController>()) {
      Get.find<CaseCreateController>().reloadStations();
    }
    if (key == SidebarItemKey.cases && Get.isRegistered<CaseListController>()) {
      Get.find<CaseListController>().reloadStations();
    }
  }

  String get breadcrumb {
    switch (active.value) {
      case SidebarItemKey.cases:
        return 'Trang chủ  /  Quản lý chuyên án';
      case SidebarItemKey.createCase:
        return 'Hệ thống  /  Quản lý vụ việc  /  Thêm mới';
      case SidebarItemKey.stations:
        return 'Hệ thống  /  Danh mục  /  Đồn biên phòng';
      case SidebarItemKey.userManagement:
        return 'Home  /  Administration  /  Users';
      case SidebarItemKey.banners:
        return 'Hệ thống  /  Banner';
    }
  }

  String get title {
    switch (active.value) {
      case SidebarItemKey.cases:
        return 'Danh sách chuyên án';
      case SidebarItemKey.createCase:
        return 'Thêm vụ việc mới';
      case SidebarItemKey.stations:
        return 'Quản lý đồn biên phòng';
      case SidebarItemKey.userManagement:
        return 'Personnel Access Control';
      case SidebarItemKey.banners:
        return 'Quản lý banner';
    }
  }
}

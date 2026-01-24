import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/dashboard/dashboard_layout.dart';
import '../../widgets/dashboard/sidebar.dart';
import '../../widgets/dashboard/top_bar.dart';
import '../admin/users/user_management_view.dart';
import '../cases/create/case_create_view.dart';
import '../cases/list/case_list_view.dart';
import '../stations/station_management_view.dart';
import 'dashboard_nav_controller.dart';

class DashboardShell extends GetView<DashboardNavController> {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.active.value;

      return DashboardLayout(
        active: active,
        onSelect: controller.select,
        child: Column(
          children: [
            DashboardTopBar(breadcrumb: controller.breadcrumb, title: controller.title),
            Expanded(
              child: IndexedStack(
                index: _indexOf(active),
                children: const [
                  CaseListView(embedded: true),
                  CaseCreateView(embedded: true),
                  StationManagementView(embedded: true),
                  UserManagementView(embedded: true),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  int _indexOf(SidebarItemKey key) {
    switch (key) {
      case SidebarItemKey.cases:
        return 0;
      case SidebarItemKey.createCase:
        return 1;
      case SidebarItemKey.stations:
        return 2;
      case SidebarItemKey.userManagement:
        return 3;
    }
  }
}

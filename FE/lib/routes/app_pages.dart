import 'package:get/get.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_shell.dart';

part 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),

    // Keep old paths for compatibility (they render the same dashboard shell)
    GetPage(
      name: Routes.caseList,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.caseCreate,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.stations,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.userManagement,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.banners,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.legalDocs,
      page: () => const DashboardShell(),
      binding: DashboardBinding(),
    ),
  ];
}

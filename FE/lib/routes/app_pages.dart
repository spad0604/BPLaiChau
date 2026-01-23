import 'package:get/get.dart';
import '../views/home_view.dart';
import '../controllers/home_controller.dart';

part 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.HOME, page: () => HomeView(), binding: HomeBinding()),
  ];
}

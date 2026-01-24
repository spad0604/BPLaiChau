import 'package:get/get.dart';
import '../../../../repositories/user_repository.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController(Get.find<UserRepository>()));
  }
}

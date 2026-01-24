import 'package:get/get.dart';
import '../../../../repositories/user_repository.dart';
import '../../../../core/base_controller.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends BaseController {
  final UserRepository _repo;
  LoginController(this._repo);

  var username = ''.obs;
  var password = ''.obs;
  var obscurePassword = true.obs;

  void togglePassword() => obscurePassword.toggle();

  Future<void> login() async {
    if (username.value.isEmpty || password.value.isEmpty) {
      showError("Vui lòng nhập tài khoản và mật khẩu");
      return;
    }

    setLoading(true);
    try {
      await _repo.login(username.value, password.value);
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

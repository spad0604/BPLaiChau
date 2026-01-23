import 'package:get/get.dart';

/// Base controller for GetX MVC-style controllers.
/// Provide common helpers: loading state, error handling, simple navigation helpers.
class BaseController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void setLoading(bool v) {
    _isLoading.value = v;
    update();
  }

  void showError(String message) {
    // default error behavior: show snackbar
    Get.snackbar('Error', message);
  }

  void navigateTo(String routeName, {dynamic arguments}) {
    Get.toNamed(routeName, arguments: arguments);
  }

  void back([result]) => Get.back(result: result);
}

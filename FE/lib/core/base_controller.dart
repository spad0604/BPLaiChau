import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Base controller for GetX MVC-style controllers.
/// Provide common helpers: loading state, error handling, simple navigation helpers.
class BaseController extends GetxController {
  final RxBool isLoadingRx = false.obs;
  bool get isLoading => isLoadingRx.value;

  void setLoading(bool v) {
    isLoadingRx.value = v;
    update();
  }

  void showError(String message, {String title = 'Lỗi'}) {
    _snack(
      title: title,
      message: message,
      background: const Color(0xFFD32F2F),
      icon: Icons.error_outline,
    );
  }

  void showSuccess(String message, {String title = 'Thành công'}) {
    _snack(
      title: title,
      message: message,
      background: const Color(0xFF1B4D3E),
      icon: Icons.check_circle_outline,
    );
  }

  void showInfo(String message, {String title = 'Thông báo'}) {
    _snack(
      title: title,
      message: message,
      background: const Color(0xFF1565C0),
      icon: Icons.info_outline,
    );
  }

  void _snack({
    required String title,
    required String message,
    required Color background,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: background.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      boxShadows: const [
        BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6)),
      ],
    );
  }

  void navigateTo(String routeName, {dynamic arguments}) {
    Get.toNamed(routeName, arguments: arguments);
  }

  void back([dynamic result]) => Get.back(result: result);
}

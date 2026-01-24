import 'package:get/get.dart';
import 'dart:async';
import '../../../../repositories/user_repository.dart';
import '../../../../repositories/banner_repository.dart';
import '../../../../core/base_controller.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends BaseController {
  final UserRepository _repo;
  final BannerRepository _bannerRepo;
  LoginController(this._repo, this._bannerRepo);

  var username = ''.obs;
  var password = ''.obs;
  var obscurePassword = true.obs;

  final RxList<String> bannerUrls = <String>[].obs;
  final RxInt bannerIndex = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final list = await _bannerRepo.list();
      final urls = <String>[];
      for (final b in list) {
        final u = (b['image_url'] ?? '').toString();
        if (u.isNotEmpty) urls.add(u);
      }
      bannerUrls.assignAll(urls);

      _timer?.cancel();
      if (bannerUrls.length >= 2) {
        _timer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (bannerUrls.isEmpty) return;
          bannerIndex.value = (bannerIndex.value + 1) % bannerUrls.length;
        });
      }
    } catch (_) {
      // ignore: banners are optional; fallback to default image
    }
  }

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

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

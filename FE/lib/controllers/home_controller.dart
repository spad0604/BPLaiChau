import '../core/base_controller.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';
import '../core/dio_provider.dart';

class HomeController extends BaseController {
  final RxInt counter = 0.obs;
  final UserRepository repo;

  HomeController(this.repo);

  void increment() {
    counter.value++;
    update();
  }

  final Rxn<UserModel> user = Rxn<UserModel>();

  Future<void> loginDemo() async {
    setLoading(true);
    try {
      final u = await repo.login('admin', 'changeme');
      user.value = u;
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(DioProvider.dio), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(Get.find()));
  }
}

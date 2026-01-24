import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../core/base_controller.dart';
import '../../repositories/banner_repository.dart';

class BannerManagementController extends BaseController {
  final BannerRepository _repo;
  BannerManagementController(this._repo);

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    setLoading(true);
    try {
      items.assignAll(await _repo.list());
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> uploadOne() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false, withData: true);
    if (result == null || result.files.isEmpty) return;

    setLoading(true);
    try {
      final banner = await _repo.upload(file: result.files.first);
      if (banner != null) {
        await fetch();
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    setLoading(true);
    try {
      await _repo.delete(bannerId);
      await fetch();
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

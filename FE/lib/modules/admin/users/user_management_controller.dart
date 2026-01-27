import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/base_controller.dart';
import '../../../repositories/admin_repository.dart';

class UserManagementController extends BaseController {
  final AdminRepository _repo;
  UserManagementController(this._repo);

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  final fullNameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final idCardCtrl = TextEditingController();

  // 0: Female, 1: Male
  final RxInt gender = 0.obs;
  final RxString role = 'admin'.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    setLoading(true);
    try {
      final list = await _repo.listPublicAdmins();
      items.assignAll(list);
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> createAccount() async {
    if (usernameCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
      showError('admins.validation.usernamePassword'.tr);
      return;
    }
    setLoading(true);
    try {
      await _repo.createAdmin({
        'username': usernameCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'full_name': fullNameCtrl.text.trim(),
        'phone_number': phoneCtrl.text.trim(),
        'date_of_birth': dobCtrl.text.trim(),
        'indentity_card_number': idCardCtrl.text.trim(),
        'gender': gender.value,
        'role': role.value,
      });
      await fetch();
      usernameCtrl.clear();
      passwordCtrl.clear();
      fullNameCtrl.clear();
      phoneCtrl.clear();
      dobCtrl.clear();
      idCardCtrl.clear();
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateUser(String username, Map<String, dynamic> updates) async {
    setLoading(true);
    try {
      await _repo.updateAdmin(username, updates);
      await fetch();
      showSuccess('admins.updated'.tr);
      return true;
    } catch (e) {
      showError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteUser(String username) async {
    setLoading(true);
    try {
      await _repo.deleteAdmin(username);
      await fetch();
      showSuccess('admins.deleted'.tr);
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    idCardCtrl.dispose();
    super.onClose();
  }
}

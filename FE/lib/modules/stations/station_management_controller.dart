import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base_controller.dart';
import '../../models/station_model.dart';
import '../../repositories/station_repository.dart';

class StationManagementController extends BaseController {
  final StationRepository _repo;
  StationManagementController(this._repo);

  final RxList<StationModel> items = <StationModel>[].obs;

  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

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

  Future<void> create() async {
    if (nameCtrl.text.trim().isEmpty) {
      showError('Vui lòng nhập tên đồn');
      return;
    }
    setLoading(true);
    try {
      await _repo.create({
        'name': nameCtrl.text.trim(),
        'code': codeCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
      });
      await fetch();
      nameCtrl.clear();
      codeCtrl.clear();
      addressCtrl.clear();
      phoneCtrl.clear();
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateStation(String id, Map<String, dynamic> updates) async {
    setLoading(true);
    try {
      await _repo.update(id, updates);
      await fetch();
      showSuccess('Đã cập nhật đồn');
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteStation(String id) async {
    setLoading(true);
    try {
      await _repo.delete(id);
      await fetch();
      showSuccess('Đã xoá đồn');
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}

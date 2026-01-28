import 'package:get/get.dart';
import 'legal_docs_controller.dart';

class LegalDocsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalDocsController>(() => LegalDocsController());
  }
}

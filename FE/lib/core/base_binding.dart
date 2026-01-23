import 'package:get/get.dart';

/// Simple binding that can be extended to lazily put controllers/services.
class BaseBinding extends Bindings {
  @override
  void dependencies() {
    // override in concrete bindings
  }
}

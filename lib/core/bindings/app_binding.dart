import 'package:get/get.dart';

import '../../controller/browser_controller.dart';
import '../../controller/prefrence_controller.dart';
import '../../controller/product_controller.dart';


class AppBinding extends Bindings {
  @override
  void dependencies() {

    Get.put<PreferenceController>(
      PreferenceController(),
      permanent: true,
    );
    Get.put<ProductController>(
      ProductController(),
      permanent: true,
    );
    Get.put<BrowserController>(
      BrowserController(),
      permanent: true,
    );
  }
}
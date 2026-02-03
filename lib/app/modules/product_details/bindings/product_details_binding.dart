import 'package:get/get.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Используем lazyPut для оптимальной загрузки контроллера
    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(),
      fenix: true, // контроллер восстанавливается при удалении из памяти
    );
  }
}

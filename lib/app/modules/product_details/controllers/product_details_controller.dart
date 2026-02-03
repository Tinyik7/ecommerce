import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../base/controllers/base_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsController extends GetxController {
  late final ProductModel product = Get.arguments;
  String selectedSize = 'M';

  Future<void> onFavoriteButtonPressed() async {
    try {
      final baseController = Get.find<BaseController>();
      await baseController.onFavoriteButtonPressed(product: product);
      update(['FavoriteButton']);
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось обновить избранное: $e');
    }
  }

  Future<void> onAddToCartPressed() async {
    try {
      final cartController = Get.find<CartController>();

      if (!product.inCart) {
        product.inCart = true;
        product.quantity = 1;
        product.size = selectedSize;

        await cartController.addProductToCart(product);
        Get.snackbar('Корзина', '${product.name ?? "Товар"} добавлен');
      } else {
        Get.snackbar('Корзина', '${product.name ?? "Товар"} уже в корзине');
      }

      update(['CartButton']);
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось добавить товар: $e');
    }
  }

  void changeSelectedSize(String size) {
    if (size == selectedSize) return;
    selectedSize = size;
    update(['Size']);
  }
}

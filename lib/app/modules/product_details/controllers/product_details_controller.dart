import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../base/controllers/base_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsController extends GetxController {
  late final ProductModel product = Get.arguments;
  String selectedSize = 'M';
  CartController? _cartController;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<CartController>()) {
      _cartController = Get.find<CartController>();
      _cartController?.syncProductState(product);
    }
  }

  Future<void> onFavoriteButtonPressed() async {
    try {
      final baseController = Get.find<BaseController>();
      await baseController.onFavoriteButtonPressed(product: product);
      update(['FavoriteButton']);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite: $e');
    }
  }

  Future<void> onAddToCartPressed() async {
    try {
      final cartController = _cartController ?? Get.find<CartController>();
      cartController.syncProductState(product);

      if (!product.inCart) {
        product.inCart = true;
        product.quantity = 1;
        product.size = selectedSize;

        await cartController.addProductToCart(product);
        cartController.syncProductState(product);
        Get.snackbar('Cart', '${product.name ?? "Product"} added');
      } else {
        Get.snackbar('Cart', '${product.name ?? "Product"} is already in cart');
      }

      update(['CartButton']);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    }
  }

  void changeSelectedSize(String size) {
    if (size == selectedSize) return;
    selectedSize = size;
    update(['Size']);
  }
}

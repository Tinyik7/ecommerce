import 'package:get/get.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../../data/models/product_model.dart';

class BaseController extends GetxController {
  int currentIndex = 0;

  void changeScreen(int selectedIndex) {
    currentIndex = selectedIndex;
    update();
  }

  Future<void> onFavoriteButtonPressed({required ProductModel product}) async {
    final favoritesController = Get.find<FavoritesController>();

    if (product.isFavorite == true) {
      await favoritesController.removeFavorite(product);
      product.isFavorite = false;
    } else {
      await favoritesController.addFavorite(product);
      product.isFavorite = true;
    }

    await favoritesController.fetchFavorites();
    update(['FavoriteButton']);
  }
}

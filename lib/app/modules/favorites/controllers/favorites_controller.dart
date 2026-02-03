import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/local/local_database_service.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_client.dart';

class FavoritesController extends GetxController {
  List<ProductModel> products = <ProductModel>[];

  final String favoritesUrl = 'http://localhost:8080/api/v1/favorites';
  int get _userId => MySharedPref.getInt('user_id') ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final int userId = _userId;
    if (userId == 0) return;

    try {
      final response = await http.get(
        Uri.parse('$favoritesUrl/$userId'),
        headers: ApiClient.authHeaders(),
      );

      if (response.statusCode == 401) {
        ApiClient.handleUnauthorized();
        return;
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        products = data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .map((product) => product..isFavorite = true)
            .toList();

        for (final product in products) {
          if (product.id != null) {
            await LocalDatabaseService.setFavorite(product.id!, true);
          }
        }
      }
    } catch (e) {
      final cachedIds = await LocalDatabaseService.readFavoriteIds();
      final cachedProducts = await LocalDatabaseService.readProducts();
      products = cachedProducts
          .where(
              (product) => product.id != null && cachedIds.contains(product.id))
          .map((product) => product..isFavorite = true)
          .toList();
    } finally {
      update();
    }
  }

  Future<void> addFavorite(ProductModel product) async {
    final int userId = _userId;
    if (userId == 0 || product.id == null) return;

    try {
      final response = await http.post(
        Uri.parse('$favoritesUrl/$userId/add'),
        headers: ApiClient.authHeaders(),
        body: jsonEncode({'productId': product.id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        product.isFavorite = true;
        products.add(product);
        await LocalDatabaseService.setFavorite(product.id!, true);
        update();
      }
    } catch (_) {}
  }

  Future<void> removeFavorite(ProductModel product) async {
    final int userId = _userId;
    if (userId == 0 || product.id == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$favoritesUrl/$userId/remove/${product.id}'),
        headers: ApiClient.authHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        products.removeWhere((p) => p.id == product.id);
        await LocalDatabaseService.setFavorite(product.id!, false);
        update();
      }
    } catch (_) {}
  }
}



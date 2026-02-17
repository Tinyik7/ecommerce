import 'dart:convert';

import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../data/local/local_database_service.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_client.dart';
import '../../base/controllers/base_controller.dart';

class CartController extends GetxController {
  List<ProductModel> products = <ProductModel>[];
  double total = 0.0;
  final RxSet<int> cartProductIds = <int>{}.obs;

  final String baseUrl = 'http://localhost:8080/api/v1/cart';

  final isSyncing = false.obs;
  final isOffline = false.obs;

  int get _userId => MySharedPref.getInt('user_id') ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final int userId = _userId;
    if (userId == 0) return;

    try {
      isSyncing.value = true;
      update();
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/$userId'),
        headers: ApiClient.authHeaders(),
      );

      if (response.statusCode == 200) {
        _hydrateFromResponse(response.body);
        isOffline.value = false;
        await _cacheCart();
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } on ApiException {
      final cached = await LocalDatabaseService.readCartItems();
      products
        ..clear()
        ..addAll(cached);
      _recalculateTotal();
      isOffline.value = true;
    } catch (e) {
      final cached = await LocalDatabaseService.readCartItems();
      products
        ..clear()
        ..addAll(cached);
      _recalculateTotal();
      isOffline.value = true;
    } finally {
      isSyncing.value = false;
      update();
    }
  }

  Future<void> addProductToCart(ProductModel product) async {
    final int userId = _userId;
    if (userId == 0 || product.id == null) return;

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/$userId/add'),
        headers: ApiClient.authHeaders(),
        body: jsonEncode({
          'productId': product.id,
          'quantity': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _hydrateFromResponse(response.body);
        await _cacheCart();
        if (product.id != null) {
          cartProductIds.add(product.id!);
        }
        product.inCart = true;
        CustomSnackBar.showCustomSnackBar(
          title: 'Cart',
          message: '${product.name ?? 'Product'} added',
        );
      }
    } catch (_) {
      final index = products.indexWhere((p) => p.id == product.id);
      ProductModel target;
      if (index >= 0) {
        target = products[index];
        target.quantity = (target.quantity ?? 0) + 1;
      } else {
        product.inCart = true;
        product.quantity = (product.quantity ?? 0) + 1;
        if (product.id != null) {
          cartProductIds.add(product.id!);
        }
        products.add(product);
        target = product;
      }
      _recalculateTotal();
      await LocalDatabaseService.upsertCartItem(target);
      isOffline.value = true;
    } finally {
      update();
    }
  }

  Future<void> removeProductFromCart(int productId) async {
    final int userId = _userId;
    if (userId == 0) return;

    try {
      final response = await ApiClient.delete(
        Uri.parse('$baseUrl/$userId/remove/$productId'),
        headers: ApiClient.authHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final removed = products.firstWhereOrNull((p) => (p.id ?? 0) == productId);
        if (removed != null) {
          removed.inCart = false;
          removed.quantity = 0;
        }
        products.removeWhere((p) => (p.id ?? 0) == productId);
        cartProductIds.remove(productId);
        _recalculateTotal();
        await LocalDatabaseService.removeCartItem(productId);
        CustomSnackBar.showCustomSnackBar(
          title: 'Cart',
          message: 'Product removed',
        );
      }
    } catch (_) {
      final removed = products.firstWhereOrNull((p) => (p.id ?? 0) == productId);
      if (removed != null) {
        removed.inCart = false;
        removed.quantity = 0;
      }
      products.removeWhere((p) => (p.id ?? 0) == productId);
      cartProductIds.remove(productId);
      _recalculateTotal();
      await LocalDatabaseService.removeCartItem(productId);
      isOffline.value = true;
    } finally {
      update();
    }
  }

  Future<void> onIncreasePressed(int productId) async {
    final product = products.firstWhereOrNull((p) => (p.id ?? 0) == productId);
    if (product == null) return;
    await addProductToCart(product);
  }

  Future<void> onDecreasePressed(int productId) async {
    final product = products.firstWhereOrNull((p) => (p.id ?? 0) == productId);
    if (product == null) return;

    final currentQty = product.quantity ?? 0;
    if (currentQty > 1) {
      product.quantity = currentQty - 1;
      await _updateQuantity(product);
    } else {
      await removeProductFromCart(productId);
    }
    _recalculateTotal();
    update();
  }

  Future<void> onDeletePressed(int productId) async {
    await removeProductFromCart(productId);
  }

  Future<void> onPurchaseNowPressed() async {
    if (products.isEmpty) return;

    products.clear();
    total = 0;
    cartProductIds.clear();
    await LocalDatabaseService.clearCart();

    Get.find<BaseController>().changeScreen(0);
    CustomSnackBar.showCustomSnackBar(
      title: 'Order placed',
      message: 'Thank you for your purchase!',
    );
    update();
  }

  Future<void> _updateQuantity(ProductModel product) async {
    final int userId = _userId;
    if (userId == 0 || product.id == null) return;

    try {
      final response = await ApiClient.put(
        Uri.parse('$baseUrl/$userId/update/${product.id}'),
        headers: ApiClient.authHeaders(),
        body: jsonEncode({'quantity': product.quantity ?? 1}),
      );

      if (response.statusCode == 200) {
        _hydrateFromResponse(response.body);
        await _cacheCart();
      }
    } catch (_) {
      await LocalDatabaseService.upsertCartItem(product);
      isOffline.value = true;
    }
  }

  void _hydrateFromResponse(String body) {
    final Map<String, dynamic> decoded =
        jsonDecode(body) as Map<String, dynamic>;
    final List<dynamic> items = decoded['items'] as List<dynamic>? ?? [];
    products = items.map((item) {
      final productJson = item['product'] as Map<String, dynamic>? ?? {};
      final product = ProductModel.fromJson(productJson);
      product.quantity = item['quantity'] as int? ?? 1;
      product.inCart = true;
      return product;
    }).toList();
    _syncCartIdsFromProducts();
    _recalculateTotal();
  }

  bool isInCart(int? productId) {
    if (productId == null) return false;
    return cartProductIds.contains(productId);
  }

  void syncProductState(ProductModel product) {
    final int? id = product.id;
    if (id == null) return;
    final bool inCartNow = cartProductIds.contains(id);
    product.inCart = inCartNow;
    if (!inCartNow) {
      product.quantity = 0;
    }
  }

  void _recalculateTotal() {
    total = products.fold<double>(
      0,
      (sum, p) => sum + (p.price ?? 0) * (p.quantity ?? 0),
    );
  }

  Future<void> _cacheCart() async {
    await LocalDatabaseService.clearCart();
    for (final product in products) {
      if (product.id != null) {
        await LocalDatabaseService.upsertCartItem(product);
      }
    }
  }

  void _syncCartIdsFromProducts() {
    cartProductIds
      ..clear()
      ..addAll(products.map((p) => p.id).whereType<int>());
  }
}



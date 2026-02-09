import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/product_model.dart';
import '../../../data/services/api_client.dart';

class AdminController extends GetxController {
  final List<ProductModel> products = <ProductModel>[];
  final String baseUrl = 'http://localhost:8080/api/v1/products';
  final String usersUrl = 'http://localhost:8080/api/v1/users';

  bool isLoading = false;
  bool isSubmitting = false;
  bool isChangingRole = false;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      update();

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'size': '100',
        'sortBy': 'createdAt',
        'sortDir': 'desc',
      });
      final response = await http.get(uri, headers: ApiClient.authHeaders());

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final List<dynamic> items;
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          items = decoded['items'] as List<dynamic>;
        } else if (decoded is List) {
          items = decoded;
        } else {
          items = <dynamic>[];
        }

        products
          ..clear()
          ..addAll(items
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList());
      } else {
        throw Exception('Failed to load products ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('РћС€РёР±РєР°', 'РќРµ СѓРґР°Р»РѕСЃСЊ Р·Р°РіСЂСѓР·РёС‚СЊ С‚РѕРІР°СЂС‹: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> saveProduct({
    int? id,
    required String name,
    required double price,
    required int quantity,
    String? description,
    String? category,
    String? image,
    double? rating,
    String? reviews,
    String? size,
    bool? isFavorite,
    bool? inCart,
    String? brand,
    String? color,
    bool? featured,
    double? discount,
    bool? inStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    try {
      isSubmitting = true;
      update();

      String? clean(String? value) {
        if (value == null) return null;
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }

      final payload = <String, dynamic>{
        'name': name.trim(),
        'price': price,
        'quantity': quantity,
      };

      void put(String key, dynamic value) {
        if (value == null) return;
        payload[key] = value;
      }

      put('description', clean(description));
      put('category', clean(category));
      put('image', clean(image));
      put('rating', rating);
      put('reviews', clean(reviews));
      put('size', clean(size));
      put('brand', clean(brand));
      put('color', clean(color));
      put('discount', discount);
      put('is_favorite', isFavorite);
      put('in_cart', inCart);
      put('featured', featured);
      put('in_stock', inStock);
      put('created_at', createdAt?.toIso8601String());
      put('updated_at', updatedAt?.toIso8601String());
      payload.putIfAbsent('in_stock', () => quantity > 0);

      final headers = ApiClient.authHeaders();
      final uri = id == null ? Uri.parse(baseUrl) : Uri.parse('$baseUrl/$id');

      late http.Response response;
      if (id == null) {
        response =
            await http.post(uri, headers: headers, body: jsonEncode(payload));
      } else {
        response =
            await http.put(uri, headers: headers, body: jsonEncode(payload));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchProducts();
        Get.back();
        Get.snackbar('Р“РѕС‚РѕРІРѕ', 'РўРѕРІР°СЂ СЃРѕС…СЂР°РЅС‘РЅ');
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      Get.snackbar('РћС€РёР±РєР°', 'РќРµ СѓРґР°Р»РѕСЃСЊ СЃРѕС…СЂР°РЅРёС‚СЊ: $e');
    } finally {
      isSubmitting = false;
      update();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      isSubmitting = true;
      update();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: ApiClient.authHeaders(),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        products.removeWhere((p) => p.id == id);
        Get.snackbar('РЈРґР°Р»РµРЅРѕ', 'РўРѕРІР°СЂ СѓРґР°Р»С‘РЅ');
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      Get.snackbar('РћС€РёР±РєР°', 'РќРµ СѓРґР°Р»РѕСЃСЊ СѓРґР°Р»РёС‚СЊ: $e');
    } finally {
      isSubmitting = false;
      update();
    }
  }

  Future<void> changeUserRole({
    required int userId,
    required String role,
  }) async {
    try {
      isChangingRole = true;
      update();

      final normalized = role.trim().toUpperCase();
      if (normalized != 'ADMIN' && normalized != 'USER') {
        throw Exception('Role must be ADMIN or USER');
      }

      final response = await http.put(
        Uri.parse('$usersUrl/$userId/role'),
        headers: ApiClient.authHeaders(),
        body: jsonEncode({'role': normalized}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Done', 'User role updated to $normalized');
        return;
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to change role: $e');
      rethrow;
    } finally {
      isChangingRole = false;
      update();
    }
  }
}



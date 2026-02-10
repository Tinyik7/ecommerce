import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/local/local_database_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_client.dart';

class HomeController extends GetxController {
  final searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  final List<ProductModel> _products = <ProductModel>[];
  final RxList<ProductModel> visibleProducts = <ProductModel>[].obs;

  final String baseUrl = 'http://localhost:8080/api/v1/products';

  final isLoading = false.obs;
  final hasError = false.obs;
  final isOffline = false.obs;

  String searchQuery = '';
  String? selectedCategory;
  double? minPriceFilter;
  double? maxPriceFilter;
  bool inStockOnly = false;
  String sortOption = 'new';

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> fetchProducts({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      hasError.value = false;

      final uri = Uri.parse(baseUrl).replace(
        queryParameters: _buildQueryParameters(),
      );

      final response = await ApiClient.get(
        uri,
        headers: ApiClient.authHeaders(),
        redirectOnUnauthorized: false,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> rawItems;
        if (decoded is Map<String, dynamic> && decoded['items'] is List) {
          rawItems = decoded['items'] as List<dynamic>;
        } else if (decoded is List) {
          rawItems = decoded;
        } else {
          rawItems = const [];
        }

        _products
          ..clear()
          ..addAll(rawItems
              .map(
                  (item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList());
        await LocalDatabaseService.cacheProducts(_products);
        isOffline.value = false;
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } on ApiException catch (e) {
      debugPrint('Network/API error loading products: ${e.message}');
      isOffline.value = true;
      final cached = await LocalDatabaseService.readProducts(
        query: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory,
        minPrice: minPriceFilter,
        maxPrice: maxPriceFilter,
      );
      _products
        ..clear()
        ..addAll(cached);
      hasError.value = _products.isEmpty;
    } catch (e) {
      debugPrint('Error loading products: $e');
      isOffline.value = true;
      final cached = await LocalDatabaseService.readProducts(
        query: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory,
        minPrice: minPriceFilter,
        maxPrice: maxPriceFilter,
      );
      _products
        ..clear()
        ..addAll(cached);
      hasError.value = _products.isEmpty;
    } finally {
      _applyLocalFilters();
      if (showLoader) isLoading.value = false;
      update();
    }
  }

  Map<String, String> _buildQueryParameters() {
    final params = <String, String>{
      'size': '100',
      'sortBy': _mapSortField(),
      'sortDir': _mapSortDirection(),
    };

    if (searchQuery.isNotEmpty) params['query'] = searchQuery;
    if (selectedCategory != null) params['category'] = selectedCategory!;
    if (minPriceFilter != null) params['minPrice'] = '$minPriceFilter';
    if (maxPriceFilter != null) params['maxPrice'] = '$maxPriceFilter';
    if (inStockOnly) params['inStock'] = 'true';

    switch (sortOption) {
      case 'price_low':
        params['sortBy'] = 'price';
        params['sortDir'] = 'asc';
        break;
      case 'price_high':
        params['sortBy'] = 'price';
        params['sortDir'] = 'desc';
        break;
      case 'rating':
        params['sortBy'] = 'rating';
        params['sortDir'] = 'desc';
        break;
    }

    return params;
  }

  String _mapSortField() {
    switch (sortOption) {
      case 'price_low':
      case 'price_high':
        return 'price';
      case 'rating':
        return 'rating';
      default:
        return 'createdAt';
    }
  }

  String _mapSortDirection() {
    switch (sortOption) {
      case 'price_low':
        return 'asc';
      default:
        return 'desc';
    }
  }

  List<String> get categories {
    final set = _products
        .map((product) => product.category)
        .whereType<String>()
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return set;
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => fetchProducts(showLoader: false),
    );
  }

  void toggleInStock(bool value) {
    inStockOnly = value;
    fetchProducts(showLoader: false);
  }

  void selectCategory(String? category) {
    selectedCategory = category == selectedCategory ? null : category;
    fetchProducts(showLoader: false);
  }

  void setPriceRange(double? min, double? max) {
    minPriceFilter = min;
    maxPriceFilter = max;
    fetchProducts(showLoader: false);
  }

  void changeSort(String value) {
    sortOption = value;
    fetchProducts(showLoader: false);
  }

  void clearFilters() {
    searchCtrl.clear();
    searchQuery = '';
    selectedCategory = null;
    minPriceFilter = null;
    maxPriceFilter = null;
    inStockOnly = false;
    sortOption = 'new';
    fetchProducts();
  }

  void _applyLocalFilters() {
    Iterable<ProductModel> filtered = _products;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final lower = searchQuery.toLowerCase();
        return (product.name ?? '').toLowerCase().contains(lower) ||
            (product.description ?? '').toLowerCase().contains(lower);
      });
    }

    if (selectedCategory != null) {
      filtered = filtered.where(
        (product) =>
            product.category?.toLowerCase() == selectedCategory?.toLowerCase(),
      );
    }

    if (minPriceFilter != null) {
      filtered =
          filtered.where((product) => (product.price ?? 0) >= minPriceFilter!);
    }

    if (maxPriceFilter != null) {
      filtered =
          filtered.where((product) => (product.price ?? 0) <= maxPriceFilter!);
    }

    if (inStockOnly) {
      filtered = filtered.where((product) => product.inStock ?? true);
    }

    final List<ProductModel> result = filtered.toList();

    switch (sortOption) {
      case 'price_low':
        result.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_high':
        result.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'rating':
        result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      default:
        result.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
    }

    visibleProducts.assignAll(result);
  }
}



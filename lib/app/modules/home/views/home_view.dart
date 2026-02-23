import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/no_data.dart';
import '../../../components/product_item.dart';
import '../../../components/screen_title.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Obx(() {
          if (controller.hasError.value && controller.visibleProducts.isEmpty) {
            return NoData(
              text: 'load_products_error'.tr,
              subtitle: 'home_try_refresh'.tr,
              icon: Icons.cloud_off_rounded,
              actionLabel: 'retry'.tr,
              onAction: controller.fetchProducts,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchProducts,
            child: ListView(
              children: [
                24.verticalSpace,
                ScreenTitle(title: 'home'.tr),
                if (controller.isOffline.value) ...[
                  10.verticalSpace,
                  _StatusBanner(
                    text: 'offline_cached_data'.tr,
                    icon: Icons.cloud_off_rounded,
                  ),
                ],
                if (controller.isLoading.value &&
                    controller.visibleProducts.isNotEmpty) ...[
                  10.verticalSpace,
                  const LinearProgressIndicator(),
                ],
                16.verticalSpace,
                _FilterCard(controller: controller),
                18.verticalSpace,
                if (controller.isLoading.value &&
                    controller.visibleProducts.isEmpty)
                  const _ProductsSkeletonGrid()
                else if (controller.visibleProducts.isEmpty)
                  NoData(
                    text:
                        _hasActiveFilters ? 'home_no_results'.tr : 'no_data'.tr,
                    subtitle: _hasActiveFilters
                        ? 'home_try_another_filters'.tr
                        : 'home_empty_catalog'.tr,
                    icon: Icons.search_off_rounded,
                    actionLabel: _hasActiveFilters ? 'clear_filters'.tr : null,
                    onAction:
                        _hasActiveFilters ? controller.clearFilters : null,
                  )
                else
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 15.h,
                      childAspectRatio: 0.62,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: controller.visibleProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.visibleProducts[index];
                      return ProductItem(product: product);
                    },
                  ),
                12.verticalSpace,
              ],
            ),
          );
        }),
      ),
    );
  }

  bool get _hasActiveFilters {
    return controller.searchQuery.isNotEmpty ||
        controller.selectedCategory != null ||
        controller.minPriceFilter != null ||
        controller.maxPriceFilter != null ||
        controller.inStockOnly;
  }
}

class _FilterCard extends StatelessWidget {
  final HomeController controller;

  const _FilterCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color:
              context.theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          _SearchField(controller: controller),
          12.verticalSpace,
          _FilterBar(controller: controller),
          10.verticalSpace,
          _ActiveFilters(controller: controller),
          if (controller.categories.isNotEmpty) ...[
            10.verticalSpace,
            _CategoryWrap(controller: controller),
          ],
          8.verticalSpace,
          _InStockSwitch(controller: controller),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchCtrl,
      onChanged: controller.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'search_catalog'.tr,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.clearFilters,
              )
            : null,
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<String>(
            initialValue: controller.sortOption,
            onSelected: controller.changeSort,
            itemBuilder: (_) => [
              PopupMenuItem(value: 'new', child: Text('sort_new'.tr)),
              PopupMenuItem(
                value: 'price_low',
                child: Text('sort_price_low'.tr),
              ),
              PopupMenuItem(
                value: 'price_high',
                child: Text('sort_price_high'.tr),
              ),
              PopupMenuItem(value: 'rating', child: Text('sort_rating'.tr)),
            ],
            child: Chip(
              avatar: const Icon(Icons.sort, size: 18),
              label: Text(_sortLabel(controller.sortOption)),
            ),
          ),
        ),
        8.horizontalSpace,
        OutlinedButton.icon(
          onPressed: () => _openPriceSheet(context, controller),
          icon: const Icon(Icons.price_change, size: 18),
          label: Text('price'.tr),
        ),
        6.horizontalSpace,
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.clearFilters,
          tooltip: 'clear_filters'.tr,
        ),
      ],
    );
  }

  static String _sortLabel(String value) {
    switch (value) {
      case 'price_low':
        return 'sort_price_low'.tr;
      case 'price_high':
        return 'sort_price_high'.tr;
      case 'rating':
        return 'sort_rating'.tr;
      default:
        return 'sort_new'.tr;
    }
  }

  static void _openPriceSheet(BuildContext context, HomeController controller) {
    final minCtrl = TextEditingController(
      text: controller.minPriceFilter?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: controller.maxPriceFilter?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          24.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('price_range'.tr, style: context.textTheme.titleLarge),
            16.verticalSpace,
            TextField(
              controller: minCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'price_from'.tr),
            ),
            12.verticalSpace,
            TextField(
              controller: maxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'price_to'.tr),
            ),
            20.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final min = double.tryParse(minCtrl.text);
                  final max = double.tryParse(maxCtrl.text);
                  controller.setPriceRange(min, max);
                  Get.back();
                },
                child: Text('apply'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (controller.selectedCategory != null) {
      chips.add(
        InputChip(
          label: Text(controller.selectedCategory!),
          onDeleted: () =>
              controller.selectCategory(controller.selectedCategory),
        ),
      );
    }

    if (controller.minPriceFilter != null ||
        controller.maxPriceFilter != null) {
      final min = controller.minPriceFilter?.toStringAsFixed(0) ?? '0';
      final max = controller.maxPriceFilter?.toStringAsFixed(0) ??
          'unlimited_symbol'.tr;
      chips.add(
        InputChip(
          label: Text('${'price'.tr} $min - $max'),
          onDeleted: () => controller.setPriceRange(null, null),
        ),
      );
    }

    if (controller.inStockOnly) {
      chips.add(
        InputChip(
          label: Text('in_stock'.tr),
          onDeleted: () => controller.toggleInStock(false),
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips,
    );
  }
}

class _CategoryWrap extends StatelessWidget {
  const _CategoryWrap({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: controller.categories.map((category) {
        final isSelected = controller.selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) => controller.selectCategory(category),
        );
      }).toList(),
    );
  }
}

class _InStockSwitch extends StatelessWidget {
  const _InStockSwitch({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: controller.inStockOnly,
      onChanged: controller.toggleInStock,
      title: Text('in_stock_only'.tr),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String text;
  final IconData icon;

  const _StatusBanner({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon),
          10.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsSkeletonGrid extends StatelessWidget {
  const _ProductsSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 0.62,
      ),
      shrinkWrap: true,
      primary: false,
      itemCount: 6,
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
          ),
          10.verticalSpace,
          Container(
            width: 100.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          6.verticalSpace,
          Container(
            width: 70.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }
}

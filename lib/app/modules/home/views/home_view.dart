import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/product_item.dart';
import '../../../components/screen_title.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.visibleProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value && controller.visibleProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Не удалось загрузить товары'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.fetchProducts,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchProducts,
            child: ListView(
              children: [
                30.verticalSpace,
                ScreenTitle(title: 'home'.tr),
                if (controller.isOffline.value) ...[
                  12.verticalSpace,
                  _OfflineBanner(theme: theme),
                ],
                20.verticalSpace,
                _SearchField(controller: controller),
                16.verticalSpace,
                _FilterBar(controller: controller),
                12.verticalSpace,
                _ActiveFilters(controller: controller),
                12.verticalSpace,
                _CategoryWrap(controller: controller),
                12.verticalSpace,
                _InStockSwitch(controller: controller),
                20.verticalSpace,
                if (controller.visibleProducts.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 100.h),
                    child: Center(
                      child: Text(
                        'no_data'.tr,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 15.h,
                      mainAxisExtent: 260.h,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: controller.visibleProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.visibleProducts[index];
                      return ProductItem(product: product);
                    },
                  ),
                10.verticalSpace,
              ],
            ),
          );
        }),
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
        hintText: 'Поиск по каталогу',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.clearFilters,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
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
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'new', child: Text('Сначала новые')),
              PopupMenuItem(
                  value: 'price_low', child: Text('Цена: по возрастанию')),
              PopupMenuItem(
                  value: 'price_high', child: Text('Цена: по убыванию')),
              PopupMenuItem(value: 'rating', child: Text('Рейтинг')),
            ],
            child: Chip(
              avatar: const Icon(Icons.sort, size: 18),
              label: Text(_sortLabel(controller.sortOption)),
            ),
          ),
        ),
        12.horizontalSpace,
        OutlinedButton.icon(
          onPressed: () => _openPriceSheet(context, controller),
          icon: const Icon(Icons.price_change, size: 18),
          label: const Text('Цена'),
        ),
        12.horizontalSpace,
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.clearFilters,
        ),
      ],
    );
  }

  static String _sortLabel(String value) {
    switch (value) {
      case 'price_low':
        return 'Цена ↑';
      case 'price_high':
        return 'Цена ↓';
      case 'rating':
        return 'Рейтинг';
      default:
        return 'Новые';
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
            Text('Диапазон цен', style: context.textTheme.titleLarge),
            16.verticalSpace,
            TextField(
              controller: minCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'От'),
            ),
            12.verticalSpace,
            TextField(
              controller: maxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'До'),
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
                child: const Text('Применить'),
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
      final max = controller.maxPriceFilter?.toStringAsFixed(0) ?? '∞';
      chips.add(
        InputChip(
          label: Text('Цена $min - $max'),
          onDeleted: () => controller.setPriceRange(null, null),
        ),
      );
    }

    if (controller.inStockOnly) {
      chips.add(
        InputChip(
          label: const Text('В наличии'),
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
    if (controller.categories.isEmpty) {
      return const SizedBox.shrink();
    }
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
      value: controller.inStockOnly,
      onChanged: controller.toggleInStock,
      title: const Text('Показывать только товары в наличии'),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off),
          12.horizontalSpace,
          Expanded(
            child: Text(
              'Нет сети, показываем сохранённые данные',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

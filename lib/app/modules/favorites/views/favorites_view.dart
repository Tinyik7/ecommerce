import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/no_data.dart';
import '../../../components/product_item.dart';
import '../../../components/screen_title.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withValues(alpha: 0.06),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: RefreshIndicator(
            onRefresh: controller.fetchFavorites,
            child: ListView(
              children: [
                24.verticalSpace,
                ScreenTitle(
                  title: 'favorites'.tr,
                  dividerEndIndent: 200,
                ),
                14.verticalSpace,
                GetBuilder<FavoritesController>(
                  builder: (_) {
                    if (controller.isLoading.value &&
                        controller.products.isEmpty) {
                      return const _FavoritesSkeletonGrid();
                    }

                    if (controller.products.isEmpty) {
                      return NoData(
                        text: 'favorites_empty_title'.tr,
                        subtitle: 'favorites_empty_subtitle'.tr,
                        icon: Icons.favorite_border_rounded,
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15.w,
                        mainAxisSpacing: 15.h,
                        childAspectRatio: 0.62,
                      ),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: controller.products.length,
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return ProductItem(product: product);
                      },
                    );
                  },
                ),
                10.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoritesSkeletonGrid extends StatelessWidget {
  const _FavoritesSkeletonGrid();

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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/no_data.dart';
import '../../../components/product_item.dart';
import '../../../components/screen_title.dart';
import '../controllers/favorites_controller.dart';
import '../../../routes/app_pages.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            30.verticalSpace,
            ScreenTitle(
              title: 'favorites'.tr,
              dividerEndIndent: 200,
            ),
            20.verticalSpace,
            GetBuilder<FavoritesController>(
              builder: (_) {
                if (controller.products.isEmpty) {
                  return NoData(text: 'no_data'.tr);
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.h,
                    mainAxisExtent: 260.h,
                  ),
                  shrinkWrap: true,
                  primary: false,
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];

                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.PRODUCT_DETAILS,
                        arguments: product, // ✅ исправлено: передаём модель
                      ),
                      child: ProductItem(product: product),
                    );
                  },
                );
              },
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}

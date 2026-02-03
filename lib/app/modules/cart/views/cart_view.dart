import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_button.dart';
import '../../../components/no_data.dart';
import '../../../components/screen_title.dart';
import '../controllers/cart_controller.dart';
import 'widgets/cart_item.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GetBuilder<CartController>(
            builder: (controller) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                30.verticalSpace,
                ScreenTitle(
                  title: 'cart'.tr,
                  dividerEndIndent: 280,
                ),
                10.verticalSpace,
                if (controller.isOffline.value)
                  Container(
                    width: double.infinity,
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
                            'Нет связи с сервером, показываем сохранённые данные',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (controller.isSyncing.value) ...[
                  10.verticalSpace,
                  const LinearProgressIndicator(),
                ],
                20.verticalSpace,
                Expanded(
                  child: controller.products.isEmpty
                      ? Center(child: NoData(text: 'no_data'.tr))
                      : ListView.builder(
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) => CartItem(
                            product: controller.products[index],
                          ).animate().fade().slideX(
                                duration: const Duration(milliseconds: 300),
                                begin: -1,
                                curve: Curves.easeInSine,
                              ),
                        ),
                ),
                20.verticalSpace,
                if (controller.products.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        width: 65.w,
                        height: 65.h,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(Constants.busIcon),
                            5.verticalSpace,
                            Text(
                              'FREE',
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      20.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total:',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontSize: 18.sp),
                          ),
                          10.verticalSpace,
                          Text(
                            '\$${controller.total.toStringAsFixed(2)}',
                            style: theme.textTheme.displayLarge?.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  theme.primaryColor.withValues(alpha: 0.5),
                              decorationThickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                30.verticalSpace,
                if (controller.products.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: CustomButton(
                      text: 'purchase_now'.tr,
                      onPressed: controller.onPurchaseNowPressed,
                      fontSize: 16.sp,
                      radius: 12.r,
                      verticalPadding: 12.h,
                      hasShadow: true,
                      shadowColor: theme.primaryColor,
                      shadowOpacity: 0.3,
                      shadowBlurRadius: 4,
                      shadowSpreadRadius: 0,
                    ).animate().fade().slideY(
                          duration: const Duration(milliseconds: 300),
                          begin: 1,
                          curve: Curves.easeInSine,
                        ),
                  ),
                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

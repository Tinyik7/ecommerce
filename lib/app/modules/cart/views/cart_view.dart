import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_button.dart';
import '../../../components/no_data.dart';
import '../../../components/screen_title.dart';
import '../../base/controllers/base_controller.dart';
import '../controllers/cart_controller.dart';
import 'widgets/cart_item.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: Container(
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
            child: GetBuilder<CartController>(
              builder: (controller) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.verticalSpace,
                  ScreenTitle(
                    title: 'cart'.tr,
                    dividerEndIndent: 280,
                  ),
                  10.verticalSpace,
                  if (controller.isOffline.value)
                    _StatusBanner(
                      text: 'offline_cached_data'.tr,
                      icon: Icons.cloud_off_rounded,
                    ),
                  if (controller.isSyncing.value) ...[
                    10.verticalSpace,
                    const LinearProgressIndicator(),
                  ],
                  16.verticalSpace,
                  Expanded(
                    child: controller.products.isEmpty
                        ? NoData(
                            text: 'cart_empty_title'.tr,
                            subtitle: 'cart_empty_subtitle'.tr,
                            icon: Icons.shopping_cart_outlined,
                            actionLabel: 'go_to_home'.tr,
                            onAction: () =>
                                Get.find<BaseController>().changeScreen(0),
                          )
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
                  if (controller.products.isNotEmpty) ...[
                    14.verticalSpace,
                    _CartSummary(
                      total: controller.total,
                    ),
                    16.verticalSpace,
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
                    18.verticalSpace,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;

  const _CartSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.h,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(Constants.busIcon),
                4.verticalSpace,
                Text(
                  'free_delivery'.tr,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'total'.tr,
                  style: theme.textTheme.bodyMedium,
                ),
                4.verticalSpace,
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 28.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon),
          12.horizontalSpace,
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

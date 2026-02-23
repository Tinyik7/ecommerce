import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_button.dart';
import '../controllers/product_details_controller.dart';
import 'widgets/rounded_button.dart';
import 'widgets/size_item.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final product = controller.product;
    final imageUrl = _resolveImageUrl(product.image);
    final price = product.price ?? 0;
    final rating = product.rating;
    final reviews = product.reviews;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 380.h,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.r),
                          bottomRight: Radius.circular(30.r),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18.h,
                      left: 20.w,
                      right: 20.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RoundedButton(
                            onPressed: () => Get.back(),
                            child: SvgPicture.asset(
                              Constants.backArrowIcon,
                              fit: BoxFit.none,
                            ),
                          ),
                          GetBuilder<ProductDetailsController>(
                            id: 'FavoriteButton',
                            builder: (_) {
                              final isFavorite =
                                  controller.product.isFavorite ?? false;
                              return RoundedButton(
                                onPressed: controller.onFavoriteButtonPressed,
                                child: SvgPicture.asset(
                                  isFavorite
                                      ? Constants.favFilledIcon
                                      : Constants.favOutlinedIcon,
                                  width: 16.w,
                                  height: 15.h,
                                  colorFilter: isFavorite
                                      ? null
                                      : const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(30.w, 70.h, 30.w, 20.h),
                        child: imageUrl == null
                            ? const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 80,
                                ),
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                .animate()
                                .fadeIn(
                                    duration: const Duration(milliseconds: 250))
                                .slideY(begin: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  product.name ?? '',
                  style: theme.textTheme.bodyLarge,
                ).animate().fade().slideX(begin: -0.15),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: theme.textTheme.displayMedium,
                    ),
                    24.horizontalSpace,
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC542)),
                    5.horizontalSpace,
                    Text(
                      rating?.toString() ?? '--',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    5.horizontalSpace,
                    Text(
                      reviews != null ? '($reviews)' : '',
                      style:
                          theme.textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                    ),
                  ],
                ).animate().fade().slideX(begin: -0.15),
              ),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'choose_size'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().slideX(begin: -0.15),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GetBuilder<ProductDetailsController>(
                  id: 'Size',
                  builder: (_) => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      for (final size in ['S', 'M', 'L', 'XL'])
                        SizeItem(
                          onPressed: () => controller.changeSelectedSize(size),
                          label: size,
                          selected: controller.selectedSize == size,
                        ),
                    ],
                  ).animate().fade().slideX(begin: -0.15),
                ),
              ),
              24.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: GetBuilder<ProductDetailsController>(
                  id: 'CartButton',
                  builder: (_) => CustomButton(
                    text: product.inCart ? 'in_cart'.tr : 'add_to_cart'.tr,
                    onPressed:
                        product.inCart ? null : controller.onAddToCartPressed,
                    fontSize: 16.sp,
                    radius: 12.r,
                    verticalPadding: 12.h,
                    hasShadow: true,
                    shadowColor: theme.primaryColor,
                    shadowOpacity: 0.3,
                    shadowBlurRadius: 4,
                    shadowSpreadRadius: 0,
                    disabled: product.inCart,
                  ).animate().fade().slideY(begin: 0.2),
                ),
              ),
              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (raw.startsWith('http')) {
      return raw;
    }
    return 'http://localhost:8080/uploads/$raw';
  }
}

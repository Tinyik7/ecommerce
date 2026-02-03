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

    // 🧠 Исправляем путь для изображений из uploads
    final imageUrl = (product.image != null && product.image!.isNotEmpty)
        ? (product.image!.startsWith('http')
            ? product.image! // если уже полный URL
            : 'http://localhost:8080/uploads/${product.image}') // backend путь
        : null;

    final price = product.price ?? 0;
    final rating = product.rating;
    final reviews = product.reviews;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 450.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1FA),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                        bottomRight: Radius.circular(30.r),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30.h,
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
                                        Colors.white, BlendMode.srcIn),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  /// 🖼️ Загрузка изображения из backend
                  if (imageUrl != null)
                    Positioned(
                      right: product.id == 2 ? 0 : 30.w,
                      bottom: -350.h,
                      child: Image.network(
                        imageUrl,
                        height: 700.h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 120,
                          color: Colors.grey,
                        ),
                      )
                          .animate()
                          .slideX(
                            duration: const Duration(milliseconds: 300),
                            begin: 1,
                            curve: Curves.easeInSine,
                          )
                          .fadeIn(),
                    ),
                ],
              ),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  product.name ?? '',
                  style: theme.textTheme.bodyLarge,
                ).animate().fade().slideX(begin: -1),
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
                    30.horizontalSpace,
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
                ).animate().fade().slideX(begin: -1),
              ),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Choose your size:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().slideX(begin: -1),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GetBuilder<ProductDetailsController>(
                  id: 'Size',
                  builder: (_) => Row(
                    children: [
                      for (final size in ['S', 'M', 'L', 'XL'])
                        Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: SizeItem(
                            onPressed: () =>
                                controller.changeSelectedSize(size),
                            label: size,
                            selected: controller.selectedSize == size,
                          ),
                        ),
                    ],
                  ).animate().fade().slideX(begin: -1),
                ),
              ),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: GetBuilder<ProductDetailsController>(
                  id: 'CartButton',
                  builder: (_) => CustomButton(
                    text: product.inCart ? 'In Cart' : 'Add to Cart',
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
                  ).animate().fade().slideY(begin: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




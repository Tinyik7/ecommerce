import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../data/models/product_model.dart';
import '../modules/base/controllers/base_controller.dart';
import '../routes/app_pages.dart';

class ProductItem extends StatelessWidget {
  final ProductModel product;

  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final imageUrl = _resolveImageUrl(product.image);

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                if (imageUrl != null)
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 48),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ).animate().fadeIn(
                            duration: const Duration(milliseconds: 180),
                          ),
                    ),
                  ),
                Positioned(
                  left: 10.w,
                  bottom: 10.h,
                  child: GetBuilder<BaseController>(
                    id: 'FavoriteButton',
                    builder: (controller) => Material(
                      color: theme.colorScheme.surface,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => controller.onFavoriteButtonPressed(
                          product: product,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.r),
                          child: SvgPicture.asset(
                            (product.isFavorite ?? false)
                                ? Constants.favFilledIcon
                                : Constants.favOutlinedIcon,
                            colorFilter: (product.isFavorite ?? false)
                                ? null
                                : ColorFilter.mode(
                                    theme.primaryColor,
                                    BlendMode.srcIn,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(),
              ],
            ),
          ),
          10.verticalSpace,
          Text(
            product.name ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ).animate().fade().slideY(
                duration: const Duration(milliseconds: 200),
                begin: 1,
                curve: Curves.easeInSine,
              ),
          5.verticalSpace,
          Text(
            '\$${(product.price ?? 0).toStringAsFixed(2)}',
            style: theme.textTheme.displaySmall,
          ).animate().fade().slideY(
                duration: const Duration(milliseconds: 200),
                begin: 1.4,
                curve: Curves.easeInSine,
              ),
        ],
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

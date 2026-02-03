import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants.dart';
import '../../../../data/models/product_model.dart';
import '../../controllers/cart_controller.dart';

class CartItem extends StatelessWidget {
  final ProductModel product;
  const CartItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final CartController controller = Get.find<CartController>();

    final imageUrl = (product.image != null && product.image!.isNotEmpty)
        ? (product.image!.startsWith('http')
            ? product.image!
            : 'http://localhost:8080/uploads/${product.image}')
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25.r),
            child: Container(
              width: 105.w,
              height: 125.h,
              color: const Color(0xFFEDF1FA),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 125.h,
                      width: 105.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.image_not_supported_outlined),
            ),
          ),
          20.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                5.verticalSpace,
                Text(
                  product.name ?? '',
                  style: theme.textTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                5.verticalSpace,
                Text(
                  'Size: ${product.size ?? '-'}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                ),
                5.verticalSpace,
                Text(
                  '\$${(product.price ?? 0).toStringAsFixed(2)}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 18.sp,
                  ),
                ),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          controller.onDecreasePressed(product.id ?? 0),
                      child: SvgPicture.asset(
                        Constants.decreaseIcon,
                        width: 22.w,
                        height: 22.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.black87,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    12.horizontalSpace,
                    Text(
                      '${product.quantity ?? 0}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    12.horizontalSpace,
                    GestureDetector(
                      onTap: () =>
                          controller.onIncreasePressed(product.id ?? 0),
                      child: SvgPicture.asset(
                        Constants.increaseIcon,
                        width: 22.w,
                        height: 22.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.black87,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => controller.onDeletePressed(product.id ?? 0),
            customBorder: const CircleBorder(),
            child: Container(
              padding: EdgeInsets.all(10.r),
              child: SvgPicture.asset(
                Constants.cancelIcon,
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  theme.textTheme.bodyMedium!.color ?? Colors.black54,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



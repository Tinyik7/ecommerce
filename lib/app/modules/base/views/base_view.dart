import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../controllers/base_controller.dart';
import '../../cart/views/cart_view.dart';
import '../../favorites/views/favorites_view.dart';
import '../../home/views/home_view.dart';
import '../../settings/views/settings_view.dart';

class BaseView extends GetView<BaseController> {
  const BaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GetBuilder<BaseController>(
      builder: (_) => Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: controller.currentIndex,
            children: const [
              HomeView(),
              FavoritesView(),
              CartView(),
              SettingsView()
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BottomNavigationBar(
                currentIndex: controller.currentIndex,
                type: BottomNavigationBarType.fixed,
                elevation: 8,
                backgroundColor: theme.scaffoldBackgroundColor,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: [
                  _mBottomNavItem(
                    label: 'home'.tr,
                    icon: Constants.homeIcon,
                  ),
                  _mBottomNavItem(
                    label: 'favorites'.tr,
                    icon: Constants.favoritesIcon,
                  ),
                  _mBottomNavItem(
                    label: 'cart'.tr,
                    icon: Constants.cartIcon,
                  ),
                  _mBottomNavItem(
                    label: 'settings'.tr,
                    icon: Constants.settingsIcon,
                  ),
                ],
                onTap: controller.changeScreen,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _mBottomNavItem({
    required String label,
    required String icon,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(
          Get.theme.iconTheme.color ?? Colors.white,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(
          Get.theme.primaryColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

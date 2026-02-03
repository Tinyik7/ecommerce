import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/screen_title.dart';
import '../controllers/settings_controller.dart';
import 'widgets/settings_item.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            30.verticalSpace,
            ScreenTitle(
              title: 'settings'.tr,
              dividerEndIndent: 230,
            ),
            20.verticalSpace,
            Text(
              'account'.tr,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
            20.verticalSpace,
            SettingsItem(
              title: controller.userName,
              subtitle: controller.userEmail,
              icon: Constants.userIcon,
              isAccount: true,
              onTap: controller.openProfileDetails,
            ),
            30.verticalSpace,
            Text(
              'settings'.tr,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
            20.verticalSpace,
            SettingsItem(
              title: 'dark_mode'.tr,
              icon: Constants.themeIcon,
              isDark: true,
            ),
            20.verticalSpace,
            GetBuilder<SettingsController>(
              id: 'Language',
              builder: (_) => SettingsItem(
                title:
                    'language: ${controller.currentLocale.languageCode.toUpperCase()}',
                icon: Constants.languageIcon,
                onTap: () => _showLanguageDialog(context, controller),
              ),
            ),
            20.verticalSpace,
            SettingsItem(
              title: 'help'.tr,
              icon: Constants.helpIcon,
              onTap: controller.openHelp,
            ),
            if (controller.isAdmin) ...[
              20.verticalSpace,
              SettingsItem(
                title: 'Admin panel',
                icon: Constants.settingsIcon,
                onTap: controller.openAdminPanel,
              ),
            ],
            20.verticalSpace,
            SettingsItem(
              title: 'sign_out'.tr,
              icon: Constants.logoutIcon,
              onTap: controller.logout,
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    Get.defaultDialog(
      title: 'Выберите язык',
      content: Column(
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () {
              controller.changeLanguage(const Locale('en'));
              Get.back();
            },
          ),
          ListTile(
            title: const Text('Русский'),
            onTap: () {
              controller.changeLanguage(const Locale('ru'));
              Get.back();
            },
          ),
          ListTile(
            title: const Text('Қазақша'),
            onTap: () {
              controller.changeLanguage(const Locale('kk'));
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

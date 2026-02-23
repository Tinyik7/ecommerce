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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withValues(alpha: 0.08),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          children: [
            ScreenTitle(
              title: 'settings'.tr,
              dividerEndIndent: 230,
            ),
            14.verticalSpace,
            _SectionTitle(text: 'account'.tr),
            10.verticalSpace,
            SettingsItem(
              title: controller.userName,
              subtitle: controller.userEmail,
              icon: Constants.userIcon,
              isAccount: true,
              onTap: controller.openProfileDetails,
            ),
            18.verticalSpace,
            _SectionTitle(text: 'settings'.tr),
            10.verticalSpace,
            SettingsItem(
              title: 'dark_mode'.tr,
              icon: Constants.themeIcon,
              isDark: true,
            ),
            10.verticalSpace,
            GetBuilder<SettingsController>(
              id: 'Language',
              builder: (_) => SettingsItem(
                title:
                    '${'language'.tr}: ${controller.currentLocale.languageCode.toUpperCase()}',
                icon: Constants.languageIcon,
                onTap: () => _showLanguageDialog(context, controller),
              ),
            ),
            10.verticalSpace,
            SettingsItem(
              title: 'help'.tr,
              icon: Constants.helpIcon,
              onTap: controller.openHelp,
            ),
            if (controller.isAdmin) ...[
              10.verticalSpace,
              SettingsItem(
                title: 'admin_panel'.tr,
                icon: Constants.settingsIcon,
                onTap: controller.openAdminPanel,
              ),
            ],
            18.verticalSpace,
            SettingsItem(
              title: 'sign_out'.tr,
              icon: Constants.logoutIcon,
              isDestructive: true,
              onTap: controller.logout,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageTile(
              label: 'lang_english'.tr,
              selected: controller.currentLocale.languageCode == 'en',
              onTap: () {
                controller.changeLanguage(const Locale('en', 'US'));
                Get.back();
              },
            ),
            _LanguageTile(
              label: 'lang_russian'.tr,
              selected: controller.currentLocale.languageCode == 'ru',
              onTap: () {
                controller.changeLanguage(const Locale('ru', 'RU'));
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.textTheme.displayMedium?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.primaryColor)
          : null,
      onTap: onTap,
    );
  }
}

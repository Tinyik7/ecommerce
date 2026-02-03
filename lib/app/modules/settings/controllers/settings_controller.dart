import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController {
  bool isLightTheme = MySharedPref.getThemeIsLight();
  Locale currentLocale = MySharedPref.getLocale();

  String userName = MySharedPref.getString('user_name') ?? 'Echoes User';
  String userEmail = MySharedPref.getString('user_email') ?? 'mail@example.com';
  String userRole = MySharedPref.getUserRole();

  bool get isAdmin => userRole.toUpperCase() == 'ADMIN';

  void changeTheme(bool value) {
    MyTheme.changeTheme();
    isLightTheme = MySharedPref.getThemeIsLight();
    update(['Theme']);
  }

  void changeLanguage(Locale locale) {
    MySharedPref.setLocale(locale);
    Get.updateLocale(locale);
    currentLocale = locale;
    update(['Language']);
  }

  Future<void> logout() async {
    await Future.wait([
      MySharedPref.removeToken(),
      MySharedPref.remove('user_email'),
      MySharedPref.remove('user_name'),
      MySharedPref.remove('user_id'),
      MySharedPref.remove('user_role'),
    ]);

    Get.offAllNamed(Routes.login);
    Get.snackbar(
      'До встречи 👋',
      'Вы вышли из аккаунта',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openProfileDetails() {
    Get.toNamed(Routes.profileDetail);
  }

  void openAdminPanel() {
    if (!isAdmin) return;
    Get.toNamed(Routes.adminPanel);
  }

  void openHelp() {
    Get.defaultDialog(
      title: 'Поддержка',
      middleText:
          'Напишите на support@echoes.app или в Telegram @EchoesSupport, чтобы получить помощь.',
      textConfirm: 'Ок',
      confirmTextColor: Colors.white,
      onConfirm: Get.back,
    );
  }
}

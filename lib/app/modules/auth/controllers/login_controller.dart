import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '\u0412\u0432\u0435\u0434\u0438\u0442\u0435\u0020\u0065\u006D\u0061\u0069\u006C';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '\u041D\u0435\u043A\u043E\u0440\u0440\u0435\u043A\u0442\u043D\u044B\u0439\u0020\u0065\u006D\u0061\u0069\u006C';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '\u0412\u0432\u0435\u0434\u0438\u0442\u0435\u0020\u043F\u0430\u0440\u043E\u043B\u044C';
    }
    return null;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final LoginResult? result = await AuthService.instance.login(
        email: emailCtrl.text,
        password: passwordCtrl.text,
      );

      if (result == null) {
        Get.snackbar(
          '\u041E\u0448\u0438\u0431\u043A\u0430',
          '\u041D\u0435\u0432\u0435\u0440\u043D\u044B\u0439\u0020\u0065\u006D\u0061\u0069\u006C\u0020\u0438\u043B\u0438\u0020\u043F\u0430\u0440\u043E\u043B\u044C',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String? token = result.token;
      if (token != null && token.isNotEmpty) {
        await MySharedPref.setToken(token);
      }

      final user = result.user;
      await MySharedPref.setString('user_email', user.email);
      await MySharedPref.setString('user_name', user.username);
      await MySharedPref.setInt('user_id', user.id);
      await MySharedPref.setUserRole(user.role ?? 'USER');

      final welcome =
          '\u0414\u043E\u0431\u0440\u043E\u0020\u043F\u043E\u0436\u0430\u043B\u043E\u0432\u0430\u0442\u044C\u002C';
      Get.snackbar(
        '\u2705\u0020\u0423\u0441\u043F\u0435\u0448\u043D\u043E',
        '$welcome ${user.username}!',
      );

      await Future.delayed(const Duration(milliseconds: 400));
      Get.offAllNamed(Routes.base);
    } on UnauthorizedException {
      Get.snackbar(
        '\u041E\u0448\u0438\u0431\u043A\u0430',
        '\u041D\u0435\u0432\u0435\u0440\u043D\u044B\u0439\u0020\u0065\u006D\u0061\u0069\u006C\u0020\u0438\u043B\u0438\u0020\u043F\u0430\u0440\u043E\u043B\u044C',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '\u041E\u0448\u0438\u0431\u043A\u0430',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

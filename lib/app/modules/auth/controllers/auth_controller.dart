import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final formKey = GlobalKey<FormState>();

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '\u0412\u0432\u0435\u0434\u0438\u0442\u0435\u0020\u0438\u043C\u044F\u0020\u043F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044F';
    }
    if (value.trim().length < 3) {
      return '\u041C\u0438\u043D\u0438\u043C\u0443\u043C\u0020\u0033\u0020\u0441\u0438\u043C\u0432\u043E\u043B\u0430';
    }
    return null;
  }

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
    if (value.length < 6) {
      return '\u041C\u0438\u043D\u0438\u043C\u0443\u043C\u0020\u0036\u0020\u0441\u0438\u043C\u0432\u043E\u043B\u043E\u0432';
    }
    return null;
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final user = await AuthService.instance.register(
        username: usernameCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
      );

      await MySharedPref.setString('user_email', user.email);
      await MySharedPref.setString('user_name', user.username);
      await MySharedPref.setInt('user_id', user.id);
      await MySharedPref.setUserRole(user.role ?? 'USER');

      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar(
          '\u2705\u0020\u0423\u0441\u043F\u0435\u0448\u043D\u043E',
          '\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0430\u0446\u0438\u044F\u0020\u043F\u0440\u043E\u0448\u043B\u0430\u0020\u0443\u0441\u043F\u0435\u0448\u043D\u043E',
        );
      });

      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(Routes.login);
    } on AuthConflictException catch (e) {
      final msg = e.message;
      if (msg.contains('email')) {
        Get.snackbar(
          '\u041E\u0448\u0438\u0431\u043A\u0430',
          '\u041F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044C\u0020\u0441\u0020\u0442\u0430\u043A\u0438\u043C\u0020\u0065\u006D\u0061\u0069\u006C\u0020\u0443\u0436\u0435\u0020\u0441\u0443\u0449\u0435\u0441\u0442\u0432\u0443\u0435\u0442',
        );
      } else if (msg.contains(
          '\u0418\u043C\u044F\u0020\u043F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044F')) {
        Get.snackbar(
          '\u041E\u0448\u0438\u0431\u043A\u0430',
          '\u0418\u043C\u044F\u0020\u043F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044F\u0020\u0443\u0436\u0435\u0020\u0437\u0430\u043D\u044F\u0442\u043E',
        );
      } else {
        Get.snackbar(
          '\u041E\u0448\u0438\u0431\u043A\u0430',
          '\u041D\u0435\u0020\u0443\u0434\u0430\u043B\u043E\u0441\u044C\u0020\u0437\u0430\u0440\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0440\u043E\u0432\u0430\u0442\u044C\u0441\u044F',
        );
      }
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
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

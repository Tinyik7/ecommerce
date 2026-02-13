import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final tokenCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Некорректный email';
    }
    return null;
  }

  String? validateToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите token';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите новый пароль';
    }
    if (value.length < 6) {
      return 'Минимум 6 символов';
    }
    return null;
  }

  Future<void> requestResetToken() async {
    final emailError = validateEmail(emailCtrl.text);
    if (emailError != null) {
      Get.snackbar('Ошибка', emailError);
      return;
    }

    try {
      isLoading.value = true;
      final token = await AuthService.instance.requestPasswordReset(
        email: emailCtrl.text,
      );
      if (token != null && token.isNotEmpty) {
        tokenCtrl.text = token;
        Get.snackbar('Готово', 'Token сгенерирован и подставлен в поле');
      } else {
        Get.snackbar('Инфо', 'Если email существует, token создан');
      }
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;
      await AuthService.instance.resetPasswordByToken(
        token: tokenCtrl.text,
        newPassword: newPasswordCtrl.text,
      );
      Get.snackbar('Готово', 'Пароль успешно обновлен');
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    tokenCtrl.dispose();
    newPasswordCtrl.dispose();
    super.onClose();
  }
}

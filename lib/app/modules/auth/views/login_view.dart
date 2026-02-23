import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';
import 'widgets/auth_scaffold.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController c = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: AuthScaffold(
        title: 'auth_login_title'.tr,
        subtitle: 'auth_login_subtitle'.tr,
        footer: TextButton(
          onPressed: () => Get.offAllNamed(Routes.register),
          child: Text('auth_to_register'.tr),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: c.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'auth_email'.tr,
                prefixIcon: const Icon(Icons.alternate_email_rounded),
              ),
              validator: c.validateEmail,
            ),
            12.verticalSpace,
            Obx(
              () => TextFormField(
                controller: c.passwordCtrl,
                obscureText: !c.isPasswordVisible.value,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'auth_password'.tr,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => c.isPasswordVisible.toggle(),
                  ),
                ),
                validator: c.validatePassword,
              ),
            ),
            6.verticalSpace,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed(Routes.forgotPassword),
                child: Text('auth_forgot_password'.tr),
              ),
            ),
            8.verticalSpace,
            Obx(
              () => ElevatedButton(
                onPressed: c.isLoading.value ? null : c.login,
                child: c.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth_sign_in'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

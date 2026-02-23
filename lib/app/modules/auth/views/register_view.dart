import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final AuthController c = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: AuthScaffold(
        title: 'auth_register_title'.tr,
        subtitle: 'auth_register_subtitle'.tr,
        footer: TextButton(
          onPressed: () => Get.offAllNamed(Routes.login),
          child: Text('auth_to_login'.tr),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: c.usernameCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'auth_username'.tr,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: c.validateUsername,
            ),
            12.verticalSpace,
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
            18.verticalSpace,
            Obx(
              () => ElevatedButton(
                onPressed: c.isLoading.value ? null : c.register,
                child: c.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth_create_account'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

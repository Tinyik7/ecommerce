import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final ForgotPasswordController c = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      child: AuthScaffold(
        showBack: true,
        title: 'auth_forgot_title'.tr,
        subtitle: 'auth_forgot_subtitle'.tr,
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
              () => ElevatedButton.icon(
                onPressed: c.isLoading.value ? null : c.requestResetToken,
                icon: const Icon(Icons.key_rounded),
                label: Text('auth_request_token'.tr),
              ),
            ),
            18.verticalSpace,
            TextFormField(
              controller: c.tokenCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'auth_reset_token'.tr,
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
              validator: c.validateToken,
            ),
            12.verticalSpace,
            TextFormField(
              controller: c.newPasswordCtrl,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'auth_new_password'.tr,
                prefixIcon: const Icon(Icons.lock_reset_rounded),
              ),
              validator: c.validatePassword,
            ),
            18.verticalSpace,
            Obx(
              () => ElevatedButton(
                onPressed: c.isLoading.value ? null : c.resetPassword,
                child: c.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth_reset_password'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

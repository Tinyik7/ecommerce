import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController c = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('\u0412\u0445\u043E\u0434')),
      body: SafeArea(
        child: Form(
          key: c.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '\u0412\u043E\u0439\u0434\u0438\u0442\u0435\u0020\u0432\u0020\u0430\u043A\u043A\u0430\u0443\u043D\u0442',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: c.emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: c.validateEmail,
              ),
              const SizedBox(height: 12),
              Obx(
                () => TextFormField(
                  controller: c.passwordCtrl,
                  obscureText: !c.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: '\u041F\u0430\u0440\u043E\u043B\u044C',
                    border: const OutlineInputBorder(),
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
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton(
                  onPressed: c.isLoading.value ? null : c.login,
                  child: c.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('\u0412\u043E\u0439\u0442\u0438'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.toNamed(Routes.forgotPassword),
                child: const Text('Забыли пароль?'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offAllNamed(Routes.register),
                child: const Text(
                  '\u041D\u0435\u0442\u0020\u0430\u043A\u043A\u0430\u0443\u043D\u0442\u0430\u003F\u0020\u0417\u0430\u0440\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0440\u043E\u0432\u0430\u0442\u044C\u0441\u044F',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

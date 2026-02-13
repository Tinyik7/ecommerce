import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final ForgotPasswordController c = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Восстановление пароля')),
      body: SafeArea(
        child: Form(
          key: c.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Запросите token, затем задайте новый пароль',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
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
                () => ElevatedButton(
                  onPressed: c.isLoading.value ? null : c.requestResetToken,
                  child: const Text('Запросить token'),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: c.tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reset token',
                  border: OutlineInputBorder(),
                ),
                validator: c.validateToken,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: c.newPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Новый пароль',
                  border: OutlineInputBorder(),
                ),
                validator: c.validatePassword,
              ),
              const SizedBox(height: 12),
              Obx(
                () => ElevatedButton(
                  onPressed: c.isLoading.value ? null : c.resetPassword,
                  child: c.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сбросить пароль'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

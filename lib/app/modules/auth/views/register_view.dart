import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final AuthController c = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u0420\u0435\u0433\u0438\u0441\u0442\u0440\u0430\u0446\u0438\u044F'),
      ),
      body: SafeArea(
        child: Form(
          key: c.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '\u0421\u043E\u0437\u0434\u0430\u0439\u0442\u0435\u0020\u0430\u043A\u043A\u0430\u0443\u043D\u0442',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: c.usernameCtrl,
                decoration: const InputDecoration(
                  labelText: '\u0418\u043C\u044F\u0020\u043F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044F',
                  border: OutlineInputBorder(),
                ),
                validator: c.validateUsername,
              ),
              const SizedBox(height: 12),
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
                  onPressed: c.isLoading.value ? null : c.register,
                  child: c.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('\u0417\u0430\u0440\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0440\u043E\u0432\u0430\u0442\u044C\u0441\u044F'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offAllNamed(Routes.login),
                child: const Text('\u0423\u0436\u0435\u0020\u0437\u0430\u0440\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0440\u043E\u0432\u0430\u043D\u044B\u003F\u0020\u0412\u043E\u0439\u0442\u0438'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/profile_detail_controller.dart';

class ProfileDetailView extends GetView<ProfileDetailController> {
  const ProfileDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: GetBuilder<ProfileDetailController>(
        builder: (c) {
          final user = c.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: c.refreshUser,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              children: [
                CircleAvatar(
                  radius: 40.r,
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                16.verticalSpace,
                Center(
                  child: Column(
                    children: [
                      Text(
                        user.username,
                        style: theme.textTheme.titleLarge,
                      ),
                      4.verticalSpace,
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                24.verticalSpace,
                _InfoTile(
                  title: 'Роль',
                  value: user.role?.toUpperCase() ?? 'USER',
                ),
                _InfoTile(
                  title: 'ID пользователя',
                  value: user.id.toString(),
                ),
                if (user.name != null && user.name!.isNotEmpty)
                  _InfoTile(
                    title: 'Имя',
                    value: user.name!,
                  ),
                if (user.createdAt != null && user.createdAt!.isNotEmpty)
                  _InfoTile(
                    title: 'Создан',
                    value: user.createdAt!,
                  ),
                12.verticalSpace,
                _ActionButton(
                  title: 'Редактировать профиль',
                  icon: Icons.edit,
                  onTap: () => _openEditProfile(context, c),
                  isLoading: c.isSaving,
                ),
                12.verticalSpace,
                _ActionButton(
                  title: 'Сменить пароль',
                  icon: Icons.lock,
                  onTap: () => _openChangePassword(context, c),
                  isLoading: c.isChangingPassword,
                ),
                20.verticalSpace,
                Text(
                  'Свайпните вниз, чтобы обновить данные из сервера.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          4.verticalSpace,
          Text(
            value,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(title),
      ),
    );
  }
}

void _openEditProfile(BuildContext context, ProfileDetailController controller) {
  final user = controller.user;
  final nameCtrl = TextEditingController(text: user?.name ?? '');
  final usernameCtrl = TextEditingController(text: user?.username ?? '');
  final emailCtrl = TextEditingController(text: user?.email ?? '');
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Некорректный email';
    return null;
  }

  Get.bottomSheet(
    backgroundColor: context.theme.scaffoldBackgroundColor,
    isScrollControlled: true,
    Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Редактировать профиль',
                  style: context.textTheme.titleLarge),
              16.verticalSpace,
              TextFormField(
                controller: usernameCtrl,
                decoration: const InputDecoration(labelText: 'Имя пользователя'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (value.trim().length < 3) return 'Минимум 3 символа';
                  return null;
                },
              ),
              12.verticalSpace,
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              12.verticalSpace,
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: validateEmail,
              ),
              20.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSaving
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          await controller.updateProfile(
                            username: usernameCtrl.text,
                            email: emailCtrl.text,
                            name: nameCtrl.text,
                          );
                          if (!controller.isSaving) {
                            Get.back();
                          }
                        },
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _openChangePassword(
    BuildContext context, ProfileDetailController controller) {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Get.bottomSheet(
    backgroundColor: context.theme.scaffoldBackgroundColor,
    isScrollControlled: true,
    Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Сменить пароль', style: context.textTheme.titleLarge),
              16.verticalSpace,
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Текущий пароль'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите текущий пароль';
                  }
                  return null;
                },
              ),
              12.verticalSpace,
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Новый пароль'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите новый пароль';
                  }
                  if (value.length < 6) return 'Минимум 6 символов';
                  return null;
                },
              ),
              20.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isChangingPassword
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          await controller.changePassword(
                            currentPassword: currentCtrl.text,
                            newPassword: newCtrl.text,
                          );
                          if (!controller.isChangingPassword) {
                            Get.back();
                          }
                        },
                  child: const Text('Обновить пароль'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

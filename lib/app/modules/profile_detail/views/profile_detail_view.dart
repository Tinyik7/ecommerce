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
        title: Text('profile_title'.tr),
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              children: [
                _ProfileHeader(
                  username: user.username,
                  email: user.email,
                ),
                18.verticalSpace,
                _InfoTile(
                  title: 'profile_role'.tr,
                  value: user.role?.toUpperCase() ?? 'USER',
                ),
                _InfoTile(
                  title: 'profile_user_id'.tr,
                  value: user.id.toString(),
                ),
                if (user.name != null && user.name!.isNotEmpty)
                  _InfoTile(
                    title: 'profile_name'.tr,
                    value: user.name!,
                  ),
                if (user.createdAt != null && user.createdAt!.isNotEmpty)
                  _InfoTile(
                    title: 'profile_created'.tr,
                    value: user.createdAt!,
                  ),
                10.verticalSpace,
                _ActionButton(
                  title: 'profile_edit'.tr,
                  icon: Icons.edit_outlined,
                  onTap: () => _openEditProfile(context, c),
                  isLoading: c.isSaving,
                ),
                10.verticalSpace,
                _ActionButton(
                  title: 'profile_change_password'.tr,
                  icon: Icons.lock_reset_rounded,
                  onTap: () => _openChangePassword(context, c),
                  isLoading: c.isChangingPassword,
                ),
                16.verticalSpace,
                Text(
                  'profile_refresh_hint'.tr,
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

class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;

  const _ProfileHeader({required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.16),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: theme.primaryColor,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: theme.textTheme.titleLarge,
                ),
                2.verticalSpace,
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
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
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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

void _openEditProfile(
    BuildContext context, ProfileDetailController controller) {
  final user = controller.user;
  final nameCtrl = TextEditingController(text: user?.name ?? '');
  final usernameCtrl = TextEditingController(text: user?.username ?? '');
  final emailCtrl = TextEditingController(text: user?.email ?? '');
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'validation_invalid_email'.tr;
    }
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
              Text('profile_edit_title'.tr,
                  style: context.textTheme.titleLarge),
              16.verticalSpace,
              TextFormField(
                controller: usernameCtrl,
                decoration: InputDecoration(labelText: 'auth_username'.tr),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (value.trim().length < 3) return 'validation_min_3'.tr;
                  return null;
                },
              ),
              12.verticalSpace,
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'profile_name'.tr),
              ),
              12.verticalSpace,
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'auth_email'.tr),
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
                  child: Text('profile_save'.tr),
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
  BuildContext context,
  ProfileDetailController controller,
) {
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
              Text(
                'profile_change_password'.tr,
                style: context.textTheme.titleLarge,
              ),
              16.verticalSpace,
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration:
                    InputDecoration(labelText: 'profile_current_password'.tr),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validation_required_current_password'.tr;
                  }
                  return null;
                },
              ),
              12.verticalSpace,
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: 'auth_new_password'.tr),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validation_required_new_password'.tr;
                  }
                  if (value.length < 6) return 'validation_min_6'.tr;
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
                  child: Text('profile_update_password'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

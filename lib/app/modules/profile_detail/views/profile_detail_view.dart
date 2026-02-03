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

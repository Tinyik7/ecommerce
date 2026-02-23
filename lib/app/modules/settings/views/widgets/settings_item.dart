import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants.dart';
import '../../controllers/settings_controller.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String icon;
  final bool isAccount;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    this.isAccount = false,
    this.isDark = false,
    this.isDestructive = false,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tileColor = isDestructive
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.4)
        : theme.colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: isAccount ? 24.r : 20.r,
                backgroundColor: isDestructive
                    ? theme.colorScheme.error
                    : theme.primaryColor,
                child: SvgPicture.asset(
                  icon,
                  width: 18.w,
                  height: 18.h,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        color: isDestructive ? theme.colorScheme.error : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      2.verticalSpace,
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              10.horizontalSpace,
              trailing ?? _defaultTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultTrailing(BuildContext context) {
    final theme = context.theme;
    if (isDark) {
      return GetBuilder<SettingsController>(
        id: 'Theme',
        builder: (controller) => CupertinoSwitch(
          value: !controller.isLightTheme,
          onChanged: controller.changeTheme,
          activeTrackColor: theme.primaryColor,
        ),
      );
    }

    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: SvgPicture.asset(
        Constants.forwardArrowIcon,
        fit: BoxFit.none,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

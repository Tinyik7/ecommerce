import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final double? dividerEndIndent;
  const ScreenTitle({
    super.key,
    required this.title,
    this.dividerEndIndent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Divider(
          thickness: 2,
          endIndent: dividerEndIndent ?? 240,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

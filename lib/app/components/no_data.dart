import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class NoData extends StatelessWidget {
  final String? text;
  const NoData({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        80.verticalSpace,
        Image.asset(Constants.noData),
        20.verticalSpace,
        Text(text ?? 'no_data'.tr, style: context.textTheme.displayMedium),
      ],
    );
  }
}

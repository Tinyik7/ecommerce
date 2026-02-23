import 'package:ecommerce_app/app/modules/auth/views/forgot_password_view.dart';
import 'package:ecommerce_app/app/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Forgot password screen renders required fields and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          home: ForgotPasswordView(),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Reset token'), findsOneWidget);
    expect(find.text('Request token'), findsOneWidget);
    expect(find.text('Reset password'), findsNWidgets(2));
  });
}

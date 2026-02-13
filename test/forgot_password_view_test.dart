import 'package:ecommerce_app/app/modules/auth/views/forgot_password_view.dart';
import 'package:flutter/material.dart';
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
      GetMaterialApp(
        home: ForgotPasswordView(),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Reset token'), findsOneWidget);
    expect(find.text('Запросить token'), findsOneWidget);
    expect(find.text('Сбросить пароль'), findsOneWidget);
  });
}

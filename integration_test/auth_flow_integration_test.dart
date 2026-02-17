import 'package:ecommerce_app/app/modules/auth/views/forgot_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('forgot password screen validates required fields', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: ForgotPasswordView(),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(3));

    await tester.tap(find.byType(ElevatedButton).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(3));
  });
}

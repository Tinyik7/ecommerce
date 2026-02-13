import 'package:ecommerce_app/app/modules/auth/controllers/forgot_password_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('ForgotPasswordController validation', () {
    test('validateEmail returns error for empty value', () {
      final controller = ForgotPasswordController();
      expect(controller.validateEmail(''), isNotNull);
      controller.onClose();
    });

    test('validateEmail returns null for valid email', () {
      final controller = ForgotPasswordController();
      expect(controller.validateEmail('user@example.com'), isNull);
      controller.onClose();
    });

    test('validateToken returns error for empty token', () {
      final controller = ForgotPasswordController();
      expect(controller.validateToken(' '), isNotNull);
      controller.onClose();
    });

    test('validatePassword enforces min length', () {
      final controller = ForgotPasswordController();
      expect(controller.validatePassword('12345'), isNotNull);
      expect(controller.validatePassword('123456'), isNull);
      controller.onClose();
    });
  });
}

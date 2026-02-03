import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../local/my_shared_pref.dart';

class ApiClient {
  ApiClient._();

  static Map<String, String> authHeaders({Map<String, String>? extra}) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final String? token = MySharedPref.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extra != null && extra.isNotEmpty) {
      headers.addAll(extra);
    }

    return headers;
  }

  static void handleUnauthorized() {
    const String title =
        '\u0421\u0435\u0441\u0441\u0438\u044F\u0020\u0438\u0441\u0442\u0435\u043A\u043B\u0430';
    const String message =
        '\u041F\u043E\u0436\u0430\u043B\u0443\u0439\u0441\u0442\u0430,\u0020\u0432\u043E\u0439\u0434\u0438\u0442\u0435\u0020\u0441\u043D\u043E\u0432\u0430';

    Get.offAllNamed(Routes.login);
    Get.snackbar(title, message);
  }
}

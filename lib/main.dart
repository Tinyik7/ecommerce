import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/data/local/local_database_service.dart';
import 'app/data/local/my_shared_pref.dart';
import 'app/data/services/api_client.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'app/translations/translations.dart';

const String baseUrl = 'http://localhost:8080';

Future<void> testConnection() async {
  final Uri url = Uri.parse('$baseUrl/api/v1/products');

  try {
    final http.Response response =
        await http.get(url, headers: ApiClient.authHeaders());
    if (response.statusCode == 401) {
      debugPrint('Unauthorized while testing backend connection.');
      return;
    }
    debugPrint('Connected to backend!');
    debugPrint('Status code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
  } catch (e) {
    debugPrint('Connection error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await MySharedPref.init();
  await LocalDatabaseService.init();

  await testConnection();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, widget) {
        return GetMaterialApp(
          title: 'app_title'.tr,
          translations: AppTranslations(),
          locale: const Locale('ru', 'RU'),
          fallbackLocale: const Locale('en', 'US'),
          useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            final bool themeIsLight = MySharedPref.getThemeIsLight();
            return Theme(
              data: MyTheme.getThemeData(isLight: themeIsLight),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: widget!,
              ),
            );
          },
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    ),
  );
}



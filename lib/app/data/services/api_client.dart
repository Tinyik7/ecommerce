import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../routes/app_pages.dart';
import '../local/my_shared_pref.dart';

class ApiClient {
  ApiClient._();

  static const Duration _timeout = Duration(seconds: 12);

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

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    bool redirectOnUnauthorized = true,
  }) {
    return _send(
      () => http.get(uri, headers: headers ?? authHeaders()),
      redirectOnUnauthorized: redirectOnUnauthorized,
    );
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool redirectOnUnauthorized = true,
  }) {
    return _send(
      () => http.post(uri, headers: headers ?? authHeaders(), body: body),
      redirectOnUnauthorized: redirectOnUnauthorized,
    );
  }

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool redirectOnUnauthorized = true,
  }) {
    return _send(
      () => http.put(uri, headers: headers ?? authHeaders(), body: body),
      redirectOnUnauthorized: redirectOnUnauthorized,
    );
  }

  static Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    bool redirectOnUnauthorized = true,
  }) {
    return _send(
      () => http.delete(uri, headers: headers ?? authHeaders(), body: body),
      redirectOnUnauthorized: redirectOnUnauthorized,
    );
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() request, {
    required bool redirectOnUnauthorized,
  }) async {
    try {
      final http.Response response = await request().timeout(_timeout);

      if (response.statusCode == 401 && redirectOnUnauthorized) {
        handleUnauthorized();
        throw const ApiException(ApiErrorKind.unauthorized, 'Session expired');
      }
      if (response.statusCode == 403) {
        throw const ApiException(ApiErrorKind.forbidden, 'Access denied');
      }
      if (response.statusCode >= 500) {
        throw ApiException(
          ApiErrorKind.server,
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      return response;
    } on TimeoutException {
      throw const ApiException(ApiErrorKind.timeout, 'Request timeout');
    } on SocketException {
      throw const ApiException(ApiErrorKind.network, 'Network unavailable');
    }
  }

  static void handleUnauthorized() {
    const String title = 'Сессия истекла';
    const String message = 'Пожалуйста, войдите снова';

    Get.offAllNamed(Routes.login);
    Get.snackbar(title, message);
  }
}

enum ApiErrorKind { unauthorized, forbidden, timeout, network, server }

class ApiException implements Exception {
  const ApiException(this.kind, this.message, {this.statusCode});

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

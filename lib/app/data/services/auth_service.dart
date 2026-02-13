import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Use `--dart-define=USE_ANDROID_EMULATOR_HOST=true` when running on the
  /// Android emulator so we automatically hit 10.0.2.2. On physical devices
  /// (or when the define isn't provided) we use the LAN IP instead.
  static const bool _useAndroidEmulatorHost =
      bool.fromEnvironment('USE_ANDROID_EMULATOR_HOST', defaultValue: false);

  /// Picks base URL based on platform to support emulators.
  String get _baseUrl {
    const String localBase = 'http://localhost:8080/api/v1/users';

    if (kIsWeb) return localBase;

    try {
      if (Platform.isAndroid && _useAndroidEmulatorHost) {
        return 'http://10.0.2.2:8080/api/v1/users';
      }
    } on UnsupportedError {
      return localBase;
    }

    return localBase;
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/register');
    http.Response res;
    try {
      res = await ApiClient.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'username': username.trim(),
          'name': username.trim(),
          'email': email.trim(),
          'password': password,
        }),
        redirectOnUnauthorized: false,
      );
    } on ApiException catch (e) {
      throw Exception(e.message);
    }

    if (res.statusCode == 409) {
      throw AuthConflictException(res.body);
    }

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
    }

    final String body = res.body.isNotEmpty ? res.body : 'Registration failed';
    throw Exception('HTTP ${res.statusCode}: $body');
  }

  Future<LoginResult?> login({
    required String email,
    required String password,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/login');
    http.Response res;
    try {
      res = await ApiClient.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'email': email.trim(),
          'password': password,
        }),
        redirectOnUnauthorized: false,
      );
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.timeout || e.kind == ApiErrorKind.network) {
        throw Exception(e.message);
      }
      rethrow;
    }

    if (res.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (res.statusCode == 200 && res.body.isNotEmpty && res.body != 'null') {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final String? token = decoded['token']?.toString();
        final dynamic userJson = decoded['user'] ?? decoded;
        if (userJson is Map<String, dynamic>) {
          final UserModel user = UserModel.fromJson(userJson);
          return LoginResult(user: user, token: token);
        }
      }
    }

    return null;
  }

  Future<UserModel?> fetchCurrentUser() async {
    final Uri uri = Uri.parse('$_baseUrl/me');
    http.Response res;
    try {
      res = await ApiClient.get(uri);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        return null;
      }
      throw Exception(e.message);
    }

    if (res.statusCode == 401) {
      return null;
    }

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
    }

    return null;
  }

  Future<UserModel> updateProfile({
    String? username,
    String? email,
    String? name,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/me');
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (username != null && username.trim().isNotEmpty) {
      payload['username'] = username.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }
    if (name != null && name.trim().isNotEmpty) {
      payload['name'] = name.trim();
    }

    http.Response res;
    try {
      res = await ApiClient.put(uri, body: jsonEncode(payload));
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        throw UnauthorizedException();
      }
      throw Exception(e.message);
    }

    if (res.statusCode == 409) {
      throw AuthConflictException(res.body);
    }
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
    }

    final String body = res.body.isNotEmpty ? res.body : 'Update failed';
    throw Exception('HTTP ${res.statusCode}: $body');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/me/password');
    http.Response res;
    try {
      res = await ApiClient.put(
        uri,
        body: jsonEncode(<String, dynamic>{
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        throw UnauthorizedException();
      }
      throw Exception(e.message);
    }

    if (res.statusCode == 400) {
      throw InvalidCurrentPasswordException();
    }
    if (res.statusCode == 200) {
      return;
    }

    final String body = res.body.isNotEmpty ? res.body : 'Password update failed';
    throw Exception('HTTP ${res.statusCode}: $body');
  }

  Future<String?> requestPasswordReset({
    required String email,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/forgot-password');
    final http.Response res = await ApiClient.post(
      uri,
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'email': email.trim()}),
      redirectOnUnauthorized: false,
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['resetToken']?.toString();
      }
    }
    return null;
  }

  Future<void> resetPasswordByToken({
    required String token,
    required String newPassword,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/reset-password');
    final http.Response res = await ApiClient.post(
      uri,
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token.trim(),
        'newPassword': newPassword,
      }),
      redirectOnUnauthorized: false,
    );

    if (res.statusCode == 200) {
      return;
    }
    if (res.statusCode == 400) {
      throw Exception('Invalid or expired reset token');
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}

class LoginResult {
  LoginResult({required this.user, this.token});

  final UserModel user;
  final String? token;
}

class AuthConflictException implements Exception {
  AuthConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {}

class InvalidCurrentPasswordException implements Exception {}



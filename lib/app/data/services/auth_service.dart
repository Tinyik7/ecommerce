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
    final http.Response res = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'username': username.trim(),
        'name': username.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

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
    final http.Response res = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'email': email.trim(),
        'password': password,
      }),
    );

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
    final http.Response res = await http.get(
      uri,
      headers: ApiClient.authHeaders(),
    );

    if (res.statusCode == 401) {
      ApiClient.handleUnauthorized();
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



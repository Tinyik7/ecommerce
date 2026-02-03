import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPref {
  MySharedPref._();

  static late SharedPreferences _sharedPreferences;

  static const String _fcmTokenKey = 'fcm_token';
  static const String _lightThemeKey = 'is_theme_light';
  static const String _authTokenKey = 'token';
  static const String _localeKey = 'locale';
  static const String _userRoleKey = 'user_role';

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> setThemeIsLight(bool isLight) async {
    await _sharedPreferences.setBool(_lightThemeKey, isLight);
  }

  static bool getThemeIsLight() {
    return _sharedPreferences.getBool(_lightThemeKey) ?? true;
  }

  static Future<void> setLocale(Locale locale) async {
    await _sharedPreferences.setString(_localeKey, locale.languageCode);
  }

  static Locale getLocale() {
    final String? code = _sharedPreferences.getString(_localeKey);
    return Locale(code ?? 'en');
  }

  static Future<void> setToken(String token) async {
    await _sharedPreferences.setString(_authTokenKey, token);
  }

  static String? getToken() {
    return _sharedPreferences.getString(_authTokenKey);
  }

  static Future<bool> removeToken() async {
    return _sharedPreferences.remove(_authTokenKey);
  }

  static Future<void> setFcmToken(String token) async {
    await _sharedPreferences.setString(_fcmTokenKey, token);
  }

  static String? getFcmToken() {
    return _sharedPreferences.getString(_fcmTokenKey);
  }

  static Future<void> setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await _sharedPreferences.setInt(key, value);
  }

  static String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  static int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  static Future<bool> remove(String key) async {
    return _sharedPreferences.remove(key);
  }

  static Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  static Future<void> setUserRole(String role) async {
    await _sharedPreferences.setString(_userRoleKey, role);
  }

  static String getUserRole() {
    return _sharedPreferences.getString(_userRoleKey) ?? 'USER';
  }
}

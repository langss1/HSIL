import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalSessionDataSource {
  LocalSessionDataSource({
    required SharedPreferences preferences,
    required FlutterSecureStorage secureStorage,
  }) : _preferences = preferences,
       _secureStorage = secureStorage;

  static const String _rememberMeKey = 'auth.remember_me';
  static const String _rememberedNikKey = 'auth.remembered_nik';
  static const String _cachedUserKey = 'auth.cached_user';

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  Future<bool> getRememberMe() async {
    return _preferences.getBool(_rememberMeKey) ?? false;
  }

  Future<String?> getRememberedNik() async {
    return _preferences.getString(_rememberedNikKey);
  }

  Future<void> saveRememberMe({
    required bool rememberMe,
    required String nik,
  }) async {
    await _preferences.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await _preferences.setString(_rememberedNikKey, nik);
    } else {
      await _preferences.remove(_rememberedNikKey);
    }
  }

  Future<UserModel?> getCachedUser() async {
    final raw = await _secureStorage.read(key: _cachedUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> cacheUser(UserModel user) {
    return _secureStorage.write(
      key: _cachedUserKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _cachedUserKey);
  }
}

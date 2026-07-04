import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/app_session.dart';

class AuthLocalStorage {
  AuthLocalStorage(this._preferences);

  final SharedPreferences _preferences;

  static const String _accessTokenKey = 'auth.accessToken';
  static const String _tokenTypeKey = 'auth.tokenType';
  static const String _userIdKey = 'auth.userId';
  static const String _deviceTypeKey = 'auth.deviceType';
  static const String _deviceSlotKey = 'auth.deviceSlot';
  static const String _deviceIdKey = 'auth.deviceId';

  AppSession? readSession() {
    final accessToken = _preferences.getString(_accessTokenKey);
    final tokenType = _preferences.getString(_tokenTypeKey);
    final userIdText = _preferences.getString(_userIdKey);
    final deviceType = _preferences.getString(_deviceTypeKey);
    final deviceSlot = _preferences.getString(_deviceSlotKey);
    final deviceId = _preferences.getString(_deviceIdKey);

    final userId = int.tryParse(userIdText ?? '');
    if (accessToken == null ||
        tokenType == null ||
        userId == null ||
        deviceType == null ||
        deviceSlot == null ||
        deviceId == null) {
      return null;
    }

    return AppSession(
      accessToken: accessToken,
      tokenType: tokenType,
      userId: userId,
      deviceType: deviceType,
      deviceSlot: deviceSlot,
      deviceId: deviceId,
    );
  }

  Future<void> saveSession(AppSession session) async {
    await _preferences.setString(_accessTokenKey, session.accessToken);
    await _preferences.setString(_tokenTypeKey, session.tokenType);
    await _preferences.setString(_userIdKey, session.userId.toString());
    await _preferences.setString(_deviceTypeKey, session.deviceType);
    await _preferences.setString(_deviceSlotKey, session.deviceSlot);
    await _preferences.setString(_deviceIdKey, session.deviceId);
  }

  Future<void> clearSession() async {
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_tokenTypeKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_deviceTypeKey);
    await _preferences.remove(_deviceSlotKey);
    await _preferences.remove(_deviceIdKey);
  }

  Future<String> readOrCreateDeviceId(String deviceType) async {
    final key = 'device.id.$deviceType';
    final savedDeviceId = _preferences.getString(key);
    if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
      return savedDeviceId;
    }

    final random = Random();
    final suffix = List.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    final createdDeviceId =
        '$deviceType-${DateTime.now().millisecondsSinceEpoch}-$suffix';
    await _preferences.setString(key, createdDeviceId);
    return createdDeviceId;
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSimplePreferences {
  static late SharedPreferences _preferences;

  static const _gpsEnabled = 'gpsEnabled';
  static const _hasPermission = 'hasPermission';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setGpsEnabled(bool enabled) async =>
      await _preferences.setBool(_gpsEnabled, enabled);

  static bool getGpsEnabled() {
    final gpsEnabled = _preferences.getBool(_gpsEnabled);
    return gpsEnabled == null ? false : gpsEnabled;
  }

  static Future setHasPermission(bool permission) async =>
      await _preferences.setBool(_hasPermission, permission);

  static bool getHasPermission() {
    final hasPermission = _preferences.getBool(_hasPermission);
    return hasPermission == null ? false : hasPermission;
  }
}

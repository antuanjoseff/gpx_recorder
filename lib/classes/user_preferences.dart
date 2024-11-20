import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _numSatelites = 'numSatelintes';
  static const _accuracy = 'accuracy';
  static const _speed = 'speed';
  static const _heading = 'heading';
  static const _provider = 'provider';
  static const _trackLength = 'trackLength';
  static const _trackTime = 'trackTime';
  static const _trackAltitude = 'trackAltitude';
  static const _trackVisible = 'trackVisible';
  static const _trackColor = 'trackColor';
  static const _gpsMethod = 'gpsMethod';
  static const _gpsUnitsDistance = 'gpsUnitsDistance';
  static const _gpsUnitsTime = 'gpsUnitsTime';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  // GETTERS

  // only for android
  static bool getNumSatelites() {
    final numSatelites = _preferences.getBool(_numSatelites);
    return numSatelites == null ? false : numSatelites;
  }

  static bool getAccuracy() {
    final accuracy = _preferences.getBool(_accuracy);
    return accuracy == null ? false : accuracy;
  }

  static bool getSpeed() {
    final speed = _preferences.getBool(_speed);
    return speed == null ? false : speed;
  }

  static bool getHeading() {
    final heading = _preferences.getBool(_heading);
    return heading == null ? false : heading;
  }

  static bool getProvider() {
    final provider = _preferences.getBool(_provider);
    return provider == null ? false : provider;
  }

  static String getTrackLength() {
    final trackLength = _preferences.getString(_trackLength);
    return trackLength == null ? '0' : trackLength;
  }

  static String getTrackTime() {
    final trackTime = _preferences.getString(_trackTime);
    return trackTime == null ? '' : trackTime;
  }

  static String getTrackAltitude() {
    final trackAltitude = _preferences.getString(_trackAltitude);
    return trackAltitude == null ? '' : trackAltitude;
  }

  static bool getTrackVisible() {
    final visible = _preferences.getBool(_trackVisible);
    return visible == null ? true : visible;
  }

  static Color getTrackColor() {
    final trackColor = _preferences.getInt(_trackColor);
    return trackColor == null ? Colors.pink : Color(trackColor);
  }

  static String getGpsMethod() {
    final method = _preferences.getString(_gpsMethod);
    return method == null ? 'meters' : method;
  }

  static double getGpsUnitsDistance() {
    final units = _preferences.getDouble(_gpsUnitsDistance);
    return units == null ? 10 : units;
  }

  static double getGpsUnitsTime() {
    final units = _preferences.getDouble(_gpsUnitsTime);
    return units == null ? 10 : units;
  }

  // SETTERS

  static Future setNumSatelites(bool numSatelites) async =>
      await _preferences.setBool(_numSatelites, numSatelites);

  static Future setAccuracy(bool accuracy) async =>
      await _preferences.setBool(_accuracy, accuracy);

  static Future setSpeed(bool speed) async =>
      await _preferences.setBool(_speed, speed);

  static Future setHeading(bool heading) async =>
      await _preferences.setBool(_heading, heading);

  static Future setProvider(bool provider) async =>
      await _preferences.setBool(_provider, provider);

  static Future setTrackLength(String length) async =>
      await _preferences.setString(_trackLength, length);

  static Future setTrackTime(String duration) async =>
      await _preferences.setString(_trackTime, duration);

  static Future setTrackAltitude(String altitude) async =>
      await _preferences.setString(_trackAltitude, altitude);

  static Future setTrackVisible(bool visible) async =>
      await _preferences.setBool(_trackVisible, visible);

  static Future setTrackColor(Color color) async =>
      await _preferences.setInt(_trackColor, color.value);

  static Future setGpsMethod(String method) async =>
      await _preferences.setString(_gpsMethod, method);

  static Future setGpsUnitsDistance(double units) async =>
      await _preferences.setDouble(_gpsUnitsDistance, units);

  static Future setGpsUnitsTime(double units) async =>
      await _preferences.setDouble(_gpsUnitsTime, units);
}

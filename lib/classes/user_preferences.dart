import 'package:shared_preferences/shared_preferences.dart';

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
}

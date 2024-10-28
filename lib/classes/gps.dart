import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// Request a location

class Gps {
  Gps();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = Location();
  StreamSubscription<LocationData>? subscription;

  Future<bool> checkService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  listenOnBackground(Function managePosition) async {
    String isInBackground = await location.isBackgroundModeEnabled()
        ? 'YES IN BACKGROUND'
        : 'NOT IN BACKGROUND';
    debugPrint(isInBackground);

    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
    location.changeSettings(accuracy: LocationAccuracy.low);

    subscription = location.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        debugPrint(err.code);
      }
      subscription?.cancel();
    }).listen((currentLocation) {
      debugPrint('IN GPS CLASS ${currentLocation.speed}');
      managePosition(currentLocation);
    });
  }

  void cancelSubscription() {
    subscription?.cancel();
  }

  changeIntervalByTime(int interval) {
    // location.changeSettings(interval: interval);
  }

  changeIntervalByDistance(double distance) {
    location.changeSettings(distanceFilter: distance);
  }
}

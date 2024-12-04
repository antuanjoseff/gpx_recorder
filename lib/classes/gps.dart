import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter/material.dart';

// Request a location

class Gps {
  Gps();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = Location();

  Future<bool> checkService() async {
    debugPrint('INSIDE CHECK SERVICE');
    _serviceEnabled = await location.serviceEnabled();
        debugPrint('INSIDE CHECK SERVICE 2');

    if (!_serviceEnabled) {
          debugPrint('INSIDE CHECK SERVICE 3');
      _serviceEnabled = await location.requestService();
          debugPrint('INSIDE CHECK SERVICE 4');

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

  Future<LocationData?> getLocation() async {
    return await location.getLocation();
  }

  Future<StreamSubscription> listenOnBackground(Function managePosition) async {
    return location.onLocationChanged.listen((LocationData currentLocation) {
      managePosition(currentLocation);
    });
  }

  enableBackground(String notificationTitle, String notificationContent) {
    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: notificationTitle,
      subtitle: notificationContent,
    );
  }

  changeSettings(
    LocationAccuracy accuracy,
    double? distanceFilter,
    int? interval,
  ) {
    debugPrint(
        'DEBUG; time (s) ${(interval! / 1000)} distance (m) $distanceFilter');
    location.changeSettings(
      accuracy: accuracy,
      interval: interval,
      distanceFilter: distanceFilter,
    );
  }

  changeIntervalByDistance(double distance) {
    location.changeSettings(
      distanceFilter: distance,
      accuracy: LocationAccuracy.high,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:location/location.dart';

// Request a location

class Gps {
  Gps();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = new Location();

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

  Future<LocationData?> getLocation() async {
    return await location.getLocation();
  }

  listenOnBackground(Function managePosition) async {
    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
    location.changeSettings(
      interval: 100,
      distanceFilter: 0,
      accuracy: LocationAccuracy.high,
    );
    location.onLocationChanged.listen((LocationData currentLocation) {
      print('IN GPS CLASS ${DateTime.now()}       ${currentLocation.accuracy}');
      managePosition(currentLocation);
    });
  }

  changeIntervalByTime(int interval) {
    location.changeSettings(interval: interval);
  }

  changeIntervalByDistance(double distance) {
    location.changeSettings(distanceFilter: distance);
  }
}

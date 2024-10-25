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

  listenOnBackground(Function managePosition) async {
    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
    location.changeSettings(interval: 1000);
    location.onLocationChanged.listen((LocationData currentLocation) {
      print('IN GPS CLASS $currentLocation');
      managePosition(currentLocation);
    });
  }

  changeInterval(int interval) {
    location.changeSettings(interval: interval);
  }
}

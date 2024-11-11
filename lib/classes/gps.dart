import 'package:location/location.dart';
import 'dart:async';

// Request a location

class Gps {
  Gps();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = Location();

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

  Future<bool> requestPermission() async {
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
      LocationAccuracy accuracy, int? interval, double? distanceFilter) {
    location.changeSettings(
      interval: interval ?? 1000,
      distanceFilter: distanceFilter ?? 0,
      accuracy: accuracy,
    );
  }

  changeIntervalByDistance(double distance) {
    location.changeSettings(
      distanceFilter: distance,
      accuracy: LocationAccuracy.high,
    );
  }
}

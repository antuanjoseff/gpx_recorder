import 'package:flutter/material.dart';

class GpsController {
  String method;
  double unitsDistance;
  int unitsTime = 10;

  GpsController({
    required this.method,
    required this.unitsDistance,
    required this.unitsTime,
  });
}

import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/track.dart';

class TrackController {
  bool visible = true;
  Color color = Colors.pink;
  int width = 4;

  TrackController({
    required this.visible,
    required this.color,
    required this.width,
  });
}

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapController {
  // Future<Line?> Function(List<Wpt> lineSegment)? loadTrack;
  // Future<void> Function()? removeTrackLine;
  // Future<List<Symbol>> Function()? addMapSymbols;
  // void Function()? removeMapSymbols;
  // List<Wpt> Function()? getGpx;
  // Future<void> Function(LineOptions changes)? updateTrack;
  void Function(
    bool numSatelites,
    bool accuracy,
    bool speed,
    bool heading,
    bool provider,
    bool visible,
    Color color,
    int width,
  )? setTrackPreferences;

  void Function()? startRecording;
  void Function()? pauseRecording;
  void Function()? resumeRecording;
  void Function()? finishRecording;
  bool Function()? mapIsCreated;
  void Function(LatLng?)? centerMap;
  void Function(String, double, int)? setGpsSettings;
  LatLng? Function()? getLastLocation;
  void Function(String)? setBaseLayer;
  LatLng Function()? getCenter;
  double Function()? getZoom;
}

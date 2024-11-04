import 'package:flutter/material.dart';

class MainController {
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
  )? setTrackPreferences;
  void Function()? startRecording;
  void Function()? pauseRecording;
  void Function()? resumeRecording;
  void Function()? finishRecording;
  bool Function()? mapIsCreated;
}
class TrackSettings {
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
  )? setTrackPreferences;
  void Function()? startRecording;
  void Function()? stopRecording;
  void Function()? finishRecording;
}

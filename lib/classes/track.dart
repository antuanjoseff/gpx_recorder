import 'package:geoxml/geoxml.dart';
import 'package:background_location/background_location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'bounds.dart' as my;
import '../utils/util.dart';
import 'package:flutter/material.dart';

class Track {
  // Map controller
  MapLibreMapController map;

  // Original track
  List<Wpt> wpts = [];

  // Array of coordinates to draw a linestring on map
  List<LatLng> gpxCoords = [];

  // Track Line (on map)
  Line? trackLine;

  // Start recording time
  DateTime? startAt;

  //Time not moving
  Duration notMovingTime = Duration(seconds: 0);

  // Track length
  double length = 0;

  // Track last / current speedlength
  double? currentSpeed = 0;

  // Track last / current accuracy
  double? accuracy;

  // Current elevation
  int? currentElevation = null;

  // Elevation Gain
  int elevationGain = 0;

  // Calculate elevation gain every X seconds
  int elevationGainInterval = 60;

  // Last DateTime when elevation gain was calculated
  DateTime? lastElevatonGainTime = null;

  // Last elevation checked for elevation gain calc
  int? lastElevationChecked;

  // Track visibility
  bool visible = true;

  // Track width
  int trackWidth = 4;

  // Track color
  Color trackColor = Colors.pink;

  // Constructor
  Track(this.wpts, this.map);

  // Bbox del track
  my.Bounds? bounds;

  Future<void> init() async {
    startAt = DateTime.now();
    if (visible) addLine();
    notMovingTime = Duration(seconds: 0);
  }

  my.Bounds? getBounds() {
    if (wpts.isEmpty) return null;
    LatLng cur;

    // Init track bounds with first track point
    bounds = my.Bounds(LatLng(wpts.first.lat!, wpts.first.lon!),
        LatLng(wpts.first.lat!, wpts.first.lon!));

    for (var i = 0; i < wpts.length; i++) {
      cur = LatLng(wpts[i].lat!, wpts[i].lon!);

      bounds!.expand(cur);
      gpxCoords.add(cur);
    }
    return bounds;
  }

  List<LatLng> getCoordsList() {
    return gpxCoords;
  }

  List<Wpt> getWpts() {
    return wpts;
  }

  double getLength() {
    return length;
  }

  double? getCurrentSpeed() {
    return currentSpeed;
  }

  int? getCurrentElevation() {
    return currentElevation;
  }

  int? getElevationGain() {
    return elevationGain;
  }

  DateTime? getStartTime() {
    return startAt;
  }

  double? getAccuracy() {
    return accuracy;
  }

  Duration getNotMovingTime() {
    return notMovingTime;
  }

  void setCurrentSpeed(double? speed) {
    currentSpeed = speed;
  }

  void setCurrentElevation(int? elevation) {
    currentElevation = elevation;
  }

  void setNotMovingTime(Duration time) {
    notMovingTime = time;
  }

  void setAccuracy(double lastAccuracy) {
    accuracy = double.parse(lastAccuracy.toStringAsFixed(2));
  }

  void reset() {
    gpxCoords = [];
    wpts = [];
  }

  void push(Wpt wpt, Location loc) {
    double inc = 0;
    LatLng P = LatLng(wpt.lat!, wpt.lon!);
    debugPrint('PUSH 0');
    if (loc.speed?.round() == 0) {
      if (gpxCoords.isNotEmpty) {
        LatLng prev = gpxCoords[gpxCoords.length - 1];
        inc = getDistanceFromLatLonInMeters(P, prev);
      }

      if (lastElevatonGainTime == null) {
        lastElevatonGainTime = DateTime.now();
        lastElevationChecked = wpt.ele == null ? null : wpt.ele!.toInt();
      } else {
        if (DateTime.now().difference(lastElevatonGainTime!).inSeconds >
            elevationGainInterval) {
          int? newElevation = wpt.ele != null ? wpt.ele!.toInt() : null;
          if (newElevation != null && lastElevationChecked != null) {
            elevationGain += newElevation - lastElevationChecked!;
            lastElevationChecked = newElevation;
          }
        }
      }
      debugPrint('PUSH 1');
      gpxCoords.add(P);
      debugPrint('PUSH 2');
      wpts.add(wpt);
      debugPrint('PUSH 3');
      length += inc;
      debugPrint('PUSH 4');
      if (visible) {
        debugPrint('PUSH 5');
        updateLine();
        debugPrint('PUSH 6');
      }
    }
  }

  void insert(int position, Wpt wpt) {
    LatLng P = LatLng(wpt.lat!, wpt.lon!);
    gpxCoords.insert(position + 1, P);
    wpts.insert(position + 1, wpt);
  }

  void remove(int index) {
    wpts.removeAt(index);
    gpxCoords.removeAt(index);
  }

  void addWpt(int idx, Wpt wpt) {
    wpts.insert(idx, wpt);
    LatLng latlon = LatLng(wpt.lat!, wpt.lon!);
    gpxCoords.insert(idx, latlon);
  }

  void removeWpt(int idx, Wpt wpt) {
    wpts.removeAt(idx);
    gpxCoords.removeAt(idx);
  }

  void moveWpt(int idx, Wpt wpt) {
    wpts[idx] = wpt;
    LatLng latlon = LatLng(wpt.lat!, wpt.lon!);
    gpxCoords[idx] = latlon;
  }

  (double, int, LatLng) getCandidateNode(LatLng clickedPoint) {
    Stopwatch stopwatch = new Stopwatch()..start();
    int numSegment = getClosestSegmentToLatLng(gpxCoords, clickedPoint);
    print('Closest at ($numSegment) executed in ${stopwatch.elapsed}');

    LatLng P = projectionPoint(
        gpxCoords[numSegment], gpxCoords[numSegment + 1], clickedPoint);

    double dist = getDistanceFromLatLonInMeters(clickedPoint, P);

    return (dist, numSegment, P);
  }

  double trackToPointDistance(LatLng location) {
    var (distance, numSement, point) = getCandidateNode(location);
    return distance;
  }

  int getClosestSegmentToLatLng(gpxCoords, point) {
    if (gpxCoords.length <= 0) return -1;
    int closestSegment = 0;
    double distance = double.infinity;
    double minD = double.infinity;

    // return 0;
    for (var i = 0; i < gpxCoords.length - 1; i++) {
      distance = minDistance(gpxCoords[i], gpxCoords[i + 1], point);

      if (distance < minD) {
        minD = distance;
        closestSegment = i;
      }
    }

    return closestSegment;
  }

  void changeNodeAt(int idx, LatLng coordinate) {
    gpxCoords[idx] = coordinate;
  }

  Wpt getWptAt(int idx) {
    return wpts[idx];
  }

  void setWptAt(int idx, Wpt wpt) {
    wpts[idx] = wpt;
  }

  Future<Line?> addLine() async {
    trackLine = await map!.addLine(
      LineOptions(
        geometry: gpxCoords,
        lineColor: trackColor.toHexStringRGB(),
        lineWidth: 3,
        lineOpacity: 0.9,
      ),
    );
    return trackLine;
  }

  void updateLine() async {
    if (visible) {
      await map.updateLine(trackLine!, LineOptions(geometry: gpxCoords));
    }
  }

  Future<void> removeLine() async {
    if (trackLine != null) {
      print('remove TRACKLINE');
      map.removeLine(trackLine!);
    }
  }
}

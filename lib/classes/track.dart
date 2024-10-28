import 'package:geoxml/geoxml.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'bounds.dart' as my;
import '../utils/util.dart';

class Track {
  // Original track
  List<Wpt> wpts = [];

  // Array of coordinates to draw a linestring on map
  List<LatLng> gpxCoords = [];

  // Start recording time
  DateTime startAt = DateTime.now();

  //Time not moving
  Duration notMovingTime = Duration(seconds: 0);

  // Track length
  double length = 0;

  // Track last / current speedlength
  double? currentSpeed = 0;

  // Current altitud
  int? currentAltitude = null;

  // Constructor
  Track(this.wpts);

  // Bbox del track
  my.Bounds? bounds;

  Future<void> init() async {
    startAt = DateTime.now();
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
    return currentAltitude;
  }

  DateTime getStartTime() {
    return startAt;
  }

  Duration getNotMovingTime() {
    return notMovingTime;
  }

  void setCurrentSpeed(double? speed) {
    currentSpeed = speed;
  }

  void setCurrentElevation(int? elevation) {
    currentAltitude = elevation;
  }

  void setNotMovingTime(Duration time) {
    notMovingTime = time;
  }

  void reset() {
    gpxCoords = [];
    wpts = [];
  }

  void push(Wpt wpt) {
    double inc = 0;
    LatLng P = LatLng(wpt.lat!, wpt.lon!);
    if (gpxCoords.isNotEmpty) {
      LatLng prev = gpxCoords[gpxCoords.length - 1];
      inc = getDistanceFromLatLonInMeters(P, prev);
    }

    gpxCoords.add(P);
    wpts.add(wpt);
    length += inc;
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
}

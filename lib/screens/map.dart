import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import '../classes/track.dart';
import '../classes/appSettings.dart';
import '../classes/user_preferences.dart';
import '../screens/track_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geoxml/geoxml.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert' show utf8;

class MapWidget extends StatefulWidget {
  final AppSettings appSettings;
  final Function onlongpress;

  const MapWidget({
    super.key,
    required this.appSettings,
    required this.onlongpress,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState(appSettings);
}

class _MapWidgetState extends State<MapWidget> {
  late bool _numSatelites;
  late bool _accuracy;
  late bool _speed;
  late bool _heading;
  late bool _provider;
  late Gps gps;
  late Track track;
  bool _myLocationEnabled = false;
  bool hasLocationPermission = false;
  bool recording = false;
  bool stop = false;
  bool isMoving = false;
  late DateTime notMovingStartedAt;
  Duration timeNotMoving = Duration(seconds: 0);

  late MapLibreMapController mapController;
  Location location = new Location();

  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.none;
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.normal;

// Vars to detect pan on map
  final stopwatch = Stopwatch();
  double bearing = 0;
  bool _isMoving = false;
  bool justStop = false;
  bool justMoved = false;
  int panTime = 0;
  bool trackCameroMove = true;
  bool mapCentered = true;
  LocationData? currentLoc = null;
  _MapWidgetState(AppSettings appSettings) {
    appSettings.setTrackPreferences = setTrackPreferences;
    appSettings.startRecording = startRecording;
    appSettings.resumeRecording = resumeRecording;
    appSettings.stopRecording = stopRecording;
    appSettings.finishRecording = finishRecording;
  }

  void setTrackPreferences(bool numSatelites, bool accuracy, bool speed,
      bool heading, bool provider) {
    _numSatelites = numSatelites;
    _accuracy = accuracy;
    _speed = speed;
    _heading = heading;
    _provider = provider;
  }

  @override
  void initState() {
    gps = Gps();
    track = Track([]);

    getUserPreferences();
    gps.checkService().then((enabled) {
      if (enabled) {
        gps.checkPermission().then((value) {
          hasLocationPermission = value;
          if (value) {
            _myLocationEnabled = true;
            callSetState();
          }
        });
      }
    });
    super.initState();
  }

  void callSetState() {
    _myLocationRenderMode = MyLocationRenderMode.compass;
    setState(() {});
  }

  void getUserPreferences() {
    _accuracy = UserPreferences.getAccuracy();
    _numSatelites = UserPreferences.getNumSatelites();
    _speed = UserPreferences.getSpeed();
    _heading = UserPreferences.getHeading();
    _provider = UserPreferences.getProvider();
  }

  void startRecording() async {
    print('start recording!!!!');

    if (hasLocationPermission) {
      recording = true;
      track.init();
      LocationData? loc = await gps.getLocation();
      if (loc != null) {
        firstCamaraView(LatLng(loc.latitude!, loc.longitude!), 14);
      }
      notMovingStartedAt = DateTime.now();
      gps.enableBackground('Geolocation', 'Geolocation detection');
      gps.changeIntervalByTime(1000);
      gps.listenOnBackground(handleNewPosition);
      setState(() {});
    }
  }

  void resumeRecording() {
    recording = true;
    print('resume recording!!!!');
  }

  void stopRecording() {
    recording = false;
    print('stop recording!!!!');
  }

  void finishRecording() async {
    recording = false;
    stop = true;
    final gpx = GeoXml();
    gpx.version = '1.1';
    gpx.creator = 'dart-gpx library';
    gpx.metadata = Metadata();
    gpx.metadata?.name = 'world cities';
    gpx.metadata?.desc = 'location of some of world cities';
    gpx.metadata?.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
    gpx.wpts = track.wpts;

    // get GPX string
    // final gpxString = GpxWriter().asString(gpx, pretty: true);
    final gpxString = gpx.toGpxString(pretty: true);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      bytes: utf8.encode(gpxString),
      // bytes: convertStringToUint8List(gpxString),
      fileName: 'track_name.gpx',
      allowedExtensions: ['gpx'],
    );
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    controller!.addListener(_onMapChanged);
  }

  void _onMapChanged() {
    final position = mapController!.cameraPosition;
    bearing = position!.bearing;

    _isMoving = mapController!.isCameraMoving;
    if (_isMoving) {
      if (!justMoved) {
        justMoved = true;
        stopwatch.start();
      }
    } else {
      justMoved = false;
      justStop = true;
      panTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();
      stopwatch.reset();

      if (trackCameroMove && panTime > 200) {
        mapCentered = false;
      }
    }
    setState(() {});
  }

  Wpt createWptFromLocation(LocationData location) {
    Wpt wpt = Wpt();

    wpt.lat = location.latitude;
    wpt.lon = location.longitude;
    wpt.ele = location.altitude;
    wpt.time = DateTime.now();

    if (_accuracy || _speed || _heading || _numSatelites || _provider) {
      wpt.extensions = {};
    }

    debugPrint('${wpt.extensions}');
    if (_accuracy) {
      wpt.extensions['accuracy'] = location.accuracy.toString();
    }
    debugPrint('${wpt.extensions}');
    if (_numSatelites) {
      wpt.extensions['satelites'] = location.satelliteNumber.toString();
    }
    debugPrint('${wpt.extensions}');
    if (_speed) {
      wpt.extensions['speed'] = location.speed.toString();
    }
    debugPrint('${wpt.extensions}');
    if (_heading) {
      wpt.extensions['heading'] = location.heading.toString();
    }
    debugPrint('${wpt.extensions}');
    if (_provider) {
      wpt.extensions['provider'] = location.provider.toString();
    }
    debugPrint('${wpt.extensions}');
    return wpt;
  }

  bool userIsNotMoving(LocationData loc) {
    return (loc.speed?.round() == 0);
  }

  void handleNewPosition(LocationData loc) {
    debugPrint('INSIDE HANDLE NEW POSITION FUNCTION');
    currentLoc = loc;
    if (userIsNotMoving(loc)) {
      // USER IS NOT MOVING
      debugPrint('NOOOOOT MOVING');
      if (isMoving) {
        isMoving = false;
        notMovingStartedAt = DateTime.now();
      } else {
        debugPrint('user remains stopped');
        Duration timestopped = DateTime.now().difference(notMovingStartedAt);
        debugPrint('STOPPED AT $notMovingStartedAt');
        debugPrint('TIME STOPPED ${timestopped.toString}');
        track.setNotMovingTime(timestopped);
      }
    } else {
      // USER IS MOVING
      if (!isMoving) {
        //user changes state
        timeNotMoving = DateTime.now().difference(notMovingStartedAt);
        track.setNotMovingTime(timeNotMoving);
      } else {
        //user remains moving
      }
      isMoving = true;
    }

    if (recording) {
      debugPrint('${loc.accuracy}');
      Wpt wpt = createWptFromLocation(loc);
      track.push(wpt);
      if (loc.accuracy != null) {
        track.setAccuracy(loc.accuracy!);
      }

      track.setCurrentSpeed(double.parse(loc.speed!.toStringAsFixed(2)));
      track.setCurrentElevation(loc.altitude?.floor());
      debugPrint('................................${track.wpts.length}');
    }
    centerMap(LatLng(loc.latitude!, loc.longitude!));
  }

  void centerMap(LatLng location) {
    mapController!.animateCamera(
      CameraUpdate.newLatLng(location),
      duration: const Duration(milliseconds: 100),
    );
  }

  void firstCamaraView(LatLng location, double zoomLevel) {
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoomLevel),
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          myLocationEnabled: _myLocationEnabled,
          myLocationTrackingMode: _myLocationTrackingMode,
          myLocationRenderMode: _myLocationRenderMode,
          onMapCreated: _onMapCreated,
          onMapLongClick: widget.onlongpress(),
          styleString:
              'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          trackCameraPosition: true,
        ),
        Positioned(
          top: 15,
          left: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              track.startAt != null
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: Colors.amber[900],
                        padding: const EdgeInsets.only(
                            bottom: 6, top: 6, left: 15, right: 15), // and this
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TrackStats(track: track!)));
                      },
                      child: Text(AppLocalizations.of(context)!.trackData,
                          style: TextStyle(color: Colors.white, fontSize: 18)))
                  : Container(),
              SizedBox(
                width: 10,
              ),
              if (!mapCentered && currentLoc != null)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: Colors.amber[900],
                      padding: const EdgeInsets.only(
                          bottom: 6, top: 6, left: 15, right: 15), // and this
                    ),
                    onPressed: () {
                      mapCentered = true;
                      if (currentLoc != null) {
                        centerMap(LatLng(
                            currentLoc!.latitude!, currentLoc!.longitude!));
                      }
                      setState(() {});
                    },
                    child: Text(AppLocalizations.of(context)!.centerMap,
                        style: TextStyle(color: Colors.white, fontSize: 18))),
            ],
          ),
        )
      ],
    );
  }
}

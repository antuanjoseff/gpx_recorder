import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/vars.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import '../classes/track.dart';
import '../controllers/main.dart';
import '../classes/user_preferences.dart';
import '../screens/track_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geoxml/geoxml.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert' show utf8;
import 'dart:async';

class MapWidget extends StatefulWidget {
  final MainController mainController;
  final Function onlongpress;

  const MapWidget({
    super.key,
    required this.mainController,
    required this.onlongpress,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState(mainController);
}

class _MapWidgetState extends State<MapWidget> {
  late Duration timestopped;
  late bool _numSatelites;
  late bool _accuracy;
  late bool _speed;
  late bool _heading;
  late bool _provider;
  late bool _trackVisible;
  late Color _trackColor;
  Gps gps = Gps();
  Track? track;
  bool _myLocationEnabled = false;
  bool hasLocationPermission = false;
  bool recording = false;
  bool pause = false;
  bool stop = false;
  bool isMoving = false;
  late DateTime notMovingStartedAt;
  Duration timeNotMoving = Duration(seconds: 0);
  StreamSubscription? locationSubscription;

  MapLibreMapController? mapController;
  Location location = Location();

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
  bool userMovedMap = false;
  LocationData? currentLoc = null;

  int milliseconds = 300;
  bool showPauseButton = false;

  ButtonStyle customStyleButton = ElevatedButton.styleFrom(
      minimumSize: Size.zero, // Set this
      padding: EdgeInsets.all(15), // and this
      backgroundColor: lightColor);

  bool showResumeOrStopButtons = false;
  bool isPaused = false;
  bool isStopped = false;
  bool isResumed = false;

  _MapWidgetState(MainController mainController) {
    mainController.setTrackPreferences = setTrackPreferences;
    mainController.startRecording = startRecording;
    mainController.resumeRecording = resumeRecording;
    mainController.pauseRecording = pauseRecording;
    mainController.finishRecording = finishRecording;
    mainController.mapIsCreated = mapIsCreated;
  }

  void setTrackPreferences(bool numSatelites, bool accuracy, bool speed,
      bool heading, bool provider, bool visible, Color color) {
    debugPrint(' nova speed $speed');
    _numSatelites = numSatelites;
    _accuracy = accuracy;
    _speed = speed;
    _heading = heading;
    _provider = provider;
    track!.visible = visible;
    track!.trackColor = color;
    if (!track!.visible) {
      track!.removeLine();
    } else {
      track!.removeLine();
      track!.addLine();
    }
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription!.cancel();
    }

    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    locationSubscription = null;
    getUserPreferences();
    checkUserLocation();
    super.initState();
  }

  void checkUserLocation() {
    gps.checkService().then((serviceEnabled) {
      if (serviceEnabled) {
        gps.checkPermission().then((hasPermission) {
          if (hasPermission) {
            _myLocationEnabled = true;
            callSetState();
          }
        });
      }
    });
  }

  Future<bool> checkGpsService() async {
    bool hasPermission = false;
    bool enabled = await gps.checkService();
    if (enabled) {
      hasPermission = await gps.checkPermission();
      if (hasPermission) {
        _myLocationEnabled = true;
        callSetState();
      }
    }
    return hasPermission;
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
    _trackVisible = UserPreferences.getTrackVisible();
    _trackColor = UserPreferences.getTrackColor()!;
  }

  void startRecording() async {
    recording = true;
    pause = false;
    timestopped = Duration(seconds: 0);
    track!.init();
    LocationData? loc = await gps.getLocation();
    if (loc != null) {
      firstCamaraView(LatLng(loc.latitude!, loc.longitude!), 14);
    }
    notMovingStartedAt = DateTime.now();
    gps.enableBackground('Geolocation', 'Geolocation detection');
    locationSubscription = gps.changeSettings(LocationAccuracy.high, 1000, 10);
    locationSubscription = await gps.listenOnBackground(handleNewPosition);
    setState(() {});
  }

  void resumeRecording() {
    recording = true;
    pause = false;
    print('resume recording!!!!');
  }

  void pauseRecording() {
    // recording = false;
    pause = true;
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
    gpx.wpts = track!.wpts;

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

  bool mapIsCreated() {
    return mapController != null;
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    controller!.addListener(_onMapChanged);
    track = Track([], mapController!);
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
        userMovedMap = true;
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
    return (loc.speed! < 0.7);
  }

  void handleNewPosition(LocationData loc) {
    debugPrint('INSIDE HANDLE NEW POSITION FUNCTION');
    currentLoc = loc;
    if (userIsNotMoving(loc)) {
      if (isMoving) {
        // USER JUST STOPPED
        isMoving = false;
        notMovingStartedAt = DateTime.now();
      } else {
        // USER REMAINS STOPPED
        timestopped = DateTime.now().difference(notMovingStartedAt);
        notMovingStartedAt = DateTime.now();
        track!.addNotMovingTime(timestopped);
      }
    } else {
      // USER IS MOVING
      if (!isMoving) {
        //user changes state
        timeNotMoving = DateTime.now().difference(notMovingStartedAt);
        track!.addNotMovingTime(timeNotMoving);
      } else {
        //user remains moving
      }
      isMoving = true;
    }

    if (recording) {
      debugPrint('${loc.accuracy}');
      Wpt wpt = createWptFromLocation(loc);
      track!.push(wpt, loc);
      if (loc.accuracy != null) {
        track!.setAccuracy(loc.accuracy!);
        track!.setHeading(loc.heading!);
        debugPrint(' H  E   A   D   I   N    G           ${loc.heading}');
      }

      track!.setCurrentSpeed(double.parse(loc.speed!.toStringAsFixed(2)));
      track!.setCurrentElevation(loc.altitude?.floor());
    }
    if (!userMovedMap) {
      centerMap(LatLng(loc.latitude!, loc.longitude!));
    }
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
              (recording)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: buttonBackgroundColor,
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
              const SizedBox(
                width: 10,
              ),
              if (userMovedMap && currentLoc != null)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: buttonBackgroundColor,
                      padding: const EdgeInsets.only(
                          bottom: 6, top: 6, left: 15, right: 15), // and this
                    ),
                    onPressed: () {
                      userMovedMap = false;
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
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: milliseconds),
          onEnd: () {
            setState(() {
              showPauseButton = true;
            });
          },
          left: (!recording && !showPauseButton) ? 10 : -75,
          bottom: 30,
          child: SizedBox(
            width: 75,
            child: Row(
              children: [
                ElevatedButton(
                  style: customStyleButton,
                  onPressed: () async {
                    if (!hasLocationPermission) {
                      print(
                          '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                      hasLocationPermission = await checkGpsService();
                    }

                    if (!mapIsCreated() || !hasLocationPermission) {
                      return;
                    }
                    print(
                        '_______________________________________________________________________');
                    startRecording();
                    setState(() {
                      recording = true;
                    });
                  },
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: milliseconds),
          left: (showPauseButton) ? 10 : -80,
          onEnd: () {
            setState(() {
              if (!showPauseButton) {
                showResumeOrStopButtons = true;
              }
            });
          },
          bottom: 30,
          child: Container(
            color: Colors.transparent,
            child: SizedBox(
              width: 80,
              child: Row(
                children: [
                  ElevatedButton(
                    style: customStyleButton,
                    onPressed: () {
                      pauseRecording!();
                      setState(() {
                        showPauseButton = false;
                        isPaused = true;
                      });
                    },
                    child: const Icon(
                      Icons.pause,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: milliseconds),
          left: showResumeOrStopButtons ? 10 : -160,
          onEnd: () {
            setState(() {
              if (isResumed && !isPaused) {
                showPauseButton = true;
              }
            });
          },
          bottom: 30,
          child: Container(
            color: Colors.transparent,
            child: SizedBox(
              width: 160,
              child: Row(
                children: [
                  ElevatedButton(
                    style: customStyleButton,
                    onPressed: () {
                      resumeRecording!();
                      setState(() {
                        showResumeOrStopButtons = false;
                        isResumed = true;
                        isPaused = false;
                      });
                    },
                    child: const Icon(
                      Icons.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      finishRecording!();
                      setState(() {
                        isStopped = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size.zero, // Set this
                      padding: EdgeInsets.all(15), // and this
                    ),
                    child: const Icon(Icons.stop, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

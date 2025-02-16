import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/vars.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import '../classes/track.dart';
import '../controllers/map.dart';
import '../classes/user_preferences.dart';
import '../screens/track_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geoxml/geoxml.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert' show utf8;
import 'dart:async';
import '../widgets/mapScale.dart';
import '../utils/util.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MapWidget extends StatefulWidget {
  final MapController mainController;

  const MapWidget({
    super.key,
    required this.mainController,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState(mainController);
}

class _MapWidgetState extends State<MapWidget> {
  Symbol? userLocation;
  late Duration movingDuration;
  late bool _numSatelites;
  late bool _accuracy;
  late bool _speed;
  late bool _heading;
  late bool _provider;
  late bool _trackVisible;
  bool ortoVisible = true;
  late Color _trackColor;
  late TextEditingController controller;
  late String gpsMethod;
  double? distancePreferences;
  int? timePreferences;

  double mapScaleWidth = 60;
  double? resolution;
  String? mapScaleText;
  Gps gps = Gps();
  List<Wpt> wpts = [];
  Track? track;
  bool _myLocationEnabled = false;
  bool hasLocationPermission = false;

  bool recording = false;
  bool isPaused = false;
  bool isStopped = false;
  bool recordingStarted = false;

  bool lastLocationMoving = false;
  late DateTime lastMovingTimeAt;
  Duration timeNotMoving = Duration(seconds: 0);
  StreamSubscription? locationSubscription;

  MapLibreMapController? mapController;
  Location location = Location();

  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.tracking;
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
  LocationData? lastLocation = null;

  int milliseconds = 300;
  bool showPauseButton = false;

  ButtonStyle styleRecordingButtons = ElevatedButton.styleFrom(
      minimumSize: Size.zero, // Set this
      padding: EdgeInsets.all(15), // and this
      backgroundColor: lightColor);

  ButtonStyle styleElevatedButtons = ElevatedButton.styleFrom(
    minimumSize: Size.zero, // Set this
    padding:
        EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5), // and this
    backgroundColor: buttonBackgroundColor,
    foregroundColor: buttonForegroundColor,
  );

  bool showResumeOrStopButtons = false;

  _MapWidgetState(MapController mainController) {
    mainController.setTrackPreferences = setTrackPreferences;
    mainController.startRecording = startRecording;
    mainController.resumeRecording = resumeRecording;
    mainController.pauseRecording = pauseRecording;
    mainController.finishRecording = finishRecording;
    mainController.mapIsCreated = mapIsCreated;
    mainController.centerMap = centerMap;
    mainController.getLastLocation = getLastLocation;
    mainController.setGpsSettings = setGpsSettings;
    mainController.setBaseLayer = setBaseLayer;
    mainController.getCenter = getCenter;
    mainController.getZoom = getZoom;
  }

  LatLng getCenter() {
    return mapController!.cameraPosition!.target;
  }

  double getZoom() {
    return mapController!.cameraPosition!.zoom;
  }

  void setBaseLayer(layer) {
    if (layer == 'orto') {
      ortoVisible = true;
    } else {
      ortoVisible = false;
    }
    mapController!.setLayerProperties(
        "osm",
        LineLayerProperties.fromJson(
            {"visibility": !ortoVisible ? "visible" : "none"}));
    mapController!.setLayerProperties(
        "ortoEsri",
        LineLayerProperties.fromJson(
            {"visibility": ortoVisible ? "visible" : "none"}));
    mapController!.setLayerProperties(
        "ortoICGC",
        LineLayerProperties.fromJson(
            {"visibility": ortoVisible ? "visible" : "none"}));
  }

  void setGpsSettings(method, distance, time) async {
    if (method == 'distance') {
      time = 0;
    } else {
      distance = 0;
    }
    distancePreferences = distance.toDouble();
    timePreferences = time;

    if (recordingStarted) {
      if (locationSubscription != null) {
        locationSubscription!.cancel();
        gps.changeSettings(LocationAccuracy.high, distance.toDouble(), time);
        locationSubscription = await gps.listenOnBackground(handleNewPosition);
      }
    }
  }

  LatLng? getLastLocation() {
    if (lastLocation != null) {
      return LatLng(lastLocation!.latitude!, lastLocation!.longitude!);
    }
    return null;
  }

  void setTrackPreferences(bool numSatelites, bool accuracy, bool speed,
      bool heading, bool provider, bool visible, Color color, int width) {
    _numSatelites = numSatelites;
    _accuracy = accuracy;
    _speed = speed;
    _heading = heading;
    _provider = provider;
    track!.visible = visible;
    track!.trackColor = color;
    track!.trackWidth = width;
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
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    getUserPreferences();
    controller = TextEditingController();
    gpsMethod = UserPreferences.getGpsMethod();
    distancePreferences =
        gpsMethod == 'distance' ? UserPreferences.getDistancePreferences() : 0;
    timePreferences = UserPreferences.getTimePreferences();
    super.initState();
  }

  Future<Symbol?> createUserLocation() async {
    bool serviceEnabled = await gps.checkService();

    if (serviceEnabled) {
      bool hasPermission = await gps.checkPermission();
      if (hasPermission) {
        LocationData? loc = await gps.getLocation();
        Symbol userloc = await mapController!.addSymbol(SymbolOptions(
            draggable: false,
            iconImage: 'userLocation',
            geometry: LatLng(loc!.latitude!, loc.longitude!)));
        return userloc;
      } else {
        return null;
      }
    } else {
      return null;
    }
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
    movingDuration = Duration(seconds: 0);
    track!.init();

    LocationData? loc = await gps.getLocation();
    _myLocationRenderMode = MyLocationRenderMode.compass;

    if (loc != null) {
      handleNewPosition(loc);
      firstCamaraView(LatLng(loc.latitude!, loc.longitude!), 14);
      _myLocationRenderMode = MyLocationRenderMode.compass;
    }
    lastMovingTimeAt = DateTime.now();

    if (!kIsWeb) {
      await locationSubscription?.cancel();
      gps.enableBackground(AppLocalizations.of(context)!.notificationTitle,
          AppLocalizations.of(context)!.notificationContent);
    }
    gpsMethod = UserPreferences.getGpsMethod();
    if (gpsMethod == 'distance') {
      gps.changeSettings(
        LocationAccuracy.high,
        distancePreferences,
        0,
      );
    } else {
      gps.changeSettings(
        LocationAccuracy.high,
        0,
        timePreferences,
      );
    }
    if (!kIsWeb) {
      locationSubscription = await gps.listenOnBackground(handleNewPosition);
    }
    setState(() {});
  }

  void resumeRecording() {
    print('resume recording!!!!');
  }

  void pauseRecording() {
    // recording = false;
    print('stop recording!!!!');
  }

  Future<String?> openDialog(String type) async {
    String name = '';
    if (type == 'track') {
      DateTime now = DateTime.now();
      name = DateFormat('yyyy-MMM-dd-hh:mm').format(now);
    } else {
      name = 'Wpt ${wpts.length + 1}';
    }

    controller.text = name;

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.trackName),
                content: TextField(
                  onTap: () => controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: controller.value.text.length),
                  autofocus: true,
                  // decoration: InputDecoration(hintText: 'Nom del track'),
                  controller: controller,
                  onSubmitted: (_) => submit(),
                ),
                actions: [
                  ElevatedButton(
                      style: styleElevatedButtons,
                      onPressed: submit,
                      child: Text(AppLocalizations.of(context)!.accept)),
                  ElevatedButton(
                      style: styleElevatedButtons,
                      onPressed: cancel,
                      child: Text(AppLocalizations.of(context)!.cancel)),
                ]));
  }

  void submit() {
    Navigator.of(context).pop(controller.text);
    controller.clear();
  }

  void cancel() {
    Navigator.of(context).pop();
  }

  void addWpt() async {
    // LocationData? location = await gps.getLocatioaddSymboln();

    if (lastLocation != null) {
      Wpt newWpt = createWptFromLocation(lastLocation!);
      String? name = await openDialog('wpt');
      if (name == null || name.isEmpty) return;
      newWpt.name = name;
      wpts.add(newWpt);
      Symbol wptSymbol = await mapController!.addSymbol(SymbolOptions(
          draggable: false,
          iconImage: 'waypoint',
          iconOffset: kIsWeb ? Offset(20, -180 / 2) : Offset(5, -25),
          geometry: LatLng(lastLocation!.latitude!, lastLocation!.longitude!)));
    }
  }

  void finishRecording() async {
    String? name = await openDialog('track');

    if (name == null || name.isEmpty) return;
    final gpx = GeoXml();
    gpx.version = '1.1';
    gpx.creator = 'dart-gpx library';
    gpx.metadata = Metadata();
    gpx.metadata?.name = 'world cities';
    gpx.metadata?.desc = 'location of some of world cities';
    gpx.metadata?.time = DateTime.utc(2010, 1, 2, 3, 4, 5);
    gpx.wpts = wpts;
    gpx.trks = [
      Trk(trksegs: [Trkseg(trkpts: track!.wpts)])
    ];

    // gpx.wpts = track!.wpts;

    // get GPX string
    // final gpxString = GpxWriter().asString(gpx, pretty: true);
    final gpxString = gpx.toGpxString(pretty: true);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      bytes: utf8.encode(gpxString),
      // bytes: convertStringToUint8List(gpxString),
      fileName: '$name.gpx',
      allowedExtensions: ['gpx'],
    );
    if (outputFile != null) {
      setState(() {
        recording = false;
        recordingStarted = false;
        isPaused = false;
        isStopped = false;
        showPauseButton = false;
        showResumeOrStopButtons = false;
      });
    }
  }

  bool mapIsCreated() {
    return mapController != null;
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    controller!.addListener(_onMapChanged);
    track = Track([], mapController!);
    resolution = await mapController!.getMetersPerPixelAtLatitude(
        mapController!.cameraPosition!.target.latitude);

    mapScaleText = (mapScaleWidth * resolution!).toStringAsFixed(2);
    setState(() {});
  }

  void _onMapChanged() async {
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

    resolution = await mapController!.getMetersPerPixelAtLatitude(
        mapController!.cameraPosition!.target.latitude);

    mapScaleText = (mapScaleWidth * resolution!).toStringAsFixed(2);
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

    if (_accuracy) {
      wpt.extensions['accuracy'] = location.accuracy.toString();
    }

    if (_numSatelites) {
      wpt.extensions['satelites'] = location.satelliteNumber.toString();
    }

    if (_speed) {
      wpt.extensions['speed'] = location.speed.toString();
    }

    if (_heading) {
      wpt.extensions['heading'] = location.heading.toString();
    }

    if (_provider) {
      wpt.extensions['provider'] = location.provider.toString();
    }

    return wpt;
  }

  bool userIsMoving(LocationData loc) {
    return (loc.speed! > 0.7);
  }

  bool accuracyIsInvalid(double? accuracy) {
    if (accuracy == null) {
      return true;
    }
    if (accuracy > 50) {
      return true;
    }
    return false;
  }

  void handleNewPosition(LocationData loc) async {
    if (accuracyIsInvalid(loc.accuracy)) {
      return;
    }

    lastLocation = loc;
    //update userLocation
    if (userLocation != null) {
      await mapController!.updateSymbol(
          userLocation!,
          SymbolOptions(
              iconRotate: loc.heading,
              geometry: LatLng(loc.latitude!, loc.longitude!)));
    }

    if (userIsMoving(loc)) {
      // USER IS MOVING
      if (!lastLocationMoving) {
        // USER JUST STARTED MOVING
        lastMovingTimeAt = DateTime.now();
      } else {
        // USER KEEPS MOVING
        movingDuration = DateTime.now().difference(lastMovingTimeAt);
        lastMovingTimeAt = DateTime.now();
        track!.addMovingTime(movingDuration);
      }
      lastLocationMoving = true;
    }
    // USER IS STOPPED
    else {
      if (lastLocationMoving) {
        ////USER JUST STOPPED
        lastMovingTimeAt = DateTime.now();
      } else {
        // USER REMAINs STOPPED
      }
      lastLocationMoving = false;
    }

    if (recording) {
      addNewLocationToTrack(loc);
    }

    if (!userMovedMap) {
      centerMap(LatLng(loc.latitude!, loc.longitude!));
    }
  }

  void addNewLocationToTrack(loc) {
    Wpt wpt = createWptFromLocation(loc);
    track!.push(wpt, loc);

    track!.setAccuracy(loc.accuracy);
    track!.setHeading(loc.heading!);
    track!.setCurrentSpeed(loc.speed);
    track!.setCurrentElevation(loc.altitude?.floor());
  }

  void centerMap(LatLng? location) {
    if (lastLocation == null) return;
    location ??= LatLng(lastLocation!.latitude!, lastLocation!.longitude!);

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
          minMaxZoomPreference: MinMaxZoomPreference(0, 18),
          // myLocationEnabled: _myLocationEnabled,
          // myLocationTrackingMode: _myLocationTrackingMode,
          // myLocationRenderMode: _myLocationRenderMode,
          onMapCreated: _onMapCreated,
          styleString: 'assets/styles/mainmap_style.json',
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          trackCameraPosition: true,
          onStyleLoadedCallback: () async {
            // addImageFromAsset(
            //     mapController!, "waypoint", "assets/symbols/waypoint.png");
            addImageFromAsset(
                mapController!, "waypoint", "assets/symbols/flag100.png");
            addImageFromAsset(mapController!, "userLocation",
                "assets/symbols/userlocation.png");
            userLocation = await createUserLocation();
          },
        ),
        // Positioned(
        //   left: 10,
        //   top: 10,
        //   child: CircleAvatar(
        //     radius: 27,
        //     backgroundColor: primaryColor,
        //     child: CircleAvatar(
        //       radius: 25,
        //       backgroundColor: Scaffold.of(context).isEndDrawerOpen
        //           ? primaryColor
        //           : Colors.white,
        //       child: IconButton(
        //         tooltip: AppLocalizations.of(context)!.baseLayer,
        //         icon: Icon(Icons.layers_rounded),
        //         color: Scaffold.of(context).isEndDrawerOpen
        //             ? Colors.white
        //             : primaryColor,
        //         onPressed: () {
        //           setState(() {
        //             Scaffold.of(context).openEndDrawer();
        //           });
        //         },
        //       ),
        //     ),
        //   ),
        // ),
        Positioned(
          top: 15,
          left: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (recording)
                  ? ElevatedButton(
                      style: styleElevatedButtons,
                      onPressed: () async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TrackStats(track: track!)));
                        centerMap(getLastLocation());
                      },
                      child: Text(AppLocalizations.of(context)!.trackData,
                          style: TextStyle(color: Colors.white, fontSize: 18)))
                  : Container(),
              const SizedBox(
                width: 10,
              ),
              if (userMovedMap && lastLocation != null)
                ElevatedButton(
                    style: styleElevatedButtons,
                    onPressed: () {
                      userMovedMap = false;
                      if (lastLocation != null) {
                        centerMap(LatLng(
                            lastLocation!.latitude!, lastLocation!.longitude!));
                      }
                      setState(() {});
                    },
                    child: Text(AppLocalizations.of(context)!.centerMap,
                        style: TextStyle(color: Colors.white, fontSize: 18))),
            ],
          ),
        ),
        resolution != null
            ? Positioned(
                bottom: 30,
                right: 10,
                child: MapScale(
                  mapscale: mapScaleText!,
                  resolution: resolution!,
                ))
            : Container(),
        AnimatedPositioned(
          left: (!recording && !recordingStarted) ? 10 : -75,
          bottom: 30,
          duration: Duration(milliseconds: milliseconds),
          onEnd: () {
            setState(() {
              recording = true;
            });
          },
          child: SizedBox(
            width: 75,
            child: Row(
              children: [
                ElevatedButton(
                  style: styleRecordingButtons,
                  onPressed: () async {
                    if (!hasLocationPermission) {
                      hasLocationPermission = await checkGpsService();
                    }

                    if (!mapIsCreated() || !hasLocationPermission) {
                      return;
                    }
                    startRecording();
                    setState(() {
                      recordingStarted = true;
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
          left: (recording) ? 10 : -80,
          duration: Duration(milliseconds: milliseconds),
          onEnd: () {
            setState(() {
              if (!recording) {
                isPaused = true;
              }
            });
          },
          bottom: 30,
          child: Container(
            color: Colors.transparent,
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  ElevatedButton(
                    style: styleRecordingButtons,
                    onPressed: () {
                      addWpt();
                    },
                    child: const Icon(
                      Icons.flag,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: styleRecordingButtons,
                    onPressed: () {
                      pauseRecording();
                      setState(() {
                        recording = false;
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
          left: isPaused ? 10 : -160,
          duration: Duration(milliseconds: milliseconds),
          onEnd: () {
            setState(() {
              if (!isPaused) {
                recording = true;
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
                    style: styleRecordingButtons,
                    onPressed: () {
                      resumeRecording();
                      setState(() {
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
                      finishRecording();
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

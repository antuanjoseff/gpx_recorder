import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import '../classes/track.dart';
import '../classes/trackSettings.dart';
import '../screens/track_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geoxml/geoxml.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert' show utf8;

class MapWidget extends StatefulWidget {
  final TrackSettings trackSettings;
  final Function onlongpress;

  const MapWidget({
    super.key,
    required this.trackSettings,
    required this.onlongpress,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState(trackSettings);
}

class _MapWidgetState extends State<MapWidget> {
  late bool _numSatelites;
  late bool _accuracy;
  late bool _speed;
  late bool _heading;
  late bool _provider;
  late Gps gps;
  late Track track;
  bool recording = false;
  bool stop = false;
  bool isMoving = false;
  late DateTime notMovingStartedAt;
  Duration timeNotMoving = Duration(seconds: 0);

  late MapLibreMapController mapController;
  Location location = new Location();
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.compass;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.trackingGps;

  _MapWidgetState(TrackSettings trackSettings) {
    trackSettings.setTrackPreferences = setTrackPreferences;
    trackSettings.startRecording = startRecording;
    trackSettings.resumeRecording = resumeRecording;
    trackSettings.stopRecording = stopRecording;
    trackSettings.finishRecording = finishRecording;
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
  void dispose() {
    // TODO: implement dispose
    gps?.cancelSubscription();
    super.dispose();
  }

  @override
  void initState() {
    gps = new Gps();
    track = Track([]);
    location.enableBackgroundMode(enable: true);
    location.changeNotificationOptions(
      title: "GPX Recorder",
      subtitle: 'Recording ....',
      // title: AppLocalizations.of(context)!.notificationTitle,
      // subtitle: AppLocalizations.of(context)!.notificationContent,
    );
    super.initState();
  }

  void startRecording() async {
    print('start recording!!!!');
    bool enabled = await gps.checkService();
    if (enabled) {
      bool hasPermission = await gps.checkPermission();
      if (hasPermission) {
        recording = true;
        track.init();
        notMovingStartedAt = DateTime.now();
        // gps.changeIntervalByTime(50);
        gps.listenOnBackground(handleNewPosition);
      }
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

    await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      bytes: utf8.encode(gpxString),
      // bytes: convertStringToUint8List(gpxString),
      fileName: 'track_name.gpx',
      allowedExtensions: ['gpx'],
    );
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
  }

  Wpt createWptFromLocation(LocationData location) {
    Wpt wpt = new Wpt();

    wpt.lat = location.latitude;
    wpt.lon = location.longitude;
    wpt.ele = location.altitude;
    wpt.time = DateTime.now();

    // wpt.extensions = {'accuracy': location.accuracy.toString()};
    // wpt.extensions = {'speed': location.speed.toString()};

    debugPrint(
        '_accuracy   $_speed   $_heading    $_numSatelites   $_provider');
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

  bool userIsNotMoving(LocationData loc) {
    return (loc.speed?.round() == 0);
  }

  void handleNewPosition(LocationData loc) {
    print(loc.accuracy);
    if (userIsNotMoving(loc)) {
      // USER IS NOT MOVING
      if (isMoving) {
        isMoving = false;
        notMovingStartedAt = DateTime.now();
      } else {
        // user remains stopped
        track.setNotMovingTime(timeNotMoving);
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
    debugPrint('Recording           $recording');
    if (recording) {
      Wpt wpt = createWptFromLocation(loc);
      print('WPT $wpt');
      track.push(wpt);
      track.setCurrentSpeed(double.parse(loc.speed!.toStringAsFixed(2)));
      track.setCurrentElevation(loc.altitude?.floor());
      debugPrint('................................${track.wpts.length}');
    }
    centerMap(LatLng(loc.latitude!, loc.longitude!));
  }

  void centerMap(LatLng location) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(location),
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          myLocationEnabled: true,
          myLocationTrackingMode: _myLocationTrackingMode,
          myLocationRenderMode: _myLocationRenderMode,
          onMapCreated: _onMapCreated,
          onMapLongClick: (point, coordinates) {
            widget.onlongpress();
          },
          styleString:
              'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          trackCameraPosition: true,
        ),
        Positioned(
            left: 10,
            top: 20,
            child: ElevatedButton(
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
                          builder: (context) => TrackStats(track: track)));
                },
                child: Text(AppLocalizations.of(context)!.trackData,
                    style: TextStyle(color: Colors.white, fontSize: 18))))
      ],
    );
  }
}

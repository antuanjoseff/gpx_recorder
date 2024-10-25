import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import '../classes/track.dart';
import '../classes/trackSettings.dart';
import '../screens/track_stats.dart';
import '../utils/util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geoxml/geoxml.dart';

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
  late Gps gps;
  late Track track;
  bool recording = false;
  bool stop = false;
  late MapLibreMapController mapController;
  Location location = new Location();
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.compass;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.trackingGps;

  _MapWidgetState(TrackSettings trackSettings) {
    trackSettings.setTrackPreferences = setTrackPreferences;
    trackSettings.startRecording = startRecording;
    trackSettings.stopRecording = stopRecording;
    trackSettings.finishRecording = finishRecording;
  }

  void setTrackPreferences(
      bool numSatelites, bool accuracy, bool speed, bool heading) {
    _numSatelites = numSatelites;
    _accuracy = accuracy;
    _speed = speed;
    _heading = heading;
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

  void startRecording() {
    recording = true;
    print('start recording!!!!');
  }

  void stopRecording() {
    recording = false;
    print('stop recording!!!!');
  }

  void finishRecording() {
    recording = false;
    stop = true;
    print('finish recording!!!!');
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;

    bool enabled = await gps.checkService();
    if (enabled) {
      bool hasPermission = await gps.checkPermission();
      if (hasPermission!) {
        gps.changeInterval(1000);
        gps.listenOnBackground(manageNewPosition);
      }
    }
  }

  Wpt createWptFromLocation(LocationData location) {
    Wpt wpt = new Wpt();
    wpt.lat = location.latitude;
    wpt.lon = location.longitude;
    wpt.ele = location.altitude;
    wpt.time = DateTime.now();
    // if (_numSatelites) {
    //   wpt.sat = location.satelliteNumber;
    // }
    // if (_accuracy || _speed || _heading) {
    //   wpt.extensions = {
    //     'accuracy': _accuracy ? location.accuracy.toString() : '',
    //     'speed': _speed ? location.speed.toString() : '',
    //     'heading': _heading ? location.heading.toString() : ''
    //   };
    // }
    return wpt;
  }

  void manageNewPosition(LocationData loc) {
    print('manageNewPosition $loc');
    if (recording) {
      Wpt wpt = createWptFromLocation(loc);
      track.push(wpt);
      debugPrint(
          '....................................................${track.trackSegment.length}');
    }
    centerMap(LatLng(loc.latitude!, loc.longitude!));
  }

  void centerMap(LatLng location) {
    mapController!.animateCamera(
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
                          builder: (context) => TrackStats(track: track!)));
                },
                child: Text(AppLocalizations.of(context)!.trackData,
                    style: TextStyle(color: Colors.white, fontSize: 18))))
      ],
    );
  }
}

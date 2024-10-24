import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:location/location.dart';
import '../classes/gps.dart';
import '../classes/track.dart';
import '../utils/util.dart';

class MapWidget extends StatefulWidget {
  MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late Gps gps;
  late Track track;
  late MapLibreMapController mapController;
  Location location = new Location();
  MyLocationRenderMode _myLocationRenderMode = MyLocationRenderMode.compass;
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.trackingGps;

  @override
  void initState() {
    super.initState();
    gps = new Gps();
    location.enableBackgroundMode(enable: true);
    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    // bool gpsEnabled = UserSimplePreferences.getGpsEnabled() ?? false;
    // bool gpsPermission = UserSimplePreferences.getHasPermission() ?? false;

    // if (gpsPermission) {
    //   location.onLocationChanged.listen((LocationData currentLocation) {
    //     manageNewPosition(currentLocation);
    //   });
    // }

    bool enabled = await gps.checkService();
    if (enabled) {
      bool hasPermission = await gps.checkPermission();

      if (hasPermission!) {
        gps.listenOnBackground(manageNewPosition);
      }
    }
  }

  void manageNewPosition(LocationData loc) {
    track.push(createWptFromLocation(loc));
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
    return MapLibreMap(
      myLocationEnabled: true,
      myLocationTrackingMode: _myLocationTrackingMode,
      myLocationRenderMode: _myLocationRenderMode,
      onMapCreated: _onMapCreated,
      styleString:
          'https://geoserveis.icgc.cat/contextmaps/icgc_orto_hibrida.json',
      initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
      trackCameraPosition: true,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/user_preferences.dart';
import '../classes/vars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'gpxSettings.dart';
import 'trackSettings.dart';
import 'gpsSettings.dart';
import '../controllers/gpx.dart';
import '../controllers/track.dart';
import '../controllers/gps.dart';
import '../controllers/map.dart';

class TabSettings extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;
  final bool visible;
  final Color color;
  final String gpsMethod;
  final double gpsUnitsDistance;
  final int gpsUnitsTime;
  final MapController mapController;

  TabSettings(
      {super.key,
      required this.speed,
      required this.heading,
      required this.numSatelites,
      required this.accuracy,
      required this.provider,
      required this.visible,
      required this.color,
      required this.gpsMethod,
      required this.gpsUnitsDistance,
      required this.gpsUnitsTime,
      required this.mapController});

  @override
  State<TabSettings> createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  GpxController gpxController = GpxController();
  TrackController trackController = TrackController();
  GpsController gpsController = GpsController();
  MapController mapController = MapController();
  late int defaultTab;

  @override
  void initState() {
    // TODO: implement initState
    defaultTab = 0;
    gpxController.speed = widget.speed;
    gpxController.heading = widget.heading;
    gpxController.numSatelites = widget.numSatelites;
    gpxController.accuracy = widget.accuracy;
    gpxController.provider = widget.provider;
    trackController.visible = widget.visible;
    trackController.color = widget.color;
    gpsController.method = widget.gpsMethod;
    gpsController.unitsDistance = widget.gpsUnitsDistance;
    gpsController.unitsTime = widget.gpsUnitsTime;
    mapController = widget.mapController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    defaultTab = UserPreferences.getDefaultTab();
    return DefaultTabController(
      length: 3,
      initialIndex: defaultTab,
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.settings),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            leading: BackButton(
              onPressed: () {
                debugPrint('${gpxController.speed}  ${gpxController.heading}');
                Navigator.of(context).pop((
                  gpxController.speed,
                  gpxController.heading,
                  gpxController.numSatelites,
                  gpxController.accuracy,
                  gpxController.provider,
                  trackController.visible,
                  trackController.color,
                  gpsController.method,
                  gpsController.unitsDistance,
                  gpsController.unitsTime,
                ));
              },
            ),
            bottom: TabBar(
              indicatorColor: fourthColor,
              indicatorWeight: 5,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('GPX', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('Track', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.satellite_alt_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('GPS', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            color: thirthColor,
            child: TabBarView(
              children: [
                GpxSettings(
                    mapController: mapController, controller: gpxController),
                TrackSettings(
                    mapController: mapController, controller: trackController),
                GpsSettings(
                    mapController: mapController, controller: gpsController),
              ],
            ),
          )),
    );
  }
}

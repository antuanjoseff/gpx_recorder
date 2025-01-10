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
  final GpxController gpxController;
  final TrackController trackController;
  final GpsController gpsController;
  final MapController mapController;

  TabSettings(
      {super.key,
      required this.gpxController,
      required this.trackController,
      required this.gpsController,
      required this.mapController});

  @override
  State<TabSettings> createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  late int defaultTab;

  @override
  void initState() {
    // TODO: implement initState
    defaultTab = 0;
    debugPrint('TAB OPEN ACCURACY ${widget.gpxController.accuracy}');
    debugPrint('TAB OPEN SPEED ${widget.gpxController.speed}');
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
                Navigator.of(context).pop((
                  widget.gpxController,
                  widget.trackController,
                  widget.gpsController,
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
                    mapController: widget.mapController,
                    controller: widget.gpxController),
                TrackSettings(
                    mapController: widget.mapController,
                    controller: widget.trackController),
                GpsSettings(
                    mapController: widget.mapController,
                    controller: widget.gpsController),
              ],
            ),
          )),
    );
  }
}

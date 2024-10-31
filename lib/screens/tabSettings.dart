import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/user_preferences.dart';
import '../classes/vars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'gpxSettings.dart';
import 'trackSettings.dart';
import '../controllers/gpx.dart';
import '../controllers/track.dart';

class TabSettings extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;
  final bool visible;
  final Color color;

  TabSettings({
    super.key,
    required this.speed,
    required this.heading,
    required this.numSatelites,
    required this.accuracy,
    required this.provider,
    required this.visible,
    required this.color,
  });

  @override
  State<TabSettings> createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  GpxController gpxController = GpxController();
  TrackController trackController = TrackController();

  @override
  void initState() {
    // TODO: implement initState
    gpxController.speed = widget.speed;
    gpxController.heading = widget.heading;
    gpxController.numSatelites = widget.numSatelites;
    gpxController.accuracy = widget.accuracy;
    gpxController.provider = widget.provider;
    trackController.visible = widget.visible;
    trackController.color = widget.color;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                  trackController.color
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

                // Tab(
                //   icon: Icon(Icons.satellite_alt),
                //   text: 'GPS',
                // ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('TRACK', style: TextStyle(color: Colors.white)),
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
                GpxSettings(controller: gpxController),
                TrackSettings(controller: trackController),
              ],
            ),
          )),
    );
  }
}

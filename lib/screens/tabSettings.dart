import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/user_preferences.dart';
import '../classes/vars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:accordion/accordion.dart';
import 'gpxSettings.dart';
import 'gpsSettings.dart';
import 'trackSettings.dart';
import '../controllers/gpx.dart';
import '../controllers/track.dart';

class TabSettings extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;

  TabSettings(
      {super.key,
      required this.speed,
      required this.heading,
      required this.numSatelites,
      required this.accuracy,
      required this.provider});

  @override
  State<TabSettings> createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  GpxController gpxController = GpxController();
  TrackController trackController = TrackController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.settings),
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            leading: BackButton(
              onPressed: () {
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
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
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
                        Icons.remove_red_eye,
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
            color: Colors.orange[300],
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

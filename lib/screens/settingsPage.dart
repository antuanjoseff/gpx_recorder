import 'package:flutter/material.dart';
import 'package:gpx_recorder/classes/user_preferences.dart';
import 'package:gpx_recorder/controllers/gps.dart';
import '../classes/vars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:accordion/accordion.dart';
import 'gpxSettings.dart';
import 'gpsSettings.dart';
import 'trackSettings.dart';
import '../controllers/gpx.dart';
import '../controllers/track.dart';

class SettingsPage extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;

  SettingsPage(
      {super.key,
      required this.speed,
      required this.heading,
      required this.numSatelites,
      required this.accuracy,
      required this.provider});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyleHeader =
      TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);

  final GpxController gpxController = GpxController();
  final TrackController trackController = TrackController();

  void colorChanged(Color color) {
    debugPrint(color.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            title: Text(AppLocalizations.of(context)!.settings),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop((
                  gpxController.speed,
                  gpxController.heading,
                  gpxController.numSatelites,
                  gpxController.accuracy,
                  gpxController.provider
                ));
              },
            )),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Accordion(
                  headerBorderColor: Colors.blueGrey,
                  headerBorderColorOpened: Colors.transparent,
                  // headerBorderWidth: 1,
                  headerBackgroundColorOpened: Colors.green,
                  contentBackgroundColor: Colors.white,
                  contentBorderColor: Colors.green,
                  contentBorderWidth: 3,
                  contentHorizontalPadding: 20,
                  scaleWhenAnimating: true,
                  openAndCloseAnimation: true,
                  headerPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                  // sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                  // sectionClosingHapticFeedback: SectionHapticFeedback.light,
                  children: [
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      headerBackgroundColor: Colors.orange[600],
                      contentBorderColor: Colors.orange[600],
                      leftIcon: const Icon(Icons.insert_drive_file_outlined,
                          color: Colors.white),
                      header: const Text('GPX properties', style: headerStyle),
                      content: GpxSettings(controller: gpxController),
                    ),
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      headerBackgroundColor: Colors.orange[600],
                      contentBorderColor: Colors.orange[600],
                      leftIcon:
                          const Icon(Icons.satellite_alt, color: Colors.white),
                      header: const Text('GPS properties', style: headerStyle),
                      content: GpsSettings(
                        controller: GpsController(),
                      ),
                    ),
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      headerBackgroundColor: Colors.orange[600],
                      contentBorderColor: Colors.orange[600],
                      leftIcon:
                          const Icon(Icons.remove_red_eye, color: Colors.white),
                      header:
                          const Text('Track properties', style: headerStyle),
                      content: TrackSettings(
                        controller: trackController,
                      ),
                    ),
                  ])
            ],
          ),
        ));
  }
}

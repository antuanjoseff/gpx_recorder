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
import '../controllers/map.dart';

class SettingsPage extends StatefulWidget {
  final GpxController gpxController;
  final TrackController trackController;
  final GpsController gpsController;
  final MapController mapController;

  SettingsPage({
    super.key,
    required this.gpxController,
    required this.trackController,
    required this.gpsController,
    required this.mapController,
  });

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

  void colorChanged(Color color) {
    debugPrint(color.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                  widget.gpxController,
                  widget.trackController,
                  widget.gpsController,
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
                      content: GpxSettings(
                          mapController: widget.mapController,
                          controller: widget.gpxController),
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
                        mapController: widget.mapController,
                        controller: widget.gpsController,
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
                        mapController: widget.mapController,
                        controller: widget.trackController,
                      ),
                    ),
                  ])
            ],
          ),
        ));
  }
}

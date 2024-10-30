import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import '../classes/vars.dart';
import '../classes/user_preferences.dart';
import '../controllers/gpx.dart';

class GpxSettings extends StatefulWidget {
  final GpxController controller;

  GpxSettings({super.key, required this.controller});

  @override
  State<GpxSettings> createState() => _GpxSettingsState();
}

class _GpxSettingsState extends State<GpxSettings> {
  late bool numSatelitesIsSwitched;
  late bool accuracyIsSwitched;
  late bool speedIsSwitched;
  late bool headingIsSwitched;
  late bool providerIsSwitched;
  double switchScale = 1;
  @override
  void initState() {
    numSatelitesIsSwitched = widget.controller.numSatelites ?? false;
    accuracyIsSwitched = widget.controller.accuracy ?? false;
    speedIsSwitched = widget.controller.speed ?? false;
    headingIsSwitched = widget.controller.heading ?? false;
    providerIsSwitched = widget.controller.provider ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black, fontSize: 20),
      child: Padding(
        padding: const EdgeInsets.only(left: 60, top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: switchScale,
                  child: Switch(
                      value: speedIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          speedIsSwitched = value;
                          widget.controller.speed = value;
                          // UserPreferences.setSpeed(value);
                        });
                      }),
                ),
                SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.speed)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: switchScale,
                  child: Switch(
                      value: headingIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          headingIsSwitched = value;
                          widget.controller.heading = value;
                          // UserPreferences.setHeading(value);
                        });
                      }),
                ),
                SizedBox(width: 20),
                Text(AppLocalizations.of(context)!.heading)
              ],
            ),
            (Platform.isAndroid)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: switchScale,
                        child: Switch(
                            value: numSatelitesIsSwitched,
                            activeTrackColor: mainColor,
                            onChanged: (value) {
                              setState(() {
                                numSatelitesIsSwitched = value;
                                widget.controller.numSatelites = value;
                                // UserPreferences.setNumSatelites(value);
                              });
                            }),
                      ),
                      SizedBox(width: 20),
                      Text(AppLocalizations.of(context)!.numSatelites)
                    ],
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: switchScale,
                  child: Switch(
                      value: accuracyIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          accuracyIsSwitched = value;
                          widget.controller.accuracy = value;
                          // UserPreferences.setAccuracy(value);
                        });
                      }),
                ),
                SizedBox(width: 20),
                Text(AppLocalizations.of(context)!.accuracy)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: switchScale,
                  child: Switch(
                      value: providerIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          providerIsSwitched = value;
                          widget.controller.provider = value;
                          // UserPreferences.setProvider(value);
                        });
                      }),
                ),
                SizedBox(width: 20),
                Text(AppLocalizations.of(context)!.provider)
              ],
            )
          ],
        ),
      ),
    );
  }
}

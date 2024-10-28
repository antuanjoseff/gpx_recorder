import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import '../classes/vars.dart';
import '../classes/user_preferences.dart';

class GpxSettings extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;

  GpxSettings(
      {super.key,
      required this.numSatelites,
      required this.accuracy,
      required this.speed,
      required this.heading,
      required this.provider});

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
    numSatelitesIsSwitched = widget.numSatelites;
    accuracyIsSwitched = widget.accuracy;
    speedIsSwitched = widget.speed;
    headingIsSwitched = widget.heading;
    providerIsSwitched = widget.provider;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black, fontSize: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          UserPreferences.setSpeed(value);
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
                          UserPreferences.setHeading(value);
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
                                UserPreferences.setNumSatelites(value);
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
                          UserPreferences.setAccuracy(value);
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
                          UserPreferences.setProvider(value);
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

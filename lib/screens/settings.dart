import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import '../classes/vars.dart';

class Settings extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;

  Settings(
      {super.key,
      required this.numSatelites,
      required this.accuracy,
      required this.speed,
      required this.heading});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool numSatelitesIsSwitched;
  late bool accuracyIsSwitched;
  late bool speedIsSwitched;
  late bool headingIsSwitched;

  @override
  void initState() {
    numSatelitesIsSwitched = widget.numSatelites;
    accuracyIsSwitched = widget.accuracy;
    speedIsSwitched = widget.speed;
    headingIsSwitched = widget.heading;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.settings),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop((
              numSatelitesIsSwitched,
              accuracyIsSwitched,
              speedIsSwitched,
              headingIsSwitched,
            ));
          },
        ),
      ),
      body: DefaultTextStyle(
        style: TextStyle(color: Colors.black, fontSize: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (Platform.isAndroid)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 50, height: 70),
                      Transform.scale(
                        scale: 1.5,
                        child: Switch(
                            value: numSatelitesIsSwitched,
                            activeTrackColor: mainColor,
                            onChanged: (value) {
                              setState(() {
                                numSatelitesIsSwitched = value;
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
                SizedBox(width: 50, height: 70),
                Transform.scale(
                  scale: 1.5,
                  child: Switch(
                      value: accuracyIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          accuracyIsSwitched = value;
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
                SizedBox(width: 50, height: 70),
                Transform.scale(
                  scale: 1.5,
                  child: Switch(
                      value: speedIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          speedIsSwitched = value;
                        });
                      }),
                ),
                SizedBox(width: 20),
                Text(AppLocalizations.of(context)!.speed)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 50, height: 70),
                Transform.scale(
                  scale: 1.5,
                  child: Switch(
                      value: headingIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          headingIsSwitched = value;
                        });
                      }),
                ),
                SizedBox(width: 20),
                Text(AppLocalizations.of(context)!.heading)
              ],
            )
          ],
        ),
      ),
    );
  }
}

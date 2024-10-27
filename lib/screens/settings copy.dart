import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import '../classes/vars.dart';

class Settings extends StatefulWidget {
  final bool numSatelites;
  final bool accuracy;
  final bool speed;
  final bool heading;
  final bool provider;

  Settings(
      {super.key,
      required this.numSatelites,
      required this.accuracy,
      required this.speed,
      required this.heading,
      required this.provider});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool numSatelitesIsSwitched;
  late bool accuracyIsSwitched;
  late bool speedIsSwitched;
  late bool headingIsSwitched;
  late bool providerIsSwitched;
  double switchScale = 1.3;
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
              providerIsSwitched,
            ));
          },
        ),
      ),
      body: DefaultTextStyle(
        style: TextStyle(color: Colors.black, fontSize: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 50, height: 70),
                Transform.scale(
                  scale: switchScale,
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
                  scale: switchScale,
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
            ),
            (Platform.isAndroid)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 50, height: 70),
                      Transform.scale(
                        scale: switchScale,
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
                  scale: switchScale,
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
                  scale: switchScale,
                  child: Switch(
                      value: providerIsSwitched,
                      activeTrackColor: mainColor,
                      onChanged: (value) {
                        setState(() {
                          providerIsSwitched = value;
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

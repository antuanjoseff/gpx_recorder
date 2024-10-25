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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (Platform.isAndroid)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 50,
                    ),
                    Switch(
                        value: numSatelitesIsSwitched,
                        activeTrackColor: mainColor,
                        onChanged: (value) {
                          setState(() {
                            numSatelitesIsSwitched = value;
                          });
                        }),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(AppLocalizations.of(context)!.numSatelites)
                  ],
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 50,
              ),
              Switch(
                  value: accuracyIsSwitched,
                  activeTrackColor: mainColor,
                  onChanged: (value) {
                    setState(() {
                      accuracyIsSwitched = value;
                    });
                  }),
              const SizedBox(
                width: 5,
              ),
              Text(AppLocalizations.of(context)!.accuracy)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 50,
              ),
              Switch(
                  value: speedIsSwitched,
                  activeTrackColor: mainColor,
                  onChanged: (value) {
                    setState(() {
                      speedIsSwitched = value;
                    });
                  }),
              const SizedBox(
                width: 5,
              ),
              Text(AppLocalizations.of(context)!.speed)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 50,
              ),
              Switch(
                  value: headingIsSwitched,
                  activeTrackColor: mainColor,
                  onChanged: (value) {
                    setState(() {
                      headingIsSwitched = value;
                    });
                  }),
              const SizedBox(
                width: 5,
              ),
              Text(AppLocalizations.of(context)!.heading)
            ],
          )
        ],
      ),
    );
  }
}

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
    return SingleChildScrollView(
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.black, fontSize: 10),
        child: Padding(
          padding: const EdgeInsets.only(left: 0, top: 0),
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Switch(
                      value: speedIsSwitched,
                      inactiveTrackColor: thirthColor,
                      activeTrackColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          speedIsSwitched = value;
                          widget.controller.speed = value;
                          // UserPreferences.setSpeed(value);s
                        });
                      }),
                  Text(AppLocalizations.of(context)!.speed)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Switch(
                      value: headingIsSwitched,
                      inactiveTrackColor: thirthColor,
                      activeTrackColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          headingIsSwitched = value;
                          widget.controller.heading = value;
                          // UserPreferences.setHeading(value);
                        });
                      }),
                  Text(AppLocalizations.of(context)!.heading)
                ],
              ),
              (Platform.isAndroid)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Switch(
                            value: numSatelitesIsSwitched,
                            activeTrackColor: primaryColor,
                            inactiveTrackColor: thirthColor,
                            onChanged: (value) {
                              setState(() {
                                numSatelitesIsSwitched = value;
                                widget.controller.numSatelites = value;
                                // UserPreferences.setNumSatelites(value);
                              });
                            }),
                        Text(AppLocalizations.of(context)!.numSatelites)
                      ],
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Switch(
                      value: accuracyIsSwitched,
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: thirthColor,
                      onChanged: (value) {
                        setState(() {
                          accuracyIsSwitched = value;
                          widget.controller.accuracy = value;
                          // UserPreferences.setAccuracy(value);
                        });
                      }),
                  Text(AppLocalizations.of(context)!.accuracy)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Switch(
                      value: providerIsSwitched,
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: thirthColor,
                      onChanged: (value) {
                        setState(() {
                          providerIsSwitched = value;
                          widget.controller.provider = value;
                          // UserPreferences.setProvider(value);
                        });
                      }),
                  Text(AppLocalizations.of(context)!.provider)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

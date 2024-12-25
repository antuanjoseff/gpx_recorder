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
  late bool numSatelites;
  late bool accuracy;
  late bool speed;
  late bool heading;
  late bool provider;

  @override
  void initState() {
    UserPreferences.setDefaultTab(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    numSatelites = false;
    accuracy = UserPreferences.getAccuracy();
    speed = UserPreferences.getSpeed();
    heading = UserPreferences.getHeading();
    provider = UserPreferences.getProvider();
    return DefaultTextStyle(
      style: TextStyle(fontSize: 20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.gpxAttributes,
                  style: TextStyle(color: primaryColor)),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: SingleChildScrollView(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(10),
                    children: [
                      Container(
                        child: ElevatedButton(
                          onPressed: () async {
                            widget.controller.speed = !widget.controller.speed;
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.controller.speed
                                ? fourthColor
                                : fifthColor,
                            foregroundColor: widget.controller.speed
                                ? Colors.white
                                : textInactiveColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.speed,
                                  size: 40,
                                  color: widget.controller.speed
                                      ? Colors.white
                                      : textInactiveColor),
                              Text(
                                AppLocalizations.of(context)!.speed,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          child: ElevatedButton(
                        onPressed: () async {
                          widget.controller.heading =
                              !widget.controller.heading;
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.controller.heading
                              ? fourthColor
                              : fifthColor,
                          foregroundColor: widget.controller.heading
                              ? Colors.white
                              : textInactiveColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.compass_calibration_sharp,
                                size: 40,
                                color: widget.controller.heading
                                    ? Colors.white
                                    : textInactiveColor),
                            Text(
                              AppLocalizations.of(context)!.heading,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      )),
                      Container(
                          child: ElevatedButton(
                        onPressed: () async {
                          widget.controller.accuracy =
                              !widget.controller.accuracy;
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.controller.accuracy
                              ? fourthColor
                              : fifthColor,
                          foregroundColor: widget.controller.accuracy
                              ? Colors.white
                              : textInactiveColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed,
                                size: 40,
                                color: widget.controller.accuracy
                                    ? Colors.white
                                    : textInactiveColor),
                            Text(
                              AppLocalizations.of(context)!.accuracy,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      )),
                      Container(
                          child: ElevatedButton(
                        onPressed: () async {
                          widget.controller.provider =
                              !widget.controller.provider;
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.controller.provider
                              ? fourthColor
                              : fifthColor,
                          foregroundColor: widget.controller.provider
                              ? Colors.white
                              : textInactiveColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.account_box_sharp,
                                size: 40,
                                color: widget.controller.provider
                                    ? Colors.white
                                    : textInactiveColor),
                            Text(
                              AppLocalizations.of(context)!.provider,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

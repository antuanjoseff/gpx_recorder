import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import '../classes/vars.dart';
import '../classes/user_preferences.dart';
import '../controllers/gpx.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';

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
      style: TextStyle(color: primaryColor, fontSize: 20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            children: [
              Container(
                color: fourthColor,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fourthColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.speed,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  color: fourthColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.heading),
                    ],
                  )),
              Container(
                  color: fourthColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.accuracy),
                    ],
                  )),
              Container(
                  color: fourthColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.provider),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../classes/vars.dart';
import '../controllers/gps.dart';
import '../classes/user_preferences.dart';

class GpsSettings extends StatefulWidget {
  final GpsController controller;
  GpsSettings({super.key, required this.controller});

  @override
  State<GpsSettings> createState() => _TrackSettingsState();
}

class _TrackSettingsState extends State<GpsSettings> {
  late String _method;
  late double _unitsDistance;
  late int _unitsTime;

  @override
  void initState() {
    UserPreferences.setDefaultTab(2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _method = UserPreferences.getGpsMethod();
    _unitsDistance = UserPreferences.getGpsUnitsDistance();
    _unitsTime = UserPreferences.getGpsUnitsTime();

    bool methodIsDistance() {
      return widget.controller.method == 'distance';
    }

    Future<String?> openDialog(context, title) async {
      String title = AppLocalizations.of(context)!.recordingMethod;
      String subtitle = methodIsDistance()
          ? AppLocalizations.of(context)!.distance
          : AppLocalizations.of(context)!.time;

      String sliderTitle = methodIsDistance()
          ? AppLocalizations.of(context)!.gpsDistanceUnits
          : AppLocalizations.of(context)!.gpsTimeUnits;

      double units = methodIsDistance()
          ? widget.controller.unitsDistance
          : widget.controller.unitsTime.toDouble();

      return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(title, style: TextStyle(color: primaryColor)),
                  content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${subtitle} (${sliderTitle})',
                            style: TextStyle(color: primaryColor)),
                        Slider(
                          value: units,
                          min: 1,
                          max: methodIsDistance() ? 100 : 60,
                          divisions: 15,
                          label: "${units!.round().toString()}",
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              units = value;
                            });
                          },
                        ),
                      ],
                    );
                  }),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(units.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.accept)),
                  ]));
    }

    return DefaultTextStyle(
      style: TextStyle(color: primaryColor, fontSize: 20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.recordingMethod),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                children: [
                  // DISTANCE BUTTON
                  Container(
                    child: ElevatedButton(
                      onPressed: () async {
                        widget.controller.method = 'distance';
                        var (result) = await openDialog(
                            context, AppLocalizations.of(context)!.distance);
                        if (result == null) return;

                        double value = double.parse(result);
                        setState(() {
                          widget.controller.unitsDistance = value;
                          _unitsDistance = value;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              methodIsDistance() ? fourthColor : fifthColor,
                          foregroundColor: methodIsDistance()
                              ? Colors.white
                              : textInactiveColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.straighten_outlined,
                              size: 40,
                              color: methodIsDistance()
                                  ? Colors.white
                                  : textInactiveColor),
                          Text(
                            AppLocalizations.of(context)!.distance,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            '${widget.controller.unitsDistance.floor()} m',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // TIME BUTTON
                  Container(
                      child: ElevatedButton(
                    onPressed: () async {
                      widget.controller.method = 'time';

                      var (result) = await openDialog(
                          context, AppLocalizations.of(context)!.time);
                      if (result == null) return;

                      double value = double.parse(result);
                      widget.controller.unitsTime = value.floor();

                      setState(() {
                        widget.controller.unitsTime = value.floor();
                        _unitsTime = value.floor();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !methodIsDistance() ? fourthColor : fifthColor,
                        foregroundColor: !methodIsDistance()
                            ? Colors.white
                            : textInactiveColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 40,
                        ),
                        Text(
                          AppLocalizations.of(context)!.time,
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '${widget.controller.unitsTime.floor()} (s)',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

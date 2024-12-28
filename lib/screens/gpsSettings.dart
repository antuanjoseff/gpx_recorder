import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../classes/vars.dart';
import '../controllers/gps.dart';
import '../classes/user_preferences.dart';
import '../controllers/map.dart';

class GpsSettings extends StatefulWidget {
  final GpsController controller;
  final MapController mapController;

  GpsSettings({
    super.key,
    required this.controller,
    required this.mapController,
  });

  @override
  State<GpsSettings> createState() => _TrackSettingsState();
}

class _TrackSettingsState extends State<GpsSettings> {
  late String _method;
  late double _unitsDistance;
  late int _unitsTime;
  late MapController mapController;
  @override
  void initState() {
    UserPreferences.setDefaultTab(2);
    mapController = widget.mapController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _method = UserPreferences.getGpsMethod();
    _unitsDistance = UserPreferences.getDistancePreferences();
    _unitsTime = UserPreferences.getTimePreferences();

    bool methodIsDistance() {
      return widget.controller.method == 'distance';
    }

    Future<String?> openDialog(context, title) async {
      String title = AppLocalizations.of(context)!.recordingMethod;
      String subtitle = methodIsDistance()
          ? AppLocalizations.of(context)!.distance
          : AppLocalizations.of(context)!.time;

      debugPrint('units times $_unitsTime');
      String sliderTitle = methodIsDistance()
          ? (_unitsDistance > 1
              ? AppLocalizations.of(context)!.gpsDistanceUnits
              : AppLocalizations.of(context)!.gpsDistanceUnit)
          : (_unitsTime > 1
              ? AppLocalizations.of(context)!.gpsTimeUnits
              : AppLocalizations.of(context)!.gpsTimeUnit);

      double units = methodIsDistance()
          ? widget.controller.unitsDistance
          : widget.controller.unitsTime.toDouble();

      return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Center(
                    child: Text(
                        methodIsDistance()
                            ? AppLocalizations.of(context)!.distance
                            : AppLocalizations.of(context)!.time,
                        style: TextStyle(color: primaryColor, fontSize: 25)),
                  ),
                  content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text('${subtitle}',
                        //     style: TextStyle(color: primaryColor)),
                        Text('${units.floor()} ${sliderTitle}',
                            style:
                                TextStyle(color: primaryColor, fontSize: 20)),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: units,
                              min: 1,
                              divisions: methodIsDistance() ? 100 : 60,
                              max: methodIsDistance() ? 100 : 60,
                              // label: "${units!.round().toString()}",
                              activeColor: primaryColor,
                              onChanged: (value) async {
                                setState(() {
                                  units = value;

                                  if (methodIsDistance()) {
                                    sliderTitle = (value > 1)
                                        ? AppLocalizations.of(context)!
                                            .gpsDistanceUnits
                                        : AppLocalizations.of(context)!
                                            .gpsDistanceUnit;

                                    _unitsDistance = value.toDouble();
                                  } else {
                                    sliderTitle = (value > 1)
                                        ? AppLocalizations.of(context)!
                                            .gpsTimeUnits
                                        : AppLocalizations.of(context)!
                                            .gpsTimeUnit;

                                    _unitsTime = value.floor();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          if (methodIsDistance()) {
                            widget.controller.unitsDistance = _unitsDistance;
                            UserPreferences.setDistancePreferences(
                                _unitsDistance);
                            mapController.setGpsSettings!(
                                'distance', _unitsDistance, 0);
                          } else {
                            widget.controller.unitsTime = _unitsTime;
                            UserPreferences.setTimePreferences(_unitsTime);
                            mapController.setGpsSettings!(
                                'time', 0, _unitsTime);
                          }

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
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: GridView.count(
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
                          result ??=
                              await UserPreferences.getDistancePreferences()
                                  .toString();

                          debugPrint('DEBUG $result');

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
                        result ??= await UserPreferences.getTimePreferences()
                            .toString();
                        debugPrint('DEBUG $result');
                        double value = double.parse(result!);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

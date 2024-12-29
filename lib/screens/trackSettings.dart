import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../classes/vars.dart';
import '../controllers/map.dart';
import '../controllers/track.dart';
import '../classes/user_preferences.dart';

class TrackSettings extends StatefulWidget {
  final TrackController controller;
  final MapController mapController;

  TrackSettings(
      {super.key, required this.controller, required this.mapController});

  @override
  State<TrackSettings> createState() => _TrackSettingsState();
}

class _TrackSettingsState extends State<TrackSettings> {
  late bool visible;
  late Color trackColor;
  late int trackWidth;

  @override
  void initState() {
    debugPrint('TRACK SETTINGS INITSTATE');
    UserPreferences.setDefaultTab(1);
    visible = UserPreferences.getTrackVisible();
    trackColor = UserPreferences.getTrackColor();
    trackWidth = UserPreferences.getTrackWidth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthValue = 4;

    return DefaultTextStyle(
      style: TextStyle(color: primaryColor, fontSize: 20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.trackProperties),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
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
                          widget.controller.visible =
                              !widget.controller.visible;

                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: widget.controller.visible
                                ? fourthColor
                                : fifthColor,
                            foregroundColor:
                                visible ? Colors.white : primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                                widget.controller.visible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 40,
                                color: widget.controller.visible
                                    ? Colors.white
                                    : textInactiveColor),
                            Text(
                              widget.controller.visible
                                  ? AppLocalizations.of(context)!.hideTrackOnMap
                                  : AppLocalizations.of(context)!
                                      .showTrackOnMap,
                              style: TextStyle(
                                fontSize: 20,
                                color: widget.controller.visible
                                    ? Colors.white
                                    : textInactiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        child: ElevatedButton(
                      onPressed: !widget.controller.visible
                          ? null
                          : () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Select a color'),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: BlockPicker(
                                                    pickerColor: trackColor,
                                                    onColorChanged:
                                                        (value) async {
                                                      trackColor = value;
                                                      widget.controller.color =
                                                          value;
                                                      setState(() {});
                                                    },
                                                    availableColors: colors,
                                                    // layoutBuilder: pickerLayoutBuilder,
                                                    // itemBuilder: pickerItemBuilder,
                                                  ),
                                                ),
                                                const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Track width'),
                                                  ],
                                                ),
                                                SliderTheme(
                                                  data: SliderTheme.of(context)
                                                      .copyWith(
                                                    trackShape:
                                                        RectangularSliderTrackShape(),
                                                    trackHeight:
                                                        trackWidth.toDouble(),
                                                    overlayColor: trackColor
                                                        .withAlpha(32),
                                                    overlayShape:
                                                        RoundSliderOverlayShape(
                                                            overlayRadius:
                                                                28.0),
                                                  ),
                                                  child: Slider(
                                                    value:
                                                        trackWidth.toDouble(),
                                                    min: 1,
                                                    divisions: 10,
                                                    max: 20,
                                                    label:
                                                        "${trackWidth.floor().toString()}",
                                                    activeColor: trackColor,
                                                    onChanged: (value) {
                                                      widget.controller.width =
                                                          value.floor();
                                                      trackWidth =
                                                          value.floor();
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                fourthColor,
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            )),
                                                    onPressed: () {
                                                      setState(() {
                                                        visible = widget
                                                            .controller.visible;
                                                        trackColor = widget
                                                            .controller.color;
                                                      });
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .close))
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  });
                              setState(() {});
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: widget.controller.visible
                              ? widget.controller.color
                              : fifthColor,
                          foregroundColor: widget.controller.visible
                              ? Colors.white
                              : primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.show_chart_outlined,
                            size: 40,
                          ),
                          Text(
                            AppLocalizations.of(context)!.changeTrackColor,
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

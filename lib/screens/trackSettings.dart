import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../classes/vars.dart';
import '../controllers/track.dart';
import '../classes/user_preferences.dart';

class TrackSettings extends StatefulWidget {
  final TrackController controller;
  TrackSettings({super.key, required this.controller});

  @override
  State<TrackSettings> createState() => _TrackSettingsState();
}

class _TrackSettingsState extends State<TrackSettings> {
  late bool visible;
  late Color trackColor;

  @override
  Widget build(BuildContext context) {
    visible = UserPreferences.getTrackVisible();
    trackColor = UserPreferences.getTrackColor();

    return DefaultTextStyle(
      style: TextStyle(color: primaryColor, fontSize: 20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.trackProperties),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                children: [
                  Container(
                    child: ElevatedButton(
                      onPressed: () async {
                        widget.controller.visible = !widget.controller.visible;
                        await UserPreferences.setTrackVisible(
                            widget.controller.visible);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: visible ? fourthColor : fifthColor,
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
                              visible ? Icons.visibility_off : Icons.visibility,
                              size: 40,
                              color: widget.controller.visible
                                  ? Colors.white
                                  : textInactiveColor),
                          Text(
                            widget.controller.visible
                                ? AppLocalizations.of(context)!.hideTrackOnMap
                                : AppLocalizations.of(context)!.showTrackOnMap,
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
                        : () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Select a color'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          BlockPicker(
                                            pickerColor: trackColor,
                                            onColorChanged: (value) async {
                                              widget.controller.color = value;
                                              UserPreferences.setTrackColor(
                                                  value);
                                              setState(() {});
                                            },
                                            availableColors: colors,
                                            // layoutBuilder: pickerLayoutBuilder,
                                            // itemBuilder: pickerItemBuilder,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: fourthColor,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  )),
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .close))
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: visible ? trackColor : fifthColor,
                        foregroundColor: visible ? Colors.white : primaryColor,
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
            ],
          ),
        ),
      ),
    );
  }
}

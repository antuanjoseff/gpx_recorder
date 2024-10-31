import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../classes/vars.dart';
import '../controllers/track.dart';

class TrackSettings extends StatefulWidget {
  final TrackController controller;
  TrackSettings({super.key, required this.controller});

  @override
  State<TrackSettings> createState() => _TrackSettingsState();
}

class _TrackSettingsState extends State<TrackSettings> {
  bool visible = true;
  @override
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
                child: ElevatedButton(
                  onPressed: () {
                    widget.controller.visible = !widget.controller.visible;
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.controller.visible ? fourthColor : fifthColor,
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
                      Icon(visible ? Icons.visibility_off : Icons.visibility,
                          size: 40,
                          color: widget.controller.visible
                              ? Colors.white
                              : primaryColor),
                      Text(
                        widget.controller.visible
                            ? AppLocalizations.of(context)!.hideTrackOnMap
                            : AppLocalizations.of(context)!.showTrackOnMap,
                        style: TextStyle(fontSize: 20),
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
                                        pickerColor: Colors.pink,
                                        onColorChanged: (value) {
                                          widget.controller.color = value;
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
                                                    BorderRadius.circular(5.0),
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
                    backgroundColor:
                        visible ? widget.controller.color : fifthColor,
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
        ),
      ),
    );
  }
}
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Switch(
              value: visible,
              activeTrackColor: primaryColor,
              onChanged: (value) {
                widget.controller.visible = value;
                visible = value;
                setState(() {});
              },
            ),
            Text(AppLocalizations.of(context)!.showTrackOnMap)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Select a color'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: Colors.pink,
                              onColorChanged: (value) =>
                                  widget.controller.color = value,
                              availableColors: colors,
                              // layoutBuilder: pickerLayoutBuilder,
                              // itemBuilder: pickerItemBuilder,
                            ),
                          ),
                        );
                      });
                },
                child: Text(
                  'Change color',
                  style: TextStyle(color: primaryColor),
                ))
          ],
        )
      ],
    );
  }
}

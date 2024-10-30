import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../classes/vars.dart';

class TrackSettings extends StatefulWidget {
  const TrackSettings({super.key});

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Switch(
              value: visible,
              onChanged: (value) {
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
                              onColorChanged: (value) => {},
                              availableColors: colors,
                              // layoutBuilder: pickerLayoutBuilder,
                              // itemBuilder: pickerItemBuilder,
                            ),
                          ),
                        );
                      });
                },
                child: const Text(
                  'Change color',
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ))
          ],
        )
      ],
    );
  }
}

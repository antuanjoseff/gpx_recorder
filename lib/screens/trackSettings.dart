import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        visible ?  : Container()
      ],
    );
  }
}

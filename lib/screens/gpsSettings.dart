import 'package:flutter/material.dart';

class Gpssettings extends StatefulWidget {
  const Gpssettings({super.key});

  @override
  State<Gpssettings> createState() => _GpssettingsState();
}

enum GpsMode { time, distance }

class _GpssettingsState extends State<Gpssettings> {
  GpsMode? _mode = GpsMode.distance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Per temps'),
          leading: Radio<GpsMode>(
            groupValue: _mode,
            value: GpsMode.time,
            onChanged: (GpsMode? value) {
              setState(() {
                _mode = value;
              });
            },
          ),
        ),
        _mode == GpsMode.time
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Cada N segons'),
                ],
              )
            : Container(),
        ListTile(
          title: Text('Per distància'),
          leading: Radio<GpsMode>(
            groupValue: _mode,
            value: GpsMode.distance,
            onChanged: (GpsMode? value) {
              setState(() {
                _mode = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

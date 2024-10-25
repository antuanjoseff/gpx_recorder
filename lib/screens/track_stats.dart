import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gpx_recorder/classes/vars.dart';
import '../classes/track.dart';
import '../classes/user_preferences.dart';

class TrackStats extends StatefulWidget {
  final Track track;
  const TrackStats({super.key, required this.track});

  @override
  State<TrackStats> createState() => _TrackStatsState();
}

class _TrackStatsState extends State<TrackStats> {
  late Track _track;
  Timer? _timer;
  late String trackLength;
  late String trackTime;
  late String trackAltitude;

  String _formatDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String formatDistance(double length) {
    int kms = (length / 1000).floor().toInt();
    int mts = (length - (kms * 1000)).toInt();

    String plural = kms > 1 ? 's ' : ' ';

    String format = '';
    if (kms > 0) {
      format = '${kms.toString()}Km$plural';
    }

    format += '${mts}m';
    return format;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _track = widget.track;

    trackLength = UserPreferences.getTrackLength();
    trackTime = UserPreferences.getTrackTime();
    trackAltitude = UserPreferences.getTrackAltitude();

    // defines a timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        trackLength = formatDistance(_track.getLength());
        trackTime =
            _formatDuration(DateTime.now().difference(_track.getStartTime()));
        trackAltitude = _track.getElevation() != null
            ? _track.getElevation().toString() + 'm'
            : '--';
      });
    });
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
    await UserPreferences.setTrackLength(trackLength);
    await UserPreferences.setTrackTime(trackTime);
    await UserPreferences.setTrackAltitude(trackAltitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.trackData),
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.distance,
                    style: TextStyle(fontSize: 25)),
                Text(
                  trackLength,
                  style: const TextStyle(fontSize: 45),
                ),
                SizedBox(height: 15),
                Text(AppLocalizations.of(context)!.altitude,
                    style: TextStyle(fontSize: 25)),
                Text(
                  trackAltitude,
                  style: const TextStyle(fontSize: 45),
                ),
                const SizedBox(height: 15),
                Text(AppLocalizations.of(context)!.movingTime,
                    style: TextStyle(fontSize: 25)),
                Text(
                  trackTime,
                  style: const TextStyle(fontSize: 45),
                )
              ],
            ),
          ],
        ));
  }
}

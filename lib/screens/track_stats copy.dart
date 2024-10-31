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
  late double trackLength;
  DateTime? trackStartedAt;
  String trackTimeDuration = '00:00:00';
  late String notMovingTime;
  late String trackAltitudeString;
  late String avgSpeed;
  late double? trackAccuracy;

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

    trackLength = _track.getLength();
    trackStartedAt = _track.getStartTime();
    trackAltitudeString = _track.getCurrentElevation() != null
        ? _track.getCurrentElevation().toString() + 'm'
        : '--';
    trackAccuracy = _track.getAccuracy();
    double kmh = 3.6 *
        (_track.getLength() /
            DateTime.now().difference(_track.getStartTime()!).inSeconds);

    // avgSpeed = kmh.toStringAsFixed(2) + ' Km/h';
    avgSpeed = _track.getCurrentSpeed().toString() + ' Km/h';
    notMovingTime = _formatDuration(_track.getNotMovingTime());
    // defines a timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        trackTimeDuration = _track.getStartTime() != null
            ? _formatDuration(DateTime.now().difference(_track.getStartTime()!))
            : '00:00:00';

        trackAltitudeString = _track.getCurrentElevation() != null
            ? _track.getCurrentElevation().toString() + 'm'
            : '--';
        // double kmh = 3.6 *
        //     (_track.getLength() /
        //         DateTime.now().difference(_track.getStartTime()).inSeconds);
        double kmh = 3.6 * _track.getCurrentSpeed()!;
        notMovingTime = _track.getStartTime() != null
            ? _formatDuration(_track.getNotMovingTime())
            : '00:00:00';

        avgSpeed = kmh.toStringAsFixed(2) + ' Km/h';
        trackAccuracy = _track.getAccuracy();
      });
    });
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.trackData),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.count(
              crossAxisCount: 2,
              children: [
                Text(AppLocalizations.of(context)!.distance,
                    style: TextStyle(fontSize: 20)),
                Text(
                  formatDistance(_track.getLength()),
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.trackSpeedAverage,
                    style: TextStyle(fontSize: 20)),
                Text(
                  avgSpeed,
                  style: const TextStyle(fontSize: 40),
                ),
                SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.altitude,
                    style: TextStyle(fontSize: 20)),
                Text(
                  trackAltitudeString,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.stoppedTime,
                    style: TextStyle(fontSize: 20)),
                Text(
                  notMovingTime,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.elapsedTime,
                    style: TextStyle(fontSize: 20)),
                Text(
                  trackTimeDuration,
                  style: const TextStyle(fontSize: 40),
                )
              ],
            ),
          ],
        ));
  }
}

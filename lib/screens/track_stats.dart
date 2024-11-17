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
  late String trackElevationString;
  late String trackHeadingString;
  late String trackElevationGainString;

  late String avgSpeed;
  late double? currentSpeed;
  String currentSpeedString = '';

  late double? trackAccuracy;
  late double? trackHeading;
  String trackAccuracyString = '';

  String distanceUnits = '';
  String elevationUnits = 'm';

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
      format = '${kms.toString()}';
      distanceUnits = 'Km$plural';
    } else {
      distanceUnits = 'm';
    }

    format += '${mts}';
    return format;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _track = widget.track;

    trackLength = _track.getLength();

    trackStartedAt = _track.getStartTime();

    trackElevationString = _track.getCurrentElevation() != null
        ? _track.getCurrentElevation()!.toStringAsFixed(0)
        : '--';

    trackElevationGainString = _track.getElevationGain() != null
        ? _track.getElevationGain()!.toStringAsFixed(0)
        : '--';

    trackAccuracy = _track.getAccuracy();
    trackHeading = _track.getHeading();

    trackAccuracyString =
        trackAccuracy != null ? trackAccuracy!.toStringAsFixed(2) : '-';
    trackHeadingString =
        trackHeading != null ? trackHeading!.toStringAsFixed(2) : '-';

    double kmh = 3.6 *
        (_track.getLength() /
            DateTime.now().difference(_track.getStartTime()!).inSeconds);

    avgSpeed = kmh.toStringAsFixed(2) + ' Km/h';

    currentSpeed = _track.getCurrentSpeed();
    currentSpeedString =
        currentSpeed != null ? currentSpeed!.toStringAsFixed(2) : '-';

    notMovingTime = _formatDuration(_track.getNotMovingTime());

    // defines a timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        trackTimeDuration = _track.getStartTime() != null
            ? _formatDuration(DateTime.now().difference(_track.getStartTime()!))
            : '00:00:00';

        trackElevationString = _track.getCurrentElevation() != null
            ? _track.getCurrentElevation()!.toStringAsFixed(0)
            : '--';

        trackElevationGainString = _track.getElevationGain() != null
            ? _track.getElevationGain()!.toStringAsFixed(0)
            : '--';

        double avgKmh = 3.6 *
            (_track.getLength() /
                DateTime.now().difference(_track.getStartTime()!).inSeconds);
        avgSpeed = avgKmh.toStringAsFixed(2);

        double currentKmh = 3.6 * _track.getCurrentSpeed()!;
        currentSpeed = _track.getCurrentSpeed();
        currentSpeedString = currentSpeed != null
            ? (3.6 * currentSpeed!).toStringAsFixed(2)
            : '-';

        notMovingTime = _track.getStartTime() != null
            ? _formatDuration(_track.getNotMovingTime())
            : '00:00:00';

        trackAccuracy = _track.getAccuracy();
        trackAccuracyString =
            trackAccuracy != null ? trackAccuracy!.toStringAsFixed(2) : '-';

        trackHeading = _track.getHeading();
        trackHeadingString =
            trackHeading != null ? trackHeading!.toStringAsFixed(2) : '-';
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
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;
    final double itemWidth = size.width / 2;
    TextStyle titleStyle = TextStyle(fontSize: 18);
    TextStyle contentStyle = TextStyle(fontSize: 25);
    TextStyle unitsStyle = TextStyle(fontSize: 17);

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(AppLocalizations.of(context)!.trackData),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Container(
          color: thirthColor,
          child: DefaultTextStyle(
            style: TextStyle(color: primaryColor),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: (itemWidth / itemHeight),
                  shrinkWrap: true,
                  children: [
                    // DISTANCIA
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.distance,
                            style: titleStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              formatDistance(_track.getLength()),
                              style: contentStyle,
                            ),
                            SizedBox(width: 5),
                            Text(
                              distanceUnits,
                              style: unitsStyle,
                            ),
                          ],
                        ),
                        Text(_track.gpxCoords.length.toStringAsFixed(2))
                      ],
                    ),
                    // ACCURACY
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.accuracy,
                            style: titleStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              trackAccuracyString,
                              style: contentStyle,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'm',
                              style: unitsStyle,
                            ),
                          ],
                        ),
                        Text(trackHeadingString)
                      ],
                    ),
                    // ELEVATION
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.altitude,
                            style: titleStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              trackElevationString,
                              style: contentStyle,
                            ),
                            SizedBox(width: 5),
                            Text(
                              distanceUnits,
                              style: unitsStyle,
                            )
                          ],
                        ),
                      ],
                    ),
                    // ELEVATION GAIN
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.elevationGain,
                            style: titleStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              trackElevationGainString,
                              style: contentStyle,
                            ),
                            SizedBox(width: 5),
                            Text(
                              elevationUnits,
                              style: unitsStyle,
                            )
                          ],
                        ),
                      ],
                    ),
                    // VELOCITAT ACTUAL
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.speed,
                            style: titleStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentSpeedString,
                              style: contentStyle,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Km/h',
                              style: unitsStyle,
                            ),
                          ],
                        )
                      ],
                    ),
                    // VELOCITAT MITJANA
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.trackSpeedAverage,
                            style: titleStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              avgSpeed,
                              style: contentStyle,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Km/h',
                              style: unitsStyle,
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.movingTime,
                            style: titleStyle),
                        Text(
                          notMovingTime,
                          style: contentStyle,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.elapsedTime,
                            style: titleStyle),
                        Text(trackTimeDuration, style: contentStyle)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

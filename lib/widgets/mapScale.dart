import 'package:flutter/material.dart';
import 'package:gpx_recorder/main.dart';
import '../classes/vars.dart';
import 'package:intl/intl.dart';

final Color scaleBackground = Colors.white.withOpacity(0.85);
final Color scaleForeground = primaryColor;

class MapScale extends StatefulWidget {
  String? mapscale;
  double? resolution;

  MapScale({
    super.key,
    required this.mapscale,
    required this.resolution,
  });

  @override
  State<MapScale> createState() => _MapScaleState();
}

class _MapScaleState extends State<MapScale> {
  double? barWidth;

  List<double> scales = [
    10000 * 1000,
    5000 * 1000,
    2000 * 1000,
    1000 * 1000,
    500 * 1000,
    200 * 1000,
    100 * 1000,
    50 * 1000,
    20 * 1000,
    10 * 1000,
    5000,
    2000,
    1000,
    500,
    200,
    100,
    50,
    20,
    10
  ];

  double? currentScale;

  String formatScale(meters) {
    var formatter = NumberFormat('###');
    if (meters == null) return '';

    if (meters < 1000) {
      return '$meters m';
    } else {
      late double formatted;
      if (meters > 1000) {
        formatted = double.parse(((meters / 1000).floor()).toString());
      }
      String m = formatter.format(formatted);
      return '${m}km';
    }
  }

  @override
  void initState() {
    debugPrint('initstate MAPSCALE INSIDE RESOLUTION ${widget.resolution}');
    currentScale = 0;
    if (widget.mapscale != null && widget.resolution != null) {
      double scale = double.parse(widget.mapscale!);
      int idx = 0;
      while (idx < scales.length) {
        if (scale < scales[idx]) {
          idx += 1;
          break;
        }
      }

      currentScale = scales[idx];
      debugPrint('MAP SHOW SCALE ${currentScale}');

      if (widget.resolution == 0) {
        barWidth = 100;
      } else {
        barWidth = currentScale! / widget.resolution!;
      }

      debugPrint('MAP SHOW SCALE ${barWidth}');
      debugPrint('SCALE RESSOLUTION ${widget.resolution}');
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scaleBackground,
      width: barWidth,
      height: 30,
      child: CustomPaint(
          foregroundPainter: LinePainter(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatScale(currentScale),
                style: TextStyle(color: scaleForeground),
              ),
            ],
          )),
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  double padding = 3;
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scaleForeground
      ..strokeWidth = 1;

    canvas.drawLine(Offset(padding, size.height - padding),
        Offset(size.width - padding, size.height - padding), paint);
    canvas.drawLine(Offset(padding, size.height - padding),
        Offset(padding, size.height / 2), paint);
    canvas.drawLine(Offset(size.width - padding, size.height - padding),
        Offset(size.width - padding, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

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

  double? barWidth;
  double showScale = 0;

  String formatScale(meters) {
    // var formatter = NumberFormat('###');
    if (meters == null) return '';

    if (meters < 1000) {
      return '${meters.floor()} m';
    }

    return '${((meters / 1000).floor()).toStringAsFixed(0)} km';
  }

  void getData() {
    if (widget.mapscale != null && widget.resolution != null) {
      double scale = double.parse(widget.mapscale!);

      int idx = 0;
      while (idx < scales.length) {
        if (scale > scales[idx]) {
          break;
        } else {
          idx += 1;
        }
      }

      if (idx == scales.length) {
        showScale = scales[idx - 1];
      } else {
        showScale = scales[idx];
      }

      if (widget.resolution == 0) {
        barWidth = 0;
      } else {
        barWidth = (showScale / widget.resolution!);
        if (barWidth! < 60) {
          showScale = scales[idx - 1];
          barWidth = (showScale / widget.resolution!);
        }
      }

      debugPrint('BARWIDTH ${barWidth}');
      debugPrint('SCALE RESSOLUTION ${widget.resolution}');
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
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
                formatScale(showScale),
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

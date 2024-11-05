import 'package:flutter/material.dart';
import 'package:gpx_recorder/main.dart';
import '../classes/vars.dart';
import 'package:intl/intl.dart';

Color scaleBackground = Colors.white.withOpacity(0.85);
Color scaleForeground = primaryColor;

class MapScale extends StatefulWidget {
  double barWidth;
  String? text;
  MapScale({
    super.key,
    required this.barWidth,
    required this.text,
  });

  @override
  State<MapScale> createState() => _MapScaleState();
}

class _MapScaleState extends State<MapScale> {
  String formatScale(scaleText) {
    var formatter = NumberFormat('###');
    if (scaleText == null) return '';
    double meters = double.parse(scaleText);
    if (meters < 1000) {
      return '$scaleText m';
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
  Widget build(BuildContext context) {
    return Container(
      color: scaleBackground,
      width: widget.barWidth,
      height: 30,
      child: CustomPaint(
          foregroundPainter: LinePainter(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatScale(widget.text),
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

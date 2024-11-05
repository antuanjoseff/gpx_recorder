import 'package:flutter/material.dart';
import 'package:gpx_recorder/main.dart';
import '../classes/vars.dart';

Color scaleBackground = primaryColor;
Color scaleForeground = thirthColor;

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
    if (scaleText == null) return '';
    double meters = double.parse(scaleText);
    if (meters < 1000) {
      return '$scaleText m';
    } else {
      if (meters > 10000) {
        return '${(meters / 1000).toStringAsFixed(0)} km';
      } else
        return '${(meters / 1000).toStringAsFixed(1)} km';
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
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scaleForeground
      ..strokeWidth = 3;

    canvas.drawLine(
        Offset(0, size.height - 5), Offset(size.width, size.height - 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

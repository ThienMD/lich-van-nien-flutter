import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  const StrokeText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.color = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()..color = color,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..strokeWidth = strokeWidth
              ..color = strokeColor
              ..style = PaintingStyle.stroke,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:calendar/components/calendar/constants.dart';

class Dot extends StatelessWidget {
  Dot(this.isShow, this.color);
  final bool isShow;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 6,
      height: 6,
      decoration: isShow ? BoxDecoration(
        color: color,
        shape: BoxShape.circle
      ) : null,
    );
  }
}
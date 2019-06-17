import 'package:flutter/material.dart';
import 'package:calendar/components/calendar/constants.dart';

class DayOfWeek extends StatelessWidget {
  DayOfWeek(this.title, this.width);

  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: width,
      height: width,
      child: Center(
        child: Text(title.toUpperCase(),

            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: DOW_TEXT_SIZE,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:calendar/components/calendar/constants.dart';
class Header extends StatelessWidget {
  Header({this.currentMonth, this.onPreviousPress, this.onNextPress});
  final DateTime currentMonth;
  final Function onPreviousPress;
  final Function onNextPress;
  @override
  Widget build(BuildContext context) {
    var month = currentMonth.month;
    var year = currentMonth.year;
    var title = '${months[month - 1]} ${year}'.toUpperCase();
    const titleStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_left),
          iconSize: 30,
          color: Colors.white,
          onPressed: () {
            onPreviousPress();
          },
        ),
        Text(title, style: titleStyle),
        IconButton(
          icon: Icon(Icons.arrow_right),
          iconSize: 30,
          color: Colors.white,
          onPressed: () {
            onNextPress();
          },
        ),
      ],
    );
  }
}
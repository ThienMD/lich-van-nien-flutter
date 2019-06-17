import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ConvertContainer extends StatefulWidget {
  @override
  State createState() {
    return _ConvertContainerState();
  }
}

class _ConvertContainerState extends State<ConvertContainer> {
  DateTime lunarDate = DateTime.now();
  DateTime solarDate = DateTime.now();
  Widget _getCalendarPicker(String label, DateTime date) {
    var labelStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold
    );
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Text(label, style: labelStyle),
          Container(
            height: 200,
            padding: EdgeInsets.only(top: 20),
            child: CupertinoDatePicker(
              initialDateTime: date,
              mode: CupertinoDatePickerMode.date,
              minimumDate: DateTime(1993, 10, 10),
              maximumDate: DateTime(2019, 10, 10),
              onDateTimeChanged: (date) {
                setState(() {
                  lunarDate = date;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: AssetImage("assets/image_blue_blur.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            this._getCalendarPicker("Dương Lịch", solarDate),
            this._getCalendarPicker("Âm Lịch", lunarDate)
          ],
        ),
      ),
    );
  }
}

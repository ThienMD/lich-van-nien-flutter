import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ConvertContainer extends StatefulWidget {
  const ConvertContainer({super.key});

  @override
  State<ConvertContainer> createState() {
    return _ConvertContainerState();
  }
}

class _ConvertContainerState extends State<ConvertContainer> {
  DateTime lunarDate = DateTime.now();
  DateTime solarDate = DateTime.now();
  Widget _getCalendarPicker(String label, DateTime date) {
    const labelStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold
    );
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Text(label, style: labelStyle),
          Container(
            height: 200,
            padding: const EdgeInsets.only(top: 20),
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image_blue_blur.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _getCalendarPicker("Dương Lịch", solarDate),
            _getCalendarPicker("Âm Lịch", lunarDate)
          ],
        ),
      ),
    );
  }
}

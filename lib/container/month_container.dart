import 'package:calendar/components/calendar/calendar.dart';
import 'package:calendar/components/event/EventList.dart';
import 'package:calendar/model/EventVO.dart';
import 'package:calendar/services/DataService.dart';
import 'package:flutter/material.dart';

class MonthContainer extends StatefulWidget {
  @override
  State createState() {
    return _MonthContainerState();
  }
}

class _MonthContainerState extends State<MonthContainer>
    with AutomaticKeepAliveClientMixin<MonthContainer> {
  List<EventVO> _eventData = new List();
  List<EventVO> _eventByMonths = new List();
  List<DateTime> _markedDates = new List();
  DateTime _calendar = DateTime.now();

  @override
  void initState() {
    super.initState();
    this._getData();
  }

  _getData() async {
    var data = await loadEventData();
    setState(() {
      _eventData = data;
    });
    this.generateEventByMonth(_calendar.month);
    this.generate_markedDates();
  }

  generate_markedDates() {
    _markedDates.clear();
    _eventData.forEach((EventVO event) {
      _markedDates.add(event.date);
    });
  }

  generateEventByMonth(int month) {
    _eventByMonths.clear();
    _eventData.forEach((EventVO event) {
      if (event.date.month == month) {
        _eventByMonths.add(event);
      }
    });
    setState(() {
      _eventByMonths = _eventByMonths;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        decoration: BoxDecoration(
          image: new DecorationImage(
            image: AssetImage("assets/image_nature_blur.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 60),
          child: Column(
            children: <Widget>[
              Calendar(
                markedDays: _markedDates,
                onDateTimeChanged: (newDate) {
                  setState(() {
                    _calendar = newDate;
                  });
                  this.generateEventByMonth(newDate.month);
                },
              ),
              Expanded(
                  flex: 1,
                  child: EventList(
                    data: _eventByMonths,
                  ))
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

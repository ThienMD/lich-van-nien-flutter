DateTime firstDayOfWeek(DateTime date) {
  int weekDay = date.weekday - 1;
  return date.subtract(new Duration(days: weekDay));
}

DateTime endDayOfWeek(DateTime date) {
  int weekDay = 7 - date.weekday;
  return date.add(new Duration(days: weekDay));
}

DateTime lastDayOfMonth(DateTime date) {
  if (date.month < 12) {
    return new DateTime(date.year, date.month + 1, 0);
  }
  return new DateTime(date.year + 1, 1, 0);
}

lastDayOfPreviousMonth(DateTime date) {
  return new DateTime(date.year, date.month, 0);
}

DateTime increaseMonth(DateTime date) {
  var month = date.month;
  var year = date.year;
  if (month == 12) {
    month = 1;
    year++;
  } else {
    month++;
  }
  return new DateTime(year, month, 1);
}

DateTime decreaseMonth(DateTime date) {
  var month = date.month;
  var year = date.year;
  if (month == 1) {
    month = 12;
    year--;
  } else {
    month--;
  }
  return new DateTime(year, month, 1);
}

bool isOtherMonth(DateTime date, DateTime currentMonth) {
  if (date.year == currentMonth.year && date.month == currentMonth.month) {
    return false;
  }
  return true;
}

bool equalDate(DateTime date1, DateTime date2) {
  if(date1 == null || date2 == null) {
    return false;
  }
  if(date1.year == date2.year && date1.month == date2.month && date1.day == date2.day) {
    return true;
  }
  return false;
}

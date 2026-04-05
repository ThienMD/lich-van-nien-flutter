import 'package:calendar/components/calendar/constants.dart';
import 'package:calendar/components/calendar/day.dart';
import 'package:calendar/components/calendar/day_of_week.dart';
import 'package:calendar/components/calendar/header.dart';
import 'package:calendar/components/calendar/utils.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    required this.markedDays,
    required this.onDateTimeChanged,
  });

  final List<DateTime> markedDays;
  final ValueChanged<DateTime> onDateTimeChanged;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const int _initialPage = 1200;
  static const Duration _pageDuration = Duration(milliseconds: 260);

  late final PageController _pageController;
  late final DateTime _baseMonth;
  late int _currentPage;
  late DateTime _calendar;
  DateTime? _selectedDate;
  late Set<String> _markedDayKeys;

  @override
  void initState() {
    super.initState();
    _baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _calendar = _baseMonth;
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage, viewportFraction: 1);
    _markedDayKeys = _buildMarkedDayKeys(widget.markedDays);
  }

  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markedDays != widget.markedDays) {
      _markedDayKeys = _buildMarkedDayKeys(widget.markedDays);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Set<String> _buildMarkedDayKeys(List<DateTime> dates) {
    return dates.map(Day.dateKey).toSet();
  }

  DateTime _monthForPage(int page) {
    final offset = page - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + offset, 1);
  }

  List<DateTime> _daysForMonth(DateTime month) {
    final start = firstDayOfWeek(DateTime(month.year, month.month, 1));
    return List<DateTime>.generate(
      42,
      (int index) => start.add(Duration(days: index)),
      growable: false,
    );
  }

  Widget _buildDateOfWeekHeader(double dayWidth, double dayHeight) {
    return Row(
      children: days
          .map(
            (String item) => DayOfWeek(title: item, width: dayWidth),
          )
          .toList(growable: false),
    );
  }

  void _onPageChanged(int page) {
    final nextMonth = _monthForPage(page);
    setState(() {
      _currentPage = page;
      _calendar = nextMonth;
    });
    widget.onDateTimeChanged(nextMonth);
  }

  void _goToPreviousMonth() {
    _pageController.previousPage(
      duration: _pageDuration,
      curve: Curves.easeOutQuart,
    );
  }

  void _goToNextMonth() {
    _pageController.nextPage(
      duration: _pageDuration,
      curve: Curves.easeOutQuart,
    );
  }

  void _onDayPress(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    final monthDelta = (date.year - _calendar.year) * 12 + date.month - _calendar.month;
    if (monthDelta != 0) {
      _pageController.animateToPage(
        _currentPage + monthDelta,
        duration: _pageDuration,
        curve: Curves.easeOutQuart,
      );
    }
  }

  Widget _buildMonthPage(BuildContext context, DateTime month) {
    final daysInView = _daysForMonth(month);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final dayWidth = constraints.maxWidth / 7;
        final headerHeight = (dayWidth * 0.55).clamp(28.0, 42.0);
        final gridHeight = (constraints.maxHeight - headerHeight - 10).clamp(220.0, 420.0);
        final dayHeight = gridHeight / 6;

        return RepaintBoundary(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: headerHeight,
                child: _buildDateOfWeekHeader(dayWidth, dayHeight),
              ),
              const SizedBox(height: 4),
              ...List<Widget>.generate(6, (int weekIndex) {
                final week = daysInView.sublist(weekIndex * 7, (weekIndex + 1) * 7);
                return SizedBox(
                  height: dayHeight,
                  child: Row(
                    children: week
                        .map(
                          (DateTime date) => Day(
                            width: dayWidth,
                            height: dayHeight,
                            date: date,
                            currentCalendar: month,
                            selectedDate: _selectedDate,
                            onDayPress: _onDayPress,
                            markedDayKeys: _markedDayKeys,
                          ),
                        )
                        .toList(growable: false),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final calendarHeight = width >= 1200 ? 420.0 : width >= 900 ? 380.0 : 320.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Header(
          currentMonth: _calendar,
          onPreviousPress: _goToPreviousMonth,
          onNextPress: _goToNextMonth,
        ),
        SizedBox(
          height: calendarHeight,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            onPageChanged: _onPageChanged,
            itemBuilder: (BuildContext context, int index) {
              final month = _monthForPage(index);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                child: Padding(
                  key: ValueKey<String>('${month.year}-${month.month}'),
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildMonthPage(context, month),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:calendar/components/calendar/dot.dart';
import 'package:calendar/components/calendar/utils.dart';
import 'package:calendar/utils/lunar_solar_utils.dart';
import 'package:flutter/material.dart';

class Day extends StatelessWidget {
  const Day({
    super.key,
    required this.width,
    required this.height,
    required this.date,
    required this.currentCalendar,
    required this.onDayPress,
    required this.markedDayKeys,
    this.selectedDate,
  });

  final double width;
  final double height;
  final DateTime date;
  final DateTime currentCalendar;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDayPress;
  final Set<String> markedDayKeys;

  static final Map<String, int> _lunarDayCache = <String, int>{};

  static String dateKey(DateTime date) => '${date.month}-${date.day}';

  int get _lunarDay {
    final key = '${date.year}-${date.month}-${date.day}';
    return _lunarDayCache.putIfAbsent(
      key,
      () => convertSolar2Lunar(date.day, date.month, date.year, 7)[0] as int,
    );
  }

  bool get _isMarked => markedDayKeys.contains(dateKey(date));

  @override
  Widget build(BuildContext context) {
    final bool isToday = equalDate(DateTime.now(), date);
    final bool isSelected = equalDate(selectedDate, date);
    final bool isOtherMonthDay = isOtherMonth(date, currentCalendar);
    final bool compact = height < 44;
    final colorScheme = Theme.of(context).colorScheme;

    Color textColor = colorScheme.onSurface;
    Color badgeColor = colorScheme.primaryContainer;
    Color fillColor = Colors.transparent;
    List<BoxShadow>? boxShadow;
    bool showDot = _isMarked;

    if (isToday) {
      fillColor = colorScheme.tertiaryContainer.withValues(alpha: 0.38);
    }

    if (isSelected) {
      fillColor = colorScheme.primary;
      badgeColor = colorScheme.onPrimary;
      boxShadow = <BoxShadow>[
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
    }

    if (isOtherMonthDay) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.38);
      showDot = false;
      fillColor = Colors.transparent;
      boxShadow = null;
    }

    final horizontalPadding = compact ? 2.0 : 4.0;
    final verticalPadding = 2.0;
    final boxHeight = (height - (verticalPadding * 2)).clamp(38.0, 64.0);
    final boxWidth = (width - (horizontalPadding * 2)).clamp(34.0, 60.0);

    final dayStyle = TextStyle(
      fontSize: compact ? 14 : 18,
      height: 1,
      color: textColor,
      fontWeight: FontWeight.w800,
    );
    final lunarDayStyle = TextStyle(
      fontSize: compact ? 7 : 10,
      height: 1,
      color: textColor.withValues(alpha: isOtherMonthDay ? 0.7 : 0.9),
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onDayPress(date),
            child: Stack(
              children: <Widget>[
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(compact ? 14 : 18),
                      boxShadow: boxShadow,
                      border: isToday && !isSelected
                          ? Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.65))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          date.day.toString(),
                          style: dayStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: compact ? 0 : 2),
                        Text(
                          _lunarDay.toString(),
                          style: lunarDayStyle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? 6 : 8,
                  right: compact ? 4 : 8,
                  child: Dot(showDot, badgeColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

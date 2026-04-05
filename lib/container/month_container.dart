import 'package:calendar/components/calendar/calendar.dart';
import 'package:calendar/components/event/event_list.dart';
import 'package:calendar/model/event_vo.dart';
import 'package:calendar/services/data_service.dart';
import 'package:flutter/material.dart';

class MonthContainer extends StatefulWidget {
  const MonthContainer({
    super.key,
    required this.useGlassTheme,
  });

  final bool useGlassTheme;

  @override
  State<MonthContainer> createState() => _MonthContainerState();
}

class _MonthContainerState extends State<MonthContainer>
    with AutomaticKeepAliveClientMixin<MonthContainer> {
  List<EventVO> _eventData = const <EventVO>[];
  List<EventVO> _eventByMonths = const <EventVO>[];
  List<DateTime> _markedDates = const <DateTime>[];
  DateTime _calendar = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final data = await loadEventData();
    if (!mounted) {
      return;
    }

    setState(() {
      _eventData = data;
      _markedDates = data.map((EventVO event) => event.date).toList(growable: false);
      _eventByMonths = _filterEventsForMonth(_calendar, data);
      _isLoading = false;
    });
  }

  List<EventVO> _filterEventsForMonth(DateTime month, List<EventVO> source) {
    return source
        .where((EventVO event) => event.date.month == month.month)
        .toList(growable: false);
  }

  void _handleMonthChanged(DateTime newDate) {
    setState(() {
      _calendar = DateTime(newDate.year, newDate.month, 1);
      _eventByMonths = _filterEventsForMonth(_calendar, _eventData);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final bool wide = size.width >= 1000;
    final bool tablet = size.width >= 700;
    final double maxWidth = wide ? 1400 : 960;
    final titleColor = widget.useGlassTheme ? Colors.white : colorScheme.onSurface;
    final subtitleColor = widget.useGlassTheme ? Colors.white70 : colorScheme.onSurfaceVariant;
    final surfaceColor = widget.useGlassTheme ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final borderColor = widget.useGlassTheme
        ? Colors.white.withValues(alpha: 0.10)
        : colorScheme.outlineVariant;

    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w800,
        );

    final calendarCard = Container(
      padding: EdgeInsets.fromLTRB(wide ? 18 : 12, 14, wide ? 18 : 12, 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: widget.useGlassTheme
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Calendar(
        markedDays: _markedDates,
        onDateTimeChanged: _handleMonthChanged,
      ),
    );

    final eventsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Sự kiện tháng ${_calendar.month}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : EventList(
                  data: _eventByMonths,
                  currentMonth: _calendar,
                ),
        ),
      ],
    );

    final bottomSafeSpace = MediaQuery.of(context).padding.bottom + (wide ? 24 : 110);

    return DecoratedBox(
      decoration: BoxDecoration(
        image: widget.useGlassTheme
            ? const DecorationImage(
                image: AssetImage('assets/image_nature_blur.jpg'),
                fit: BoxFit.cover,
              )
            : null,
        gradient: widget.useGlassTheme
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFF7FAFE), Color(0xFFE7EEF8)],
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.useGlassTheme
                ? <Color>[
                    Colors.black.withValues(alpha: 0.18),
                    const Color(0xFF07111F).withValues(alpha: 0.72),
                  ]
                : <Color>[
                    Colors.white.withValues(alpha: 0.66),
                    const Color(0xFFF1F6FC).withValues(alpha: 0.94),
                  ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: wide
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(tablet ? 24 : 16, 18, tablet ? 24 : 16, 20),
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Lịch tháng', style: titleStyle),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Tối ưu cho web, iPad và macOS — vuốt hoặc bấm để xem nhanh ngày đẹp và sự kiện âm lịch.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: subtitleColor,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(flex: 6, child: calendarCard),
                                const SizedBox(width: 18),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: surfaceColor,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: borderColor),
                                      boxShadow: widget.useGlassTheme
                                          ? null
                                          : <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                    ),
                                    child: eventsSection,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        tablet ? 24 : 16,
                        18,
                        tablet ? 24 : 16,
                        bottomSafeSpace,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Lịch tháng', style: titleStyle),
                          const SizedBox(height: 6),
                          Text(
                            'Vuốt để xem nhanh ngày đẹp và sự kiện âm lịch.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: subtitleColor,
                                ),
                          ),
                          const SizedBox(height: 16),
                          calendarCard,
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(minHeight: 220),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor),
                              boxShadow: widget.useGlassTheme
                                  ? null
                                  : <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                            ),
                            child: SizedBox(
                              height: 260,
                              child: eventsSection,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

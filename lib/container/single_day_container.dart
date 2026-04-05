import 'dart:async';

import 'package:calendar/components/SelectDateButton.dart';
import 'package:calendar/components/StrokeText.dart';
import 'package:calendar/components/SwipeDetector.dart';
import 'package:calendar/model/QuoteVO.dart';
import 'package:calendar/services/DataService.dart';
import 'package:calendar/utils/date_utils.dart';
import 'package:calendar/utils/lunar_solar_utils.dart';
import 'package:flutter/material.dart';

class SingleDayContainer extends StatefulWidget {
  const SingleDayContainer({
    super.key,
    required this.useGlassTheme,
  });

  final bool useGlassTheme;

  @override
  State<SingleDayContainer> createState() => _SingleDayContainerState();
}

class _SingleDayContainerState extends State<SingleDayContainer>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<SingleDayContainer> {
  List<QuoteVO> _quoteData = const <QuoteVO>[];
  DateTime _selectedDate = DateTime.now();
  Timer? _timer;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _getData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward(from: 0.86);
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      if (!mounted) {
        return;
      }
      final now = DateTime.now();
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          now.hour,
          now.minute,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getData() async {
    final data = await loadQuoteData();
    if (!mounted) {
      return;
    }

    setState(() {
      _quoteData = data;
    });
  }

  void _replayAnimation() {
    _controller.forward(from: 0.86);
  }

  void _goToPreviousDay() {
    _replayAnimation();
    setState(() {
      _selectedDate = decreaseDay(_selectedDate);
    });
  }

  void _goToNextDay() {
    _replayAnimation();
    setState(() {
      _selectedDate = increaseDay(_selectedDate);
    });
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1920, 8),
      lastDate: DateTime(2101),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    });
  }

  Widget _buildActionButtons(BuildContext context, {required bool onImage}) {
    final title = 'Tháng ${_selectedDate.month} • ${_selectedDate.year}';
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = onImage ? Colors.white : colorScheme.onSurface;
    final backgroundColor = onImage
        ? Colors.white.withValues(alpha: 0.14)
        : colorScheme.surfaceContainerHighest;
    final borderColor = onImage ? Colors.white.withValues(alpha: 0.24) : colorScheme.outlineVariant;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: <Widget>[
        FilledButton.tonal(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime.now();
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          child: const Text('Hôm nay'),
        ),
        SelectDateButton(
          title: title,
          onPress: () => _showDatePicker(context),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildHeaderOverlay(BuildContext context, {required bool compact, required double maxWidth}) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: compact ? 16 : 22),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildActionButtons(context, onImage: true),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    QuoteVO quote, {
    required bool onLightSurface,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    if (quote.content.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = onLightSurface ? const Color(0xFF182230) : Colors.white;
    final secondaryColor = onLightSurface ? const Color(0xFF5B6473) : Colors.white70;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: onLightSurface ? Colors.white : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: onLightSurface
              ? const Color(0xFFDCE4F0)
              : Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: onLightSurface
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            quote.content,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              quote.author,
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(
    BuildContext context,
    String label,
    String value,
    String caption, {
    bool hasBorder = true,
    required bool onLightSurface,
  }) {
    final labelColor = onLightSurface ? const Color(0xFF6B7280) : Colors.white70;
    final valueColor = onLightSurface ? const Color(0xFF101828) : Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: hasBorder
                  ? (onLightSurface ? const Color(0xFFDCE4F0) : Colors.white12)
                  : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: TextStyle(color: labelColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context, {
    required bool onLightSurface,
    EdgeInsetsGeometry? margin,
  }) {
    final hourMinute =
        '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}';
    final lunarDates =
        convertSolar2Lunar(_selectedDate.day, _selectedDate.month, _selectedDate.year, 7);
    final lunarDay = lunarDates[0];
    final lunarMonth = lunarDates[1];
    final lunarYear = lunarDates[2];
    final lunarMonthName = getCanChiMonth(lunarMonth, lunarYear);
    final jd = jdn(_selectedDate.day, _selectedDate.month, _selectedDate.year);
    final dayName = getCanDay(jd);
    final beginHourName = getBeginHour(jd);

    return Container(
      margin: margin ?? EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewPadding.bottom + 72),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: onLightSurface ? Colors.white : Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: onLightSurface
              ? const Color(0xFFDCE4F0)
              : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: onLightSurface
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          _infoBox(context, 'Giờ đầu', hourMinute, beginHourName, onLightSurface: onLightSurface),
          _infoBox(context, 'Ngày', '$lunarDay', dayName, onLightSurface: onLightSurface),
          _infoBox(
            context,
            'Tháng (Lunar)',
            '$lunarMonth',
            lunarMonthName,
            hasBorder: false,
            onLightSurface: onLightSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    QuoteVO quote,
    String dayOfWeek,
    int backgroundIndex,
    BoxConstraints constraints,
  ) {
    final shellColor = widget.useGlassTheme
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.96);
    final rightPanelColor = widget.useGlassTheme
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFFF7F9FC);
    final panelWidth = (constraints.maxWidth - 36).clamp(980.0, 1280.0);
    final panelHeight = (constraints.maxHeight - 40).clamp(620.0, 860.0);
    final leftOverlayColors = widget.useGlassTheme
        ? <Color>[
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.30),
          ]
        : <Color>[
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.36),
          ];

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        child: SizedBox(
          width: panelWidth,
          height: panelHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: shellColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: widget.useGlassTheme
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFD8E2EF),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.useGlassTheme ? 0.22 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.asset(
                            'assets/image_${backgroundIndex + 1}.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: leftOverlayColors,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildActionButtons(context, onImage: true),
                              const Spacer(),
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    StrokeText(
                                      _selectedDate.day.toString(),
                                      strokeWidth: 0,
                                      fontSize: 118,
                                      color: Colors.white,
                                      strokeColor: Colors.white,
                                    ),
                                    Text(
                                      dayOfWeek,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Vuốt trái/phải để đổi ngày',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: rightPanelColor,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Today overview',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _buildQuoteCard(context, quote, onLightSurface: true),
                                  const SizedBox(height: 18),
                                  _buildDateInfo(
                                    context,
                                    onLightSurface: true,
                                    margin: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, QuoteVO quote, String dayOfWeek) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isCompact = constraints.maxHeight < 680;
        final maxWidth = 760.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: <Widget>[
                  SizedBox(height: isCompact ? 72 : 94),
                  StrokeText(
                    _selectedDate.day.toString(),
                    strokeWidth: 0,
                    fontSize: isCompact ? 96 : 118,
                    color: Colors.white,
                    strokeColor: Colors.white,
                  ),
                  Text(
                    dayOfWeek,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isCompact ? 24 : 28,
                    ),
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  const Text(
                    'Vuốt trái/phải để đổi ngày',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: isCompact ? 12 : 18),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQuoteCard(
                          context,
                          quote,
                          onLightSurface: false,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  _buildDateInfo(context, onLightSurface: false),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainDate() {
    final backgroundIndex = _selectedDate.day % 17;
    final dayOfWeek = getNameDayOfWeek(_selectedDate);
    final quote = _quoteData.isNotEmpty
        ? _quoteData[_selectedDate.day % _quoteData.length]
        : const QuoteVO('', '');

    return Expanded(
      child: SwipeDetector(
        onSwipeLeft: _goToNextDay,
        onSwipeRight: _goToPreviousDay,
        child: FadeTransition(
          opacity: _animation,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final isWide = constraints.maxWidth >= 980;
              final isCompact = constraints.maxHeight < 680;
              final maxWidth = isWide ? 1280.0 : 760.0;

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(
                    child: Image.asset(
                      'assets/image_${backgroundIndex + 1}.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: widget.useGlassTheme
                              ? <Color>[
                                  Colors.white.withValues(alpha: 0.02),
                                  Colors.black.withValues(alpha: 0.10),
                                ]
                              : <Color>[
                                  Colors.white.withValues(alpha: 0.62),
                                  const Color(0xFFEFF4FB).withValues(alpha: 0.92),
                                ],
                        ),
                      ),
                    ),
                  ),
                  if (isWide)
                    _buildDesktopLayout(
                      context,
                      quote,
                      dayOfWeek,
                      backgroundIndex,
                      constraints,
                    )
                  else
                    _buildMobileLayout(context, quote, dayOfWeek),
                  if (!isWide)
                    Positioned.fill(
                      child: _buildHeaderOverlay(
                        context,
                        compact: isCompact,
                        maxWidth: maxWidth,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        _buildMainDate(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

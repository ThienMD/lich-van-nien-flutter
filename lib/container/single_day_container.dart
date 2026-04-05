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
    required this.selectedDate,
    this.onSelectedDateChanged,
    this.onOpenAiTab,
  });

  final bool useGlassTheme;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onSelectedDateChanged;
  final VoidCallback? onOpenAiTab;

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
  int _swipeDirection = 1;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
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
  void didUpdateWidget(covariant SingleDayContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate && widget.selectedDate != _selectedDate) {
      _selectedDate = widget.selectedDate;
    }
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

  void _setSelectedDate(
    DateTime nextDate, {
    bool replay = false,
    int direction = 0,
  }) {
    if (replay) {
      _replayAnimation();
    }

    setState(() {
      _swipeDirection = direction;
      _selectedDate = nextDate;
    });
    widget.onSelectedDateChanged?.call(nextDate);
  }

  void _goToPreviousDay() {
    _setSelectedDate(
      decreaseDay(_selectedDate),
      replay: true,
      direction: -1,
    );
  }

  void _goToNextDay() {
    _setSelectedDate(
      increaseDay(_selectedDate),
      replay: true,
      direction: 1,
    );
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

    _setSelectedDate(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      ),
    );
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
          onPressed: () => _setSelectedDate(DateTime.now()),
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

  String _formatDateChip(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _lunarYearName(int lunarYear) {
    return '${CAN[(lunarYear + 6) % 10]} ${CHI[(lunarYear + 8) % 12]}';
  }

  static const Map<String, String> _zodiacEmoji = <String, String>{
    'Tý': '🐭',
    'Sửu': '🐮',
    'Dần': '🐯',
    'Mão': '🐱',
    'Thìn': '🐲',
    'Tỵ': '🐍',
    'Ngọ': '🐴',
    'Mùi': '🐐',
    'Thân': '🐵',
    'Dậu': '🐔',
    'Tuất': '🐶',
    'Hợi': '🐷',
  };

  String _animalFromCanChi(String canChiValue) {
    final parts = canChiValue.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.last : canChiValue;
  }

  String _animalDisplay(String canChiValue) {
    final animal = _animalFromCanChi(canChiValue);
    return '${_zodiacEmoji[animal] ?? '✨'} $animal';
  }

  Widget _buildProfileHeader(BuildContext context) {
    final chipText = _formatDateChip(_selectedDate);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            FilledButton.tonal(
              onPressed: () => _setSelectedDate(DateTime.now()),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.78),
                foregroundColor: const Color(0xFF22252E),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Hôm nay',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDatePicker(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Ngày $chipText',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFF22252E),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const Icon(Icons.expand_more_rounded, color: Color(0xFF5B6473)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onOpenAiTab,
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF693B),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x33FF693B),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaperQuoteCard(BuildContext context, QuoteVO quote) {
    final safeQuote = quote.content.isEmpty ? 'Mỗi ngày là một cơ hội mới để sống nhẹ nhàng và sáng rõ hơn.' : quote.content;
    final safeAuthor = quote.author.isEmpty ? 'Lịch Vạn Niên' : quote.author;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.format_quote_rounded, size: 42, color: Color(0x22000000)),
          Text(
            safeQuote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1B1B1F),
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              safeAuthor,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF8A8A94),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperFactTile({
    required String label,
    required String value,
    required String caption,
    bool emphasize = false,
    bool showDivider = true,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: showDivider ? const Color(0x14000000) : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A7A80),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: emphasize ? const Color(0xFF22B32E) : const Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF303543),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
    final lunarDates = convertSolar2Lunar(
      _selectedDate.day,
      _selectedDate.month,
      _selectedDate.year,
      7,
    );
    final lunarDay = lunarDates[0] as int;
    final lunarMonth = lunarDates[1] as int;
    final lunarYear = lunarDates[2] as int;
    final jd = jdn(_selectedDate.day, _selectedDate.month, _selectedDate.year);
    final dayName = getCanDay(jd);
    final lunarMonthName = getCanChiMonth(lunarMonth, lunarYear);
    final yearName = _lunarYearName(lunarYear);
    final dayAnimal = _animalDisplay(dayName);
    final monthAnimal = _animalDisplay(lunarMonthName);
    final yearAnimal = _animalDisplay(yearName);
    final monthLabel = 'Tháng ${_selectedDate.month}, ${_selectedDate.year}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            MediaQuery.of(context).padding.top + 4,
            12,
            MediaQuery.of(context).padding.bottom + 64,
          ),
          child: Column(
            children: <Widget>[
              _buildProfileHeader(context),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Text(
                        _selectedDate.day.toString(),
                        style: const TextStyle(
                          fontSize: 148,
                          height: 0.95,
                          color: Color(0xFF22B32E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.spa_rounded, color: Color(0xFFFF7A9C), size: 30),
                      const SizedBox(height: 4),
                      Text(
                        dayOfWeek,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthLabel,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF303543),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vuốt trái / phải để đổi ngày',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 14),
                      _buildPaperQuoteCard(context, quote),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            _buildPaperFactTile(
                              label: 'Ngày',
                              value: dayAnimal,
                              caption: 'Âm $lunarDay • $dayName',
                              emphasize: true,
                            ),
                            _buildPaperFactTile(
                              label: 'Tháng',
                              value: monthAnimal,
                              caption: 'Tháng $lunarMonth • $lunarMonthName',
                            ),
                            _buildPaperFactTile(
                              label: 'Năm',
                              value: yearAnimal,
                              caption: 'Năm $lunarYear • $yearName',
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(_animation),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 340),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              final horizontalOffset = _swipeDirection == 0
                  ? 0.0
                  : (_swipeDirection > 0 ? 0.12 : -0.12);

              return ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(horizontalOffset, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(
                    opacity: curved,
                    child: child,
                  ),
                ),
              );
            },
            child: LayoutBuilder(
              key: ValueKey<String>(
                '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
              ),
              builder: (BuildContext context, BoxConstraints constraints) {
                final isWide = constraints.maxWidth >= 980;

                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned.fill(
                      child: Image.asset(
                        'assets/image_${backgroundIndex + 1}.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isWide
                                ? (widget.useGlassTheme
                                    ? <Color>[
                                        Colors.white.withValues(alpha: 0.02),
                                        Colors.black.withValues(alpha: 0.10),
                                      ]
                                    : <Color>[
                                        Colors.white.withValues(alpha: 0.42),
                                        const Color(0xFFEFF4FB).withValues(alpha: 0.78),
                                      ])
                                : <Color>[
                                    const Color(0xFFF9F5EA).withValues(alpha: 0.80),
                                    const Color(0xFFF2F5EF).withValues(alpha: 0.88),
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
                  ],
                );
              },
            ),
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

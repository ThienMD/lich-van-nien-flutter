import 'dart:ui';

import 'package:calendar/container/horoscope_container.dart';
import 'package:calendar/container/info_container.dart';
import 'package:calendar/container/month_container.dart';
import 'package:calendar/container/single_day_container.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _useGlassTheme = true;

  ThemeData _buildTheme(bool useGlassTheme) {
    final brightness = useGlassTheme ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2B6CF6),
      brightness: brightness,
    );
    final navSelectedColor = useGlassTheme ? const Color(0xFF2D5BDB) : colorScheme.primary;
    const navUnselectedColor = Color(0xFF6B7280);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: useGlassTheme
          ? const Color(0xFF08111E)
          : const Color(0xFFF4F7FB),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardThemeData(
        elevation: useGlassTheme ? 0 : 1,
        color: useGlassTheme ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: navSelectedColor.withValues(alpha: useGlassTheme ? 0.18 : 0.12),
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? navSelectedColor : navUnselectedColor,
            size: selected ? 25 : 23,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            color: selected ? const Color(0xFF111827) : navUnselectedColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        useIndicator: true,
        indicatorColor: navSelectedColor.withValues(alpha: useGlassTheme ? 0.18 : 0.12),
        selectedIconTheme: IconThemeData(color: navSelectedColor, size: 25),
        unselectedIconTheme: const IconThemeData(color: navUnselectedColor, size: 23),
        selectedLabelTextStyle: const TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: navUnselectedColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleThemeModeChanged(bool useGlassTheme) {
    setState(() {
      _useGlassTheme = useGlassTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lịch Vạn Niên',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(_useGlassTheme),
      home: MyHomePage(
        useGlassTheme: _useGlassTheme,
        onThemeModeChanged: _handleThemeModeChanged,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.useGlassTheme,
    required this.onThemeModeChanged,
  });

  final bool useGlassTheme;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();
  DateTime? _birthDate;

  void _handleSelectedDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleBirthDateChanged(DateTime? date) {
    setState(() {
      _birthDate = date;
    });
  }

  List<Widget> get _tabs => <Widget>[
        SingleDayContainer(
          useGlassTheme: widget.useGlassTheme,
          selectedDate: _selectedDate,
          onSelectedDateChanged: _handleSelectedDateChanged,
          birthDate: _birthDate,
          onOpenAiTab: () {
            setState(() {
              _currentIndex = 2;
            });
          },
        ),
        MonthContainer(useGlassTheme: widget.useGlassTheme),
        HoroscopeContainer(
          selectedDate: _selectedDate,
          useGlassTheme: widget.useGlassTheme,
          birthDate: _birthDate,
          onBirthDateChanged: _handleBirthDateChanged,
        ),
        InfoContainer(
          useGlassTheme: widget.useGlassTheme,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool useRail = width >= 900;

    final destinations = const <NavigationRailDestination>[
      NavigationRailDestination(
        icon: Icon(Icons.today_outlined),
        selectedIcon: Icon(Icons.today),
        label: Text('Ngày'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.calendar_view_month_rounded),
        selectedIcon: Icon(Icons.calendar_view_month),
        label: Text('Tháng'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.nights_stay_outlined),
        selectedIcon: Icon(Icons.nights_stay),
        label: Text('Tử vi'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.info_outline_rounded),
        selectedIcon: Icon(Icons.info_rounded),
        label: Text('Thông tin'),
      ),
    ];

    final mobileDestinations = const <Widget>[
      NavigationDestination(
        icon: Icon(Icons.today_outlined),
        selectedIcon: Icon(Icons.today),
        label: 'Ngày',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Tháng',
      ),
      NavigationDestination(
        icon: Icon(Icons.nights_stay_outlined),
        selectedIcon: Icon(Icons.nights_stay),
        label: 'Tử vi',
      ),
      NavigationDestination(
        icon: Icon(Icons.info_outline_rounded),
        selectedIcon: Icon(Icons.info_rounded),
        label: 'Thông tin',
      ),
    ];

    final desktopContent = IndexedStack(
      index: _currentIndex,
      children: _tabs,
    );

    final mobileContent = IndexedStack(
      index: _currentIndex,
      children: _tabs,
    );

    return Scaffold(
      extendBody: !useRail && widget.useGlassTheme,
      body: useRail
          ? SafeArea(
              child: Row(
                children: <Widget>[
                  Expanded(child: desktopContent),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.useGlassTheme
                                ? const Color(0xDFFAFBFF)
                                : Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: widget.useGlassTheme
                                  ? Colors.white.withValues(alpha: 0.42)
                                  : const Color(0xFFE5E7EB),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: NavigationRail(
                            selectedIndex: _currentIndex,
                            onDestinationSelected: (int index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            labelType: NavigationRailLabelType.all,
                            backgroundColor: Colors.transparent,
                            minWidth: 88,
                            minExtendedWidth: 96,
                            destinations: destinations,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : mobileContent,
      bottomNavigationBar: useRail
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.useGlassTheme
                          ? const Color(0xDFFAFBFF)
                          : Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: widget.useGlassTheme
                            ? Colors.white.withValues(alpha: 0.40)
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: NavigationBar(
                      selectedIndex: _currentIndex,
                      backgroundColor: Colors.transparent,
                      indicatorColor: widget.useGlassTheme
                          ? const Color(0x332B6CF6)
                          : Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 0,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      destinations: mobileDestinations,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

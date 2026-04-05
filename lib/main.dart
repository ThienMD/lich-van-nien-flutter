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
        backgroundColor: useGlassTheme
            ? Colors.white.withValues(alpha: 0.62)
            : Colors.white.withValues(alpha: 0.94),
        indicatorColor: useGlassTheme
            ? const Color(0x262B6CF6)
            : colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: useGlassTheme
            ? const Color(0x262B6CF6)
            : colorScheme.secondaryContainer,
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

  List<Widget> get _tabs => <Widget>[
        SingleDayContainer(useGlassTheme: widget.useGlassTheme),
        MonthContainer(useGlassTheme: widget.useGlassTheme),
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
      index: _currentIndex > 2 ? 2 : _currentIndex,
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
                      child: NavigationRail(
                        selectedIndex: _currentIndex,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: widget.useGlassTheme
                            ? Colors.white.withValues(alpha: 0.72)
                            : Colors.white,
                        destinations: destinations,
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
                child: NavigationBar(
                  selectedIndex: _currentIndex > 2 ? 2 : _currentIndex,
                  backgroundColor: widget.useGlassTheme
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.94),
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
    );
  }
}

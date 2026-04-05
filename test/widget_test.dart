import 'dart:ui';

import 'package:calendar/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the main navigation destinations', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Ngày'), findsWidgets);
    expect(find.text('Tháng'), findsWidgets);
    expect(find.text('Tử vi'), findsOneWidget);
    expect(find.text('Thông tin'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);
  });

  testWidgets('month view renders without layout overflow on compact screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tháng').last);
    await tester.pumpAndSettle();

    expect(find.text('Lịch tháng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop glass day view renders and theme switch stays in info tab', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Chế độ giao diện'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Thông tin'));
    await tester.pumpAndSettle();

    expect(find.text('Chế độ giao diện'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI tử vi is available as a dedicated bottom tab', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tử vi').last);
    await tester.pumpAndSettle();

    expect(find.text('Thỉnh thầy tử vi'), findsOneWidget);
    expect(find.text('Nhập câu hỏi tử vi của bạn...'), findsOneWidget);
    expect(find.textContaining('Ngày sinh'), findsWidgets);
    expect(find.textContaining('Preview mode'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

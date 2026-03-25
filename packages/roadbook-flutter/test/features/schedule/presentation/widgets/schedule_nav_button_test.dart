// test/features/schedule/presentation/widgets/schedule_nav_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/presentation/widgets/schedule_nav_button.dart';

void main() {
  testWidgets('disabled when coordinate is 0,0', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ScheduleNavButton(
          coordinate: '0,0',
          name: 'Test',
          isHotel: false,
        ),
      ),
    ));
    // Button renders with opacity
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, lessThan(1.0));
  });

  testWidgets('disabled when coordinate is empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ScheduleNavButton(
          coordinate: '',
          name: 'Test',
          isHotel: false,
        ),
      ),
    ));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, lessThan(1.0));
  });

  testWidgets('enabled when coordinate is valid', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ScheduleNavButton(
          coordinate: '116.4,39.9',
          name: '故宫',
          isHotel: false,
        ),
      ),
    ));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, equals(1.0));
  });

  testWidgets('shows bottom sheet with 5 transport options on tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ScheduleNavButton(
          coordinate: '116.4,39.9',
          name: '故宫',
          isHotel: false,
        ),
      ),
    ));
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(find.text('驾车'), findsOneWidget);
    expect(find.text('打车'), findsOneWidget);
    expect(find.text('公交'), findsOneWidget);
    expect(find.text('步行'), findsOneWidget);
    expect(find.text('骑行'), findsOneWidget);
  });
}

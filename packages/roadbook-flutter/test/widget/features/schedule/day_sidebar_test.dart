// test/widget/features/schedule/day_sidebar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/presentation/widgets/day_sidebar.dart';

void main() {
  final monday = DateTime(2026, 3, 23); // known Monday

  testWidgets('renders weekday label for day 1', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DaySidebar(
          totalDays: 3,
          selectedDay: 1,
          travelStartDate: monday,
          onDaySelected: (_) {},
        ),
      ),
    ));
    expect(find.text('周一'), findsOneWidget);
  });

  testWidgets('renders weekday label for day 2', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DaySidebar(
          totalDays: 3,
          selectedDay: 1,
          travelStartDate: monday,
          onDaySelected: (_) {},
        ),
      ),
    ));
    expect(find.text('周二'), findsOneWidget);
  });

  testWidgets('always renders 待规划 cell', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DaySidebar(
          totalDays: 2,
          selectedDay: 0,
          travelStartDate: monday,
          onDaySelected: (_) {},
        ),
      ),
    ));
    expect(find.text('待规划'), findsOneWidget);
  });
}

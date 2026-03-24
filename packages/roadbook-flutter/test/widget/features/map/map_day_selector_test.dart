import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_day_selector.dart';
import 'package:roadbook_flutter/features/schedule/domain/schedule_provider.dart';

Widget buildWidget({
  required int totalDays,
  required int travelId,
  int selectedDay = 1,
  VoidCallback? onSearchTap,
}) {
  return ProviderScope(
    overrides: [
      selectedDayProvider(travelId).overrideWith((ref) => selectedDay),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: MapDaySelectorBar(
          travelId: travelId,
          totalDays: totalDays,
          onSearchTap: onSearchTap ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('渲染正确数量的 Day Chip', (tester) async {
    await tester.pumpWidget(buildWidget(totalDays: 3, travelId: 1));
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('Day 3'), findsOneWidget);
  });

  testWidgets('搜索图标存在且可点击', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(totalDays: 2, travelId: 1, onSearchTap: () => tapped = true),
    );
    await tester.tap(find.byIcon(Icons.search));
    expect(tapped, isTrue);
  });
}

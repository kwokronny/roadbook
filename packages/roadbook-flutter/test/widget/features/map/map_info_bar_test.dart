import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_info_bar.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';
import 'package:roadbook_flutter/shared/models/amap_poi.dart';

void main() {
  final schedule = Schedule(
    id: 1,
    tId: 1,
    name: '故宫博物院',
    coordinate: '116.397,39.917',
    address: '景山前街4号',
    isHotel: false,
    startTime: DateTime(2026, 3, 24, 9, 0),
    endTime: DateTime(2026, 3, 24, 12, 0),
  );

  final poi = AmapPoi(
    id: 'poi_1',
    name: '南锣鼓巷',
    address: '东城区南锣鼓巷',
    longitude: 116.4,
    latitude: 39.93,
  );

  testWidgets('Schedule 模式：显示名称和时间', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MapInfoBar.schedule(
          schedule: schedule,
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('故宫博物院'), findsOneWidget);
    expect(find.text('09:00 — 12:00'), findsOneWidget);
  });

  testWidgets('POI 模式：显示名称和添加按钮', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MapInfoBar.poi(
          poi: poi,
          onAdd: () {},
          isAdding: false,
        ),
      ),
    ));
    expect(find.text('南锣鼓巷'), findsOneWidget);
    expect(find.text('+ 加入待规划'), findsOneWidget);
  });

  testWidgets('onTap 回调触发', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MapInfoBar.schedule(
          schedule: schedule,
          onTap: () => tapped = true,
        ),
      ),
    ));
    await tester.tap(find.byType(MapInfoBar));
    expect(tapped, isTrue);
  });
}

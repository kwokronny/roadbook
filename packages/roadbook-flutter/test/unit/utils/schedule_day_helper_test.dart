import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';
import 'package:roadbook_flutter/shared/utils/schedule_day_helper.dart';

Schedule _s({int id = 1, DateTime? start, DateTime? end, bool hotel = false}) =>
    Schedule(
      id: id,
      tId: 1,
      name: 'Test',
      coordinate: '116.0,39.0',
      address: 'Addr',
      isHotel: hotel,
      startTime: start,
      endTime: end,
    );

void main() {
  final travelStart = DateTime(2026, 3, 24);  // Day 1

  group('schedulesForDay', () {
    test('day=0 返回无时间的行程（待规划）', () {
      final all = [
        _s(id: 1, start: null),                          // 待规划
        _s(id: 2, start: DateTime(2026, 3, 24, 9, 0)),   // Day 1
      ];
      final result = schedulesForDay(0, all, travelStart);
      expect(result.map((s) => s.id), [1]);
    });

    test('day=1 返回第一天的行程，按时间排序', () {
      final all = [
        _s(id: 1, start: DateTime(2026, 3, 24, 14, 0)), // Day 1 下午
        _s(id: 2, start: DateTime(2026, 3, 24, 9, 0)),  // Day 1 上午
        _s(id: 3, start: DateTime(2026, 3, 25, 9, 0)),  // Day 2
      ];
      final result = schedulesForDay(1, all, travelStart);
      expect(result.map((s) => s.id), [2, 1]);
    });

    test('酒店横跨多天，在每天都出现', () {
      final all = [
        _s(
          id: 1,
          start: DateTime(2026, 3, 24, 14, 0),
          end: DateTime(2026, 3, 26, 12, 0),
          hotel: true,
        ),
      ];
      expect(schedulesForDay(1, all, travelStart).map((s) => s.id), [1]);
      expect(schedulesForDay(2, all, travelStart).map((s) => s.id), [1]);
      expect(schedulesForDay(3, all, travelStart).map((s) => s.id), [1]);
      expect(schedulesForDay(4, all, travelStart), isEmpty);
    });

    test('空列表返回空', () {
      expect(schedulesForDay(1, [], travelStart), isEmpty);
    });
  });
}

// test/unit/features/schedule/quick_time_sheet_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/presentation/schedule_quick_time_sheet.dart';

void main() {
  group('HotelHourRangeState', () {
    test('state0: first tap sets checkIn, clears checkOut', () {
      var state = HotelHourRangeState.empty();
      state = state.tap(12);
      expect(state.checkInHour, 12);
      expect(state.checkOutHour, isNull);
      expect(state.phase, HotelHourPhase.awaitingCheckOut);
    });

    test('state1→state2: second tap sets checkOut', () {
      var state = HotelHourRangeState.empty().tap(10);
      state = state.tap(14);
      expect(state.checkInHour, 10);
      expect(state.checkOutHour, 14);
      expect(state.phase, HotelHourPhase.complete);
    });

    test('state1→state2: auto-swaps when checkOut < checkIn', () {
      var state = HotelHourRangeState.empty().tap(14);
      state = state.tap(10);
      expect(state.checkInHour, 10);
      expect(state.checkOutHour, 14);
    });

    test('state2: third tap resets to empty', () {
      var state = HotelHourRangeState.empty().tap(10).tap(14).tap(8);
      expect(state.checkInHour, isNull);
      expect(state.checkOutHour, isNull);
      expect(state.phase, HotelHourPhase.awaitingCheckIn);
    });

    test('isInRange returns true for middle hours', () {
      final state = HotelHourRangeState.empty().tap(10).tap(14);
      expect(state.isInRange(12), isTrue);
      expect(state.isInRange(10), isFalse); // endpoints not "range middle"
      expect(state.isInRange(14), isFalse);
      expect(state.isInRange(9), isFalse);
    });
  });

  group('buildStartTime (regular schedule)', () {
    final travelStart = DateTime(2026, 3, 23); // Day 1

    test('day + hour → correct DateTime', () {
      final result = buildStartTime(
          travelStart: travelStart, selectedDay: 1, selectedHour: 9);
      expect(result, DateTime(2026, 3, 23, 9, 0, 0));
    });

    test('day + no hour → midnight', () {
      final result = buildStartTime(
          travelStart: travelStart, selectedDay: 2, selectedHour: null);
      expect(result, DateTime(2026, 3, 24, 0, 0, 0));
    });

    test('day 0 (待规划) → null', () {
      final result = buildStartTime(
          travelStart: travelStart, selectedDay: 0, selectedHour: 9);
      expect(result, isNull);
    });
  });

  group('buildHotelDateTime', () {
    final travelStart = DateTime(2026, 3, 23);

    test('day + hour → correct DateTime', () {
      final result = buildHotelDateTime(
          travelStart: travelStart, day: 2, hour: 14);
      expect(result, DateTime(2026, 3, 24, 14, 0, 0));
    });

    test('day + no hour → noon default', () {
      final result = buildHotelDateTime(
          travelStart: travelStart, day: 2, hour: null);
      expect(result, DateTime(2026, 3, 24, 12, 0, 0));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/presentation/widgets/travel_card.dart';

void main() {
  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  DateTime daysFromNow(int n) => today().add(Duration(days: n));

  group('computeTravelStatus', () {
    test('today equals startDate → ongoing', () {
      expect(computeTravelStatus(today(), daysFromNow(3)), TravelStatus.ongoing);
    });

    test('today equals endDate → ongoing', () {
      expect(computeTravelStatus(daysFromNow(-3), today()), TravelStatus.ongoing);
    });

    test('today is between start and end → ongoing', () {
      expect(computeTravelStatus(daysFromNow(-2), daysFromNow(2)), TravelStatus.ongoing);
    });

    test('endDate before today → ended', () {
      expect(computeTravelStatus(daysFromNow(-5), daysFromNow(-1)), TravelStatus.ended);
    });

    test('startDate 3 days from now → upcoming', () {
      expect(computeTravelStatus(daysFromNow(3), daysFromNow(7)), TravelStatus.upcoming);
    });

    test('startDate exactly 7 days from now → upcoming (boundary)', () {
      expect(computeTravelStatus(daysFromNow(7), daysFromNow(10)), TravelStatus.upcoming);
    });

    test('startDate 8 days from now → planning', () {
      expect(computeTravelStatus(daysFromNow(8), daysFromNow(12)), TravelStatus.planning);
    });

    test('startDate 30 days from now → planning', () {
      expect(computeTravelStatus(daysFromNow(30), daysFromNow(35)), TravelStatus.planning);
    });
  });
}

// test/shared/models/travel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';

void main() {
  group('Travel', () {
    test('fromJson parses cities string to list', () {
      final travel = Travel.fromJson({
        'id': 1,
        'name': 'Trip A',
        'startDate': '2024-06-01',
        'endDate': '2024-06-05',
        'public': false,
        'city': '北京',
        'Users': [],
        'Schedules': [],
      });
      expect(travel.cities, ['北京']);
    });

    test('fromJson parses multi-city string', () {
      final travel = Travel.fromJson({
        'id': 2,
        'name': 'Trip B',
        'startDate': '2024-07-01',
        'endDate': '2024-07-10',
        'public': true,
        'city': '北京,上海,成都',
        'Users': [],
        'Schedules': [],
      });
      expect(travel.cities, ['北京', '上海', '成都']);
    });

    test('fromJson handles empty cities', () {
      final travel = Travel.fromJson({
        'id': 3,
        'name': 'Trip C',
        'startDate': '2024-08-01',
        'endDate': '2024-08-03',
        'public': false,
        'city': '',
        'Users': [],
        'Schedules': [],
      });
      expect(travel.cities, isEmpty);
    });
  });
}

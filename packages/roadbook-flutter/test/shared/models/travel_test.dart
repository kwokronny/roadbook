// test/shared/models/travel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';

void main() {
  group('Travel', () {
    final json = {
      'id': 10,
      'name': '上海之旅',
      'startDate': '2026-04-10',
      'endDate': '2026-04-14',
      'isPublic': false,
      'cities': '上海',
      'collaborators': [],
      'schedules': [],
      'equip': null,
    };

    test('fromJson parses cities string to list', () {
      final travel = Travel.fromJson(json);
      expect(travel.cities, ['上海']);
    });

    test('fromJson parses multi-city string', () {
      final j = Map<String, dynamic>.from(json)..['cities'] = '北京,上海';
      final travel = Travel.fromJson(j);
      expect(travel.cities, ['北京', '上海']);
    });

    test('fromJson handles empty cities', () {
      final j = Map<String, dynamic>.from(json)..['cities'] = '';
      final travel = Travel.fromJson(j);
      expect(travel.cities, isEmpty);
    });
  });
}

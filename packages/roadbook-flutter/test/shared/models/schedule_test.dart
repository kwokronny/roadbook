// test/shared/models/schedule_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

void main() {
  group('Schedule', () {
    final json = {
      'id': 5,
      'tId': 10,
      'name': '外滩观光隧道',
      'coordinate': '121.489,31.233',
      'address': '上海市黄浦区中山东二路479号',
      'cover': 'https://img.example.com/cover.jpg',
      'dianpingUUID': null,
      'isHotel': false,
      'startTime': '2026-04-10 09:00:00',
      'endTime': null,
      'screenshots': 'url1,url2',
      'notes': null,
    };

    test('fromJson parses basic fields', () {
      final s = Schedule.fromJson(json);
      expect(s.name, '外滩观光隧道');
      expect(s.isHotel, isFalse);
    });

    test('screenshotList splits comma-separated string', () {
      final s = Schedule.fromJson(json);
      expect(s.screenshotList, ['url1', 'url2']);
    });

    test('screenshotList returns empty list when null', () {
      final j = Map<String, dynamic>.from(json)..['screenshots'] = null;
      final s = Schedule.fromJson(j);
      expect(s.screenshotList, isEmpty);
    });

    test('screenshotList ignores empty segments', () {
      final j = Map<String, dynamic>.from(json)..['screenshots'] = 'url1,,url2';
      final s = Schedule.fromJson(j);
      expect(s.screenshotList, ['url1', 'url2']);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

void main() {
  group('PublicTravelOwner.fromJson', () {
    test('parses all fields', () {
      final json = {'id': 5, 'username': 'xiaoli', 'name': '旅行达人小李', 'avatar': 'https://a.com/img.jpg'};
      final owner = PublicTravelOwner.fromJson(json);
      expect(owner.id, 5);
      expect(owner.username, 'xiaoli');
      expect(owner.name, '旅行达人小李');
      expect(owner.avatar, 'https://a.com/img.jpg');
    });

    test('avatar can be null', () {
      final json = {'id': 1, 'username': 'u', 'name': 'U', 'avatar': null};
      expect(PublicTravelOwner.fromJson(json).avatar, isNull);
    });
  });

  group('PublicTravel.fromJson', () {
    final baseJson = {
      'id': 10,
      'name': '东京7日游',
      'city': '东京,大阪',
      'startDate': '2026-04-01',
      'endDate': '2026-04-07',
      'viewCount': 1200,
      'owner': {'id': 5, 'username': 'xiaoli', 'name': '达人小李', 'avatar': null},
    };

    test('parses id, name, viewCount', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.id, 10);
      expect(t.name, '东京7日游');
      expect(t.viewCount, 1200);
    });

    test('splits city string into list', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.cities, ['东京', '大阪']);
    });

    test('parses startDate and endDate as DateTime', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.startDate, DateTime(2026, 4, 1));
      expect(t.endDate, DateTime(2026, 4, 7));
    });

    test('days returns correct count', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.days, 7); // endDate - startDate + 1
    });

    test('cityLabel joins cities with ·', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.cityLabel, '东京 · 大阪');
    });

    test('gradientIndex cycles by id % 4', () {
      final t = PublicTravel.fromJson(baseJson); // id=10, 10%4=2
      expect(t.gradientIndex, 2);
    });
  });
}

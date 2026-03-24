import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/amap_poi.dart';

void main() {
  group('AmapPoi.fromJson', () {
    test('解析完整 POI 响应', () {
      final json = {
        'id': 'B000A806R5',
        'name': '故宫博物院',
        'address': '景山前街4号',
        'location': '116.397026,39.917839',
        'type': '风景名胜;景点;景点',
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.id, 'B000A806R5');
      expect(poi.name, '故宫博物院');
      expect(poi.address, '景山前街4号');
      expect(poi.longitude, closeTo(116.397026, 0.000001));
      expect(poi.latitude, closeTo(39.917839, 0.000001));
      expect(poi.type, '风景名胜;景点;景点');
    });

    test('address 为空字符串时保留空字符串', () {
      final json = {
        'id': 'B001',
        'name': '某地',
        'address': '',
        'location': '116.0,39.0',
        'type': null,
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.address, '');
      expect(poi.type, isNull);
    });

    test('location 格式为 lng,lat', () {
      final json = {
        'id': 'X',
        'name': 'X',
        'address': 'X',
        'location': '120.5,30.2',
        'type': null,
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.longitude, closeTo(120.5, 0.001));
      expect(poi.latitude, closeTo(30.2, 0.001));
    });
  });
}

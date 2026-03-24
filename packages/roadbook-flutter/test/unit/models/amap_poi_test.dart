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

    test('address 字段缺失时回退为空字符串', () {
      final json = {
        'id': 'B002',
        'name': '某地',
        'location': '116.0,39.0',
        'type': null,
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.address, '');
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
      expect(poi.longitude, 120.5);
      expect(poi.latitude, 30.2);
    });

    test('location 为 null 时抛出 FormatException', () {
      final json = {
        'id': 'Y',
        'name': 'Y',
        'address': 'Y',
        'location': null,
        'type': null,
      };
      expect(() => AmapPoi.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('location 缺失时抛出 FormatException', () {
      final json = {
        'id': 'Z',
        'name': 'Z',
        'address': 'Z',
        'type': null,
      };
      expect(() => AmapPoi.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('location 格式错误（只有一段）时抛出 FormatException', () {
      final json = {
        'id': 'W',
        'name': 'W',
        'address': 'W',
        'location': '116.397026',
        'type': null,
      };
      expect(() => AmapPoi.fromJson(json), throwsA(isA<FormatException>()));
    });
  });

  group('AmapPoi.toJson', () {
    test('toJson 重组 location 为 lng,lat 格式', () {
      const poi = AmapPoi(
        id: 'B000A806R5',
        name: '故宫博物院',
        address: '景山前街4号',
        longitude: 116.397026,
        latitude: 39.917839,
        type: '风景名胜;景点;景点',
      );
      final json = poi.toJson();
      expect(json['id'], 'B000A806R5');
      expect(json['name'], '故宫博物院');
      expect(json['address'], '景山前街4号');
      expect(json['location'], '116.397026,39.917839');
      expect(json['type'], '风景名胜;景点;景点');
    });

    test('toJson type 为 null 时正确序列化', () {
      const poi = AmapPoi(
        id: 'B001',
        name: '某地',
        address: '',
        longitude: 116.0,
        latitude: 39.0,
      );
      final json = poi.toJson();
      expect(json['type'], isNull);
      expect(json['location'], '116.0,39.0');
    });
  });
}

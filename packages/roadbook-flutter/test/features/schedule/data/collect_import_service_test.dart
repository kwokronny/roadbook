// test/features/schedule/data/collect_import_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/data/collect_import_service.dart';

void main() {
  const tId = 42;

  // ─── AI mode ──────────────────────────────────────────────────────────────

  group('CollectImportService.parseAiJson', () {
    test('parses valid JSON array into ScheduleFormData list', () {
      const json = '''[
        {
          "name": "颐和园",
          "coordinate": "116.27,39.99",
          "address": "北京市海淀区",
          "notes": "著名皇家园林",
          "startTime": "2024-06-01 09:00:00"
        },
        {
          "name": "故宫",
          "coordinate": "116.40,39.92",
          "address": "北京市东城区",
          "isHotel": false
        }
      ]''';

      final result = CollectImportService.parseAiJson(json, tId: tId);

      expect(result.length, 2);
      expect(result[0].tId, tId);
      expect(result[0].name, '颐和园');
      expect(result[0].coordinate, '116.27,39.99');
      expect(result[0].address, '北京市海淀区');
      expect(result[0].notes, '著名皇家园林');
      expect(result[0].startTime, DateTime(2024, 6, 1, 9, 0, 0));
      expect(result[0].isHotel, isFalse);

      expect(result[1].name, '故宫');
      expect(result[1].startTime, isNull);
    });

    test('defaults coordinate to "0,0" and address to "" when missing', () {
      const json = '[{"name": "测试地点"}]';
      final result = CollectImportService.parseAiJson(json, tId: tId);
      expect(result[0].coordinate, '0,0');
      expect(result[0].address, '');
      expect(result[0].isHotel, isFalse);
    });

    test('ignores invalid startTime and treats as null', () {
      const json = '[{"name": "X", "startTime": "not-a-date"}]';
      final result = CollectImportService.parseAiJson(json, tId: tId);
      expect(result[0].startTime, isNull);
    });

    test('throws CollectImportException on invalid JSON', () {
      expect(
        () => CollectImportService.parseAiJson('not json', tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('throws CollectImportException when root is not an array', () {
      expect(
        () => CollectImportService.parseAiJson('{"name": "x"}', tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('returns empty list for empty array', () {
      final result = CollectImportService.parseAiJson('[]', tId: tId);
      expect(result, isEmpty);
    });
  });

  // ─── Dianping mode ────────────────────────────────────────────────────────

  group('CollectImportService.parseDianpingJson', () {
    const dianpingJson = '''
    {
      "records": [
        {
          "collectItemList": [
            {
              "title": "小龙坎",
              "image": "https://img.example.com/1.jpg",
              "favorCore": {"bizUuid": "abc-123"},
              "lng": 104.06,
              "lat": 30.67,
              "address": "成都市锦江区",
              "collectShare": {"content": "超好吃的火锅"}
            }
          ]
        }
      ]
    }
    ''';

    test('parses Dianping JSON into ScheduleFormData list', () {
      final result = CollectImportService.parseDianpingJson(dianpingJson, tId: tId);

      expect(result.length, 1);
      expect(result[0].tId, tId);
      expect(result[0].name, '小龙坎');
      expect(result[0].cover, 'https://img.example.com/1.jpg');
      expect(result[0].dianpingUUID, 'abc-123');
      expect(result[0].coordinate, '104.06,30.67');
      expect(result[0].address, '成都市锦江区');
      expect(result[0].notes, '====大众点评====\n超好吃的火锅');
      expect(result[0].isHotel, isFalse);
      expect(result[0].startTime, isNull);
    });

    test('throws CollectImportException on invalid JSON', () {
      expect(
        () => CollectImportService.parseDianpingJson('bad', tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('throws CollectImportException when collectItemList is missing', () {
      const noItems = '{"records": [{}]}';
      expect(
        () => CollectImportService.parseDianpingJson(noItems, tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('handles missing favorCore gracefully (dianpingUUID = null)', () {
      const json = '''
      {"records": [{"collectItemList": [
        {"title": "X", "lng": 1.0, "lat": 2.0, "address": "A",
         "collectShare": {"content": "note"}}
      ]}]}
      ''';
      final result = CollectImportService.parseDianpingJson(json, tId: tId);
      expect(result[0].dianpingUUID, isNull);
    });

    test('notes is null when collectShare is missing', () {
      const json = '''
      {"records": [{"collectItemList": [
        {"title": "X", "lng": 1.0, "lat": 2.0, "address": "A"}
      ]}]}
      ''';
      final result = CollectImportService.parseDianpingJson(json, tId: tId);
      expect(result[0].notes, isNull);
    });
  });
}

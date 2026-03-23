// test/features/schedule/data/schedule_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/data/schedule_repository.dart';

Map<String, dynamic> _schedJson({int id = 1}) => {
  'id': id,
  'tId': 10,
  'name': 'Place $id',
  'coordinate': '116.4,39.9',
  'address': '北京',
  'cover': null,
  'dianpingUUID': null,
  'isHotel': false,
  'startTime': '2024-06-01T09:00:00.000Z',
  'endTime': null,
  'screenshots': null,
  'notes': null,
};

void main() {
  group('ScheduleRepository', () {
    late Dio dio;
    late ScheduleRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      repo = ScheduleRepository(dio);
    });

    test('list returns parsed schedule list', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect((options.data as Map)['id'], 10);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: [_schedJson(id: 1), _schedJson(id: 2)],
          ));
        },
      ));

      final result = await repo.list(10);
      expect(result.length, 2);
      expect(result.first.id, 1);
    });

    test('add sends tId and returns saved schedule', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map;
          expect(body['tId'], 10);
          expect(body['name'], 'New Place');
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 99),
          ));
        },
      ));

      const form = ScheduleFormData(
        tId: 10,
        name: 'New Place',
        coordinate: '116.4,39.9',
        address: '北京',
        isHotel: false,
      );
      final s = await repo.add(form);
      expect(s.id, 99);
    });

    test('add formats startTime as "YYYY-MM-DD HH:mm:ss" for backend', () async {
      String? capturedStartTime;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedStartTime = (options.data as Map)['startTime'] as String?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(),
          ));
        },
      ));

      final form = ScheduleFormData(
        tId: 10,
        name: 'X',
        coordinate: '0,0',
        address: '',
        isHotel: false,
        startTime: DateTime(2024, 6, 1, 9, 0, 0),
      );
      await repo.add(form);
      expect(capturedStartTime, '2024-06-01 09:00:00');
    });

    test('update formats startTime as "YYYY-MM-DD HH:mm:ss" for backend', () async {
      String? capturedStartTime;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedStartTime = (options.data as Map)['startTime'] as String?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 5),
          ));
        },
      ));

      final form = ScheduleFormData(
        id: 5,
        tId: 10,
        name: 'X',
        coordinate: '0,0',
        address: '',
        isHotel: false,
        startTime: DateTime(2024, 6, 1, 9, 0, 0),
      );
      await repo.update(form);
      expect(capturedStartTime, '2024-06-01 09:00:00');
    });

    test('update sends id and returns updated schedule', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 5),
          ));
        },
      ));

      const form = ScheduleFormData(
        id: 5,
        tId: 10,
        name: 'Updated',
        coordinate: '116.4,39.9',
        address: '北京',
        isHotel: false,
      );
      await repo.update(form);
      expect(capturedId, 5);
    });

    test('remove sends id', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: null));
        },
      ));

      await repo.remove(42);
      expect(capturedId, 42);
    });

    test('clone sends id and returns cloned schedule', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect((options.data as Map)['id'], 7);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 88),
          ));
        },
      ));

      final s = await repo.clone(7);
      expect(s.id, 88);
    });
  });
}

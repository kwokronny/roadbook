// test/features/travel/data/travel_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/data/travel_repository.dart';

// Backend field names: public, city, Users, Schedules
Map<String, dynamic> _travelJson({int id = 1, String name = 'Trip A'}) => {
  'id': id,
  'name': name,
  'startDate': '2024-06-01',
  'endDate': '2024-06-05',
  'public': false,
  'city': '北京',
  'Users': [],
  'Schedules': [],
};

void main() {
  group('TravelRepository', () {
    late Dio dio;
    late TravelRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      repo = TravelRepository(dio);
    });

    test('page returns TravelPage with parsed travels and hasMore', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          expect(body['page'], 1);
          expect(body['pageSize'], 15);
          expect(body['name'], '');
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'record': [_travelJson(id: 1), _travelJson(id: 2)],
              'total': 20,
              'page': 1,
              'pageSize': 15,
            },
          ));
        },
      ));

      final result = await repo.page(page: 1, keyword: '');
      expect(result.travels.length, 2);
      expect(result.travels.first.name, 'Trip A');
      expect(result.hasMore, isTrue); // 2 < 20
    });

    test('page hasMore is false when all loaded', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'record': [_travelJson()],
              'total': 1,
              'page': 1,
              'pageSize': 15,
            },
          ));
        },
      ));

      final result = await repo.page(page: 1, keyword: '');
      expect(result.hasMore, isFalse);
    });

    test('page passes keyword as name param', () async {
      String? capturedName;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedName = (options.data as Map)['name'] as String;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'record': [], 'total': 0, 'page': 1, 'pageSize': 15},
          ));
        },
      ));

      await repo.page(page: 1, keyword: '上海');
      expect(capturedName, '上海');
    });

    test('save sends correct payload and returns Travel', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          expect(body['name'], 'New Trip');
          expect(body['public'], false);
          expect(body['city'], '深圳,广州');
          expect(body['startDate'], '2024-09-01 00:00:00');
          expect(body['endDate'], '2024-09-05 00:00:00');
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _travelJson(id: 99, name: 'New Trip'),
          ));
        },
      ));

      final travel = await repo.save(TravelFormData(
        name: 'New Trip',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 9, 5),
        isPublic: false,
        cities: ['深圳', '广州'],
      ));
      expect(travel.id, 99);
    });

    test('save throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': '保存失败'},
            ),
          ));
        },
      ));

      expect(
        () => repo.save(TravelFormData(
          name: 'x',
          startDate: DateTime(2024),
          endDate: DateTime(2024),
          isPublic: false,
          cities: [],
        )),
        throwsA(isA<String>()),
      );
    });

    test('save includes id when editing existing travel', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _travelJson(id: 5),
          ));
        },
      ));

      await repo.save(TravelFormData(
        id: 5,
        name: 'Edit Trip',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 9, 3),
        isPublic: false,
        cities: [],
      ));
      expect(capturedId, 5);
    });

    test('remove sends id and completes', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: null,
          ));
        },
      ));

      await repo.remove(42);
      expect(capturedId, 42);
    });

    test('page throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': '获取失败'},
            ),
          ));
        },
      ));

      expect(() => repo.page(page: 1, keyword: ''), throwsA(isA<String>()));
    });

    test('detail returns Travel', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect((options.data as Map)['id'], 5);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'id': 5,
              'name': 'Detail Trip',
              'startDate': '2024-06-01',
              'endDate': '2024-06-05',
              'public': false,
              'city': '北京',
              'Users': [],
            },
          ));
        },
      ));

      final travel = await repo.detail(5);
      expect(travel.id, 5);
      expect(travel.name, 'Detail Trip');
    });

    test('setRole sends correct payload', () async {
      Map<String, dynamic>? captured;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options.data as Map<String, dynamic>;
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: null));
        },
      ));

      await repo.setRole(10, userId: 3, role: 'edit');
      expect(captured?['id'], 10);
      expect(captured?['uid'], 3);
      expect(captured?['role'], 'edit');
    });

    test('invite returns token string', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: 'tok.jwt.abc'));
        },
      ));

      final token = await repo.invite(10);
      expect(token, 'tok.jwt.abc');
    });
  });
}

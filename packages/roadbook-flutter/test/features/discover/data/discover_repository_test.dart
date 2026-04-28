import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/discover/data/discover_repository.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DiscoverRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = DiscoverRepository(mockDio);
  });

  final ownerJson = {'id': 1, 'username': 'u', 'name': 'U', 'avatar': null};
  final travelJson = {
    'id': 1,
    'name': 'Trip',
    'city': '东京',
    'startDate': '2026-04-01',
    'endDate': '2026-04-03',
    'viewCount': 10,
    'owner': ownerJson,
  };

  test('discover returns DiscoverPage with hasMore=true when more exist', () async {
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          data: {'total': 50, 'list': [travelJson]},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final page = await repo.discover(page: 1);
    expect(page.travels.length, 1);
    expect(page.travels.first, isA<PublicTravel>());
    expect(page.hasMore, isTrue); // 1 loaded < 50 total
  });

  test('discover returns hasMore=false when all loaded', () async {
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          data: {'total': 1, 'list': [travelJson]},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final page = await repo.discover(page: 1);
    expect(page.hasMore, isFalse);
  });

  test('discover throws String on DioException', () async {
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'message': '获取失败'},
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ));

    expect(() => repo.discover(page: 1), throwsA(isA<String>()));
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/luggage/data/luggage_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late LuggageRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = LuggageRepository(mockDio);
    registerFallbackValue(RequestOptions(path: ''));
  });

  test('setEquip posts to /api/travel/equip/set with correct payload', () async {
    when(() => mockDio.post<dynamic>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              data: null,
              requestOptions: RequestOptions(path: ''),
              statusCode: 200,
            ));

    await expectLater(
        repo.setEquip(travelId: 5, equip: '[{"id":"c1"}]'), completes);

    final captured = verify(() => mockDio.post<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
        )).captured;
    expect(captured[0], '/api/travel/equip/set');
    expect((captured[1] as Map)['id'], 5);
    expect((captured[1] as Map)['equip'], '[{"id":"c1"}]');
  });

  test('setEquip throws the DioException message as a String', () async {
    when(() => mockDio.post<dynamic>(any(), data: any(named: 'data')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: ''),
      message: '网络错误',
    ));

    await expectLater(
        repo.setEquip(travelId: 1, equip: '[]'), throwsA('网络错误'));
  });

  test('setEquip throws fallback message when DioException has no message', () async {
    when(() => mockDio.post<dynamic>(any(), data: any(named: 'data')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: ''),
      // message is null
    ));

    await expectLater(
        repo.setEquip(travelId: 1, equip: '[]'), throwsA('保存行李清单失败'));
  });
}

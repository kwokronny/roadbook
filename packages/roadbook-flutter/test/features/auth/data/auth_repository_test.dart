// test/features/auth/data/auth_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/auth/data/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late Dio dio;
    late AuthRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      repo = AuthRepository(dio);
    });

    test('login sends MD5 password and parses AuthResult', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          // 密码不是明文
          expect(body['password'], isNot('pass123'));
          // MD5 始终为 32 位十六进制
          expect((body['password'] as String).length, 32);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'token': 'tok-abc',
              'user': {
                'id': 1,
                'username': 'alice',
                'avatar': null,
                'name': 'Alice'
              },
            },
          ));
        },
      ));

      final result = await repo.login('alice', 'pass123');
      expect(result.token, 'tok-abc');
      expect(result.user.username, 'alice');
      expect(result.user.name, 'Alice');
    });

    test('register sends MD5 password and parses AuthResult', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          expect((body['password'] as String).length, 32);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'token': 'tok-xyz',
              'user': {
                'id': 2,
                'username': 'bob',
                'avatar': null,
                'name': null
              },
            },
          ));
        },
      ));

      final result = await repo.register('bob', 'secret99');
      expect(result.token, 'tok-xyz');
      expect(result.user.id, 2);
    });

    test('login throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': '用户不存在或密码错误'},
            ),
          ));
        },
      ));

      expect(() => repo.login('x', 'y'), throwsA(isA<String>()));
    });

    test('register throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'message': '用户名已存在'},
            ),
          ));
        },
      ));

      expect(() => repo.register('existing', 'pass123'), throwsA(isA<String>()));
    });
  });
}

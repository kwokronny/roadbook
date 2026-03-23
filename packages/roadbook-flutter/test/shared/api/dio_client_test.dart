// test/shared/api/dio_client_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/api/dio_client.dart';

// 测试用假 token 提供器
String? _mockToken;

Dio buildTestDio(String baseUrl) =>
    DioClientFactory.create(baseUrl: baseUrl, tokenProvider: () => _mockToken);

void main() {
  group('DioClient interceptor', () {
    late Dio dio;

    setUp(() {
      _mockToken = null;
      dio = buildTestDio('http://localhost');
    });

    test('injects Authorization header when token is present', () async {
      _mockToken = 'test-token';
      RequestOptions? captured;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(DioException(requestOptions: options)); // 不真正发请求
        },
      ));

      try {
        await dio.post('/test');
      } catch (_) {}

      expect(captured?.headers['Authorization'], 'Bearer test-token');
    });

    test('does not inject Authorization when token is null', () async {
      _mockToken = null;
      RequestOptions? captured;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(DioException(requestOptions: options));
        },
      ));

      try {
        await dio.post('/test');
      } catch (_) {}

      expect(captured?.headers.containsKey('Authorization'), isFalse);
    });

    test('skipAuth extra skips token injection', () async {
      _mockToken = 'test-token';
      RequestOptions? captured;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(DioException(requestOptions: options));
        },
      ));

      try {
        await dio.post('/test', options: Options(extra: {'skipAuth': true}));
      } catch (_) {}

      expect(captured?.headers.containsKey('Authorization'), isFalse);
    });
  });
}

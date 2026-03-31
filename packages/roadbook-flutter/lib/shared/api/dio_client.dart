// lib/shared/api/dio_client.dart
import 'package:dio/dio.dart';

typedef TokenProvider = String? Function();
typedef OnUnauthorized = void Function();

abstract class DioClientFactory {
  /// [tokenProvider] 返回当前 token，null 时不注入 Authorization。
  /// [onUnauthorized] 收到 401 时调用（通常清空 token 并跳登录页）。
  static Dio create({
    required String baseUrl,
    required TokenProvider tokenProvider,
    OnUnauthorized? onUnauthorized,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    dio.interceptors.add(_AuthInterceptor(
      tokenProvider: tokenProvider,
      onUnauthorized: onUnauthorized,
    ));

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.tokenProvider, this.onUnauthorized});

  final TokenProvider tokenProvider;
  final OnUnauthorized? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = tokenProvider();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code != null && code != 200) {
        if (code == 401) onUnauthorized?.call();
        final msg = (data['msg'] ?? data['message'] ?? '请求失败').toString();
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            message: msg,
          ),
        );
        return;
      }
      if (data.containsKey('data')) {
        response.data = data['data'];
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}

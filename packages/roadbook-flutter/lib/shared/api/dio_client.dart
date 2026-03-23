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
    // 解包 { code, data, message } 结构
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      response.data = data['data'];
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

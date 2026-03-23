// lib/features/auth/data/auth_repository.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/user.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});
  final String token;
  final User user;
}

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  String _md5(String input) {
    final bytes = utf8.encode(input);
    return md5.convert(bytes).toString();
  }

  Future<AuthResult> login(String username, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'username': username, 'password': _md5(password)},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = res.data ?? (throw '登录失败');
      return AuthResult(
        token: data['token'] as String,
        user: User.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '登录失败';
    }
  }

  Future<AuthResult> register(String username, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {'username': username, 'password': _md5(password)},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = res.data ?? (throw '注册失败');
      return AuthResult(
        token: data['token'] as String,
        user: User.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '注册失败';
    }
  }
}

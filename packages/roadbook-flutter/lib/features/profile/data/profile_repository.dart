// lib/features/profile/data/profile_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/user.dart';

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  /// 更新昵称（name 字段）。返回更新后的 User。
  Future<User> updateName(String name) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userUpdate,
        data: {'name': name},
      );
      return User.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '更新失败';
    }
  }

  /// 上传头像图片，返回头像 URL 后更新 user 记录。返回更新后的 User。
  Future<User> uploadAvatar(File imageFile) async {
    try {
      // Step 1: 上传图片，拿到 URL
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });
      final uploadRes = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.upload,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final rawData = uploadRes.data!['data'];
      if (rawData is! List || rawData.isEmpty) {
        throw '上传失败：服务器响应格式错误';
      }
      final avatarUrl = rawData.first as String;

      // Step 2: 将 URL 写入 user 记录
      final updateRes = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userUpdate,
        data: {'avatar': avatarUrl},
      );
      return User.fromJson(updateRes.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '上传失败';
    }
  }
}

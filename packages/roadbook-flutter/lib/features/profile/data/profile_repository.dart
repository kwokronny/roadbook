// lib/features/profile/data/profile_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/upload_repository.dart';
import '../../../shared/models/user.dart';

class ProfileRepository {
  ProfileRepository(this._dio, this._upload);
  final Dio _dio;
  final UploadRepository _upload;

  /// Parse response body — handles both Map and String (JSON) responses.
  Map<String, dynamic>? _parseBody(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  /// 更新昵称（name 字段）。返回更新后的 User。
  Future<User> updateName(String name) async {
    try {
      // Update name
      final updateRes = await _dio.post(ApiEndpoints.userUpdate, data: {'name': name});
      // Try to get user from update response first
      final updateBody = _parseBody(updateRes.data);
      final updateData = updateBody?['data'];
      if (updateData is Map<String, dynamic>) {
        return User.fromJson(updateData);
      }
      // Fallback: re-fetch current user
      final detailRes = await _dio.post(ApiEndpoints.userDetail);
      final detailBody = _parseBody(detailRes.data);
      final detailData = detailBody?['data'];
      if (detailData is Map<String, dynamic>) {
        return User.fromJson(detailData);
      }
      throw '更新成功但无法获取用户信息';
    } on DioException catch (e) {
      final body = _parseBody(e.response?.data);
      throw body?['message'] as String? ?? '更新失败';
    }
  }

  /// 上传头像图片，返回新的 avatar URL。
  Future<String> uploadAvatar(File imageFile) async {
    try {
      // Step 1: 上传图片 (复用 UploadRepository)
      final urls = await _upload.upload([XFile(imageFile.path)]);
      if (urls.isEmpty) throw '上传失败';
      final avatarUrl = urls.first;

      // Step 2: 将 URL 写入 user 记录
      await _dio.post(ApiEndpoints.userUpdate, data: {'avatar': avatarUrl});

      return avatarUrl;
    } on DioException catch (e) {
      final body = _parseBody(e.response?.data);
      throw body?['message'] as String? ?? '上传失败';
    }
  }
}

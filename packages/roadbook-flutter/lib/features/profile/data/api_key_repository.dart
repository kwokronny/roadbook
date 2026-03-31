// lib/features/profile/data/api_key_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/api_key.dart';

class ApiKeyRepository {
  ApiKeyRepository(this._dio);
  final Dio _dio;

  Future<List<ApiKey>> list() async {
    try {
      final res = await _dio.post<dynamic>(ApiEndpoints.apiKeyList);
      final items = res.data as List<dynamic>;
      return items
          .map((e) => ApiKey.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.message ?? '获取 API Key 列表失败';
    }
  }

  /// 创建 API Key，返回包含完整 key 的对象（仅此一次可见）。
  Future<ApiKey> create(String name) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.apiKeyCreate,
        data: {'name': name},
      );
      return ApiKey.fromJson(res.data!);
    } on DioException catch (e) {
      throw e.message ?? '创建 API Key 失败';
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.post(ApiEndpoints.apiKeyRemove, data: {'id': id});
    } on DioException catch (e) {
      throw e.message ?? '删除 API Key 失败';
    }
  }
}

import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';

class LuggageRepository {
  LuggageRepository(this._dio);
  final Dio _dio;

  Future<void> setEquip({required int travelId, required String equip}) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.equipSet,
        data: {'id': travelId, 'equip': equip},
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['msg'] as String? ??
          (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          '保存行李清单失败';
      throw msg;
    }
  }
}

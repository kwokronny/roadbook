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
      throw e.message ?? '保存行李清单失败';
    }
  }
}

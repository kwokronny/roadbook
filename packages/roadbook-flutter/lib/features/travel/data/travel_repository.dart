// lib/features/travel/data/travel_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/travel.dart';

const _pageSize = 15;

class TravelPage {
  const TravelPage({required this.travels, required this.hasMore});
  final List<Travel> travels;
  final bool hasMore;
}

class TravelFormData {
  const TravelFormData({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isPublic,
    required this.cities,
  });
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;
  final List<String> cities;
}

class TravelRepository {
  TravelRepository(this._dio);
  final Dio _dio;

  Future<TravelPage> page({required int page, required String keyword}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelPage,
        data: {'page': page, 'pageSize': _pageSize, 'name': keyword},
      );
      final data = res.data!;
      final records = (data['record'] as List<dynamic>)
          .map((e) => Travel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = data['total'] as int;
      final loadedCount = (page - 1) * _pageSize + records.length;
      return TravelPage(travels: records, hasMore: loadedCount < total);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取旅程失败';
    }
  }

  Future<Travel> save(TravelFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelSave,
        data: {
          if (form.id != null) 'id': form.id,
          'name': form.name,
          'startDate': form.startDate.toIso8601String(),
          'endDate': form.endDate.toIso8601String(),
          'public': form.isPublic,
          'city': form.cities.join(','),
        },
      );
      return Travel.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '保存旅程失败';
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.travelRemove, data: {'id': id});
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '删除旅程失败';
    }
  }
}

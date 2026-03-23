// lib/features/schedule/data/schedule_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/schedule.dart';

class ScheduleFormData {
  const ScheduleFormData({
    this.id,
    required this.tId,
    required this.name,
    required this.coordinate,
    required this.address,
    required this.isHotel,
    this.startTime,
    this.endTime,
    this.cover,
    this.dianpingUUID,
    this.notes,
    this.screenshots,
  });

  final int? id;
  final int tId;
  final String name;
  final String coordinate;
  final String address;
  final bool isHotel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? cover;
  final String? dianpingUUID;
  final String? notes;
  final String? screenshots;

  Map<String, dynamic> toAddJson() => {
        'tId': tId,
        'name': name,
        'coordinate': coordinate,
        'address': address,
        'isHotel': isHotel,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        if (cover != null) 'cover': cover,
        if (dianpingUUID != null) 'dianpingUUID': dianpingUUID,
        if (notes != null) 'notes': notes,
        if (screenshots != null) 'screenshots': screenshots,
      };

  Map<String, dynamic> toUpdateJson() => {
        'id': id!,
        'name': name,
        'coordinate': coordinate,
        'address': address,
        'isHotel': isHotel,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'cover': cover,
        'dianpingUUID': dianpingUUID,
        'notes': notes,
        'screenshots': screenshots,
      };
}

class ScheduleRepository {
  ScheduleRepository(this._dio);
  final Dio _dio;

  Future<List<Schedule>> list(int travelId) async {
    try {
      final res = await _dio.post<List<dynamic>>(
        ApiEndpoints.scheduleList,
        data: {'id': travelId},
      );
      return (res.data ?? [])
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取行程失败';
    }
  }

  Future<Schedule> add(ScheduleFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleAdd,
        data: form.toAddJson(),
      );
      return Schedule.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '添加行程失败';
    }
  }

  Future<Schedule> update(ScheduleFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleUpdate,
        data: form.toUpdateJson(),
      );
      return Schedule.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '更新行程失败';
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.scheduleRemove, data: {'id': id});
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '删除行程失败';
    }
  }

  Future<Schedule> clone(int id) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleClone,
        data: {'id': id},
      );
      return Schedule.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '克隆行程失败';
    }
  }
}

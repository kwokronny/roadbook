// lib/features/schedule/data/schedule_repository.dart
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/schedule.dart';

// Backend requires "YYYY-MM-DD HH:mm:ss" (parameter@2.x dateTime format)
final _dateTimeFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

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
        if (startTime != null) 'startTime': _dateTimeFmt.format(startTime!),
        if (endTime != null) 'endTime': _dateTimeFmt.format(endTime!),
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
        // Explicitly send null to clear the field in DB when time is removed
        'startTime': startTime != null ? _dateTimeFmt.format(startTime!) : null,
        'endTime': endTime != null ? _dateTimeFmt.format(endTime!) : null,
        if (cover != null) 'cover': cover,
        if (dianpingUUID != null) 'dianpingUUID': dianpingUUID,
        if (notes != null) 'notes': notes,
        if (screenshots != null) 'screenshots': screenshots,
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
      final data = Map<String, dynamic>.from(res.data as Map);
      // Backend creates the record with omit(tId), so tId may be missing in response
      data['tId'] ??= form.tId;
      return Schedule.fromJson(data);
    } on DioException catch (e) {
      final msg = e.message ??
          (e.response?.data as Map?)?['msg'] as String? ??
          '添加行程失败';
      throw msg;
    }
  }

  Future<Schedule> update(ScheduleFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleUpdate,
        data: form.toUpdateJson(),
      );
      final data = Map<String, dynamic>.from(res.data as Map);
      data['tId'] ??= form.tId;
      return Schedule.fromJson(data);
    } on DioException catch (e) {
      final msg = e.message ??
          (e.response?.data as Map?)?['msg'] as String? ??
          '更新行程失败';
      throw msg;
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.scheduleRemove, data: {'id': id});
    } on DioException catch (e) {
      final msg = e.message ??
          (e.response?.data as Map?)?['msg'] as String? ??
          '删除行程失败';
      throw msg;
    }
  }

  Future<Schedule> clone(int id) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleClone,
        data: {'id': id},
      );
      final data = Map<String, dynamic>.from(res.data as Map);
      return Schedule.fromJson(data);
    } on DioException catch (e) {
      final msg = e.message ??
          (e.response?.data as Map?)?['msg'] as String? ??
          '克隆行程失败';
      throw msg;
    }
  }
}

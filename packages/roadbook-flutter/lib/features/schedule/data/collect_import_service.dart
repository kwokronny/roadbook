// lib/features/schedule/data/collect_import_service.dart
import 'dart:convert';
import 'schedule_repository.dart';

/// 解析/转换失败时抛出
class CollectImportException implements Exception {
  const CollectImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class CollectImportService {
  // ── AI 采集模式 ─────────────────────────────────────────────────────────────

  /// 解析 AI 生成的 JSON 数组，返回 [ScheduleFormData] 列表。
  static List<ScheduleFormData> parseAiJson(String json, {required int tId}) {
    late dynamic decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      throw const CollectImportException('JSON 格式错误，请检查输入内容');
    }
    if (decoded is! List) {
      throw const CollectImportException('JSON 必须是数组（以 [ 开头）');
    }

    return decoded.map((e) {
      final m = e as Map<String, dynamic>;
      final startTimeStr = m['startTime'] as String?;
      final startTime =
          startTimeStr != null ? DateTime.tryParse(startTimeStr) : null;
      return ScheduleFormData(
        tId: tId,
        name: (m['name'] as String?) ?? '',
        coordinate: (m['coordinate'] as String?) ?? '0,0',
        address: (m['address'] as String?) ?? '',
        isHotel: (m['isHotel'] as bool?) ?? false,
        startTime: startTime,
        endTime: null,
        cover: m['cover'] as String?,
        dianpingUUID: m['dianpingUUID'] as String?,
        notes: m['notes'] as String?,
        screenshots: m['screenshots'] as String?,
      );
    }).toList();
  }

  // ── 点评收藏模式 ───────────────────────────────────────────────────────────

  /// 解析大众点评收藏 JSON，返回 [ScheduleFormData] 列表。
  static List<ScheduleFormData> parseDianpingJson(String json, {required int tId}) {
    late dynamic decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      throw const CollectImportException('JSON 格式错误，请检查输入内容');
    }

    final records = (decoded as Map<String, dynamic>)['records'] as List<dynamic>?;
    final items = records?.firstOrNull != null
        ? (records!.first as Map<String, dynamic>)['collectItemList'] as List<dynamic>?
        : null;

    if (items == null) {
      throw const CollectImportException('未找到 collectItemList，请确认粘贴的是点评收藏 JSON');
    }

    return items.map((e) {
      final m = e as Map<String, dynamic>;
      final favorCore = m['favorCore'] as Map<String, dynamic>?;
      final collectShare = m['collectShare'] as Map<String, dynamic>?;
      final lng = m['lng'];
      final lat = m['lat'];
      final coordinate = '${lng ?? 0},${lat ?? 0}';
      final content = collectShare?['content'] as String?;

      return ScheduleFormData(
        tId: tId,
        name: (m['title'] as String?) ?? '',
        coordinate: coordinate,
        address: (m['address'] as String?) ?? '',
        isHotel: false,
        cover: m['image'] as String?,
        dianpingUUID: favorCore?['bizUuid'] as String?,
        notes: (content != null && content.isNotEmpty)
            ? '====大众点评====\n$content'
            : null,
      );
    }).toList();
  }
}

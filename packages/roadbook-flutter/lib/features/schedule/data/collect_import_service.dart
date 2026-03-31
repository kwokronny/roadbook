// lib/features/schedule/data/collect_import_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
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

  // ── 点评收藏 URL 模式 ──────────────────────────────────────────────────────

  /// 从点评分享文本中提取 albumId。
  /// 支持粘贴完整分享文本（如「【分享专辑：北京】作者：小肥 https://...」）。
  static String extractAlbumId(String text) {
    // 先从文本中提取 URL
    final urlMatch =
        RegExp(r'https?://[^\s]+').firstMatch(text.trim());
    final raw = urlMatch?.group(0) ?? text.trim();

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final albumId = uri.queryParameters['albumId'] ??
          uri.queryParameters['albumid'];
      if (albumId != null && albumId.isNotEmpty) return albumId;
    }
    // fallback: 正则匹配整段文本
    final match =
        RegExp(r'albumid=(\d+)', caseSensitive: false).firstMatch(text);
    if (match != null) return match.group(1)!;
    throw const CollectImportException('未找到 albumId，请确认粘贴的是点评收藏分享链接');
  }

  /// 通过点评 mapi 获取收藏专辑详情并解析为 [ScheduleFormData]。
  static Future<List<ScheduleFormData>> fetchDianpingAlbum(
    String shareUrl, {
    required int tId,
  }) async {
    final albumId = extractAlbumId(shareUrl);
    final apiUrl =
        'https://mapi.dianping.com/mapi/collect/getfavoralbumdetail.bin'
        '?nextstart=&type=0&albumid=$albumId&mapi_cacheType=0&';

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
    try {
      final res = await dio.get<dynamic>(apiUrl);
      final data = res.data;
      final json = data is String ? jsonDecode(data) : data;
      return parseDianpingJson(jsonEncode(json), tId: tId);
    } on DioException catch (e) {
      throw CollectImportException('请求点评接口失败: ${e.message ?? e.toString()}');
    } finally {
      dio.close();
    }
  }

  // ── 点评收藏 JSON 模式 ────────────────────────────────────────────────────

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

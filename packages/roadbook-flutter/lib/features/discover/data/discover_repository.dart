// lib/features/discover/data/discover_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/public_travel.dart';

const _pageSize = 20;

class DiscoverPage {
  const DiscoverPage({required this.travels, required this.hasMore});
  final List<PublicTravel> travels;
  final bool hasMore;
}

class DiscoverRepository {
  DiscoverRepository(this._dio);
  final Dio _dio;

  Future<DiscoverPage> discover({
    required int page,
    String? city,
    String? keyword,
  }) async {
    try {
      final data = <String, dynamic>{'page': page, 'pageSize': _pageSize};
      if (keyword != null && keyword.isNotEmpty) {
        data['keyword'] = keyword;
      } else if (city != null && city.isNotEmpty) {
        data['city'] = city;
      }
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelDiscover,
        data: data,
      );
      final body = res.data!;
      final total = body['total'] as int;
      final list = (body['list'] as List<dynamic>)
          .map((e) => PublicTravel.fromJson(e as Map<String, dynamic>))
          .toList();
      final loaded = (page - 1) * _pageSize + list.length;
      return DiscoverPage(travels: list, hasMore: loaded < total);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取失败';
    }
  }
}

// lib/shared/api/upload_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/dio_provider.dart';
import 'api_endpoints.dart';

class UploadRepository {
  UploadRepository(this._dio);
  final Dio _dio;

  /// Uploads [files] to POST /upload (multipart/form-data, field: 'file').
  /// Returns absolute URLs. Throws [String] on DioException.
  ///
  /// Note: _AuthInterceptor unwraps the {code, data} envelope on success,
  /// so response.data is already List<dynamic> here.
  /// In the error path the interceptor does NOT unwrap, so
  /// e.response?.data is still {code, message} — ['message'] extraction is correct.
  Future<List<String>> upload(List<XFile> files) async {
    try {
      final formData = FormData();
      for (final f in files) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(f.path, filename: f.name),
        ));
      }
      final res = await _dio.post<dynamic>(ApiEndpoints.upload, data: formData);
      final relativePaths = (res.data as List<dynamic>).cast<String>();
      final base = _dio.options.baseUrl.endsWith('/')
          ? _dio.options.baseUrl.substring(0, _dio.options.baseUrl.length - 1)
          : _dio.options.baseUrl;
      return relativePaths.map((p) => '$base$p').toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? data['msg']) as String? : null;
      throw msg ?? e.message ?? '上传失败';
    }
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.read(dioProvider));
});

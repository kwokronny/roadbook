// lib/shared/api/upload_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../providers/dio_provider.dart';
import 'api_endpoints.dart';

class UploadRepository {
  UploadRepository(this._dio);
  final Dio _dio;

  /// Max dimension (width or height) for compressed images.
  static const int _maxDimension = 1920;

  /// JPEG quality (0-100).
  static const int _quality = 80;

  /// File size threshold — only compress if larger than 500KB.
  static const int _compressThreshold = 500 * 1024;

  /// Compress an image file if it exceeds [_compressThreshold].
  /// Returns the original path if no compression needed or compression fails.
  Future<String> _compressIfNeeded(XFile file) async {
    final fileSize = await File(file.path).length();
    if (fileSize <= _compressThreshold) return file.path;

    final ext = p.extension(file.path).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png', '.heic', '.heif', '.webp'].contains(ext);
    if (!isImage) return file.path;

    try {
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        'upload_${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(file.path)}.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        quality: _quality,
      );

      return result?.path ?? file.path;
    } catch (_) {
      return file.path;
    }
  }

  /// Uploads [files] to POST /upload (multipart/form-data, field: 'file').
  /// Images are compressed before upload if they exceed 500KB.
  /// Returns absolute URLs. Throws [String] on DioException.
  Future<List<String>> upload(List<XFile> files) async {
    try {
      final formData = FormData();
      for (final f in files) {
        final compressedPath = await _compressIfNeeded(f);
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(compressedPath, filename: p.basename(compressedPath)),
        ));
      }
      final res = await _dio.post<dynamic>(ApiEndpoints.upload, data: formData);
      final resData = res.data;
      final List<dynamic> rawPaths;
      if (resData is List) {
        rawPaths = resData;
      } else if (resData is String) {
        rawPaths = [resData];
      } else {
        throw '上传返回格式异常: ${resData.runtimeType}';
      }
      final relativePaths = rawPaths.cast<String>();
      final base = _dio.options.baseUrl.endsWith('/')
          ? _dio.options.baseUrl.substring(0, _dio.options.baseUrl.length - 1)
          : _dio.options.baseUrl;
      return relativePaths.map((p) => '$base$p').toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? data['msg']) as String? : null;
      throw msg ?? e.message ?? '上传失败';
    } catch (e) {
      throw '上传失败: $e';
    }
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.read(dioProvider));
});

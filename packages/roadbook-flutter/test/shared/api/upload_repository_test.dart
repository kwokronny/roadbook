// test/shared/api/upload_repository_test.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadbook_flutter/shared/api/upload_repository.dart';

void main() {
  group('UploadRepository', () {
    late Dio dio;
    late UploadRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      repo = UploadRepository(dio);
    });

    test('upload single file returns one-element absolute URL list', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // _AuthInterceptor unwraps {code,data} envelope on success;
          // the interceptor mock delivers the unwrapped List<dynamic> directly.
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: ['/public/uploads/abc.jpg'],
          ));
        },
      ));

      final file = File('${Directory.systemTemp.path}/test.jpg')
        ..writeAsBytesSync([0xFF, 0xD8]);
      final urls = await repo.upload([XFile(file.path)]);
      expect(urls, ['http://localhost:3000/public/uploads/abc.jpg']);
      file.deleteSync();
    });

    test('upload multiple files returns absolute URL list for all files', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: ['/public/uploads/a.jpg', '/public/uploads/b.jpg'],
          ));
        },
      ));

      final f1 = File('${Directory.systemTemp.path}/t1.jpg')
        ..writeAsBytesSync([0xFF, 0xD8]);
      final f2 = File('${Directory.systemTemp.path}/t2.jpg')
        ..writeAsBytesSync([0xFF, 0xD8]);

      final urls = await repo.upload([XFile(f1.path), XFile(f2.path)]);
      expect(urls.length, 2);
      expect(urls[0], 'http://localhost:3000/public/uploads/a.jpg');
      expect(urls[1], 'http://localhost:3000/public/uploads/b.jpg');
      f1.deleteSync();
      f2.deleteSync();
    });

    test('strips trailing slash from baseUrl — no double-slash in result', () async {
      final dioWithSlash = Dio(BaseOptions(baseUrl: 'http://localhost:3000/'));
      final repoWithSlash = UploadRepository(dioWithSlash);
      dioWithSlash.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: ['/public/uploads/abc.jpg'],
          ));
        },
      ));

      final file = File('${Directory.systemTemp.path}/test2.jpg')
        ..writeAsBytesSync([0xFF, 0xD8]);
      final urls = await repoWithSlash.upload([XFile(file.path)]);
      expect(urls.first, 'http://localhost:3000/public/uploads/abc.jpg');
      file.deleteSync();
    });

    test('upload throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': '文件过大'},
            ),
          ));
        },
      ));

      final file = File('${Directory.systemTemp.path}/big.jpg')
        ..writeAsBytesSync([0xFF, 0xD8]);
      await expectLater(
        () => repo.upload([XFile(file.path)]),
        throwsA(isA<String>()),
      );
      file.deleteSync();
    });
  });
}

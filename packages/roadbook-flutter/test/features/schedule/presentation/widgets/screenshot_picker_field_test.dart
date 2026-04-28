// test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadbook_flutter/features/schedule/presentation/widgets/screenshot_picker_field.dart';
import 'package:roadbook_flutter/shared/api/upload_repository.dart';

// Minimal Dio stand-in — never called because upload() is overridden
class _FakeDio extends Fake implements Dio {}

// Fake repository: returns preset URLs immediately
class _FakeUploadRepository extends UploadRepository {
  _FakeUploadRepository(this._urls) : super(_FakeDio());
  final List<String> _urls;

  @override
  Future<List<String>> upload(List<XFile> files) async => _urls;
}

// Slow fake: completes only when caller calls complete()
class _SlowUploadRepository extends UploadRepository {
  _SlowUploadRepository(this._completer) : super(_FakeDio());
  final Completer<List<String>> _completer;

  @override
  Future<List<String>> upload(List<XFile> files) => _completer.future;
}

Widget _build({
  required List<String> value,
  required ValueChanged<List<String>> onChanged,
  int maxCount = 9,
  UploadRepository? uploadRepo,
}) {
  return ProviderScope(
    overrides: [
      if (uploadRepo != null)
        uploadRepositoryProvider.overrideWithValue(uploadRepo),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ScreenshotPickerField(
          value: value,
          onChanged: onChanged,
          maxCount: maxCount,
        ),
      ),
    ),
  );
}

void main() {
  group('ScreenshotPickerField', () {
    testWidgets('renders thumbnails for existing URLs', (tester) async {
      await tester.pumpWidget(_build(
        value: ['http://a.com/1.jpg', 'http://a.com/2.jpg'],
        onChanged: (_) {},
      ));

      expect(find.byType(Image), findsNWidgets(2));
      // "+" button visible (2 < maxCount 9)
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('hides + button when value.length == maxCount', (tester) async {
      final urls = List.generate(3, (i) => 'http://a.com/$i.jpg');
      await tester.pumpWidget(_build(
        value: urls,
        onChanged: (_) {},
        maxCount: 3,
      ));

      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('tapping × calls onChanged with item removed', (tester) async {
      final received = <List<String>>[];
      await tester.pumpWidget(_build(
        value: ['http://a.com/1.jpg', 'http://a.com/2.jpg'],
        onChanged: received.add,
      ));

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      expect(received.length, 1);
      expect(received.first, ['http://a.com/2.jpg']);
    });

    testWidgets('shows CircularProgressIndicator while upload is in progress',
        (tester) async {
      final completer = Completer<List<String>>();
      final slowRepo = _SlowUploadRepository(completer);

      await tester.pumpWidget(_build(
        value: [],
        onChanged: (_) {},
        uploadRepo: slowRepo,
      ));

      // Trigger upload directly (bypasses ImagePicker platform channel)
      final state = tester.state<ScreenshotPickerFieldState>(
          find.byType(ScreenshotPickerField));
      state.triggerUploadForTest([]);

      await tester.pump();

      // "+" replaced by CircularProgressIndicator during upload
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete upload
      completer.complete(['http://a.com/new.jpg']);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'onChanged called with appended URLs after upload completes',
        (tester) async {
      final received = <List<String>>[];
      final fakeRepo = _FakeUploadRepository(['http://a.com/uploaded.jpg']);

      await tester.pumpWidget(_build(
        value: ['http://a.com/existing.jpg'],
        onChanged: received.add,
        uploadRepo: fakeRepo,
      ));

      final state = tester.state<ScreenshotPickerFieldState>(
          find.byType(ScreenshotPickerField));
      await state.triggerUploadForTest([XFile('/fake/path.jpg')]);
      await tester.pump();

      expect(received.length, 1);
      expect(received.first,
          ['http://a.com/existing.jpg', 'http://a.com/uploaded.jpg']);
    });
  });
}

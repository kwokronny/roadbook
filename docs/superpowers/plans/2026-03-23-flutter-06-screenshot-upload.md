# Flutter Screenshot Upload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to upload multiple screenshots to a schedule item, display them as thumbnails in the edit sheet and on the schedule card.

**Architecture:** A shared `UploadRepository` handles `POST /upload` multipart requests and returns absolute URLs. A new `ScreenshotPickerField` widget manages picker + upload + display in a horizontal scroll row. `ScheduleEditSheet` holds `_screenshots` state and wires it through the widget; `ScheduleItem` replaces the count text with actual thumbnails.

**Tech Stack:** Flutter, Riverpod ^2.5 (manual), Dio ^5.4 (multipart FormData), image_picker (already in pubspec), flutter_test

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `lib/shared/api/upload_repository.dart` | **Create** | POST /upload, return absolute URLs |
| `lib/features/schedule/presentation/widgets/screenshot_picker_field.dart` | **Create** | Picker + upload + horizontal thumbnail UI |
| `lib/features/schedule/presentation/schedule_edit_sheet.dart` | **Modify** | Add `_screenshots` state + render ScreenshotPickerField |
| `lib/features/schedule/presentation/widgets/schedule_item.dart` | **Modify** | Replace count text with 42×42 thumbnail row |
| `test/shared/api/upload_repository_test.dart` | **Create** | Unit tests for upload |
| `test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart` | **Create** | Widget tests for picker field |
| `test/features/schedule/presentation/widgets/schedule_item_test.dart` | **Create** | Widget tests for thumbnail display |

---

## Task 1: UploadRepository

**Files:**
- Create: `lib/shared/api/upload_repository.dart`
- Test: `test/shared/api/upload_repository_test.dart`

`ApiEndpoints.upload = '/upload'` already exists in `lib/shared/api/api_endpoints.dart`.

- [ ] **Step 1: Write the failing tests**

Create `test/shared/api/upload_repository_test.dart`:

```dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter test test/shared/api/upload_repository_test.dart
```

Expected: FAIL — `upload_repository.dart` not found.

- [ ] **Step 3: Implement UploadRepository**

Create `lib/shared/api/upload_repository.dart`:

```dart
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
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '上传失败';
    }
  }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.read(dioProvider));
});
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/shared/api/upload_repository_test.dart
```

Expected: 4 tests pass.

- [ ] **Step 5: Run analyzer**

```bash
flutter analyze lib/shared/api/upload_repository.dart
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/shared/api/upload_repository.dart test/shared/api/upload_repository_test.dart
git commit -m "feat: add UploadRepository for POST /upload multipart"
```

---

## Task 2: ScheduleItem Thumbnail Display

**Files:**
- Modify: `lib/features/schedule/presentation/widgets/schedule_item.dart`
- Test: `test/features/schedule/presentation/widgets/schedule_item_test.dart`

Replace the `'N 张截图'` count text (the block starting with `// 截图数量` comment, lines 131–136) with a real thumbnail row.

- [ ] **Step 1: Write the failing tests**

Create `test/features/schedule/presentation/widgets/schedule_item_test.dart`:

```dart
// test/features/schedule/presentation/widgets/schedule_item_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/presentation/widgets/schedule_item.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

Schedule _makeSchedule({String? screenshots}) => Schedule(
      id: 1,
      tId: 1,
      name: 'Test Stop',
      coordinate: '0,0',
      address: 'Test Address',
      isHotel: false,
      screenshots: screenshots,
    );

void main() {
  group('ScheduleItem thumbnails', () {
    testWidgets('no thumbnails when screenshotList is empty', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScheduleItem(
            schedule: _makeSchedule(),
            onTap: () {},
          ),
        ),
      ));

      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('renders 3 thumbnails when screenshotList has 3 items',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScheduleItem(
            schedule: _makeSchedule(
                screenshots:
                    'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg'),
            onTap: () {},
          ),
        ),
      ));

      expect(find.byType(Image), findsNWidgets(3));
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('shows only 4 thumbnails and +N box when list has 6 items',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScheduleItem(
            schedule: _makeSchedule(
                screenshots:
                    'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg'
                    ',http://a.com/4.jpg,http://a.com/5.jpg,http://a.com/6.jpg'),
            onTap: () {},
          ),
        ),
      ));

      expect(find.byType(Image), findsNWidgets(4));
      expect(find.text('+2'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/schedule/presentation/widgets/schedule_item_test.dart
```

Expected: FAIL — still finds count text widgets, not `Image` widgets.

- [ ] **Step 3: Replace count text with thumbnail row**

In `lib/features/schedule/presentation/widgets/schedule_item.dart`, find and replace the entire screenshot count block:

```dart
                      // 截图数量（Plan 6 实现上传，此处仅展示数量）
                      if (schedule.screenshotList.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('${schedule.screenshotList.length} 张截图',
                            style: AppTextStyles.micro),
                      ],
```

with:

```dart
                      // 截图缩略图（最多 4 张，超出显示 +N）
                      if (schedule.screenshotList.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _ScreenshotThumbnails(urls: schedule.screenshotList),
                      ],
```

Then add the `_ScreenshotThumbnails` private widget at the bottom of the file, after the closing `}` of the `ScheduleItem` class (after `_hotelLabel()`'s closing `}`):

```dart
class _ScreenshotThumbnails extends StatelessWidget {
  const _ScreenshotThumbnails({required this.urls});
  final List<String> urls;

  static const _size = 42.0;
  static const _radius = 8.0;
  static const _gap = 6.0;
  static const _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    final visible = urls.take(_maxVisible).toList();
    final overflow = urls.length - _maxVisible;

    return Row(
      children: [
        for (final url in visible) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Image.network(
              url,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: _size,
                height: _size,
                color: AppColors.border,
                child: const Icon(Icons.broken_image_outlined,
                    size: 18, color: AppColors.textDisabled),
              ),
            ),
          ),
          const SizedBox(width: _gap),
        ],
        if (overflow > 0)
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Center(
              child: Text(
                '+$overflow',
                style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/schedule/presentation/widgets/schedule_item_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/schedule/presentation/widgets/schedule_item.dart \
        test/features/schedule/presentation/widgets/schedule_item_test.dart
git commit -m "feat: replace screenshot count text with thumbnail row in ScheduleItem"
```

---

## Task 3: ScreenshotPickerField Widget

**Files:**
- Create: `lib/features/schedule/presentation/widgets/screenshot_picker_field.dart`
- Test: `test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart`

Note: `ImagePicker.pickMultiImage()` requires a platform channel that is unavailable in widget tests. Tests for the "×" (delete) and maxCount-hiding behaviour do not require the picker. The upload flow (calling `onChanged` after upload) is verified via a `Completer`-based fake repository that lets us observe the async transition. The full end-to-end "tap + pick + upload" path is covered by manual/integration testing.

- [ ] **Step 1: Write the failing tests**

Create `test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart`:

```dart
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
```

**Important:** Tests 4 and 5 use `ScreenshotPickerFieldState.triggerUploadForTest()` — a test-only method you must expose in the implementation (see Step 3).

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart
```

Expected: FAIL — `screenshot_picker_field.dart` not found.

- [ ] **Step 3: Implement ScreenshotPickerField**

Create `lib/features/schedule/presentation/widgets/screenshot_picker_field.dart`:

```dart
// lib/features/schedule/presentation/widgets/screenshot_picker_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../../shared/api/upload_repository.dart';

class ScreenshotPickerField extends ConsumerStatefulWidget {
  const ScreenshotPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxCount = 9,
  });

  /// Current list of absolute screenshot URLs.
  final List<String> value;

  /// Called with the new list after upload or deletion.
  final ValueChanged<List<String>> onChanged;

  /// Maximum number of screenshots allowed. Default: 9.
  final int maxCount;

  @override
  ScreenshotPickerFieldState createState() => ScreenshotPickerFieldState();
}

// Public state class so widget tests can call triggerUploadForTest()
class ScreenshotPickerFieldState
    extends ConsumerState<ScreenshotPickerField> {
  bool _uploading = false;

  Future<void> _onAddTap() async {
    final remaining = widget.maxCount - widget.value.length;
    if (remaining <= 0) return;

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    await triggerUploadForTest(picked.take(remaining).toList());
  }

  /// Exposed for widget tests to trigger the upload flow directly,
  /// bypassing the ImagePicker platform channel.
  Future<void> triggerUploadForTest(List<XFile> files) async {
    setState(() => _uploading = true);
    try {
      final repo = ref.read(uploadRepositoryProvider);
      final newUrls = await repo.upload(files);
      widget.onChanged([...widget.value, ...newUrls]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _onRemoveTap(int index) {
    final updated = List<String>.from(widget.value)..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < widget.value.length; i++) ...[
            _Thumbnail(
              url: widget.value[i],
              onRemove: () => _onRemoveTap(i),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.value.length < widget.maxCount)
            _uploading
                ? const SizedBox(
                    width: 64,
                    height: 64,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                  )
                : _AddButton(onTap: _onAddTap),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.onRemove});
  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 64,
              height: 64,
              color: AppColors.border,
              child: const Icon(Icons.broken_image_outlined,
                  size: 24, color: AppColors.textDisabled),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 22, color: AppColors.textSecondary),
            const SizedBox(height: 2),
            Text('添加', style: AppTextStyles.micro),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart
```

Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/schedule/presentation/widgets/screenshot_picker_field.dart \
        test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart
git commit -m "feat: add ScreenshotPickerField widget with upload and delete"
```

---

## Task 4: Wire ScreenshotPickerField into ScheduleEditSheet

**Files:**
- Modify: `lib/features/schedule/presentation/schedule_edit_sheet.dart`

No new tests — integration is a wiring change; covered by existing widget tests.

- [ ] **Step 1: Add `_screenshots` state field**

In `lib/features/schedule/presentation/schedule_edit_sheet.dart`, add the field in `_ScheduleEditSheetState` after `bool _saving = false;`:

```dart
  late List<String> _screenshots;
```

- [ ] **Step 2: Initialize `_screenshots` in `initState`**

In `initState()`, insert immediately before the `if (s != null)` block (i.e., after the `_notesCtrl = TextEditingController(...)` line):

```dart
    _screenshots = s?.screenshotList ?? [];
```

- [ ] **Step 3: Add import for ScreenshotPickerField**

At the top of the file, after the existing imports, add:

```dart
import 'widgets/screenshot_picker_field.dart';
```

- [ ] **Step 4: Add ScreenshotPickerField to the form UI**

In the `build` method, find this block (the notes field followed by the day-grid label):

```dart
                  const SizedBox(height: 16),
                  // ── 天选择宫格
                  Text('出行天', style: AppTextStyles.cardTitle),
```

Replace it with:

```dart
                  const SizedBox(height: 16),
                  // ── 截图上传
                  Text('截图', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  ScreenshotPickerField(
                    value: _screenshots,
                    onChanged: (v) => setState(() => _screenshots = v),
                  ),
                  const SizedBox(height: 16),
                  // ── 天选择宫格
                  Text('出行天', style: AppTextStyles.cardTitle),
```

- [ ] **Step 5: Fix `_buildFormData()` to use `_screenshots`**

In `_buildFormData()`, find and replace:

```dart
      screenshots: widget.schedule?.screenshots,
```

with:

```dart
      screenshots: _screenshots.isEmpty ? null : _screenshots.join(','),
```

- [ ] **Step 6: Run analyzer**

```bash
flutter analyze lib/features/schedule/presentation/schedule_edit_sheet.dart
```

Expected: No issues found.

- [ ] **Step 7: Commit**

```bash
git add lib/features/schedule/presentation/schedule_edit_sheet.dart
git commit -m "feat: wire ScreenshotPickerField into ScheduleEditSheet"
```

---

## Task 5: Full Validation

**Files:** No new files.

- [ ] **Step 1: Run full analyzer**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: Run full test suite**

```bash
flutter test
```

Expected: All tests pass. Count should be ≥ 84 (74 existing + 4 upload_repository + 3 schedule_item + 5 screenshot_picker_field).

- [ ] **Step 3: Commit if any cleanup was needed**

```bash
git add -p
git commit -m "fix: address analyzer issues in screenshot upload"
```

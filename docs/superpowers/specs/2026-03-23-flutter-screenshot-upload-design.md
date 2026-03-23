# Flutter Screenshot Upload Design

## Goal

Allow users to attach multiple screenshots to a schedule item. Screenshots are selected from the device photo library, compressed, uploaded to the backend, and displayed as thumbnails in both the edit sheet and the schedule card.

## Context

- Backend: `POST /api/upload` — multipart/form-data, field name `file`, max 512 KB per file, returns array of relative URL strings (e.g. `/public/uploads/abc.webp`)
- Data model: `Schedule.screenshots` — comma-separated URL string, already parsed by `screenshotList` getter on the `Schedule` model
- `image_picker` already in pubspec; no new dependencies required
- Existing repositories throw `String` on error — this feature follows the same convention

---

## Architecture

### New Files

**`lib/shared/api/upload_repository.dart`**

Shared HTTP concern, not tied to any feature domain.

```dart
class UploadRepository {
  UploadRepository(this._dio);
  final Dio _dio;

  /// Uploads [files] to POST /api/upload.
  /// Returns absolute URLs by prepending Dio baseUrl to each relative path.
  /// Throws [String] on DioException.
  Future<List<String>> upload(List<XFile> files) async { ... }
}

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return UploadRepository(ref.read(dioProvider));
});
```

- Constructs `MultipartFile` from each `XFile`, posts as `FormData`
- Response data is `List<dynamic>` of relative paths; prepend `_dio.options.baseUrl` to form absolute URLs
- On `DioException`: extract `response.data['message']` or fall back to `'上传失败'`

**`lib/features/schedule/presentation/widgets/screenshot_picker_field.dart`**

Self-contained stateful widget. Pure UI + upload orchestration; no Riverpod state.

```dart
class ScreenshotPickerField extends ConsumerStatefulWidget {
  const ScreenshotPickerField({
    super.key,
    required this.value,       // current URL list
    required this.onChanged,   // called with new URL list after upload or delete
    this.maxCount = 9,
  });

  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final int maxCount;
}
```

Internal state: `bool _uploading` — disables "+" during upload, shows `CircularProgressIndicator` in its place.

Upload flow:
1. `ImagePicker().pickMultiImage(imageQuality: 80)`
2. Clamp selection to `maxCount - value.length` remaining slots
3. Call `ref.read(uploadRepositoryProvider).upload(picked)`
4. `onChanged(value + newUrls)`
5. On error: show `SnackBar` with error message

UI layout: `SingleChildScrollView(scrollDirection: Axis.horizontal)` → `Row` with:
- For each URL: 64×64 `Stack` — `Image.network` (cover fit, 8dp radius) with `errorBuilder` placeholder + top-right × `IconButton`
- At end (when `value.length < maxCount`): 64×64 dashed border "+" box (or loading indicator when `_uploading`)

### Modified Files

**`lib/features/schedule/presentation/schedule_edit_sheet.dart`**

Add `List<String> _screenshots` to form state:
- Initialize: `widget.schedule?.screenshotList ?? []`
- Render `ScreenshotPickerField(value: _screenshots, onChanged: (v) => setState(() => _screenshots = v))`
- On submit: `ScheduleFormData(... screenshots: _screenshots.isEmpty ? null : _screenshots.join(','))`

**`lib/features/schedule/presentation/widgets/schedule_item.dart`**

Replace the existing `'N 张截图'` text with thumbnail row:
- `screenshotList.take(4)` → 42×42 `Image.network` widgets, 8dp radius, 6dp gap
- If `screenshotList.length > 4`: append a 42×42 grey box showing `+N`
- Entire thumbnail row only rendered when `screenshotList.isNotEmpty`

---

## Data Flow

```
User taps "+"
  → ImagePicker (gallery, imageQuality: 80)
  → UploadRepository.upload(files)       # POST /api/upload multipart
  → List<String> absoluteUrls
  → onChanged(_screenshots + absoluteUrls)
  → setState in ScheduleEditSheet
  → ScreenshotPickerField re-renders with new thumbnails

User taps "×" on thumbnail
  → onChanged(_screenshots..removeAt(i))
  → setState in ScheduleEditSheet

User saves schedule
  → ScheduleFormData(screenshots: _screenshots.join(','))
  → ScheduleRepository.add/edit(form)    # existing API
```

---

## Error Handling

| Scenario | Behavior |
|---|---|
| Upload fails (network / 500) | SnackBar with error string; `_uploading` reset to false |
| Image too large (>512 KB after compression) | Backend returns 413; caught as DioException, shown in SnackBar |
| `Image.network` load fails | `errorBuilder` shows grey placeholder icon |
| No images selected (picker cancelled) | No-op |

---

## Testing

### `test/shared/api/upload_repository_test.dart`

Uses Dio interceptor mock (same pattern as `travel_repository_test.dart`):

- `upload` success → returns absolute URL list (base URL prepended)
- `upload` DioException → throws `String`

### `test/features/schedule/presentation/widgets/screenshot_picker_field_test.dart`

Widget tests with mock `UploadRepository` via `ProviderScope` override:

- Renders existing URLs as thumbnails
- Hides "+" when `value.length == maxCount`
- Tapping × calls `onChanged` with item removed
- Tapping "+" with mock upload → calls `onChanged` with appended URLs
- Shows loading indicator during upload (`_uploading = true`)

### `test/features/schedule/presentation/widgets/schedule_item_test.dart`

- No thumbnails rendered when `screenshotList` is empty
- Up to 4 thumbnails rendered; 5th+ shown as `+N` box

---

## Constraints

- Max 9 screenshots per schedule item (enforced client-side in `ScreenshotPickerField`)
- `imageQuality: 80` JPEG compression via `image_picker` (no extra dependency)
- URL storage format unchanged: comma-separated relative or absolute URLs in `Schedule.screenshots`
- `UploadRepository` is placed in `lib/shared/` — available for future features (e.g. user avatar upload)

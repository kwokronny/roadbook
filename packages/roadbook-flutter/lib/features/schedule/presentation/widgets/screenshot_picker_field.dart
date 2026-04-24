// lib/features/schedule/presentation/widgets/screenshot_picker_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';

import '../../../../shared/api/upload_repository.dart';
import '../../../../shared/widgets/app_toast.dart';

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
      if (mounted) AppToast.error(context, e.toString());
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
            const Icon(Icons.add, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: 2),
            Text('添加', style: AppTextStyles.micro),
          ],
        ),
      ),
    );
  }
}

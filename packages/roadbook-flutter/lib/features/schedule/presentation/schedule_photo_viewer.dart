// lib/features/schedule/presentation/schedule_photo_viewer.dart
import 'package:flutter/material.dart';

class SchedulePhotoViewer extends StatefulWidget {
  const SchedulePhotoViewer({
    super.key,
    required this.urls,
    required this.scheduleName,
    required this.initialIndex,
  });

  final List<String> urls;
  final String scheduleName;
  final int initialIndex;

  static Future<void> show(
    BuildContext context, {
    required List<String> urls,
    required String scheduleName,
    required int initialIndex,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: true,
      builder: (_) => SchedulePhotoViewer(
        urls: urls,
        scheduleName: scheduleName,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<SchedulePhotoViewer> createState() => _SchedulePhotoViewerState();
}

class _SchedulePhotoViewerState extends State<SchedulePhotoViewer> {
  late final PageController _pageCtrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main PageView
          PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Center(
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white54)),
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.scheduleName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_current + 1} / ${widget.urls.length}',
                    style: const TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Left/right arrows
          if (widget.urls.length > 1) ...[
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_left,
                  onTap: _current > 0
                      ? () => _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut)
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_right,
                  onTap: _current < widget.urls.length - 1
                      ? () => _pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut)
                      : null,
                ),
              ),
            ),
          ],

          // Bottom filmstrip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(widget.urls.length, (i) {
                      final isActive = i == _current;
                      return GestureDetector(
                        onTap: () => _pageCtrl.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isActive ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.network(
                              widget.urls[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const ColoredBox(
                                color: Colors.white12,
                                child: Icon(Icons.broken_image_outlined,
                                    color: Colors.white38, size: 14),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.3,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, color: Colors.white, size: 20)),
        ),
      ),
    );
  }
}

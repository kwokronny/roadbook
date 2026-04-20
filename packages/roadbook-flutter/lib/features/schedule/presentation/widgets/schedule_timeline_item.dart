// lib/features/schedule/presentation/widgets/schedule_timeline_item.dart
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/widgets/glass_popover.dart';
import '../schedule_photo_viewer.dart';
import 'schedule_nav_button.dart';

class ScheduleTimelineItem extends StatelessWidget {
  const ScheduleTimelineItem({
    super.key,
    required this.schedule,
    required this.travelStartDate,
    required this.canEdit,
    this.displayDay,
    this.onEditTimeTap,
    this.onEdit,
    this.onClone,
    this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onToggleSelect,
  });

  final Schedule schedule;
  final DateTime travelStartDate;
  final bool canEdit;
  final int? displayDay;
  final VoidCallback? onEditTimeTap;
  final VoidCallback? onEdit;
  final VoidCallback? onClone;
  final VoidCallback? onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleSelect;

  static const _maxThumbs = 4;
  static final _timeFmt = DateFormat('HH:mm');

  int? get _checkInDay {
    if (!schedule.isHotel || schedule.startTime == null) return null;
    return schedule.startTime!.toLocal().difference(travelStartDate).inDays + 1;
  }

  int? get _checkOutDay {
    if (!schedule.isHotel || schedule.endTime == null) return null;
    return schedule.endTime!.toLocal().difference(travelStartDate).inDays + 1;
  }

  String get _timeLabel {
    if (displayDay == 0) return '待规划';
    if (schedule.isHotel) {
      final d = displayDay;
      if (d != null && d > 0) {
        if (d == _checkInDay && schedule.startTime != null) {
          return '入住 ${_timeFmt.format(schedule.startTime!.toLocal())}';
        }
        if (d == _checkOutDay && schedule.endTime != null) {
          return '退房 ${_timeFmt.format(schedule.endTime!.toLocal())}';
        }
      }
      return '住宿';
    }
    if (schedule.startTime == null) return '待规划';
    return _timeFmt.format(schedule.startTime!.toLocal());
  }

  Color get _accentColor {
    if (displayDay == 0) return AppColors.inkTertiary;
    if (schedule.isHotel) return AppColors.lavender;
    if (schedule.startTime == null) return AppColors.inkTertiary;
    return AppColors.primary;
  }

  Color get _timeBadgeBg {
    if (displayDay == 0) return const Color(0x0D1C1C1E); // neutral
    if (schedule.isHotel) return AppColors.lavenderTimeBg;
    if (schedule.startTime == null) return const Color(0x0D1C1C1E);
    return AppColors.coralTint;
  }

  Color get _timeBadgeText {
    if (displayDay == 0) return AppColors.inkTertiary;
    if (schedule.isHotel) return AppColors.lavenderDeep;
    if (schedule.startTime == null) return AppColors.inkTertiary;
    return const Color(0xFFD4410A); // coral dark
  }

  bool get _hasCoordinate =>
      schedule.coordinate.isNotEmpty && schedule.coordinate != '0,0';

  bool get _hasExtras =>
      (schedule.notes != null && schedule.notes!.isNotEmpty) ||
      schedule.screenshotList.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionMode ? onToggleSelect : null,
      onLongPress: canEdit && !isSelectionMode ? onLongPress : null,
      child: Padding(
        padding: EdgeInsets.only(bottom: isSelectionMode ? 10 : 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox (if in selection mode)
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(top: 14, right: 8),
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.inkTertiary, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            // ── Card (glass for all variants)
            Expanded(
              child: _buildCardBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    final isHotel = schedule.isHotel;
    final nameColor = isHotel ? AppColors.lavenderDeep : AppColors.inkPrimary;
    final addrColor = isHotel ? AppColors.lavenderAddr : AppColors.inkTertiary;
    final noteColor = AppColors.inkSecondary;
    final moreColor = isHotel ? AppColors.lavender : AppColors.inkTertiary;

    final hasNotes = schedule.notes != null && schedule.notes!.isNotEmpty;
    final hasPhotos = schedule.screenshotList.isNotEmpty;
    final hasLower = !isSelectionMode && (hasNotes || hasPhotos);

    // ── Upper card: glass card with cover, time+more row, title, address, nav
    final upperContent = Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoverImage(schedule: schedule),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Time badge + More button row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: canEdit ? onEditTimeTap : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _timeBadgeBg,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_timeLabel,
                                    style: TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.w500, color: _timeBadgeText)),
                                if (canEdit) ...[
                                  const SizedBox(width: 3),
                                  Icon(Icons.edit_calendar_outlined,
                                      size: 11, color: _timeBadgeText),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (canEdit && !isSelectionMode)
                          _MoreIconButton(
                            onEdit: onEdit,
                            onClone: onClone,
                            onDelete: onDelete,
                            color: moreColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(schedule.name,
                        style: TextStyle(fontSize: 17,
                            fontWeight: FontWeight.w500, color: nameColor),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    ...[
                      const SizedBox(height: 1),
                      Text(schedule.address.isNotEmpty ? schedule.address : '暂无地址信息',
                          style: TextStyle(fontSize: 13, color: addrColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // ── Nav button: full width, outside the cover+body row
          if (_hasCoordinate && !isSelectionMode) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ScheduleNavButton(
                  coordinate: schedule.coordinate,
                  name: schedule.name,
                  isHotel: schedule.isHotel),
            ),
          ],
        ],
      ),
    );

    // ── Upper card widget (glass for all, with lavender tint for hotel)
    final upperRadius = hasLower
        ? const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.card),
            topRight: Radius.circular(AppRadius.card),
          )
        : BorderRadius.circular(AppRadius.card);

    // Build upper card manually to control border radius per lower-section state.
    // Shadow lives on the outer DecoratedBox so ClipRRect doesn't cut it off.
    final Widget upperCardWrapped = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: upperRadius,
        boxShadow: GlassSpec.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: upperRadius,
        child: BackdropFilter(
          filter: GlassSpec.cardBlur,
          child: Container(
            decoration: BoxDecoration(
              color: GlassSpec.cardBg,
              borderRadius: upperRadius,
              border: Border.all(
                color: isHotel ? AppColors.lavenderFrostBorder : GlassSpec.cardBorder,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Tint overlay for hotel
                if (isHotel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: upperRadius,
                        gradient: LinearGradient(
                          begin: const Alignment(-0.5, -0.5),
                          end: const Alignment(0.5, 0.5),
                          colors: [
                            AppColors.lavenderFrost,
                            AppColors.lavenderFrost.withValues(alpha: AppColors.lavenderFrost.a * 0.33),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Specular highlight
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: upperRadius,
                        gradient: GlassSpec.specularHighlight,
                      ),
                    ),
                  ),
                ),
                // Content
                upperContent,
              ],
            ),
          ),
        ),
      ),
    );

    // ── Lower section: photos + notes
    Widget? lowerSection;
    if (hasLower) {
      final lowerBg = isHotel
          ? const Color(0x098C5CF6) // lavender subtle
          : const Color(0x091C1C1E); // neutral subtle
      const lowerRadius = BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );

      lowerSection = Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0C8), // 顶部：浓暖黄
              Color(0xFFFFF8E7), // 底部：便利贴浅色
            ],
          ),
          borderRadius: lowerRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPhotos) ...[
              _buildScreenshots(context),
              if (hasNotes) const SizedBox(height: 8),
            ],
            if (hasNotes)
              Text(
                schedule.notes!,
                style: TextStyle(fontSize: 13, color: noteColor, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        upperCardWrapped,
        if (lowerSection != null) lowerSection,
      ],
    );
  }

  Widget _buildScreenshots(BuildContext context) {
    final urls = schedule.screenshotList;
    final visible = urls.take(_maxThumbs).toList();
    final overflow = urls.length - _maxThumbs;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < visible.length; i++)
          GestureDetector(
            onTap: () => SchedulePhotoViewer.show(
              context,
              urls: urls,
              scheduleName: schedule.name,
              initialIndex: i,
            ),
            child: ClipRRect(
              key: const Key('screenshotThumb'),
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                visible[i],
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: const Color(0x0D1C1C1E),
                  child: const Icon(Icons.broken_image_outlined,
                      size: 14, color: AppColors.inkTertiary),
                ),
              ),
            ),
          ),
        if (overflow > 0)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x0D1C1C1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('+$overflow',
                  style: AppTextStyles.micro
                      .copyWith(fontWeight: FontWeight.w500)),
            ),
          ),
      ],
    );
  }
}

// ─── More Icon Button (borderless, inline with time row) ────────────────────

enum _MenuAction { edit, clone, delete }

class _MoreIconButton extends StatelessWidget {
  const _MoreIconButton({this.onEdit, this.onClone, this.onDelete, required this.color});
  final VoidCallback? onEdit;
  final VoidCallback? onClone;
  final VoidCallback? onDelete;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
      return GestureDetector(
        onTap: () {
          final box = ctx.findRenderObject() as RenderBox;
          final pos = box.localToGlobal(Offset.zero);
          showGlassPopover(
            context: ctx,
            position: RelativeRect.fromLTRB(
                pos.dx, pos.dy + 20,
                MediaQuery.of(ctx).size.width - pos.dx - box.size.width, 0),
            items: [
              PopoverItem(icon: Icons.edit_outlined, label: '编辑', onTap: () => onEdit?.call()),
              PopoverItem(icon: Icons.copy_outlined, label: '克隆', onTap: () => onClone?.call()),
              PopoverItem(icon: Icons.delete_outline, label: '删除', isDestructive: true,
                  onTap: () => onDelete?.call()),
            ],
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.more_horiz, size: 16, color: color),
        ),
      );
    });
  }
}

// ─── Dashed Line Painter ─────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Dark line (inset shadow — top)
    final darkPaint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Light line (highlight — bottom, 0.5px offset)
    final lightPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), darkPaint);
      canvas.drawLine(Offset(x, 1), Offset(x + dashWidth, 1), lightPaint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Cover Image (48x48) ─────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.schedule});
  final Schedule schedule;

  Color get _bg {
    if (schedule.isHotel) return AppColors.lavenderTint;
    if (schedule.startTime == null) return const Color(0x0A1C1C1E); // neutral
    return const Color(0x14FF6B3D); // rgba(255,107,61,0.08)
  }

  Color get _border {
    if (schedule.isHotel) return const Color(0x268C5CF6); // rgba(140,92,246,0.15)
    if (schedule.startTime == null) return const Color(0x0F1C1C1E); // rgba(28,28,30,0.06)
    return const Color(0x1FFF6B3D); // rgba(255,107,61,0.12)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _bg,
        border: Border.all(color: _border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: schedule.cover != null && schedule.cover!.isNotEmpty
            ? Image.network(
                schedule.cover!,
                width: 48, height: 48, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _DefaultIcon(schedule: schedule),
              )
            : _DefaultIcon(schedule: schedule),
      ),
    );
  }
}

class _DefaultIcon extends StatelessWidget {
  const _DefaultIcon({required this.schedule});
  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        schedule.isHotel ? '🏨' : '📍',
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}

// ── Subtle noise texture overlay ────────────────────────────────────────────

class _NoisePainter extends CustomPainter {
  static final _rng = math.Random(42);
  static const _density = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x0A000000);
    const step = 4.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if (_rng.nextDouble() < _density) {
          canvas.drawCircle(Offset(x, y), 0.6, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) => false;
}

// ── Expandable note box ─────────────────────────────────────────────────────

class _ExpandableNote extends StatefulWidget {
  const _ExpandableNote({
    required this.text,
    required this.isDark,
    required this.noteColor,
  });
  final String text;
  final bool isDark;
  final Color noteColor;

  @override
  State<_ExpandableNote> createState() => _ExpandableNoteState();
}

class _ExpandableNoteState extends State<_ExpandableNote> {
  bool _expanded = false;
  bool _overflows = false;

  final _textStyle = const TextStyle(
      fontSize: 14, fontStyle: FontStyle.italic, height: 1.5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: _textStyle),
      maxLines: 2,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: (context.size?.width ?? 300) - 28); // minus padding
    if (mounted && tp.didExceedMaxLines != _overflows) {
      setState(() => _overflows = tp.didExceedMaxLines);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, 12, 14, _overflows ? 8 : 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0x1AFFFFFF)
            : const Color(0xFFEDE5D8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: Text(widget.text,
                style: _textStyle.copyWith(color: widget.noteColor),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            secondChild: Text(widget.text,
                style: _textStyle.copyWith(color: widget.noteColor)),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (_overflows) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? '收起' : '展开',
                    style: TextStyle(
                        fontSize: 13, color: widget.noteColor.withValues(alpha: 0.5)),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: widget.noteColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// lib/features/travel/presentation/widgets/travel_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';
import '../../../../shared/widgets/glass_popover.dart';

// ─── Status helpers ─────────────────────────────────────────────────────────

TravelStatusType computeTravelStatus(DateTime start, DateTime end) {
  final now = DateTime.now();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay   = DateTime(end.year,   end.month,   end.day);
  final today    = DateTime(now.year,   now.month,   now.day);

  if (!today.isBefore(startDay) && !today.isAfter(endDay)) return TravelStatusType.ongoing;
  if (today.isAfter(endDay))                                return TravelStatusType.ended;
  final daysUntil = startDay.difference(today).inDays;
  return daysUntil <= 7 ? TravelStatusType.upcoming : TravelStatusType.planning;
}

String _labelFor(TravelStatusType status) => switch (status) {
  TravelStatusType.ongoing  => '旅行中',
  TravelStatusType.upcoming => '即将出发',
  TravelStatusType.planning => '规划中',
  TravelStatusType.ended    => '已结束',
};

// ─── Status-based gradient specs ────────────────────────────────────────────

class _StatusGradientSpec {
  const _StatusGradientSpec({
    required this.gradient,
    required this.borderColor,
    this.shadow,
    this.hasAccentBar = false,
    this.opacity = 1.0,
  });

  final LinearGradient gradient;
  final Color borderColor;
  final BoxShadow? shadow;
  final bool hasAccentBar;
  final double opacity;

  static _StatusGradientSpec forStatus(TravelStatusType status) => switch (status) {
    TravelStatusType.ongoing => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x00FF6B3D), Color(0x14FF6B3D)], // transparent → coral 8%
      ),
      borderColor: Color(0x40FFFFFF), // subtle white border, no colored outline
    ),
    TravelStatusType.upcoming => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x008C5CF6), Color(0x0F8C5CF6)], // transparent → lavender 6%
      ),
      borderColor: Color(0x40FFFFFF), // subtle white border
    ),
    TravelStatusType.planning => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x008C5CF6), Color(0x0A8C5CF6)], // transparent → lavender 4%
      ),
      borderColor: Color(0x40FFFFFF), // subtle white border
    ),
    TravelStatusType.ended => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x001C1C1E), Color(0x081C1C1E)], // transparent → ink 3%
      ),
      borderColor: Color(0x33FFFFFF), // even subtler for ended
      opacity: 0.75,
    ),
  };
}

// ─── TravelCard V2 ──────────────────────────────────────────────────────────

class TravelCard extends StatelessWidget {
  const TravelCard({
    super.key,
    required this.travel,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.luggageChecked = 0,
    this.luggageTotal = 0,
  });

  final Travel travel;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int luggageChecked;
  final int luggageTotal;

  @override
  Widget build(BuildContext context) {
    final status = computeTravelStatus(travel.startDate, travel.endDate);
    final spec   = _StatusGradientSpec.forStatus(status);
    final days   = travel.endDate.difference(travel.startDate).inDays + 1;
    final people = travel.collaborators.length;
    final fmt    = DateFormat('MM/dd');

    // Arc progress: ongoing = day progress (purple), planning/upcoming = luggage (coral)
    double? arcProgress;
    Color? arcColor;
    String? arcStartLabel;
    String? arcEndLabel;
    String? arcProgressLabel;
    String? arcStartEmoji; // only for planning (luggage)
    if (status == TravelStatusType.ongoing) {
      final elapsed = DateTime.now().difference(travel.startDate).inDays + 1;
      arcProgress = (elapsed / days).clamp(0.0, 1.0);
      arcColor = AppColors.lavender;
      arcStartLabel = fmt.format(travel.startDate);
      arcEndLabel = fmt.format(travel.endDate);
      arcProgressLabel = 'Day $elapsed';
    } else if (status == TravelStatusType.planning || status == TravelStatusType.upcoming) {
      if (luggageTotal > 0) {
        arcProgress = (luggageChecked / luggageTotal).clamp(0.0, 1.0);
        arcColor = AppColors.lavender;
        arcStartEmoji = '🧳';
        arcStartLabel = fmt.format(travel.startDate);
        arcEndLabel = fmt.format(travel.endDate);
        arcProgressLabel = '准备中';
      }
    } else if (status == TravelStatusType.ended) {
      arcProgress = 1.0;
      arcColor = AppColors.inkTertiary;
      arcStartLabel = fmt.format(travel.startDate);
      arcEndLabel = fmt.format(travel.endDate);
      arcProgressLabel = '已结束';
    }

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: GlassSpec.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: BackdropFilter(
          filter: GlassSpec.cardBlur,
          child: Container(
            decoration: BoxDecoration(
              color: GlassSpec.cardBg,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: spec.borderColor, width: 1),
            ),
          child: Stack(
            children: [
              // Specular highlight
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      gradient: GlassSpec.specularHighlight,
                    ),
                  ),
                ),
              ),
              // Status color tint overlay — separate layer on top of glass
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      gradient: spec.gradient,
                    ),
                  ),
                ),
              ),
              // More button (fixed top-right)
              Positioned(
                top: 4,
                right: 4,
                child: Builder(builder: (ctx) {
                  return GestureDetector(
                    onTap: () => _showMorePopover(ctx),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: AppColors.inkTertiary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Name
                    Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: Text(
                        travel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ── Row 2: Status pill + Date | Days · People
                    Row(
                      children: [
                        _StatusBadge(status: status),
                        const Spacer(),
                        Text(
                          '${days}天 · ${people}人',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.inkPrimary.withValues(alpha: 0.50),
                          ),
                        ),
                      ],
                    ),
                    // ── Arc progress line
                    if (arcProgress != null) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 56,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 56),
                              painter: _ArcProgressPainter(
                                progress: arcProgress!,
                                color: arcColor!,
                                hasEmoji: arcStartEmoji != null,
                              ),
                            ),
                            // Emoji at arc start point
                            if (arcStartEmoji != null)
                              Positioned(
                                left: -4,
                                top: 18,
                                child: Text(arcStartEmoji!, style: const TextStyle(fontSize: 16)),
                              ),
                            // Labels below arc
                            Positioned(
                              left: 0, right: 0, bottom: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(arcStartLabel!,
                                      style: TextStyle(fontSize: 12, color: arcColor)),
                                  Text(arcProgressLabel!,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: arcColor)),
                                  Text(arcEndLabel!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.inkTertiary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ── Bottom row: Avatars | City tags
                    if (arcProgress == null) const SizedBox(height: 16),
                    if (arcProgress != null) const SizedBox(height: 10),
                    Row(
                      children: [
                        if (travel.collaborators.isNotEmpty)
                          _buildCollaborators(),
                        const Spacer(),
                        if (travel.cities.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < travel.cities.length && i < 4; i++) ...[
                                if (i > 0) const SizedBox(width: 4),
                                _CityTag(city: travel.cities[i]),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );

    // Apply overall opacity for ended status
    if (spec.opacity < 1.0) {
      card = Opacity(opacity: spec.opacity, child: card);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: card,
      ),
    );
  }

  void _showMorePopover(BuildContext ctx) {
    if (onEdit == null && onDelete == null) return;
    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    showGlassPopover(
      context: ctx,
      position: RelativeRect.fromLTRB(
        pos.dx, pos.dy + 20,
        MediaQuery.of(ctx).size.width - pos.dx - box.size.width, 0,
      ),
      items: [
        if (onEdit != null)
          PopoverItem(
            icon: Icons.edit_outlined,
            label: '编辑',
            onTap: () => onEdit!(),
          ),
        if (onDelete != null)
          PopoverItem(
            icon: Icons.delete_outline,
            label: '删除',
            isDestructive: true,
            onTap: () => onDelete!(),
          ),
      ],
    );
  }

  Widget _buildCollaborators() {
    final visible = travel.collaborators.take(5).toList();
    final overflow = travel.collaborators.length - 5;
    const double size = 28;
    const double overlap = 8;

    return SizedBox(
      width: size + (visible.length - 1) * (size - overlap) + (overflow > 0 ? (size - overlap) + size : 0),
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4C4C6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.70), width: 2),
                ),
                child: ClipOval(
                  child: visible[i].user.avatar != null && visible[i].user.avatar!.isNotEmpty
                      ? Image.network(
                          visible[i].user.avatar!,
                          width: size, height: size, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback(
                              visible[i].user.name ?? visible[i].user.username),
                        )
                      : _avatarFallback(visible[i].user.name ?? visible[i].user.username),
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4C4C6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.70), width: 2),
                ),
                child: Center(
                  child: Text('+$overflow',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Center(
      child: Text(
        name.characters.first,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Status badge (compact: dot + label) ────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TravelStatusType status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusBadgeBg(status),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.statusBadgeText(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _labelFor(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.statusBadgeText(status),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── City tag (neutral dark style) ──────────────────────────────────────────

// ─── Arc progress painter (curved line from left to right) ─────────────────

class _ArcProgressPainter extends CustomPainter {
  _ArcProgressPainter({
    required this.progress,
    required this.color,
    this.hasEmoji = false,
  });
  final double progress;
  final Color color;
  final bool hasEmoji;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const arcH = 28.0; // arc height
    const y0 = 28.0;   // baseline Y (bottom of arc)
    const dotR = 3.5;

    // Build the arc path using a quadratic bezier
    final arcPath = Path()
      ..moveTo(0, y0)
      ..quadraticBezierTo(w / 2, y0 - arcH, w, y0);

    // ── Track: dashed line
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw dashed track
    final pathMetrics = arcPath.computeMetrics().first;
    final totalLen = pathMetrics.length;
    const dashLen = 4.0;
    const gapLen = 3.0;
    double dist = 0;
    while (dist < totalLen) {
      final start = dist;
      final end = (dist + dashLen).clamp(0.0, totalLen);
      final segment = pathMetrics.extractPath(start, end);
      canvas.drawPath(segment, trackPaint);
      dist += dashLen + gapLen;
    }

    // ── Progress: solid line overlay
    if (progress > 0) {
      final progressLen = totalLen * progress;
      final progressPath = pathMetrics.extractPath(0, progressLen);
      canvas.drawPath(
        progressPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );

      // Progress dot (current position)
      final tangent = pathMetrics.getTangentForOffset(progressLen);
      if (tangent != null) {
        // Outer glow
        canvas.drawCircle(tangent.position, dotR + 2, Paint()..color = color.withValues(alpha: 0.15));
        // Solid dot
        canvas.drawCircle(tangent.position, dotR, Paint()..color = color);
      }
    }

    // ── Start dot
    if (!hasEmoji) {
      canvas.drawCircle(Offset(0, y0), dotR, Paint()..color = color);
    }
    // ── End dot
    canvas.drawCircle(Offset(w, y0), dotR,
        Paint()..color = const Color(0x471C1C1E)); // inkTertiary
  }

  @override
  bool shouldRepaint(covariant _ArcProgressPainter old) =>
      progress != old.progress || color != old.color;
}

// ─── City tag (neutral dark style) ──────────────────────────────────────────

class _CityTag extends StatelessWidget {
  const _CityTag({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cityTagBg(0),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cityTagBorder(0), width: 1),
      ),
      child: Text(
        city,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.cityTagText(0),
        ),
      ),
    );
  }
}

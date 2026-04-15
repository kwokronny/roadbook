// lib/features/travel/presentation/widgets/travel_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';

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
        colors: [Color(0x99FFFFFF), Color(0x14FF6B3D)], // white 60% -> coral 8%
      ),
      borderColor: Color(0x1FFF6B3D), // coral 12%
      shadow: BoxShadow(color: Color(0x1AFF6B3D), blurRadius: 24, offset: Offset(0, 6)),
      hasAccentBar: true,
    ),
    TravelStatusType.upcoming => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x8CFFFFFF), Color(0x0F8C5CF6)], // white 55% -> lavender 6%
      ),
      borderColor: Color(0x1A8C5CF6), // lavender 10%
    ),
    TravelStatusType.planning => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x85FFFFFF), Color(0x0A8C5CF6)], // white 52% -> lavender 4%
      ),
      borderColor: Color(0x1A8C5CF6), // lavender 10%
    ),
    TravelStatusType.ended => const _StatusGradientSpec(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x61FFFFFF), Color(0x081C1C1E)], // white 38% -> ink 3%
      ),
      borderColor: Color(0xA6FFFFFF), // white 65%
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
  });

  final Travel travel;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = computeTravelStatus(travel.startDate, travel.endDate);
    final spec   = _StatusGradientSpec.forStatus(status);
    final days   = travel.endDate.difference(travel.startDate).inDays + 1;
    final people = travel.collaborators.length;
    final fmt    = DateFormat('MM/dd');

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: spec.gradient,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: spec.borderColor, width: 1),
            boxShadow: [
              if (spec.shadow != null) spec.shadow!,
              ...GlassSpec.cardShadow,
            ],
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
              // Top accent bar for ongoing status
              if (spec.hasAccentBar)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B3D), Color(0xFFFF8C42)],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                    ),
                  ),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Name + More icon ───────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showMoreActions(context),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: AppColors.inkTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── Row 2: Status pill + Date | People + Days ─────────────
                    Row(
                      children: [
                        _StatusBadge(status: status),
                        const SizedBox(width: 6),
                        Text(
                          '${fmt.format(travel.startDate)} - ${fmt.format(travel.endDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkPrimary.withValues(alpha: 0.55),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${days}天 · ${people}人',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.inkPrimary.withValues(alpha: 0.50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ── Row 3: Avatar group | City tags ───────────────────────
                    Row(
                      children: [
                        if (travel.collaborators.isNotEmpty)
                          _buildCollaborators(),
                        const Spacer(),
                        if (travel.cities.isNotEmpty)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < travel.cities.length && i < 4; i++) ...[
                                  if (i > 0) const SizedBox(width: 4),
                                  _CityTag(city: travel.cities[i]),
                                ],
                              ],
                            ),
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

  void _showMoreActions(BuildContext context) {
    if (onEdit == null && onDelete == null) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined, size: 20, color: AppColors.inkPrimary),
                title: const Text('编辑'),
                onTap: () { Navigator.pop(context); onEdit!(); },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, size: 20, color: AppColors.destructive),
                title: const Text('删除', style: TextStyle(color: AppColors.destructive)),
                onTap: () { Navigator.pop(context); onDelete!(); },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborators() {
    final visible = travel.collaborators.take(5).toList();
    final overflow = travel.collaborators.length - 5;
    const double size = 24;
    const double overlap = 6;

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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.statusBadgeBg(status),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.statusBadgeText(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _labelFor(status),
            style: TextStyle(
              fontSize: 10,
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
